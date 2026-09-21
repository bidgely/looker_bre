--SRE NBI Engine Daily Run Statistics[Amazon Redshift][2 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users as total_users_successful, s.total_users_with_200_errorcode, s.total_users_with_300_errorcode, s.nbi_error_pct, s.last_updated_timestamp
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_nbi_generated_errors s
ON
    m.pilot_id = s.pilot_id;


--SRE Post Ingestion Data Quality[Apps Script Addon][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*,
    e.overlapping_bc_count
FROM
(
    SELECT
        COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
        COALESCE(a.meter_type, b.meter_type) AS meter_type,
        COALESCE(a.fuel_type, b.fuel_type) AS fuel_type,
        COALESCE(a.ingestion_type, b.ingestion_type) AS ingestion_type,
        user_with_delay_0_3 AS user_raw_with_delay_0_3,
        user_with_delay_4_7 AS user_raw_with_delay_4_7,
        user_with_delay_8_15 AS user_raw_with_delay_8_15,
        user_with_delay_gt_15 AS user_raw_with_delay_gt_15,
        invoice_with_delay_0_7 AS user_invoice_with_delay_0_7,
        invoice_with_delay_7_15 AS user_invoice_with_delay_7_15,
        invoice_with_delay_15_30 AS user_invoice_with_delay_15_30,
        invoice_with_delay_gt_30 AS user_invoice_with_delay_gt_30,
        COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
        COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
        COALESCE(a.last_updated_timestamp, b.last_updated_timestamp) AS last_updated_timestamp
    FROM
    (
        SELECT
            pilot_id, meter_type, fuel_type,
            user_with_delay_0_3, user_with_delay_4_7, user_with_delay_8_15, user_with_delay_gt_15,
            analysis_date, reporting_date, last_updated_timestamp,
            'CONSUMPTION' AS ingestion_type
        FROM reporting.sre_raw_consumption_delay
    ) a
    FULL JOIN
    (
        SELECT
            pilot_id, meter_type, fuel_type,
            invoice_with_delay_0_7, invoice_with_delay_7_15, invoice_with_delay_15_30, invoice_with_delay_gt_30,
            analysis_date, reporting_date, last_updated_timestamp,
            CASE
                WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
                THEN 'OPOWER'
                ELSE 'BILLING'
            END AS ingestion_type
        FROM reporting.sre_invoice_delay_tracker
    ) b
    ON a.pilot_id = b.pilot_id
       AND a.meter_type = b.meter_type
       AND a.fuel_type = b.fuel_type
       AND a.ingestion_type = b.ingestion_type
) s
LEFT JOIN (
    SELECT
        pilot_id,
        failed_record_count AS overlapping_bc_count,
        analysis_date,
        reporting_date,
        last_updated_timestamp,
        CASE
            WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
            THEN 'OPOWER'
            ELSE 'BILLING'
        END AS ingestion_type
    FROM reporting.sre_ingestion_errors_statistic
    WHERE application_error_code = 'ERROR_CONFLICTING_INVOICE_DATA'
) e
ON s.pilot_id = e.pilot_id
   AND s.analysis_date = e.analysis_date
   AND s.ingestion_type = e.ingestion_type
JOIN
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
    FROM data_sanity.master_pilot_list
) m
ON m.pilot_id = s.pilot_id


--SRE HER Quality Statistics (non-PSEG)[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id,
    s.analysis_date::DATE AS analysis_date,         -- Convert from text to date
    s.reporting_date::DATE AS reporting_date,
    s.low_bc_duration_count,
    s.high_bc_duration_count,
    s.staleness_count,
    s.solar_template_count,
    s.solar_consistency_count,
    s.solar_generation_count,
    s.report_consistency_count,
    s.itemization_count,
    s.bill_change_consistency_count,
    s.ev_itemization_count,
    s.tou_template_count,
    s.last_updated_timestamp,
    s.nbi_occurance_count,
    s.nbi_value_count,
    s.nbi_appliance_itemisation_count,
    s.nbi_non_null_insight_count,
    s.nbi_unicode_count,
    s.nbi_extreme_insight_count
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot ,
    pilot_type ,
    isevpilot ,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_her_qc_data s
ON
    m.pilot_id = s.pilot_id;


--SRE SQS Queue Health Metrics By Day[Amazon Redshift][0 charts, 0 variables]
SELECT
    module_name,
    environment,
    queue_type,
    queue_name,
    DATE_TRUNC('day', analysis_date)::DATE AS analysis_date,
    ROUND(
        (
            (SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) /
             NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0) * 50)  -- Success rate (50%)
            + (100 - LEAST(AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) / 1000, 1) * 100) * 0.3  -- Backlog (30%, capped at 1000)
            + (100 - LEAST(MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) / 3600, 1) * 100) * 0.2  -- Latency (20%, capped at 1 hour)
        ), 0
    ) AS health_score
