include: "/views/bre_na/bre_na_disaggregation_fields.view.lkml"

# SRC-10: source period calculations and ranking preserved; dashboard filters remain outside them.
view: bre_na_disaggregation_quality {
  extends: [bre_na_disaggregation_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        WITH
            bounds AS (
                SELECT MIN(CAST(analysis_date AS DATE)) AS min_date, MAX(CAST(analysis_date AS DATE)) AS max_date
                FROM delta_prodna.reporting.sre_quality_disagg
            ),
            anchors AS (
                SELECT
                    CAST(date_add('day', -1 * (day_of_week(MIN(min_date)) % 7), MIN(min_date)) AS DATE) AS week_anchor,
                    CAST(date_trunc('month', MIN(min_date)) AS DATE) AS month_anchor
                FROM bounds
            ),

        daily AS (
            SELECT
                pilot_id,
                reporting_date,
                analysis_date,
                meter_type,
                fuel_type,
                istou,
                appliances_kwh_variance_pct_1,
                appliances_kwh_variance_pct_2,
                total_cost_deviation_pct_1,
                total_cost_deviation_pct_2,
                cost_per_kwh_deviation_pct,
                seasonal_appliance_usage_deviation_pct,
                single_appliance_domination_deviation_pct,
                missing_dwelliing_pct,
                ao_pct_non_tou,
                ac_pct_non_tou,
                sh_pct_non_tou,
                other_pct_non_tou,
                solar_pct_non_tou,
                missing_solar_pct_non_tou,
                last_updated_timestamp,
                'Daily' AS period
            FROM delta_prodna.reporting.sre_quality_disagg
        ),

        weekly_base AS (
            SELECT
                pilot_id,
                CAST(analysis_date AS DATE) AS analysis_date_dt,
                CAST(date_add('day', (date_diff('day', a.week_anchor, CAST(analysis_date AS DATE)) / 7) * 7, a.week_anchor) AS DATE) AS week_start,
                meter_type,
                fuel_type,
                istou,
                appliances_kwh_variance_pct_1,
                appliances_kwh_variance_pct_2,
                total_cost_deviation_pct_1,
                total_cost_deviation_pct_2,
                cost_per_kwh_deviation_pct,
                seasonal_appliance_usage_deviation_pct,
                single_appliance_domination_deviation_pct,
                missing_dwelliing_pct,
                ao_pct_non_tou,
                ac_pct_non_tou,
                sh_pct_non_tou,
                other_pct_non_tou,
                solar_pct_non_tou,
                missing_solar_pct_non_tou,
                last_updated_timestamp
            FROM delta_prodna.reporting.sre_quality_disagg
                CROSS JOIN anchors a
        ),
        weekly AS (
            SELECT
                pilot_id,
                CAST(MAX(analysis_date_dt) AS VARCHAR) AS reporting_date, -- Latest date in the week
                CAST(week_start AS VARCHAR) AS analysis_date, -- Week start
                meter_type,
                fuel_type,
                istou,
                AVG(appliances_kwh_variance_pct_1) AS appliances_kwh_variance_pct_1,
                AVG(appliances_kwh_variance_pct_2) AS appliances_kwh_variance_pct_2,
                AVG(total_cost_deviation_pct_1) AS total_cost_deviation_pct_1,
                AVG(total_cost_deviation_pct_2) AS total_cost_deviation_pct_2,
                AVG(cost_per_kwh_deviation_pct) AS cost_per_kwh_deviation_pct,
                AVG(
                    seasonal_appliance_usage_deviation_pct
                ) AS seasonal_appliance_usage_deviation_pct,
                AVG(
                    single_appliance_domination_deviation_pct
                ) AS single_appliance_domination_deviation_pct,
                AVG(missing_dwelliing_pct) AS missing_dwelliing_pct,
                AVG(ao_pct_non_tou) AS ao_pct_non_tou,
                AVG(ac_pct_non_tou) AS ac_pct_non_tou,
                AVG(sh_pct_non_tou) AS sh_pct_non_tou,
                AVG(other_pct_non_tou) AS other_pct_non_tou,
                AVG(solar_pct_non_tou) AS solar_pct_non_tou,
                AVG(missing_solar_pct_non_tou) AS missing_solar_pct_non_tou,
                MAX(last_updated_timestamp) AS last_updated_timestamp,
                'Weekly' AS period
            FROM weekly_base
            GROUP BY
                pilot_id,
                week_start,
                meter_type,
                fuel_type,
                istou
        ),

        monthly_base AS (
            SELECT
                pilot_id,
                CAST(analysis_date AS DATE) AS analysis_date_dt,
                CAST(date_add('month', date_diff('month', a.month_anchor, CAST(analysis_date AS DATE)), a.month_anchor) AS DATE) AS month_start,
                meter_type,
                fuel_type,
                istou,
                appliances_kwh_variance_pct_1,
                appliances_kwh_variance_pct_2,
                total_cost_deviation_pct_1,
                total_cost_deviation_pct_2,
                cost_per_kwh_deviation_pct,
                seasonal_appliance_usage_deviation_pct,
                single_appliance_domination_deviation_pct,
                missing_dwelliing_pct,
                ao_pct_non_tou,
                ac_pct_non_tou,
                sh_pct_non_tou,
                other_pct_non_tou,
                solar_pct_non_tou,
                missing_solar_pct_non_tou,
                last_updated_timestamp
            FROM delta_prodna.reporting.sre_quality_disagg
                CROSS JOIN anchors a
        ),
        monthly AS (
            SELECT
                pilot_id,
                CAST(MAX(analysis_date_dt) AS VARCHAR) AS reporting_date, -- Latest date in the month
                CAST(month_start AS VARCHAR) AS analysis_date, -- Month start
                meter_type,
                fuel_type,
                istou,
                AVG(appliances_kwh_variance_pct_1) AS appliances_kwh_variance_pct_1,
                AVG(appliances_kwh_variance_pct_2) AS appliances_kwh_variance_pct_2,
                AVG(total_cost_deviation_pct_1) AS total_cost_deviation_pct_1,
                AVG(total_cost_deviation_pct_2) AS total_cost_deviation_pct_2,
                AVG(cost_per_kwh_deviation_pct) AS cost_per_kwh_deviation_pct,
                AVG(
                    seasonal_appliance_usage_deviation_pct
                ) AS seasonal_appliance_usage_deviation_pct,
                AVG(
                    single_appliance_domination_deviation_pct
                ) AS single_appliance_domination_deviation_pct,
                AVG(missing_dwelliing_pct) AS missing_dwelliing_pct,
                AVG(ao_pct_non_tou) AS ao_pct_non_tou,
                AVG(ac_pct_non_tou) AS ac_pct_non_tou,
                AVG(sh_pct_non_tou) AS sh_pct_non_tou,
                AVG(other_pct_non_tou) AS other_pct_non_tou,
                AVG(solar_pct_non_tou) AS solar_pct_non_tou,
                AVG(missing_solar_pct_non_tou) AS missing_solar_pct_non_tou,
                MAX(last_updated_timestamp) AS last_updated_timestamp,
                'Monthly' AS period
            FROM monthly_base
            GROUP BY
                pilot_id,
                month_start,
                meter_type,
                fuel_type,
                istou
        ),

        stats AS (
            SELECT *
            FROM daily
            UNION ALL
            SELECT *
            FROM weekly
            UNION ALL
            SELECT *
            FROM monthly
        )

        SELECT m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || COALESCE(m.pilot_name, '') AS pilot_id_name, s.*
        FROM stats s
            JOIN (
                SELECT
                    pilot_id, CASE
                        WHEN POSITION('(' IN pilot_name) > 0 THEN SUBSTRING(
                            pilot_name
                            FROM POSITION('(' IN pilot_name)
                        )
                        ELSE pilot_name
                    END AS pilot_name
                FROM delta_prodna.reporting.pilot_consolidated_product_type_events
            ) m ON s.pilot_id = CAST(m.pilot_id AS VARCHAR)
        ORDER BY s.analysis_date DESC, s.pilot_id
      ) q
      WHERE q.period = {% parameter period %}
        AND {% condition date_range %} CAST(q.reporting_date AS DATE) {% endcondition %}
        AND {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition meter_type %} q.meter_type {% endcondition %}
        AND {% condition fuel_type %} q.fuel_type {% endcondition %}
    ;;
  }
  dimension: appliances_kwh_variance_pct_1 {
    type: number
    description: "Source appliances_kwh_variance_pct_1; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.appliances_kwh_variance_pct_1 ;;
  }
  measure: appliances_kwh_variance_pct_1_average {
    type: average
    description: "Unweighted average of appliances_kwh_variance_pct_1 over selected source rows."
    value_format: "0.00\"%\""
    sql: ${appliances_kwh_variance_pct_1} ;;
  }
  dimension: appliances_kwh_variance_pct_2 {
    type: number
    description: "Source appliances_kwh_variance_pct_2; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.appliances_kwh_variance_pct_2 ;;
  }
  measure: appliances_kwh_variance_pct_2_average {
    type: average
    description: "Unweighted average of appliances_kwh_variance_pct_2 over selected source rows."
    value_format: "0.00\"%\""
    sql: ${appliances_kwh_variance_pct_2} ;;
  }
  dimension: total_cost_deviation_pct_1 {
    type: number
    description: "Source total_cost_deviation_pct_1; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.total_cost_deviation_pct_1 ;;
  }
  measure: total_cost_deviation_pct_1_average {
    type: average
    description: "Unweighted average of total_cost_deviation_pct_1 over selected source rows."
    value_format: "0.00\"%\""
    sql: ${total_cost_deviation_pct_1} ;;
  }
  dimension: total_cost_deviation_pct_2 {
    type: number
    description: "Source total_cost_deviation_pct_2; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.total_cost_deviation_pct_2 ;;
  }
  measure: total_cost_deviation_pct_2_average {
    type: average
    description: "Unweighted average of total_cost_deviation_pct_2 over selected source rows."
    value_format: "0.00\"%\""
    sql: ${total_cost_deviation_pct_2} ;;
  }
  dimension: cost_per_kwh_deviation_pct {
    type: number
    description: "Source cost_per_kwh_deviation_pct; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.cost_per_kwh_deviation_pct ;;
  }
  measure: cost_per_kwh_deviation_pct_average {
    type: average
    description: "Unweighted average of cost_per_kwh_deviation_pct over selected source rows."
    value_format: "0.00\"%\""
    sql: ${cost_per_kwh_deviation_pct} ;;
  }
  dimension: seasonal_appliance_usage_deviation_pct {
    type: number
    description: "Source seasonal_appliance_usage_deviation_pct; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.seasonal_appliance_usage_deviation_pct ;;
  }
  measure: seasonal_appliance_usage_deviation_pct_average {
    type: average
    description: "Unweighted average of seasonal_appliance_usage_deviation_pct over selected source rows."
    value_format: "0.00\"%\""
    sql: ${seasonal_appliance_usage_deviation_pct} ;;
  }
  dimension: ao_pct_non_tou {
    type: number
    description: "Source ao_pct_non_tou; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.ao_pct_non_tou ;;
  }
  measure: ao_pct_non_tou_average {
    type: average
    description: "Unweighted average of ao_pct_non_tou over selected source rows."
    value_format: "0.00\"%\""
    sql: ${ao_pct_non_tou} ;;
  }
  dimension: sh_pct_non_tou {
    type: number
    description: "Source sh_pct_non_tou; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.sh_pct_non_tou ;;
  }
  measure: sh_pct_non_tou_average {
    type: average
    description: "Unweighted average of sh_pct_non_tou over selected source rows."
    value_format: "0.00\"%\""
    sql: ${sh_pct_non_tou} ;;
  }
  dimension: other_pct_non_tou {
    type: number
    description: "Source other_pct_non_tou; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.other_pct_non_tou ;;
  }
  measure: other_pct_non_tou_average {
    type: average
    description: "Unweighted average of other_pct_non_tou over selected source rows."
    value_format: "0.00\"%\""
    sql: ${other_pct_non_tou} ;;
  }
  dimension: solar_pct_non_tou {
    type: number
    description: "Source solar_pct_non_tou; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.solar_pct_non_tou ;;
  }
  measure: solar_pct_non_tou_average {
    type: average
    description: "Unweighted average of solar_pct_non_tou over selected source rows."
    value_format: "0.00\"%\""
    sql: ${solar_pct_non_tou} ;;
  }
  dimension: single_appliance_domination_deviation_pct {
    type: number
    description: "Source single_appliance_domination_deviation_pct; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.single_appliance_domination_deviation_pct ;;
  }
  measure: single_appliance_domination_deviation_pct_average {
    type: average
    description: "Unweighted average of single_appliance_domination_deviation_pct over selected source rows."
    value_format: "0.00\"%\""
    sql: ${single_appliance_domination_deviation_pct} ;;
  }
  dimension: missing_dwelliing_pct {
    type: number
    description: "Source missing_dwelliing_pct; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.missing_dwelliing_pct ;;
  }
  measure: missing_dwelliing_pct_average {
    type: average
    description: "Unweighted average of missing_dwelliing_pct over selected source rows."
    value_format: "0.00\"%\""
    sql: ${missing_dwelliing_pct} ;;
  }
}
