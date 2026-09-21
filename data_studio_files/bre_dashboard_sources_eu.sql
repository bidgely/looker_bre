--User Analytics[Google Analytics][8 charts, 0 variables]
--not required


--SRE Billing Cycle Length[Amazon Redshift][1 chart, 0 variables]
select pilot_id,bc_1_15_count,bc_15_30_count,bc_31_45_count,bc_45_60_count,bc_61_75_count,
bc_76_90_count,bc_gt_90_count,analysis_date,reporting_date, CASE
            WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
            THEN 'OPOWER'
            ELSE 'BILLING'
        END AS ingestion_type from reporting.utility_billing_length_tracker ubt;


--SRE Post Ingestion Data Quality[Amazon Redshift][3 charts, 0 variables]
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


--SRE Master Pilot List[Amazon Redshift][1 chart, 0 variables]
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
ON l.pilot_id = m.pilot_id;


--SRE Ingestion Audit[Amazon Redshift][7 charts, 0 variables]
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


--SRE Email Statistics[Amazon Redshift][6 charts, 0 variables]
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


--SRE Ingestion Failure Statistics[Amazon Redshift][2 charts, 0 variables]
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
    failure_percentage desc);


--SRE Email Reco Statistics[Amazon Redshift][2 charts, 0 variables]
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


--SRE Invoice Statistics[Amazon Redshift][9 charts, 0 variables]
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
) where rnk=1;


--SRE All Active Users[Amazon Redshift][2 charts, 0 variables]
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
ON m.pilot_id = s.pilot_id;


--SRE Email Failure Statistics[Amazon Redshift][3 charts, 0 variables]
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
    failure_count DESC;


--SRE Failure Statistics[Amazon Redshift][3 charts, 0 variables]
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
ORDER BY analysis_date DESC, pilot_id, module_name, failure_percentage DESC;


--SRE Quality Disagg[Amazon Redshift][3 charts, 0 variables]
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
