# NA Rate Comparison: data_studio_files/bre_na_rate_comparison_implementation.md
---
- dashboard: bre_na_rate_comparison
  title: BRE NA — Rate Comparison
  description: NA Data Governance Rate Comparison. Draft pending Looker and original-report validation.
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  elements:
  - col: 0
    explore: bre_dashboard
    fields:
    - bre_dashboard.active_users_uuid_summary
    - bre_dashboard.active_users_total_uuid_sum
    filters:
      bre_dashboard.source_family: activeusers
      bre_dashboard.reporting_date: 7 days ago for 7 days
    height: 3
    hidden_fields:
    - bre_dashboard.active_users_total_uuid_sum
    limit: 1
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
    model: bre_na
    name: na_5a_t01
    note_display: hover
    note_state: collapsed
    note_text: NA-5A-T01. Latest active-user snapshot per pilot, then reporting-date filtering. Email Type and
      Promotion exclusions do not apply to this source.
    row: 0
    show_comparison: false
    show_single_value_title: false
    show_view_names: false
    title: Active Users out of Total
    type: single_value
    width: 24
  - col: 0
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_rate_comparison
    fields:
    - bre_na_rate_comparison.missing_load_shift_selected_average
    - bre_na_rate_comparison.missing_load_shift_average_change
    - bre_na_rate_comparison.missing_load_shift_previous_average
    filters:
      bre_na_rate_comparison.comparison_date_range: 7 days ago for 7 days
      bre_na_rate_comparison.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_rate_comparison.missing_load_shift_previous_average
    limit: 1
    listen:
      Time Period: bre_na_rate_comparison.comparison_date_range
      Pilot ID: bre_na_rate_comparison.pilot_id
      Pilot Name: bre_na_rate_comparison.pilot_name
      Email Type (Exclude): bre_na_rate_comparison.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison.excluded_promotions
    model: bre_na
    name: na_5a_t02
    note_display: hover
    note_state: collapsed
    note_text: NA-5A-T02. Source-row average of rc_missing_anomaly, compared with the preceding equal-length analysis-date
      range.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average missing load shift count
    title: Missing Load Shift Count ( < 3 days)- Average
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_rate_comparison
    fields:
    - bre_na_rate_comparison.missing_load_shift_selected_median
    - bre_na_rate_comparison.missing_load_shift_median_change
    - bre_na_rate_comparison.missing_load_shift_previous_median
    filters:
      bre_na_rate_comparison.comparison_date_range: 7 days ago for 7 days
      bre_na_rate_comparison.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_rate_comparison.missing_load_shift_previous_median
    limit: 1
    listen:
      Time Period: bre_na_rate_comparison.comparison_date_range
      Pilot ID: bre_na_rate_comparison.pilot_id
      Pilot Name: bre_na_rate_comparison.pilot_name
      Email Type (Exclude): bre_na_rate_comparison.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison.excluded_promotions
    model: bre_na
    name: na_5a_t03
    note_display: hover
    note_state: collapsed
    note_text: NA-5A-T03. Source-row exact median of rc_missing_anomaly, compared with the preceding equal-length
      analysis-date range.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median missing load shift count
    title: Missing Load Shift Count ( < 3 days) - Median
    type: single_value
    width: 6
  - col: 12
    explore: bre_na_rate_comparison
    fields:
    - bre_na_rate_comparison.gauge_label
    - bre_na_rate_comparison.accuracy_perc_average
    filters:
      bre_na_rate_comparison.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_rate_comparison.date_range
      Pilot ID: bre_na_rate_comparison.pilot_id
      Pilot Name: bre_na_rate_comparison.pilot_name
      Email Type (Exclude): bre_na_rate_comparison.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison.excluded_promotions
    model: bre_na
    name: na_5a_t04
    row: 3
    show_view_names: false
    title: Distribution - Accuracy %
    type: looker_column
    width: 6
    note_text: NA-5A-T04. Unweighted average of source accuracy_perc fractions displayed as percent. Gauge fills
      at 100%; actual value always retained.
    note_display: hover
    note_state: collapsed
    show_value_labels: true
    advanced_vis_config: "{\n  \"chart\": {\n    \"type\": \"solidgauge\",\n    \"animation\": false,\n    \"spacing\"\
      : [\n      8,\n      16,\n      16,\n      16\n    ]\n  },\n  \"title\": {\n    \"text\": null\n  },\n  \"\
      legend\": {\n    \"enabled\": false\n  },\n  \"pane\": {\n    \"startAngle\": -90,\n    \"endAngle\": 90,\n\
      \    \"center\": [\n      \"50%\",\n      \"76%\"\n    ],\n    \"size\": \"120%\",\n    \"background\": [\n\
      \      {\n        \"outerRadius\": \"100%\",\n        \"innerRadius\": \"76%\",\n        \"shape\": \"arc\"\
      ,\n        \"backgroundColor\": \"#E8EDF3\",\n        \"borderWidth\": 0\n      }\n    ]\n  },\n  \"yAxis\"\
      : [\n    {\n      \"min\": 0,\n      \"max\": 100,\n      \"minPadding\": 0,\n      \"maxPadding\": 0,\n \
      \     \"startOnTick\": true,\n      \"endOnTick\": false,\n      \"lineWidth\": 0,\n      \"tickWidth\": 0,\n\
      \      \"minorTickInterval\": null,\n      \"title\": {\n        \"text\": null\n      },\n      \"labels\"\
      : {\n        \"distance\": 14,\n        \"format\": \"{value:,.0f}%\",\n        \"style\": {\n          \"\
      fontSize\": \"11px\",\n          \"color\": \"#526174\"\n        }\n      },\n      \"stops\": [\n       \
      \ [\n          0,\n          \"#148A78\"\n        ],\n        [\n          1,\n          \"#148A78\"\n   \
      \     ]\n      ],\n      \"tickPositions\": [\n        0,\n        100\n      ]\n    }\n  ],\n  \"plotOptions\"\
      : {\n    \"solidgauge\": {\n      \"animation\": false,\n      \"radius\": \"100%\",\n      \"innerRadius\"\
      : \"76%\",\n      \"rounded\": false,\n      \"overshoot\": 0,\n      \"wrap\": false,\n      \"dataLabels\"\
      : {\n        \"enabled\": true,\n        \"format\": \"{point.y:,.2f}%\",\n        \"nullFormat\": \"No data\"\
      ,\n        \"borderWidth\": 0,\n        \"y\": -15,\n        \"crop\": false,\n        \"overflow\": \"allow\"\
      ,\n        \"style\": {\n          \"fontSize\": \"26px\",\n          \"fontWeight\": \"600\",\n         \
      \ \"color\": \"#172B4D\",\n          \"textOutline\": \"none\"\n        }\n      }\n    }\n  },\n  \"tooltip\"\
      : {\n    \"enabled\": true,\n    \"headerFormat\": \"\",\n    \"pointFormat\": \"<b>{point.y:,.2f}%</b>\"\n\
      \  },\n  \"series\": [\n    {\n      \"type\": \"solidgauge\",\n      \"name\": \"Accuracy %\"\n    }\n  ]\n\
      }"
  - col: 18
    explore: bre_na_rate_comparison
    fields:
    - bre_na_rate_comparison.gauge_label
    - bre_na_rate_comparison.deviation_perc_average
    filters:
      bre_na_rate_comparison.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_rate_comparison.date_range
      Pilot ID: bre_na_rate_comparison.pilot_id
      Pilot Name: bre_na_rate_comparison.pilot_name
      Email Type (Exclude): bre_na_rate_comparison.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison.excluded_promotions
    model: bre_na
    name: na_5a_t05
    row: 3
    show_view_names: false
    title: Distribution - Deviation %
    type: looker_column
    width: 6
    note_text: NA-5A-T05. Unweighted average of source deviation_perc fractions displayed as percent. Gauge fills
      at 100%; actual value always retained.
    note_display: hover
    note_state: collapsed
    show_value_labels: true
    advanced_vis_config: "{\n  \"chart\": {\n    \"type\": \"solidgauge\",\n    \"animation\": false,\n    \"spacing\"\
      : [\n      8,\n      16,\n      16,\n      16\n    ]\n  },\n  \"title\": {\n    \"text\": null\n  },\n  \"\
      legend\": {\n    \"enabled\": false\n  },\n  \"pane\": {\n    \"startAngle\": -90,\n    \"endAngle\": 90,\n\
      \    \"center\": [\n      \"50%\",\n      \"76%\"\n    ],\n    \"size\": \"120%\",\n    \"background\": [\n\
      \      {\n        \"outerRadius\": \"100%\",\n        \"innerRadius\": \"76%\",\n        \"shape\": \"arc\"\
      ,\n        \"backgroundColor\": \"#E8EDF3\",\n        \"borderWidth\": 0\n      }\n    ]\n  },\n  \"yAxis\"\
      : [\n    {\n      \"min\": 0,\n      \"max\": 100,\n      \"minPadding\": 0,\n      \"maxPadding\": 0,\n \
      \     \"startOnTick\": true,\n      \"endOnTick\": false,\n      \"lineWidth\": 0,\n      \"tickWidth\": 0,\n\
      \      \"minorTickInterval\": null,\n      \"title\": {\n        \"text\": null\n      },\n      \"labels\"\
      : {\n        \"distance\": 14,\n        \"format\": \"{value:,.0f}%\",\n        \"style\": {\n          \"\
      fontSize\": \"11px\",\n          \"color\": \"#526174\"\n        }\n      },\n      \"stops\": [\n       \
      \ [\n          0,\n          \"#DC2626\"\n        ],\n        [\n          1,\n          \"#DC2626\"\n   \
      \     ]\n      ],\n      \"tickPositions\": [\n        0,\n        100\n      ]\n    }\n  ],\n  \"plotOptions\"\
      : {\n    \"solidgauge\": {\n      \"animation\": false,\n      \"radius\": \"100%\",\n      \"innerRadius\"\
      : \"76%\",\n      \"rounded\": false,\n      \"overshoot\": 0,\n      \"wrap\": false,\n      \"dataLabels\"\
      : {\n        \"enabled\": true,\n        \"format\": \"{point.y:,.2f}%\",\n        \"nullFormat\": \"No data\"\
      ,\n        \"borderWidth\": 0,\n        \"y\": -15,\n        \"crop\": false,\n        \"overflow\": \"allow\"\
      ,\n        \"style\": {\n          \"fontSize\": \"26px\",\n          \"fontWeight\": \"600\",\n         \
      \ \"color\": \"#172B4D\",\n          \"textOutline\": \"none\"\n        }\n      }\n    }\n  },\n  \"tooltip\"\
      : {\n    \"enabled\": true,\n    \"headerFormat\": \"\",\n    \"pointFormat\": \"<b>{point.y:,.2f}%</b>\"\n\
      \  },\n  \"series\": [\n    {\n      \"type\": \"solidgauge\",\n      \"name\": \"Deviation %\"\n    }\n \
      \ ]\n}"
  - name: na_5a_t06
    title: MS/BP Email Promotion Section Validation (Only Available for DESC-RESI)
    model: bre_na
    explore: bre_na_rate_comparison
    type: looker_column
    fields:
    - bre_na_rate_comparison.period_date
    - bre_na_rate_comparison.favourable_count_sum
    - bre_na_rate_comparison.anomaly_count_sum
    - bre_na_rate_comparison.accuracy_perc_average
    filters:
      bre_na_rate_comparison.date_range: 7 days ago for 7 days
      bre_na_rate_comparison.period: Daily
    listen:
      Time Period: bre_na_rate_comparison.date_range
      Pilot ID: bre_na_rate_comparison.pilot_id
      Pilot Name: bre_na_rate_comparison.pilot_name
      Email Type (Exclude): bre_na_rate_comparison.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison.excluded_promotions
      Period: bre_na_rate_comparison.period
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_rate_comparison.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_rate_comparison.favourable_count_sum: 'Favourable #'
      bre_na_rate_comparison.anomaly_count_sum: 'Anomaly #'
      bre_na_rate_comparison.accuracy_perc_average: Accuracy %
    series_types:
      bre_na_rate_comparison.accuracy_perc_average: line
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: NA-5A-T06. Analysis-date filtering and Period grouping; source anomaly definitions retained. Source
      availability title retained; no fixed pilot restriction supplied.
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_na_rate_comparison.favourable_count_sum
        axisId: bre_na_rate_comparison.favourable_count_sum
        name: 'Favourable #'
      - id: bre_na_rate_comparison.anomaly_count_sum
        axisId: bre_na_rate_comparison.anomaly_count_sum
        name: 'Anomaly #'
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Accuracy %
      orientation: right
      series:
      - id: bre_na_rate_comparison.accuracy_perc_average
        axisId: bre_na_rate_comparison.accuracy_perc_average
        name: Accuracy %
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  - name: na_5a_t07
    title: Track TOU and RC Triggers Post-Invoice (Only Available for DESC-RESI)
    model: bre_na
    explore: bre_na_rate_comparison_triggers
    type: looker_column
    fields:
    - bre_na_rate_comparison_triggers.pilot_id_name
    - bre_na_rate_comparison_triggers.total_records_sum
    - bre_na_rate_comparison_triggers.missing_tou_count_sum
    - bre_na_rate_comparison_triggers.missing_rc_count_sum
    - bre_na_rate_comparison_triggers.avg_invoice_to_tou_latency_hrs_average
    - bre_na_rate_comparison_triggers.avg_tou_to_rc_latency_hrs_average
    filters:
      bre_na_rate_comparison_triggers.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_rate_comparison_triggers.date_range
      Pilot ID: bre_na_rate_comparison_triggers.pilot_id
      Pilot Name: bre_na_rate_comparison_triggers.pilot_name
      Email Type (Exclude): bre_na_rate_comparison_triggers.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison_triggers.excluded_promotions
    row: 15
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_rate_comparison_triggers.pilot_id_name
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: ordinal
    series_labels:
      bre_na_rate_comparison_triggers.total_records_sum: 'Total Invoice #'
      bre_na_rate_comparison_triggers.missing_tou_count_sum: 'Missing TOU Trigger #'
      bre_na_rate_comparison_triggers.missing_rc_count_sum: 'Missing RC Trigger #'
      bre_na_rate_comparison_triggers.avg_invoice_to_tou_latency_hrs_average: Avg Invoice-TOU Trigger Delay (hrs)
      bre_na_rate_comparison_triggers.avg_tou_to_rc_latency_hrs_average: Avg TOU-RC Trigger Delay (hrs)
    series_types:
      bre_na_rate_comparison_triggers.avg_invoice_to_tou_latency_hrs_average: line
      bre_na_rate_comparison_triggers.avg_tou_to_rc_latency_hrs_average: line
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: NA-5A-T07. Reporting-date filtering; source-row average latencies. Source LEFT JOIN and zero-latency
      coalescing retained. Source availability title retained; no fixed pilot restriction supplied.
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_na_rate_comparison_triggers.total_records_sum
        axisId: bre_na_rate_comparison_triggers.total_records_sum
        name: 'Total Invoice #'
      - id: bre_na_rate_comparison_triggers.missing_tou_count_sum
        axisId: bre_na_rate_comparison_triggers.missing_tou_count_sum
        name: 'Missing TOU Trigger #'
      - id: bre_na_rate_comparison_triggers.missing_rc_count_sum
        axisId: bre_na_rate_comparison_triggers.missing_rc_count_sum
        name: 'Missing RC Trigger #'
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Hours
      orientation: right
      series:
      - id: bre_na_rate_comparison_triggers.avg_invoice_to_tou_latency_hrs_average
        axisId: bre_na_rate_comparison_triggers.avg_invoice_to_tou_latency_hrs_average
        name: Avg Invoice-TOU Trigger Delay (hrs)
      - id: bre_na_rate_comparison_triggers.avg_tou_to_rc_latency_hrs_average
        axisId: bre_na_rate_comparison_triggers.avg_tou_to_rc_latency_hrs_average
        name: Avg TOU-RC Trigger Delay (hrs)
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  - name: na_5a_t08
    title: Post-Production Monitoring KPIs – MS/BP Emails, Rate Comparison and Invoice Pipeline (Only Available
      for DESC-RESI)
    model: bre_na
    explore: bre_na_rate_comparison
    type: looker_column
    fields:
    - bre_na_rate_comparison.period_date
    - bre_na_rate_comparison.rc_ooo_trigger_anomaly_sum
    - bre_na_rate_comparison.rc_early_trigger_anomally_sum
    - bre_na_rate_comparison.rc_missing_anomaly_sum
    - bre_na_rate_comparison.ls_low_value_anomally_sum
    filters:
      bre_na_rate_comparison.date_range: 7 days ago for 7 days
      bre_na_rate_comparison.period: Daily
    listen:
      Time Period: bre_na_rate_comparison.date_range
      Pilot ID: bre_na_rate_comparison.pilot_id
      Pilot Name: bre_na_rate_comparison.pilot_name
      Email Type (Exclude): bre_na_rate_comparison.excluded_email_types
      Promotion (Exclude): bre_na_rate_comparison.excluded_promotions
      Period: bre_na_rate_comparison.period
    row: 23
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_rate_comparison.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_rate_comparison.rc_ooo_trigger_anomaly_sum: 'RC Out-Of-Order Trigger #'
      bre_na_rate_comparison.rc_early_trigger_anomally_sum: 'RC Low Latency Trigger #'
      bre_na_rate_comparison.rc_missing_anomaly_sum: 'LS Missing # (< 3 days)'
      bre_na_rate_comparison.ls_low_value_anomally_sum: 'LS Low Value # (< $20)'
    series_types: {}
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: NA-5A-T08. Analysis-date filtering and Period grouping; source anomaly definitions retained. Source
      availability title retained; no fixed pilot restriction supplied.
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_na_rate_comparison.rc_ooo_trigger_anomaly_sum
        axisId: bre_na_rate_comparison.rc_ooo_trigger_anomaly_sum
        name: 'RC Out-Of-Order Trigger #'
      - id: bre_na_rate_comparison.rc_early_trigger_anomally_sum
        axisId: bre_na_rate_comparison.rc_early_trigger_anomally_sum
        name: 'RC Low Latency Trigger #'
      - id: bre_na_rate_comparison.rc_missing_anomaly_sum
        axisId: bre_na_rate_comparison.rc_missing_anomaly_sum
        name: 'LS Missing # (< 3 days)'
      - id: bre_na_rate_comparison.ls_low_value_anomally_sum
        axisId: bre_na_rate_comparison.ls_low_value_anomally_sum
        name: 'LS Low Value # (< $20)'
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_rate_comparison
    field: bre_na_rate_comparison.date_range
    model: bre_na
    name: Time Period
    required: true
    title: Time Period
    type: field_filter
    ui_config:
      display: popover
      type: advanced
  - allow_multiple_values: false
    default_value: Daily
    explore: bre_na_rate_comparison
    field: bre_na_rate_comparison.period
    model: bre_na
    name: Period
    required: true
    title: Period
    type: field_filter
    ui_config:
      display: popover
      type: button_toggles
  - allow_multiple_values: true
    default_value: '10037'
    explore: bre_pilot_filters
    field: bre_pilots.pilot_id
    model: bre_na
    name: Pilot ID
    required: false
    title: Pilot ID
    type: field_filter
    ui_config:
      display: inline
      type: dropdown_menu
  - allow_multiple_values: true
    default_value: PSEG
    explore: bre_pilot_filters
    field: bre_pilots.pilot_name
    model: bre_na
    name: Pilot Name
    required: false
    title: Pilot Name
    type: field_filter
    ui_config:
      display: inline
      type: dropdown_menu
  - name: Email Type (Exclude)
    title: Email Type (Exclude)
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_rate_comparison
    field: bre_na_rate_comparison.excluded_email_types
    ui_config:
      type: tag_list
      display: popover
  - name: Promotion (Exclude)
    title: Promotion (Exclude)
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_rate_comparison
    field: bre_na_rate_comparison.excluded_promotions
    ui_config:
      type: tag_list
      display: popover
