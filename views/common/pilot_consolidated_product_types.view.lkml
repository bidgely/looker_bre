view: pilot_consolidated_product_types {

  derived_table: {
    sql: select * from reporting.pilot_consolidated_product_type_events ;;
  }
  dimension: invoice_valid_code {
    description: "Shows valid codes for each pilot"
    type: number
    sql: ${TABLE}.invoice_valid_code ;;
  }
  dimension: pilot_id {
    description: "pilot id"
    type: number
  }
  dimension: pilot_id_suggestions {
    description: "pilot id"
    type: string
    sql: ${pilot_id} ;;
  }
  dimension: pilot_name {
    description: "pilot name"
    type: string
    suggest_persist_for: "5 minutes"
    sql: case
    when ${TABLE}.pilot_name like '%DUKE%' then 'Duke Energy'
    when ${TABLE}.pilot_name like '%RMP%' and ${TABLE}.pilot_name not like '%RMP SMB%' then 'RMP'
    when ${TABLE}.pilot_name like '%RMP SMB%' then ${TABLE}.pilot_name
    when ${pilot_id} = 10067 then 'OGE-RES-OK'
    when ${TABLE}.pilot_name like '%PNMTOU%' then 'PNM TOD'
    when ${TABLE}.pilot_name like '%pnm-resi%' then 'PNM Resi'
    when ${TABLE}.pilot_name like '%pnm-smb%' then 'PNM SMB'
    else ${TABLE}.pilot_name end ;;
  }
  dimension: pilot_name_original {
    description: "pilot name original"
    type: string
    suggest_persist_for: "5 minutes"
    sql: ${TABLE}.pilot_name ;;
  }
  dimension: email_enabled {
    description: "is email enabled for pilot"
    type: yesno
  }
  dimension: sms_enabled {
    description: "is sms enabled for pilot"
    type: yesno
  }
  dimension: survey_enabled {
    description: "is survey enabled for pilot"
    type: yesno
  }
  dimension: public_api_enabled {
    description: "is api enabled for pilot"
    type: yesno
  }
  dimension: mobile_enabled {
    description: "is mobile enabled for pilot"
    type: yesno
  }
  dimension: web_enabled {
    description: "is web enabled for pilot"
    type: yesno
  }
  dimension: is_non_invoice_pilots {
    hidden: yes
    type: yesno
    sql: ${pilot_id} in ('20010','10008') ;;
  }
  dimension: past_year_start {
    type: number
    sql: ${TABLE}.past_year_start ;;
  }
  dimension: past_year_end {
    type: number
    sql: ${TABLE}.past_year_end ;;
  }
  dimension: completed_month_start {
    type: number
    sql: ${TABLE}.completed_month_start ;;
  }
  dimension: completed_month_end {
    type: number
    sql: ${TABLE}.completed_month_end ;;
  }
  dimension: mtd_month_start {
    type: number
    sql: ${TABLE}.mtd_month_start ;;
  }
  dimension: mtd_month_end {
    type: number
    sql: ${TABLE}.mtd_month_end ;;
  }
  dimension: time_difference_from_utc {
    hidden: yes
    type: number
    sql: ${TABLE}.time_difference_from_utc ;;
  }

  dimension: is_meter_based_move_out {
    hidden: yes
    type: yesno
    sql: case when ${pilot_id} in ('10032')then true else ${TABLE}.is_meter_based_move_out end ;;
  }

  dimension: time_zone {
    type: string
    sql: case when ${TABLE}.time_zone is NULL or LENGTH(${TABLE}.time_zone) = 0 then 'UTC' else ${TABLE}.time_zone end;;
  }

  # For now adding this here in lookml later need to be move to some table.
  dimension: is_dashboard_v2_pilot {
    description: "Check whether a pilot using dashboard v2"
    type: yesno
    sql: (${pilot_id} = 10009 OR ${pilot_id} = 10017);;
  }

  dimension: is_multi_meter_pilot {
    description: "Check whether a pilot is multi meter"
    type: yesno
    sql: (${pilot_id} = 10009 OR ${pilot_id} = 10017 OR ${pilot_id} = 10028);;
  }

  dimension: is_user_inactive_gateway_token_pilot {
    hidden: yes
    description: "User is inactive based on gateway token"
    sql: ${pilot_id} = 10008 ;;
  }

  dimension: date_at_older_threshold_in_past_year {
    description: "Gets older threshold date in past year which is used in disagg dashboards"
    hidden: yes
    type: date
    sql:  date_add('day', -${past_year_start}, current_date) ;;
  }
  dimension: date_at_older_threshold_in_past_month {
    description: "Gets older threshold date in past month which is used in disagg dashboards"
    hidden: yes
    type: date
    sql:  date_add('day', -${completed_month_start}, current_date) ;;
  }
  dimension: date_at_newer_threshold_in_past  {
    description: "Gets newer threshold date which is used in disagg dashboards"
    hidden: yes
    type:  date
    sql:  date_add('day', -${past_year_end}, current_date) ;;
  }
  dimension: is_disagg_triggered_based_on_invoice {
    hidden: yes
    description: "Pilots for whom disagg is trigerred when we have invoice. Applicable for disagg dashboards."
    type: yesno
    sql: ${TABLE}.is_disagg_trigger_on_invoice_ingestion = 'true'  ;;
  }
  dimension: is_nsm_pilot {
    hidden: yes
    type: yesno
    sql: ${TABLE}.is_nsm_pilot = 'true' ;;
  }
  dimension: is_60_min_data_pilot {
    hidden: yes
    type: yesno
    sql: ${TABLE}.is_60_min_data_pilot = 'true' ;;
  }
  dimension: is_30_min_data_pilot {
    hidden: yes
    type: yesno
    sql: ${TABLE}.is_30_min_data_pilot = 'true' ;;
  }
  dimension: is_15_min_data_pilot {
    hidden: yes
    type: yesno
    sql: ${TABLE}.is_15_min_data_pilot = 'true' ;;
  }
  dimension: pilots_for_whom_solar_homes_are_removed_before_calculating_bad_data_homes {
    hidden: yes
    description: "Pilots for whom solar homes are removed before calculating bad data homes. Applicable for disagg dashboards."
    type: yesno
    sql:  ${pilot_id} = 20010 ;;
  }
  dimension: is_disagg_shown_based_on_invoice_code {
    hidden: yes
    description: "Pilots for whom disagg is shown to end users when invoice code is 0. Applicable for disagg dashboards."
    type: yesno
    sql:  ${pilot_id} = 20006 ;;
  }
  dimension: does_cluster_name_contain_users {
    hidden: yes
    description: "Pilots for whom cluster name contains the word Users"
    type: yesno
    sql:  ${pilot_name} = 'United Illuminating'
          OR
          ${pilot_name} = 'RMP'
          OR
          ${pilot_name} = 'Pacific Power';;
  }
  dimension: high_consumption_threshold_for_ami_users {
    description: "this is the high consumption threshold for the ami users, if the consumption exceeds this threshold, the user is said to have high consumption"
    type: number
    sql: case
    when ${TABLE}.pilot_id = 10017 then 480000
    else 480000 end;; #the thresholds for other pilots can be added here
  }
  dimension: high_consumption_threshold_for_nsm_users {
    description: "this is the high consumption threshold for the nsm users, if the consumption exceeds this threshold, the user is said to have high consumption"
    type: number
    sql: case
    when ${TABLE}.pilot_id = 10017 then 480000
    else 480000 end;; #the thresholds for other pilots can be added here, going forward
  }
  dimension: is_hybrid_pilot {
    type: yesno
    sql: ${is_nsm_pilot} and (${is_60_min_data_pilot} OR ${is_30_min_data_pilot} OR ${is_15_min_data_pilot}) ;;
  }
}
