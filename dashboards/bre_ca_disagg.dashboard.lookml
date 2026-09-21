# Disagg dashboard using the approved CA tile definitions and shared views.
---
- dashboard: bre_ca_disagg
  title: BRE CA — Disagg
  description: CA disaggregation monitoring.
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  elements:
  - name: active_uuid
    title: Active UUID out of Total UUID
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.active_users_uuid_summary
    - bre_dashboard.active_users_total_uuid_sum
    filters:
      bre_dashboard.source_family: activeusers
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 0
    col: 0
    width: 24
    height: 3
    hidden_fields:
    - bre_dashboard.active_users_total_uuid_sum
    show_single_value_title: false
    show_comparison: false
    note_text: Latest reporting-date snapshot per pilot. Only Pilot ID and Pilot Name controls affect this tile.
    note_display: hover
    note_state: collapsed
  - name: invoices_average
    title: '# of Invoices Per Day — Average'
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.invoice_statistics_invoices_selected_average
    - bre_dashboard.invoice_statistics_invoices_average_change
    - bre_dashboard.invoice_statistics_invoices_previous_average
    filters:
      bre_dashboard.source_family: invoicestatistics
      bre_dashboard.invoice_in_comparison_window: 'Yes'
      bre_dashboard.invoice_comparison_date_range: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.invoice_comparison_date_range
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
      Module Name: bre_dashboard.module_name
    row: 3
    col: 0
    width: 6
    height: 4
    hidden_fields:
    - bre_dashboard.invoice_statistics_invoices_previous_average
    show_single_value_title: true
    single_value_title: Average invoices
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row average. Comparison is percentage change versus the preceding equal-length date range;
      absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: invoices_median
    title: '# of Invoices Per Day — Median'
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.invoice_statistics_invoices_selected_median
    - bre_dashboard.invoice_statistics_invoices_median_change
    - bre_dashboard.invoice_statistics_invoices_previous_median
    filters:
      bre_dashboard.source_family: invoicestatistics
      bre_dashboard.invoice_in_comparison_window: 'Yes'
      bre_dashboard.invoice_comparison_date_range: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.invoice_comparison_date_range
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
      Module Name: bre_dashboard.module_name
    row: 3
    col: 6
    width: 6
    height: 4
    hidden_fields:
    - bre_dashboard.invoice_statistics_invoices_previous_median
    show_single_value_title: true
    single_value_title: Median invoices
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row median. Comparison is percentage change versus the preceding equal-length date range;
      absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: success_t_7
    title: Average Success % — T-7 Day
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average
    filters:
      bre_dashboard.source_family: invoicestatistics
      bre_dashboard.reporting_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
      Module Name: bre_dashboard.module_name
    row: 3
    col: 12
    width: 6
    height: 4
    show_single_value_title: true
    single_value_title: T-7 day
    show_comparison: false
    value_format: 0.00"%"
    note_text: Average source success percentage for SCHEDULED rows with delay_in_days = 7, filtered by reporting_date.
    note_display: hover
    note_state: collapsed
  - name: success_t_2
    title: Average Success % — T-2 Day
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average
    filters:
      bre_dashboard.source_family: invoicestatistics
      bre_dashboard.reporting_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
      Module Name: bre_dashboard.module_name
    row: 3
    col: 18
    width: 6
    height: 4
    show_single_value_title: true
    single_value_title: T-2 day
    show_comparison: false
    value_format: 0.00"%"
    note_text: Average source success percentage for SCHEDULED rows with delay_in_days = 2, filtered by reporting_date.
    note_display: hover
    note_state: collapsed
  - name: daily_invoice_disagg_statistics
    title: Daily Invoice Ingestion vs Hybrid Disagg Processing Success %
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.disagg_period_date
    - bre_dashboard.invoice_statistics_daily_total_invoices
    - bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average
    - bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average
    - bre_dashboard.invoice_statistics_successful_itemisation_correction_pct_max
    filters:
      bre_dashboard.source_family: invoicestatistics
      bre_dashboard.reporting_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Period: bre_dashboard.period
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
      Module Name: bre_dashboard.module_name
    row: 7
    col: 0
    width: 24
    height: 8
    sorts:
    - bre_dashboard.disagg_period_date
    x_axis_scale: time
    x_axis_label: Analysis Date
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: ''
    series_labels:
      bre_dashboard.invoice_statistics_daily_total_invoices: Daily Total Invoices
      bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average: Success Rate (T-2)
      bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average: Success Rate (T-7)
      bre_dashboard.invoice_statistics_successful_itemisation_correction_pct_max: Correction Line
    series_types:
      bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average: line
      bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average: line
      bre_dashboard.invoice_statistics_successful_itemisation_correction_pct_max: line
    y_axes:
    - label: Invoices
      orientation: left
      series:
      - id: bre_dashboard.invoice_statistics_daily_total_invoices
        name: Daily Total Invoices
        axisId: bre_dashboard.invoice_statistics_daily_total_invoices
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: Success %
      orientation: right
      series:
      - id: bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average
        name: Success Rate (T-2)
        axisId: bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average
      - id: bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average
        name: Success Rate (T-7)
        axisId: bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average
      - id: bre_dashboard.invoice_statistics_successful_itemisation_correction_pct_max
        name: Correction Line
        axisId: bre_dashboard.invoice_statistics_successful_itemisation_correction_pct_max
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    series_value_format:
      bre_dashboard.invoice_statistics_successful_itemisation_t_2_pct_average: 0.00"%"
      bre_dashboard.invoice_statistics_successful_itemisation_t_7_pct_average: 0.00"%"
      bre_dashboard.invoice_statistics_successful_itemisation_correction_pct_max: 0.00"%"
    note_text: Filtered by reporting_date and grouped by analysis_date using Period (Daily, Sunday-start Weekly,
      or Monthly). Invoice volume averages source rows for a group with one distinct analysis date, otherwise sums
      them. Correction Line is the maximum ADHOC success percentage.
    note_display: hover
    note_state: collapsed
  - name: daily_disagg_quality
    title: Daily Disagg Quality Report (Only for Elec AMI)
    model: bre_ca
    explore: bre_dashboard
    type: looker_line
    fields:
    - bre_dashboard.disagg_period_date
    - bre_dashboard.disagg_quality_appliances_kwh_variance_pct_1_average
    - bre_dashboard.disagg_quality_appliances_kwh_variance_pct_2_average
    - bre_dashboard.disagg_quality_total_cost_deviation_pct_1_average
    - bre_dashboard.disagg_quality_total_cost_deviation_pct_2_average
    - bre_dashboard.disagg_quality_cost_per_kwh_deviation_pct_average
    - bre_dashboard.disagg_quality_seasonal_appliance_usage_deviation_pct_average
    - bre_dashboard.disagg_quality_ao_pct_non_tou_average
    - bre_dashboard.disagg_quality_ac_pct_non_tou_average
    - bre_dashboard.disagg_quality_sh_pct_non_tou_average
    - bre_dashboard.disagg_quality_other_pct_non_tou_average
    - bre_dashboard.disagg_quality_solar_pct_non_tou_average
    - bre_dashboard.disagg_quality_single_appliance_domination_deviation_pct_average
    - bre_dashboard.disagg_quality_missing_dwelliing_pct_average
    filters:
      bre_dashboard.source_family: disaggquality
      bre_dashboard.reporting_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Period: bre_dashboard.period
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
    row: 15
    col: 0
    width: 24
    height: 10
    sorts:
    - bre_dashboard.disagg_period_date
    x_axis_scale: time
    x_axis_label: Analysis Date
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: ''
    series_labels:
      bre_dashboard.disagg_quality_appliances_kwh_variance_pct_1_average: "$/KWH Across Appliances %Var (Flag 1)"
      bre_dashboard.disagg_quality_appliances_kwh_variance_pct_2_average: "$/KWH Across Appliances %Var (Flag 2)"
      bre_dashboard.disagg_quality_total_cost_deviation_pct_1_average: "Total $ Across Appliances Out of Range (Flag 1)"
      bre_dashboard.disagg_quality_total_cost_deviation_pct_2_average: "Total $ Across Appliances Out of Range (Flag 2)"
      bre_dashboard.disagg_quality_cost_per_kwh_deviation_pct_average: "$/KWH Out of Range"
      bre_dashboard.disagg_quality_seasonal_appliance_usage_deviation_pct_average: "Non-Seasonal Appliance Usage"
      bre_dashboard.disagg_quality_ao_pct_non_tou_average: "AO I/O % Dev"
      bre_dashboard.disagg_quality_ac_pct_non_tou_average: "AC I/O % Dev"
      bre_dashboard.disagg_quality_sh_pct_non_tou_average: "SH I/O % Dev"
      bre_dashboard.disagg_quality_other_pct_non_tou_average: "Other I/O % Dev"
      bre_dashboard.disagg_quality_solar_pct_non_tou_average: "Zero Solar Estimation"
      bre_dashboard.disagg_quality_single_appliance_domination_deviation_pct_average: "Single Appliance Domination"
      bre_dashboard.disagg_quality_missing_dwelliing_pct_average: "Missing Dwelling Type"
    note_text: Average of each source quality metric, filtered by reporting_date and grouped by analysis_date
      using Period (Daily, Sunday-start Weekly, or Monthly). Source percentage values are not rescaled.
    note_display: hover
    note_state: collapsed
  - name: disagg_failure_reasons
    title: Daily Top Disagg/Itemisation Failure Reasons
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.disagg_period_date
    - bre_dashboard.failure_reason
    - bre_dashboard.processing_failures_failure_percentage_average
    filters:
      bre_dashboard.source_family: processingfailures
      bre_dashboard.failure_scope: Top Three
      bre_dashboard.reporting_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Period: bre_dashboard.period
      Meter Type: bre_dashboard.meter_type
      Fuel Type: bre_dashboard.fuel_type
      Module Name: bre_dashboard.module_name
    row: 25
    col: 0
    width: 24
    height: 9
    sorts:
    - bre_dashboard.disagg_period_date
    - bre_dashboard.failure_reason
    x_axis_scale: time
    x_axis_label: Period
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: normal
    pivots:
    - bre_dashboard.failure_reason
    column_limit: 200
    series_labels:
      bre_dashboard.processing_failures_failure_percentage_average: Failure %
    note_text: Average failure percentage by failure reason, filtered by reporting_date. Retains source rank
      ≤ 3 per analysis date, pilot and module before Daily/Weekly/Monthly grouping; more than three reasons
      may appear across the selected dates and pilots. Source percentage values are not rescaled.
    note_display: hover
    note_state: collapsed
  filters:
  - name: Time Period
    title: Time Period
    type: field_filter
    default_value: 7 days ago for 7 days
    allow_multiple_values: false
    required: true
    ui_config:
      type: advanced
      display: popover
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.reporting_date
  - name: Period
    title: Period
    type: field_filter
    default_value: Daily
    allow_multiple_values: false
    required: true
    ui_config:
      type: button_toggles
      display: popover
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.period
  - name: Pilot ID
    title: Pilot ID
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.pilot_id
  - name: Pilot Name
    title: Pilot Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.pilot_name
  - name: Meter Type
    title: Meter Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_invoice_filters
    field: bre_invoice_statistics.meter_type
  - name: Fuel Type
    title: Fuel Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_invoice_filters
    field: bre_invoice_statistics.fuel_type
  - name: Module Name
    title: Module Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_invoice_filters
    field: bre_invoice_statistics.module_name