FROM reporting.sre_queue_metrics_fact
GROUP BY module_name, environment, queue_type, queue_name, DATE_TRUNC('day', analysis_date);


--SRE All Active Users[Apps Script Addon][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (
        SELECT
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name,
            pilot_id,
            islaunchpadpilot,
            pilot_type,
            isevpilot,
            timezone
        FROM data_sanity.master_pilot_list
    ) AS m
JOIN (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY pilot_id ORDER BY reporting_date DESC) AS rn
        FROM reporting.sre_total_active_users
    ) t
    WHERE rn = 1
) s
ON m.pilot_id = s.pilot_id


--User Analytics[Google Analytics][11 charts, 0 variables]
--not required


--SRE Master Pilot List[Apps Script Addon][1 chart, 0 variables]
WITH all_data AS (
    SELECT
        CAST(pilot_id AS VARCHAR) AS pilot_id,
        CAST(analysis_date AS TIMESTAMP) AS analysis_date,
        CAST(reporting_date AS TIMESTAMP) AS reporting_date
    FROM reporting.sre_ingestion_audit

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_invoice_statistics

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_quality_email_stats

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_nbi_generated_errors

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_cluster_eligible_users

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_email_daily_tracker
),

latest_data AS (
    SELECT
        pilot_id,
        MAX(analysis_date) AS analysis_date,
        MAX(reporting_date) AS reporting_date
    FROM all_data
    GROUP BY pilot_id
),

master_cleaned AS (
    SELECT
        CAST(pilot_id AS VARCHAR) AS pilot_id,
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name
    FROM data_sanity.master_pilot_list
)

SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    l.pilot_id,
    l.analysis_date,
    l.reporting_date
FROM latest_data l
JOIN master_cleaned m
ON l.pilot_id = m.pilot_id


--SRE Ingestion Failure Statistics[Apps Script Addon][1 chart, 0 variables]
select * from (
SELECT
    sfs.*,
    ROW_NUMBER() OVER (
        PARTITION BY analysis_date, pilot_id, ingestion_type
        ORDER BY failure_percentage DESC
    ) AS rank
FROM
    (SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_ingestion_errors_statistic s
ON
    m.pilot_id = s.pilot_id) as sfs
ORDER BY
    analysis_date DESC,
    pilot_id,
    ingestion_type,
    failure_percentage desc)

--SRE Failure Statistics[Amazon Redshift][1 chart, 0 variables]
select * from (
SELECT
    sfs.*,
    ROW_NUMBER() OVER (
        PARTITION BY analysis_date, pilot_id, module_name
        ORDER BY failure_percentage DESC
    ) AS rank
FROM
    (SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_failure_statistics s
ON
    m.pilot_id = s.pilot_id) as sfs
ORDER BY
    analysis_date DESC,
    pilot_id,
    module_name,
    failure_percentage desc);


