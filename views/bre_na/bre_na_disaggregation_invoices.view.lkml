include: "/views/bre_na/bre_na_disaggregation_invoice_fields.view.lkml"

# SRC-04: preserve original latest-row selection; filter only after source windows.
view: bre_na_disaggregation_invoices {
  extends: [bre_na_disaggregation_invoice_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        Select *
        from
        (
            SELECT
            m.pilot_name, s.pilot_id  || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name,
            s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
            COALESCE(s.failed_itemisation_pct,0) as failed_itemisation_pct,
            COALESCE(s.successful_itemisation_pct,0) as successful_itemisation_pct,
            s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
            s.fuel_type,module_name, s.analysis_date,s.delay_in_days,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
            FROM (select * from delta_prodna.reporting.sre_invoice_statistics where trigger_flag='SCHEDULED')s left join
            (
                SELECT
                CASE
                    WHEN POSITION('(' IN pilot_name) > 0
                    THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name,
                pilot_id
                FROM delta_prodna.reporting.pilot_consolidated_product_type_events
            ) as m
        ON
            CAST(m.pilot_id AS VARCHAR) = s.pilot_id
        ) where rnk=1
        union all
        Select *
        from
        (
            SELECT
            m.pilot_name, s.pilot_id  || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name,
            s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
            COALESCE(s.failed_itemisation_pct,0) as failed_itemisation_pct,
            COALESCE(s.successful_itemisation_pct,0) as successful_itemisation_pct,
            s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
            s.fuel_type,module_name, s.analysis_date,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
            FROM (select * from delta_prodna.reporting.sre_invoice_statistics where trigger_flag='ADHOC')s left join
            (
                SELECT
                CASE
                    WHEN POSITION('(' IN pilot_name) > 0
                    THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name,
                pilot_id
                FROM delta_prodna.reporting.pilot_consolidated_product_type_events
            ) as m
        ON
            CAST(m.pilot_id AS VARCHAR) = s.pilot_id
        ) where rnk=1
      ) q
      WHERE {% condition pilot_id %} q.pilot_id {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition meter_type %} q.meter_type {% endcondition %}
        AND {% condition fuel_type %} q.fuel_type {% endcondition %}
        AND {% condition module_name %} q.module_name {% endcondition %}
        AND {% if comparison_date_range._is_filtered %}
          ({% condition comparison_date_range %} q.analysis_date {% endcondition %}
           OR COALESCE(q.analysis_date >= date_add('day',
             -date_diff('day', CAST({% date_start comparison_date_range %} AS DATE), CAST({% date_end comparison_date_range %} AS DATE)),
             CAST({% date_start comparison_date_range %} AS DATE))
             AND q.analysis_date < CAST({% date_start comparison_date_range %} AS DATE), FALSE))
        {% else %}
          {% condition date_range %} q.analysis_date {% endcondition %}
        {% endif %}
    ;;
  }
}
