# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0"]
# ///
"""Offline BRE validation and planning-query export; never connects to a database.

Run: uv run scripts/validate_bre_models.py --output-dir /private/tmp/bre-validation
The renderer covers the Liquid and SQL_TABLE_NAME constructs used here. It is
not the Looker compiler: LookML Validator and actual query_sql checks remain
separate acceptance checks in Looker.
"""
import argparse
import json
import re
from pathlib import Path

import lkml
import sqlglot
from liquid import Environment, StrictUndefined
from sqlglot import exp

ROOT = Path(__file__).resolve().parents[1]
PERIOD_FAMILIES = {"hergeneration", "herfailures", "herautomationquality"}
LIQUID = Environment(undefined=StrictUndefined)
TABLE_REF = re.compile(r"\$\{([a-z_]+)\.SQL_TABLE_NAME\}")
FIELD_REF = re.compile(r"\$\{([a-z_][a-z0-9_]*)(?:::(date|datetime|string))?\}")
COMMON_FIELDS = {
    "pilot_id", "pilot_name", "pilot_id_name", "analysis_date", "reporting_date",
    "last_updated_timestamp", "source_rank", "source_period", "period_date",
}


def check_no_pdts():
    """Check every model/view, including existing Itron models, without data access."""
    counts = {"models": 0, "views": 0, "derived_tables": 0}
    def inspect(node, path):
        if isinstance(node, dict):
            assert not node.get("aggregate_tables"), f"Aggregate PDT in {path}"
            if "derived_table" in node:
                counts["derived_tables"] += 1
                # All current derived tables are query-time SQL. Reject build
                # triggers, materialization and custom DDL if added later.
                assert set(node["derived_table"]) == {"sql"}, f"Non-ephemeral derived table in {path}"
            for value in node.values():
                inspect(value, path)
        elif isinstance(node, list):
            for value in node:
                inspect(value, path)
    for path in sorted(ROOT.rglob("*.lkml")):
        if any(part.startswith(".") for part in path.relative_to(ROOT).parts):
            continue
        parsed = lkml.load(path.open())
        counts["models"] += int(path.name.endswith(".model.lkml"))
        counts["views"] += len(parsed.get("views", []))
        inspect(parsed, path)
    return counts | {"result": "PASS"}


def parse_project():
    views = {}
    paths = {}
    for path in sorted((ROOT / "views/bre").glob("*.view.lkml")):
        parsed = lkml.load(path.open())
        for view in parsed["views"]:
            assert view["name"] not in views, f"Duplicate view: {view['name']}"
            views[view["name"]] = view
            paths[view["name"]] = path
    for name, view in views.items():
        includes = lkml.load(paths[name].open()).get("includes", [])
        for group in view.get("extends__all", []):
            for parent in group:
                assert parent in views, f"Missing parent view: {parent}"
                parent_path = "/" + str(paths[parent].relative_to(ROOT))
                assert parent_path in includes, f"Missing direct include of {parent} in {paths[name]}"
    assert len(views) == 25, f"Expected 25 views, got {len(views)}"
    base = views["bre_dashboard_fields"]
    dimensions = {f["name"]: f for f in base["dimensions"]}
    measures = {f["name"]: f for f in base["measures"]}
    parameters = {f["name"]: f for f in base["parameters"]}
    assert COMMON_FIELDS <= dimensions.keys()
    all_names = list(dimensions) + list(measures) + list(parameters) + [f["name"] for f in base.get("filters", [])]
    assert len(all_names) == len(set(all_names)), "Duplicate field name"
    for view in views.values():
        fields = view.get("dimensions", []) + view.get("measures", [])
        if not view["name"].startswith("bre_dashboard_") or view["name"] == "bre_dashboard_fields":
            assert view["dimensions"][0].get("primary_key") == "yes", view["name"]
        for field in fields:
            assert field.get("description"), (view["name"], field["name"])
        dt = view.get("derived_table", {})
        assert set(dt) <= {"sql"}, "Unexpected persistence configuration"
    for measure in measures.values():
        assert "${TABLE}" not in measure["sql"], measure["name"]
    sets = {s["name"]: s["fields"] for s in base["sets"]}
    for members in sets.values():
        assert set(members) <= set(all_names)
    return views, paths, dimensions, measures, sets