--SRE Post Ingestion Data Quality[Amazon Redshift][2 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*,
    e.overlapping_bc_count
FROM
(
    SELECT
        COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
        COALESCE(a.meter_type, b.meter_type) AS meter_type,
        COALESCE(a.fuel_type, b.fuel_type) AS fuel_type,
        COALESCE(a.ingestion_type, b.ingestion_type) AS ingestion_type,
        user_with_delay_0_3 AS user_raw_with_delay_0_3,
        user_with_delay_4_7 AS user_raw_with_delay_4_7,
        user_with_delay_8_15 AS user_raw_with_delay_8_15,
        user_with_delay_gt_15 AS user_raw_with_delay_gt_15,
        invoice_with_delay_0_7 AS user_invoice_with_delay_0_7,
        invoice_with_delay_7_15 AS user_invoice_with_delay_7_15,
        invoice_with_delay_15_30 AS user_invoice_with_delay_15_30,
        invoice_with_delay_gt_30 AS user_invoice_with_delay_gt_30,
        COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
        COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
        COALESCE(a.last_updated_timestamp, b.last_updated_timestamp) AS last_updated_timestamp
    FROM
    (
        SELECT
            pilot_id, meter_type, fuel_type,
            user_with_delay_0_3, user_with_delay_4_7, user_with_delay_8_15, user_with_delay_gt_15,
            analysis_date, reporting_date, last_updated_timestamp,
            'CONSUMPTION' AS ingestion_type
        FROM reporting.sre_raw_consumption_delay
    ) a
    FULL JOIN
    (
        SELECT
            pilot_id, meter_type, fuel_type,
            invoice_with_delay_0_7, invoice_with_delay_7_15, invoice_with_delay_15_30, invoice_with_delay_gt_30,
            analysis_date, reporting_date, last_updated_timestamp,
            CASE
                WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
                THEN 'OPOWER'
                ELSE 'BILLING'
            END AS ingestion_type
        FROM reporting.sre_invoice_delay_tracker
    ) b
    ON a.pilot_id = b.pilot_id
       AND a.meter_type = b.meter_type
       AND a.fuel_type = b.fuel_type
       AND a.ingestion_type = b.ingestion_type
) s
LEFT JOIN (
    SELECT
        pilot_id,
        failed_record_count AS overlapping_bc_count,
        analysis_date,
        reporting_date,
        last_updated_timestamp,
        CASE
            WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
            THEN 'OPOWER'
            ELSE 'BILLING'
        END AS ingestion_type
    FROM reporting.sre_ingestion_errors_statistic
    WHERE application_error_code = 'ERROR_CONFLICTING_INVOICE_DATA'
) e
ON s.pilot_id = e.pilot_id
   AND s.analysis_date = e.analysis_date
   AND s.ingestion_type = e.ingestion_type
JOIN
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
    FROM data_sanity.master_pilot_list
) m
ON m.pilot_id = s.pilot_id;


--SRE HER Cluster Specific Generation Stats[Apps Script Addon][2 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
SELECT
       CASE
           WHEN POSITION('(' IN pilot_name) > 0
           THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
           ELSE pilot_name -- Keep the original name if '(' doesn't exist
       END AS pilot_name,
       pilot_id,
       islaunchpadpilot,
       pilot_type,
       isevpilot,
       timezone
   FROM data_sanity.master_pilot_list

) AS m
JOIN

