connection: "starburst_prod_na"

# Granular includes per project convention (avoid wildcard includes)
include: "/views/common/date_series.view.lkml"
include: "/views/common/pilot_consolidated_product_types.view.lkml"
include: "/views/itron/itron_enrollment_files.view.lkml"
include: "/views/itron/itron_di_monitoring.view.lkml"
include: "/views/itron/itron_feature_message.view.lkml"
include: "/views/itron/itron_appliance_data.view.lkml"
include: "/views/itron/itron_config_issued.view.lkml"
include: "/views/itron/itron_config_confirmation.view.lkml"
include: "/views/itron/itron_config_messages.view.lkml"
include: "/views/itron/itron_consumption_data.view.lkml"
include: "/views/itron/itron_consumption_data_uat.view.lkml"
include: "/views/itron/itron_solar_uat_data.view.lkml"
include: "/views/itron/itron_meter_config_update_request.view.lkml"
include: "/dashboards/itron_di_monitoring_dashboard_v2__production_pilots.dashboard.lookml"

explore: itron_enrollment_files {
  view_name: itron_enrollment_files
  persist_for: "8 hours"

  join: date_series {
    view_label: "User Created Date Series"
    type: full_outer
    relationship: many_to_one
    sql_on: ${itron_enrollment_files.start_time_date} <= ${date_series.continous_date} ;;
  }
  join: itron_di_monitoring {
    type: left_outer
    relationship: one_to_many
    sql_on: ${itron_enrollment_files.meter_id} = ${itron_di_monitoring.meter_id} and ${date_series.continous_date} = ${itron_di_monitoring.event_date};;
  }
  join: itron_appliance_data {
    type: left_outer
    relationship: one_to_many
    sql_on: ${itron_enrollment_files.meter_id} = ${itron_appliance_data.meter_id} and ${date_series.continous_date} = ${itron_appliance_data.event_date} and {%condition itron_appliance_data.corresponding_event_flag_filter%} ${itron_appliance_data.corresponding_event_flag} {%endcondition%};;
  }
  join: itron_consumption_data {
    type: left_outer
    relationship: one_to_many
    sql_on: ${itron_enrollment_files.uuid} = ${itron_consumption_data.uuid} and ${date_series.continous_date} = ${itron_consumption_data.data_date};;
  }
  join: itron_config_messages {
    view_label: "Config Recieved"
    type: left_outer
    relationship: one_to_one
    sql_on: ${itron_enrollment_files.meter_id} = ${itron_config_messages.meter_id} and ${date_series.continous_date} = ${itron_config_messages.update_time_date};;
  }
  join: itron_config_confirmation {
    view_label: "Config Confirmation"
    type: left_outer
    relationship: one_to_one
    sql_on: ${itron_enrollment_files.meter_id} = ${itron_config_confirmation.meter_id} and ${date_series.continous_date} = ${itron_config_confirmation.update_time_date};;
  }
  join: itron_config_issued {
    view_label: "Config Issued"
    type: left_outer
    relationship: one_to_one
    sql_on: ${itron_enrollment_files.uuid} = ${itron_config_issued.uuid} and ${date_series.continous_date} = ${itron_config_issued.first_update_date};;
  }
  join: itron_solar_uat_data {
    view_label: "Solar Data"
    type: inner
    relationship: one_to_one
    sql_on: ${itron_enrollment_files.uuid} = ${itron_solar_uat_data.uuid} and ${date_series.continous_date} = ${itron_solar_uat_data.date_hour_date};;
  }
  join: itron_meter_config_update_request {
    view_label: "Config Update Data"
    type: left_outer
    relationship: one_to_one
    sql_on: ${itron_enrollment_files.uuid} = ${itron_meter_config_update_request.uuid} and ${date_series.continous_date} = ${itron_meter_config_update_request.issued_date};;
  }
}
