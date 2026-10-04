include: "/views/bre_na/bre_na_tou_fields.view.lkml"

# SRC-35. Original ratio branches, zero handling, inner join, and row grain retained.
# Duplicate trigger_name and last_updated_timestamp projections are emitted only once.
view: bre_na_tou {
  extends: [bre_na_tou_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        SELECT
            m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
            s.*
        FROM
            (SELECT
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name,
            pilot_id
        FROM delta_prodna.reporting.pilot_consolidated_product_type_events) as m
        JOIN
            (select pilot_id,analysis_date,reporting_date,delay_in_days,trigger_name,tou_mode,
        total_tou_eligible_invoices,
        actual_total_tou_invoices,
        successful_tou_eligible_invoices,
        total_tou_eligible_invoices-successful_tou_eligible_invoices as failed_tou_eligible_invoices,
        last_updated_timestamp,trigger_flag,total_disagg_tou_invoices,
        case when total_disagg_tou_invoices != actual_total_tou_invoices then
        case when total_tou_eligible_invoices >0 then round(100.00*successful_tou_eligible_invoices/total_tou_eligible_invoices,2) else 0 end
        else case when total_disagg_tou_invoices >0 then round(100.00*successful_tou_eligible_invoices/total_disagg_tou_invoices,2) else 0 end
        end as successful_tou_eligible_invoices_pct,
        case when total_disagg_tou_invoices != actual_total_tou_invoices then
        case when total_tou_eligible_invoices >0 then round(100.00*(total_tou_eligible_invoices-successful_tou_eligible_invoices)/total_tou_eligible_invoices,2) else 0 end
        else case when total_disagg_tou_invoices >0 then round(100.00*(total_tou_eligible_invoices-successful_tou_eligible_invoices)/total_disagg_tou_invoices,2) else 0 end
        end as failed_tou_eligible_invoices_pct
        from delta_prodna.reporting.sre_tou_appliance_batch_aggregation) as s
        ON
            m.pilot_id = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition tou_mode %} q.tou_mode {% endcondition %}
        AND {% condition delay_in_days %} q.delay_in_days {% endcondition %}
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