(
select pilot_id,cluster_id,analysis_date,schedule_start,schedule_end,fuel_type,'Daily' as "Period",
expected_eligible_users as expected_eligible_users,
actual_eligible_users as actual_eligible_users,
actual_generation_count as actual_generation_count,
expected_eligible_users-actual_generation_count as weekly_actual_failure_count,last_updated_timestamp
from
(
SELECT
ISNULL(a.pilot_id, b.pilot_id) AS pilot_id,
ISNULL(a.cluster_id, b.cluster_id) AS cluster_id,
ISNULL(a.analysis_date, b.analysis_date) AS analysis_date,
ISNULL(a.reporting_date, b.reporting_date) AS reporting_date,
ISNULL(a.schedule_start, b.schedule_start) AS schedule_start,
ISNULL(a.schedule_end, b.schedule_end) AS schedule_end,
ISNULL(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
and a.measurement_type=b.measurement_type
)
union all
select pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly' as "Period",
max(expected_eligible_users) as weekly_expected_eligible_users,
max(actual_eligible_users) as weekly_actual_eligible_users,
sum(actual_generation_count) as weekly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as weekly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
ISNULL(a.pilot_id, b.pilot_id) AS pilot_id,
ISNULL(a.cluster_id, b.cluster_id) AS cluster_id,
ISNULL(a.analysis_date, b.analysis_date) AS analysis_date,
ISNULL(a.reporting_date, b.reporting_date) AS reporting_date,
date_trunc('week',ISNULL(a.analysis_date, b.analysis_date))::date AS analysis_week,
ISNULL(a.schedule_start, b.schedule_start) AS schedule_start,
ISNULL(a.schedule_end, b.schedule_end) AS schedule_end,
ISNULL(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,"Period"
union all
select pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly' as "Period",
max(expected_eligible_users) as monthly_expected_eligible_users,
max(actual_eligible_users) as monthly_actual_eligible_users,
sum(actual_generation_count) as monthly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as monthly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
ISNULL(a.pilot_id, b.pilot_id) AS pilot_id,
ISNULL(a.cluster_id, b.cluster_id) AS cluster_id,
ISNULL(a.analysis_date, b.analysis_date) AS analysis_date,
ISNULL(a.reporting_date, b.reporting_date) AS reporting_date,
date_trunc('month',ISNULL(a.analysis_date, b.analysis_date))::date AS analysis_month,
ISNULL(a.schedule_start, b.schedule_start) AS schedule_start,
ISNULL(a.schedule_end, b.schedule_end) AS schedule_end,
ISNULL(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,"Period"
)AS s ON m.pilot_id = s.pilot_id


--SRE Quality Disagg[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_disagg s
ON
    m.pilot_id = s.pilot_id;


--SRE Email Statistics[Apps Script Addon][4 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_email_stats s
ON
    m.pilot_id = s.pilot_id


--SRE HER Schedule Specific Statistics[Apps Script Addon][3 charts, 0 variables]
SELECT m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,s.pilot_id,s.cluster_id,s.measurement_type as fuel_type,s.schedule_start,s.schedule_end,
s.total_eligible_users,s.total_generated_notification_id,s.total_scheduled_notification_id,s.total_queued_notification_id,s.total_printed_notification_id,
s.total_mailed_notification_id,s.total_failed_notification_id,s.reporting_date,
s.last_updated_timestamp ,s.analysis_date,s.total_swept_notification_id
FROM
(
    select pilot_id,schedule_start,schedule_end,measurement_type,cluster_id,
    sum(total_eligible_users) as total_eligible_users,
    sum(total_generated_notification_id) as total_generated_notification_id,
    sum(total_scheduled_notification_id) as total_scheduled_notification_id,
    sum(total_swept_notification_id) as total_swept_notification_id,
    sum(total_queued_notification_id) as total_queued_notification_id,
    sum(total_printed_notification_id) as total_printed_notification_id,
    sum(total_mailed_notification_id) as total_mailed_notification_id,
    sum(total_failed_notification_id) as total_failed_notification_id,
    max(analysis_date) as analysis_date,
    max(reporting_date) as reporting_date,
    max(last_updated_timestamp) as last_updated_timestamp
    from
    (
        Select pilot_id,cluster_id,measurement_type,
        case when schedule_quarter_start < schedule_start then schedule_start else schedule_quarter_start end schedule_start ,
        date(DATEADD(quarter, 1, schedule_quarter_start)-1) as schedule_end,
        total_eligible_users,total_generated_notification_id,total_scheduled_notification_id,total_swept_notification_id,total_queued_notification_id,total_printed_notification_id,total_mailed_notification_id,total_failed_notification_id,
        reporting_date,analysis_date,last_updated_timestamp
        from
        (
            Select *,date(date_trunc('quarter',analysis_date)) as schedule_quarter_start,
            row_number()over(partition by pilot_id,cluster_id,measurement_type,schedule_start,schedule_end,date_trunc('quarter',analysis_date) order by reporting_date desc) as rk
            from reporting.sre_daily_her_tracker
            where pilot_id=10037
        )x where rk=1
        union
        Select pilot_id,cluster_id,measurement_type,schedule_start,schedule_end,
        total_eligible_users,total_generated_notification_id,total_scheduled_notification_id,total_swept_notification_id,total_queued_notification_id,total_printed_notification_id,total_mailed_notification_id,total_failed_notification_id,
        reporting_date,analysis_date,last_updated_timestamp
        from
        (
            Select *,
            row_number()over(partition by pilot_id,cluster_id,measurement_type,schedule_start,schedule_end order by reporting_date desc) as rk
            from reporting.sre_daily_her_tracker
            where pilot_id<>10037
        )x where rk=1
    )
    group by pilot_id,schedule_start,schedule_end,measurement_type,cluster_id
)s
JOIN
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
    FROM data_sanity.master_pilot_list
) m ON m.pilot_id = s.pilot_id


--SRE NBI Gen Quality Generic Tag[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users, s.total_nbi_users_with_generic_tag, s.pct_users_with_generic_tag, s.last_updated_timestamp
 FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_nbi_generic_tag_users s
ON
    m.pilot_id = s.pilot_id;


--SRE SQS Queue Metrics By Day[Amazon Redshift][0 charts, 0 variables]
SELECT
    DATE_TRUNC('day', analysis_date) AS ingestion_day,
    module_name,
    environment,
    queue_type,
    queue_name,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) AS total_messages_received,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesSent' THEN metric_value ELSE 0 END) AS total_messages_sent,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) AS total_messages_deleted,
    AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) AS avg_queue_backlog,
    MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) AS max_latency,
        -- Success rate calculation (percentage)
    ROUND(
        SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0),
    2) AS success_rate,  -- Rounded to 2 decimal places
    ROUND(
	    SUM(CASE WHEN metric_name = 'NumberOfEmptyReceives' THEN metric_value ELSE 0 END) /
	    NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) +
	           SUM(CASE WHEN metric_name = 'NumberOfEmptyReceives' THEN metric_value ELSE 0 END), 0) * 100, 2) AS empty_receives_ratio
