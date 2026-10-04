# NA Email 6a: data_studio_files/bre_na_email_implementation.md
---
- dashboard: bre_na_email_governance
  title: BRE NA — Email Data Governance
  description: NA Email 6a Data Governance. Eight tiles; native Looker and original-report validation pending.
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
    name: na_6a_t01
    note_display: hover
    note_state: collapsed
    note_text: NA-6A-T01. Latest active-user snapshot per pilot, then reporting-date filtering. Reporting Frequency
      and Email Type do not apply to this source.
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
    explore: bre_na_email_delivery
    fields:
    - bre_na_email_delivery.emails_delivered_selected_average
    - bre_na_email_delivery.emails_delivered_average_change
    - bre_na_email_delivery.emails_delivered_previous_average
    filters:
      bre_na_email_delivery.comparison_date_range: 7 days ago for 7 days
      bre_na_email_delivery.in_comparison_window: 'Yes'
      bre_na_email_delivery.delivery_mode: Daily
    height: 4
    hidden_fields:
    - bre_na_email_delivery.emails_delivered_previous_average
    limit: 1
    listen:
      Time Period: bre_na_email_delivery.comparison_date_range
      Pilot ID: bre_na_email_delivery.pilot_id
      Pilot Name: bre_na_email_delivery.pilot_name
      Reporting Frequency: bre_na_email_delivery.delivery_mode
      Email Type: bre_na_email_delivery.email_type
    model: bre_na
    name: na_6a_t02
    note_display: hover
    note_state: collapsed
    note_text: NA-6A-T02. Source-row average of delivery_cnt, compared with the preceding equal-length analysis-date
      range.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average emails delivered
    title: '# of Email Delivered - Average'
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_email_delivery
    fields:
    - bre_na_email_delivery.emails_delivered_selected_median
    - bre_na_email_delivery.emails_delivered_median_change
    - bre_na_email_delivery.emails_delivered_previous_median
    filters:
      bre_na_email_delivery.comparison_date_range: 7 days ago for 7 days
      bre_na_email_delivery.in_comparison_window: 'Yes'
      bre_na_email_delivery.delivery_mode: Daily
    height: 4
    hidden_fields:
    - bre_na_email_delivery.emails_delivered_previous_median
    limit: 1
    listen:
      Time Period: bre_na_email_delivery.comparison_date_range
      Pilot ID: bre_na_email_delivery.pilot_id
      Pilot Name: bre_na_email_delivery.pilot_name
      Reporting Frequency: bre_na_email_delivery.delivery_mode
      Email Type: bre_na_email_delivery.email_type
    model: bre_na
    name: na_6a_t03
    note_display: hover
    note_state: collapsed
    note_text: NA-6A-T03. Source-row exact median of delivery_cnt, compared with the preceding equal-length analysis-date
      range.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median emails delivered
    title: '# of Email Delivered - Median'
    type: single_value
    width: 6
  - col: 12
    explore: bre_na_email_delivery
    fields:
    - bre_na_email_delivery.gauge_label
    - bre_na_email_delivery.calc_generation_perc
    filters:
      bre_na_email_delivery.date_range: 7 days ago for 7 days
      bre_na_email_delivery.delivery_mode: Daily
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_email_delivery.date_range
      Pilot ID: bre_na_email_delivery.pilot_id
      Pilot Name: bre_na_email_delivery.pilot_name
      Reporting Frequency: bre_na_email_delivery.delivery_mode
      Email Type: bre_na_email_delivery.email_type
    model: bre_na
    name: na_6a_t04
    row: 3
    show_view_names: false
    title: Metrics Average - Generation
    type: looker_column
    width: 6
    note_text: NA-6A-T04. SUM(generation_cnt) / SUM(invoice_ingested) displayed as percent. Zero denominator returns
      NULL. Gauge fills at 100%, retaining the actual numeric value.
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
      \  },\n  \"series\": [\n    {\n      \"type\": \"solidgauge\",\n      \"name\": \"Generation %\"\n    }\n\
      \  ]\n}"
  - col: 18
    explore: bre_na_email_delivery
    fields:
    - bre_na_email_delivery.gauge_label
    - bre_na_email_delivery.calc_delivery_perc
    filters:
      bre_na_email_delivery.date_range: 7 days ago for 7 days
      bre_na_email_delivery.delivery_mode: Daily
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_email_delivery.date_range
      Pilot ID: bre_na_email_delivery.pilot_id
      Pilot Name: bre_na_email_delivery.pilot_name
      Reporting Frequency: bre_na_email_delivery.delivery_mode
      Email Type: bre_na_email_delivery.email_type
    model: bre_na
    name: na_6a_t05
    row: 3
    show_view_names: false
    title: Metrics Average - Delivery
    type: looker_column
    width: 6
    note_text: NA-6A-T05. SUM(delivery_cnt) / SUM(generation_cnt) displayed as percent. Zero denominator returns
      NULL. Gauge fills at 100%, retaining the actual numeric value.
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
      \  },\n  \"series\": [\n    {\n      \"type\": \"solidgauge\",\n      \"name\": \"Delivery %\"\n    }\n  ]\n\
      }"
  - name: na_6a_t06
    title: Weekly/Daily Email Delivery Statistics
    model: bre_na
    explore: bre_na_email_delivery
    type: looker_column
    fields:
    - bre_na_email_delivery.period_date
    - bre_na_email_delivery.invoice_ingested_sum
    - bre_na_email_delivery.generation_cnt_sum
    - bre_na_email_delivery.delivery_cnt_sum
    - bre_na_email_delivery.calc_generation_perc
    - bre_na_email_delivery.calc_delivery_perc
    filters:
      bre_na_email_delivery.date_range: 7 days ago for 7 days
      bre_na_email_delivery.period: Daily
      bre_na_email_delivery.delivery_mode: Daily
    listen:
      Time Period: bre_na_email_delivery.date_range
      Pilot ID: bre_na_email_delivery.pilot_id
      Pilot Name: bre_na_email_delivery.pilot_name
      Period: bre_na_email_delivery.period
      Reporting Frequency: bre_na_email_delivery.delivery_mode
      Email Type: bre_na_email_delivery.email_type
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_email_delivery.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_email_delivery.invoice_ingested_sum: 'Eligible Invoices #'
      bre_na_email_delivery.generation_cnt_sum: 'Email Generation #'
      bre_na_email_delivery.delivery_cnt_sum: 'Email Delivery #'
      bre_na_email_delivery.calc_generation_perc: Generation %
      bre_na_email_delivery.calc_delivery_perc: Delivery %
    series_types:
      bre_na_email_delivery.calc_generation_perc: line
      bre_na_email_delivery.calc_delivery_perc: line
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: NA-6A-T06. Count sums as grouped bars; documented ratios of sums as percentage lines. Analysis-date
      filtering and Period grouping; Reporting Frequency selects the Daily or Weekly source branch.
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_na_email_delivery.invoice_ingested_sum
        axisId: bre_na_email_delivery.invoice_ingested_sum
        name: 'Eligible Invoices #'
      - id: bre_na_email_delivery.generation_cnt_sum
        axisId: bre_na_email_delivery.generation_cnt_sum
        name: 'Email Generation #'
      - id: bre_na_email_delivery.delivery_cnt_sum
        axisId: bre_na_email_delivery.delivery_cnt_sum
        name: 'Email Delivery #'
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Percent
      orientation: right
      series:
      - id: bre_na_email_delivery.calc_generation_perc
        axisId: bre_na_email_delivery.calc_generation_perc
        name: Generation %
      - id: bre_na_email_delivery.calc_delivery_perc
        axisId: bre_na_email_delivery.calc_delivery_perc
        name: Delivery %
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  - name: na_6a_t07
    title: Weekly Email Reco Quality Report
    model: bre_na
    explore: bre_na_email_recommendations
    type: looker_column
    fields:
    - bre_na_email_recommendations.analysis_date
    - bre_na_email_recommendations.metric_name
    - bre_na_email_recommendations.notification_pct_average
    pivots:
    - bre_na_email_recommendations.metric_name
    filters:
      bre_na_email_recommendations.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_email_recommendations.date_range
      Pilot ID: bre_na_email_recommendations.pilot_id
      Pilot Name: bre_na_email_recommendations.pilot_name
      Email Type: bre_na_email_recommendations.email_type
    row: 15
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_email_recommendations.analysis_date
    - bre_na_email_recommendations.metric_name
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    stacking: normal
    note_display: hover
    note_state: collapsed
    note_text: NA-6A-T07. AVG(notification_pct), stacked by metric_name at analysis-date grain. Reporting Frequency
      is absent from this source; no additional weekly-only restriction was supplied.
  - name: na_6a_t08
    title: Weekly Top Email Failure Reasons
    model: bre_na
    explore: bre_na_email_failures
    type: looker_column
    fields:
    - bre_na_email_failures.period_date
    - bre_na_email_failures.failure_reason
    - bre_na_email_failures.metric_toggle
    pivots:
    - bre_na_email_failures.failure_reason
    filters:
      bre_na_email_failures.date_range: 7 days ago for 7 days
      bre_na_email_failures.period: Daily
      bre_na_email_failures.metric: failure_pct
    listen:
      Time Period: bre_na_email_failures.date_range
      Pilot ID: bre_na_email_failures.pilot_id
      Pilot Name: bre_na_email_failures.pilot_name
      Email Type: bre_na_email_failures.email_type
      Period: bre_na_email_failures.period
      Failure Metric: bre_na_email_failures.metric
    row: 23
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_email_failures.period_date
    - bre_na_email_failures.failure_reason
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    stacking: normal
    note_display: hover
    note_state: collapsed
    note_text: NA-6A-T08. Confirmed AVG(failure_pct) or SUM(failure_count), grouped by Period and failure reason.
      Source rank is retained, but no top-N cutoff was supplied. Reporting Frequency is absent from this source.
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_email_delivery
    field: bre_na_email_delivery.date_range
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
    explore: bre_na_email_delivery
    field: bre_na_email_delivery.period
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
  - name: Reporting Frequency
    title: Reporting Frequency
    type: field_filter
    default_value: Daily
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_email_delivery
    field: bre_na_email_delivery.delivery_mode
    ui_config:
      type: tag_list
      display: popover
  - name: Email Type
    title: Email Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_email_delivery
    field: bre_na_email_delivery.email_type
    ui_config:
      type: tag_list
      display: popover
  - name: Failure Metric
    title: Failure Metric
    type: field_filter
    default_value: failure_pct
    allow_multiple_values: false
    required: true
    model: bre_na
    explore: bre_na_email_failures
    field: bre_na_email_failures.metric
    ui_config:
      type: button_toggles
      display: popover