def reference_sql(match, sql, fields):
    """Simulate typed references and Looker's default DATE display formatting.

    Looker returns a formatted VARCHAR for untyped references to date dimensions.
    Omitting this behavior previously hid nested date_format and comparison errors.
    This is still a focused simulator, not the full Looker SQL compiler.
    """
    kind = match.group(2)
    if kind:
        datatype = {"date": "DATE", "datetime": "TIMESTAMP", "string": "VARCHAR"}[kind]
        return f"CAST(({sql}) AS {datatype})"
    if fields[match.group(1)].get("type") == "date":
        return f"date_format(({sql}), '%Y-%m-%d')"
    return f"({sql})"


def render(text, env, family, period, scope, date_start="2026-09-06", date_end="2026-09-13"):
    # Fixed fixture boundaries simulate Looker tags; this is not its filter parser.
    for tag, boundary in (("date_start", date_start), ("date_end", date_end)):
        literal = "NULL" if boundary is None else f"DATE '{boundary}'"
        text = re.sub(r"\{%\s*" + tag + r"\s+(?:bre_dashboard\.)?ingestion_comparison_date_range\s*%\}", literal, text)
    def date_condition(match):
        value = match.group(1).strip()
        clauses = []
        if date_start: clauses.append(f"({value}) >= DATE '{date_start}'")
        if date_end: clauses.append(f"({value}) < DATE '{date_end}'")
        return "(" + " AND ".join(clauses or ["TRUE"]) + ")"
    text = re.sub(r"\{%\s*condition\s+(?:bre_dashboard\.)?ingestion_comparison_date_range\s*%\}(.*?)\{%\s*endcondition\s*%\}", date_condition, text, flags=re.S)
    values = {"source_family": family, "period": period, "failure_scope": scope}
    def parameter(match):
        value = values[match.group(1).removeprefix("bre_dashboard.")]
        return "'" + value.replace("'", "''") + "'"
    text = re.sub(r"\{%\s*parameter\s+((?:bre_dashboard\.)?[a-z_]+)\s*%\}", parameter, text)
    context = {k: {"_parameter_value": "'" + v + "'"} for k, v in values.items()}
    context["bre_dashboard"] = dict(context)
    context["_model"] = {"_name": "bre_" + env}
    output = LIQUID.from_string(text).render(**context)
    assert "{%" not in output and "{{" not in output
    return output