FROM reporting.sre_queue_metrics_fact
--WHERE analysis_date >= CURRENT_TIMESTAMP - INTERVAL '7 days'  -- Reduce the date range
GROUP BY ingestion_day, module_name, environment, queue_type, queue_name
ORDER BY ingestion_day DESC;


--SRE HER Generation Statistics[Amazon Redshift][0 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_her_statistics s
ON
    m.pilot_id = s.pilot_id;


--SRE NBI Gen Quality Generic Tag[Apps Script Addon][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users, s.total_nbi_users_with_generic_tag, s.pct_users_with_generic_tag, s.last_updated_timestamp
 FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_nbi_generic_tag_users s
ON
    m.pilot_id = s.pilot_id


--SRE Quality Disagg[Apps Script Addon][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_disagg s
ON
    m.pilot_id = s.pilot_id


--SRE Ingestion Failure Statistics #1[Extract Data][1 chart, 0 variables]
--based on SRE Ingestion Failure Statistics Apps Script Source


--SRE Email Statistics[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_email_stats s
ON
    m.pilot_id = s.pilot_id;


--SRE Invoice Statistics[Apps Script Addon][9 charts, 0 variables]
Select *
from
(
    SELECT
    s.pilot_id  || ' : ' || isnull(m.pilot_name,'') AS pilot_id_name,
    s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
    isnull(s.failed_itemisation_pct,0) as failed_itemisation_pct,
    isnull(s.successful_itemisation_pct,0) as successful_itemisation_pct,
    s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
    s.fuel_type,module_name, s.analysis_date,s.delay_in_days,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
    FROM (select * from reporting.sre_invoice_statistics where trigger_flag='SCHEDULED')s left join
    (
        SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
            ELSE pilot_name -- Keep the original name if '(' doesn't exist
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
        FROM data_sanity.master_pilot_list
    ) as m
ON
    m.pilot_id = s.pilot_id
) where rnk=1
union all
Select *
from
(
    SELECT
    s.pilot_id  || ' : ' || isnull(m.pilot_name,'') AS pilot_id_name,
    s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
    isnull(s.failed_itemisation_pct,0) as failed_itemisation_pct,
    isnull(s.successful_itemisation_pct,0) as successful_itemisation_pct,
    s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
    s.fuel_type,module_name, s.analysis_date,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
    FROM (select * from reporting.sre_invoice_statistics where trigger_flag='ADHOC')s left join
    (
        SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
            ELSE pilot_name -- Keep the original name if '(' doesn't exist
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
        FROM data_sanity.master_pilot_list
    ) as m
ON
    m.pilot_id = s.pilot_id
) where rnk=1


--SRE HER Quality Statistics[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
    FROM data_sanity.master_pilot_list
) AS m
JOIN
(
    -- Daily
    SELECT
        pilot_id,
        DATEADD(day, epoch_day, '1970-01-01'::date)::date + 1 AS reporting_date,
        DATEADD(day, epoch_day, '1970-01-01'::date)::date       AS analysis_date,
        SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
        SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
        SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
        SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
        SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
        SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
        SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
        SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
        SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
        SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
        SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
        SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
        SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
        SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
        SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
        SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
        SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
        SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
        SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
        'Daily' AS period
    FROM public.her_automation_query_results
    GROUP BY 1,2,3

    UNION ALL

    -- Weekly
    SELECT
        pilot_id,
        DATE_TRUNC('week', DATEADD(day, epoch_day, '1970-01-01'::date)::date + 1)::date AS reporting_date,
        DATE_TRUNC('week', DATEADD(day, epoch_day, '1970-01-01'::date)::date)::date     AS analysis_date,
        SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
        SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
        SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
        SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
        SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
        SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
        SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
        SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
        SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
        SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
        SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
        SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
        SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
        SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
        SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
        SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
        SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
        SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
        SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
        'Weekly' AS period
    FROM public.her_automation_query_results
    GROUP BY 1,2,3

    UNION ALL

    -- Monthly
    SELECT
        pilot_id,
        DATE_TRUNC('month', DATEADD(day, epoch_day, '1970-01-01'::date)::date + 1)::date AS reporting_date,
        DATE_TRUNC('month', DATEADD(day, epoch_day, '1970-01-01'::date)::date)::date     AS analysis_date,
        SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
        SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
        SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
        SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
        SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
        SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
        SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
        SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
        SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
        SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
        SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
        SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
        SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
        SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
        SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
        SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
        SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
        SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
        SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
        'Monthly' AS period
    FROM public.her_automation_query_results
    GROUP BY 1,2,3
) AS s
ON m.pilot_id = s.pilot_id;


--SRE NBI EMR Metrics[Amazon Redshift][0 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.analysis_date,s.pilot_id,s.module_name,s.cluster_id,s.cluster_type,s.metric_name,s.metric_value,s.reason_code,s.steps_status,

    -- Duration in seconds (rounded)
    ROUND(EXTRACT(EPOCH FROM (s.end_time - s.creation_time))) AS duration_seconds,

    -- Timestamps casted to ISO 8601 string format
    TO_CHAR(s.creation_time AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS creation_time_str,
    TO_CHAR(s.end_time AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS end_time_str,
    TO_CHAR(s.event_timestamp AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS event_timestamp_str

FROM
    (
        SELECT
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name,
            pilot_id,
            islaunchpadpilot,
            pilot_type,
            isevpilot,
            timezone
        FROM data_sanity.master_pilot_list
    ) AS m
JOIN
    reporting.sre_emr_metrics_fact s
ON
    m.pilot_id = s.pilot_id;


--SRE Email Reco Statistics[Amazon Redshift][1 chart, 0 variables]
SELECT
    s.pilot_id  || ' : ' || isnull(m.pilot_name,'') AS pilot_id_name,
    s.*
FROM reporting.sre_quality_reco_stats s left join
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
ON
    m.pilot_id = s.pilot_id;


--SRE Quality Disagg - CA[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_disagg s
ON
    m.pilot_id = s.pilot_id;


--SRE Billing Cycle Length[Apps Script Addon][0 charts, 0 variables]
select pilot_id,bc_1_15_count,bc_15_30_count,bc_31_45_count,bc_45_60_count,bc_61_75_count,
bc_76_90_count,bc_gt_90_count,analysis_date,reporting_date, CASE
            WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
            THEN 'OPOWER'
            ELSE 'BILLING'
        END AS ingestion_type from reporting.utility_billing_length_tracker ubt


--SRE Email Statistics[Amazon Redshift][2 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_quality_email_stats s
ON
    m.pilot_id = s.pilot_id;


--SRE Ingestion Audit[Amazon Redshift][1 chart, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_ingestion_audit s
ON
    m.pilot_id = s.pilot_id;


--SRE Ingestion Audit[Apps Script Addon][7 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_ingestion_audit s
ON
    m.pilot_id = s.pilot_id


--SRE HER Cluster Specific Failure Rate[Apps Script Addon][2 charts, 0 variables]
with cte as
(
    select analysis_date,reporting_date,pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Daily' as "Period",
    failure_count,last_updated_timestamp
    from reporting.sre_her_schedule_errors
    union all
    select date_trunc('Week',analysis_date)::date as analysis_date,date_trunc('Week',reporting_date)::date as reporting_date,
    pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Weekly' as "Period",
    sum(failure_count) as failure_count,max(last_updated_timestamp) as last_updated_timestamp
    from reporting.sre_her_schedule_errors
    group by 1,2,3,4,5,6,7,8
    union all
    select date_trunc('Month',analysis_date)::date as analysis_date,date_trunc('Month',reporting_date)::date as reporting_date,
    pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Monthly' as "Period",
    sum(failure_count) as failure_count,max(last_updated_timestamp) as last_updated_timestamp
    from reporting.sre_her_schedule_errors
    group by 1,2,3,4,5,6,7,8
),
her_errors as
(
select a.pilot_id,a.cluster_id,a.schedule_start,a.schedule_end,a.measurement_type as fuel_type,a.failure_reason,failure_count,total_failure_count,a.period, a.analysis_date, a.reporting_date,
round((100.00*failure_count)/total_failure_count,2) as failure_percentage, a.last_updated_timestamp,
ROW_NUMBER() OVER (PARTITION BY a.pilot_id,a.cluster_id,a.schedule_start,a.schedule_end,a.measurement_type,a."period",a.analysis_date ORDER BY failure_count DESC) AS rank
from cte a
join
(
    Select pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date,reporting_date,sum(failure_count) as total_failure_count
    from cte
    group by pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date,reporting_date

)b on a.pilot_id=b.pilot_id
and a.cluster_id=b.cluster_id
and a.schedule_start=b.schedule_start
and a.schedule_end=b.schedule_end
and a.measurement_type=b.measurement_type
and a."period"=b."period"
and a.analysis_date=b.analysis_date
and a.reporting_date=b.reporting_date
)
select  m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,s.*
from her_errors s
join
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
            ELSE pilot_name -- Keep the original name if '(' doesn't exist
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
    FROM data_sanity.master_pilot_list
) as m ON m.pilot_id = s.pilot_id


--SRE Email Failure Statistics[Apps Script Addon][2 charts, 0 variables]
SELECT
    sfs.*,
    ROW_NUMBER() OVER (
        PARTITION BY analysis_date, pilot_id, email_type
        ORDER BY failure_count DESC
    ) AS rank
FROM
    (SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_email_failure_reasons s
ON
    m.pilot_id = s.pilot_id) as sfs
ORDER BY
    analysis_date DESC,
    pilot_id,
    email_type,
    failure_count DESC


--SRE SQS Metrics By Hour[Amazon Redshift][0 charts, 0 variables]
SELECT
    DATE_TRUNC('hour', analysis_date) AS ingestion_hour,
    environment,
    module_name,
    queue_type,
    queue_name,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) AS total_messages_received,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesSent' THEN metric_value ELSE 0 END) AS total_messages_sent,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) AS total_messages_deleted,
    AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) AS avg_queue_backlog,
    MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) AS max_latency,
    -- Success rate calculation (percentage)
    ROUND(
        SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0),
    2) AS success_rate,  -- Rounded to 2 decimal places
    SUM(CASE WHEN metric_name = 'ApproximateNumberOfMessagesDelayed' THEN metric_value ELSE 0 END) AS delayed_messages
FROM reporting.sre_queue_metrics_fact
--WHERE analysis_date >= CURRENT_TIMESTAMP - INTERVAL '7 days'  -- Reduce the date range
GROUP BY ingestion_hour, environment, module_name, queue_type, queue_name
ORDER BY ingestion_hour DESC;


--SRE SQS Queue Metrics[Amazon Redshift][0 charts, 0 variables]
select * from reporting.sre_queue_metrics_fact;


--SRE Email Reco Statistics[Apps Script Addon][1 chart, 0 variables]
SELECT
    s.pilot_id  || ' : ' || isnull(m.pilot_name,'') AS pilot_id_name,
    s.*
FROM reporting.sre_quality_reco_stats s left join
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
ON
    m.pilot_id = s.pilot_id


--SRE NBI Engine Daily Run Statistics[Apps Script Addon][6 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users as total_users_successful, s.total_users_with_200_errorcode, s.total_users_with_300_errorcode, s.nbi_error_pct, s.last_updated_timestamp
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_nbi_generated_errors s
ON
    m.pilot_id = s.pilot_id


--SRE_NBI_FALED_JOB_COUNT[Amazon Redshift][0 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    (SELECT
    pilot_id,
    analysis_date::DATE AS analysis_date,

    COUNT(DISTINCT cluster_type) AS stages_present,

    -- Check if any known stage is marked as failed
    MAX(
        CASE
            WHEN metric_value IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED')
            THEN 1
            ELSE 0
        END
    ) AS has_failed_stage,

    -- Final failure condition: either missing a stage or any stage failed
    CASE
        WHEN COUNT(DISTINCT cluster_type) < 3
             OR MAX(CASE
                      WHEN metric_value IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED')
                      THEN 1
                      ELSE 0
                  END) = 1
        THEN 1
        ELSE 0
    END AS is_failed

FROM
    reporting.sre_emr_metrics_fact
GROUP BY
    pilot_id, analysis_date::DATE) s
ON
    m.pilot_id = s.pilot_id;


--SRE Email Daily Tracker[Amazon Redshift][3 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id,
    islaunchpadpilot ,
    pilot_type ,
    isevpilot ,
    timezone
FROM data_sanity.master_pilot_list) as m
JOIN
    reporting.sre_email_daily_tracker s
ON
    m.pilot_id = s.pilot_id;


--SRE Failure Statistics[Apps Script Addon][3 charts, 0 variables]
WITH cleaned_pilots AS (
  SELECT
    pilot_id,
    CASE
      WHEN POSITION('(' IN pilot_name) > 0
      THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
      ELSE pilot_name
    END AS pilot_name,
    islaunchpadpilot,
    pilot_type,
    isevpilot,
    timezone
  FROM data_sanity.master_pilot_list
),
joined_data AS (
  SELECT
    s.*,
    m.pilot_name,
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name
  FROM reporting.sre_failure_statistics s
  JOIN cleaned_pilots m ON s.pilot_id = m.pilot_id
),
ranked_data AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY analysis_date, pilot_id, module_name
      ORDER BY failure_percentage DESC
    ) AS rank
  FROM joined_data
)
SELECT *
FROM ranked_data
WHERE rank <= 3
ORDER BY analysis_date DESC, pilot_id, module_name, failure_percentage DESC


--SRE Ingestion Failure Statistics[Extract Data][0 charts, 0 variables]
--based on SRE Ingestion Failure Statistics Apps Script Source


--HER Aggregated Generation Stats[Apps Script Addon][3 charts, 0 variables]
SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
SELECT
       CASE
           WHEN POSITION('(' IN pilot_name) > 0
           THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name)) -- Extract from the '(' onward
           ELSE pilot_name -- Keep the original name if '(' doesn't exist
       END AS pilot_name,
       pilot_id,
       islaunchpadpilot,
       pilot_type,
       isevpilot,
       timezone
   FROM data_sanity.master_pilot_list

) AS m
JOIN

(
select pilot_id,cluster_id,analysis_date,schedule_start,schedule_end,fuel_type,'Daily' as "Period",
expected_eligible_users as expected_eligible_users,
actual_eligible_users as actual_eligible_users,
actual_generation_count as actual_generation_count,
expected_eligible_users-actual_generation_count as weekly_actual_failure_count,last_updated_timestamp
from
(
SELECT
ISNULL(a.pilot_id, b.pilot_id) AS pilot_id,
ISNULL(a.cluster_id, b.cluster_id) AS cluster_id,
ISNULL(a.analysis_date, b.analysis_date) AS analysis_date,
ISNULL(a.reporting_date, b.reporting_date) AS reporting_date,
ISNULL(a.schedule_start, b.schedule_start) AS schedule_start,
ISNULL(a.schedule_end, b.schedule_end) AS schedule_end,
ISNULL(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
and a.measurement_type=b.measurement_type
)
union all
select pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly' as "Period",
max(expected_eligible_users) as weekly_expected_eligible_users,
max(actual_eligible_users) as weekly_actual_eligible_users,
sum(actual_generation_count) as weekly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as weekly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
ISNULL(a.pilot_id, b.pilot_id) AS pilot_id,
ISNULL(a.cluster_id, b.cluster_id) AS cluster_id,
ISNULL(a.analysis_date, b.analysis_date) AS analysis_date,
ISNULL(a.reporting_date, b.reporting_date) AS reporting_date,
date_trunc('week',ISNULL(a.analysis_date, b.analysis_date))::date AS analysis_week,
ISNULL(a.schedule_start, b.schedule_start) AS schedule_start,
ISNULL(a.schedule_end, b.schedule_end) AS schedule_end,
ISNULL(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,"Period"
union all
select pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly' as "Period",
max(expected_eligible_users) as monthly_expected_eligible_users,
max(actual_eligible_users) as monthly_actual_eligible_users,
sum(actual_generation_count) as monthly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as monthly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
ISNULL(a.pilot_id, b.pilot_id) AS pilot_id,
ISNULL(a.cluster_id, b.cluster_id) AS cluster_id,
ISNULL(a.analysis_date, b.analysis_date) AS analysis_date,
ISNULL(a.reporting_date, b.reporting_date) AS reporting_date,
date_trunc('month',ISNULL(a.analysis_date, b.analysis_date))::date AS analysis_month,
ISNULL(a.schedule_start, b.schedule_start) AS schedule_start,
ISNULL(a.schedule_end, b.schedule_end) AS schedule_end,
ISNULL(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,"Period"
)AS s ON m.pilot_id = s.pilot_id