def expand(view_name, views, env, family, period, scope, stack=()):
    assert view_name not in stack, f"Cyclic SQL reference: {stack} -> {view_name}"
    raw = views[view_name]["derived_table"]["sql"]
    selected = render(raw, env, family, period, scope)
    return TABLE_REF.sub(
        lambda m: "(\n" + expand(m.group(1), views, env, family, period, scope, stack + (view_name,)) + "\n)",
        selected,
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, help="Optional location for SQL planning fixtures and their manifest")
    args = parser.parse_args()
    persistence = check_no_pdts()
    views, paths, dimensions, measures, sets = parse_project()
    cases = []
    signature = None
    for env, expected in (("ca", 19), ("eu", 13)):
        model = lkml.load((ROOT / f"models/bre_{env}.model.lkml").open())
        assert model["connection"] == f"starburst_prod_{env}"
        assert model["week_start_day"] == "monday"
        explore = model["explores"][0]
        assert explore["name"] == "bre_dashboard"
        helpers = {e["name"]: e for e in model["explores"][1:]}
        assert set(helpers) == {"bre_ingestion_filter_values", "bre_pilot_filters"}
        assert all(e.get("hidden") == "yes" for e in helpers.values())
        assert helpers["bre_pilot_filters"]["view_name"] == "bre_pilots"
        assert explore["from"] == f"bre_dashboard_{env}"
        assert not explore.get("joins"), "Fact joins are outside this model's contract"
        includes = set(model["includes"])
        assert all("*" not in path and (ROOT / path.lstrip("/")).exists() for path in includes)
        allowed_fields = set()
        for member in explore["fields"]:
            assert member.startswith("bre_dashboard.") and member.endswith("*")
            allowed_fields.update(sets[member.split(".")[1][:-1]])
        route = views[f"bre_dashboard_{env}"]
        route_sql = route["derived_table"]["sql"]
        controls = set(re.findall(r"([a-z_.]+)\._parameter_value", route_sql))
        controls.update(re.findall(r"\{%\s*parameter\s+([a-z_.]+)\s*%\}", route_sql))
        expected_controls = {f"{explore['name']}.{name}" for name in ("source_family", "period", "failure_scope")}
        assert controls <= expected_controls, f"Router parameters must use the Explore alias: {controls}"
        assert f"{explore['name']}.source_family" in controls
        params = {p["name"]: p for p in route["parameters"]}
        families = [v["value"] for v in params["source_family"]["allowed_values"]]
        assert len(families) == expected
        assert params["source_family"]["default_value"] == "ingestionaudit"
        assert params["failure_scope"]["default_value"] == ("All" if env == "ca" else "Top Three")
        if env == "eu":
            assert not any(name.startswith(("her_", "nbi_")) for name in allowed_fields)
        for family in families + ["invalidfamily"]:
            periods = ["Daily", "Weekly", "Monthly"]
            scopes = ["All", "Top Three"] if family == "processingfailures" else [params["failure_scope"]["default_value"]]
            for period in periods:
                for scope in scopes:
                    route_text = render(route["derived_table"]["sql"], env, family, period, scope)
                    dependencies = TABLE_REF.findall(route_text)
                    assert len(dependencies) == (0 if family == "invalidfamily" else 1)
                    for dependency in dependencies:
                        assert "/" + str(paths[dependency].relative_to(ROOT)) in includes
                    expanded = expand(route["name"], views, env, family, period, scope)
                    tree = sqlglot.parse_one(expanded, read="trino")
                    names = [s.alias_or_name for s in tree.selects]
                    assert len(names) == len(set(names)), "Duplicate router output columns"
                    assert signature is None or signature == names, "Inconsistent output schema"
                    signature = names
                    catalogs = {t.catalog for t in tree.find_all(exp.Table) if t.catalog}
                    assert catalogs <= {f"delta_prod{env}"}, catalogs
                    assert not re.search(r"\bISNULL\s*\(|::|\bDATEADD\s*\(", expanded, re.I)
                    for select in tree.find_all(exp.Select):
                        projected = [s.alias_or_name for s in select.selects]
                        assert len(projected) == len(set(projected)), projected
                    if family in PERIOD_FAMILIES:
                        assert f"f.source_period = '{period}'" in route_text
                    assert ("f.source_rank <= 3" in route_text) == (family == "processingfailures" and scope == "Top Three")
                    # Compile every exposed dimension and measure together. This
                    # checks field references, inactive NULL branches and grouping.
                    cache = {}
                    def dimension_sql(name):
                        if name not in cache:
                            sql = render(dimensions[name]["sql"], env, family, period, scope).replace("${TABLE}", "q")
                            cache[name] = FIELD_REF.sub(lambda m: reference_sql(m, dimension_sql(m.group(1)), dimensions), sql)
                        return cache[name]
                    def measure_sql(name):
                        sql = render(measures[name]["sql"], env, family, period, scope)
                        return FIELD_REF.sub(lambda m: reference_sql(m, measure_sql(m.group(1)) if m.group(1) in measures else dimension_sql(m.group(1)), dimensions | measures), sql)
                    select_fields = []
                    for name in dimensions:
                        if name in allowed_fields:
                            select_fields.append(f"{dimension_sql(name)} AS {name}")
                    group_count = len(select_fields)
                    for name, measure in measures.items():
                        if name not in allowed_fields:
                            continue
                        sql = measure_sql(name)
                        if name != "source_row_count" and not name.replace('_','').startswith(family):
                            assert not re.search(r"\b(SUM|AVG)\s*\(", sql), (family,name)
                        select_fields.append(f"{sql} AS {name}")
                    compiled = "SELECT\n" + ",\n".join(select_fields) + "\nFROM (\n" + expanded + "\n) q\nGROUP BY " + ", ".join(str(i) for i in range(1,group_count+1))
                    assert "${" not in compiled, "Unresolved LookML reference in validation fixture"
                    sqlglot.parse_one(compiled, read="trino")
                    cases.append(dict(env=env,family=family,period=period,scope=scope,sql=compiled))
    if args.output_dir:
        args.output_dir.mkdir(parents=True, exist_ok=True)
        manifest=[]
        for i,case in enumerate(cases):
            path=args.output_dir / f"{i:03}_{case['env']}_{case['family']}_{case['period'].lower()}_{case['scope'].replace(' ','').lower()}.sql"
            path.write_text("EXPLAIN (TYPE VALIDATE)\n" + case['sql'] + ";\n")
            manifest.append({k:v for k,v in case.items() if k!='sql'} | {'path':str(path)})
        (args.output_dir / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps({'lookml_files':len(views)+2,'source_families':20,'rendered_cases':len(cases),'router_columns':len(signature),'result':'PASS','no_pdts':persistence,'looker_validator':'NOT RUN; requires Looker'},indent=2))


if __name__ == '__main__':
    main()
