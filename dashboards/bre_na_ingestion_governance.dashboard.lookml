# NA 1a — Data Governance Ingestion. See data_studio_files/bre_na_ingestion_implementation.md.
---
- crossfilter_enabled: false
  dashboard: bre_na_ingestion_governance
  description: NA Ingestion data governance, including Rate Comparison joined on pilot ID and exact last updated timestamp. Draft pending Looker validation and original-report parity review.
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
    name: active_uuid
    note_display: hover
    note_state: collapsed
    note_text: NA-1A-T01. Latest snapshot per pilot, then filtered by reporting date. File Type and Rate Plan are
      absent from this source.
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
    explore: bre_dashboard
    fields:
    - bre_dashboard.ingestion_audit_files_selected_average
    - bre_dashboard.ingestion_audit_files_average_change
    - bre_dashboard.ingestion_audit_files_previous_average
    filters:
      bre_dashboard.ingestion_comparison_date_range: 7 days ago for 7 days
      bre_dashboard.ingestion_in_comparison_window: 'Yes'
      bre_dashboard.source_family: ingestionaudit
    height: 4
    hidden_fields:
    - bre_dashboard.ingestion_audit_files_previous_average
    limit: 1
    listen:
      File Type: bre_dashboard.ingestion_file_type
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.ingestion_comparison_date_range
    model: bre_na
    name: files_average
    note_display: hover
    note_state: collapsed
    note_text: NA-1A-T02. Source-row average. Comparison is percentage change versus the preceding equal-length
      date range; absent or zero previous values have no percentage change.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average files
    title: '# of Files Per Day — Average'
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_dashboard
    fields:
    - bre_dashboard.ingestion_audit_files_selected_median
    - bre_dashboard.ingestion_audit_files_median_change
    - bre_dashboard.ingestion_audit_files_previous_median
    filters:
      bre_dashboard.ingestion_comparison_date_range: 7 days ago for 7 days
      bre_dashboard.ingestion_in_comparison_window: 'Yes'
      bre_dashboard.source_family: ingestionaudit
    height: 4
    hidden_fields:
    - bre_dashboard.ingestion_audit_files_previous_median
    limit: 1
    listen:
      File Type: bre_dashboard.ingestion_file_type
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.ingestion_comparison_date_range
    model: bre_na
    name: files_median
    note_display: hover
    note_state: collapsed
    note_text: NA-1A-T03. Source-row median. Comparison is percentage change versus the preceding equal-length date
      range; absent or zero previous values have no percentage change.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median files
    title: '# of Files Per Day — Median'
    type: single_value
    width: 6
  - col: 12
    explore: bre_dashboard
    fields:
    - bre_dashboard.na_gauge_label
    - bre_dashboard.na_users_millions_sum
    filters:
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.source_family: postingestion
    height: 4
    limit: 1
    listen:
      File Type: bre_dashboard.ingestion_file_type
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
    model: bre_na
    name: daily_users
    row: 3
    show_view_names: false
    title: Daily Average - Users (M)/day
    type: looker_column
    width: 6
    note_text: NA-1A-T04. SUM of documented users in millions, not normalized by days. Gauge scale is 0–20 M (display range, not a target). At or above 20 M the arc is full;
      the center always shows the actual value in millions, including values above the scale. Source NULLIF behavior is preserved.
    note_display: hover
    note_state: collapsed
    show_value_labels: true
    advanced_vis_config: |-
      {
        "chart": {
          "type": "solidgauge",
          "animation": false,
          "spacing": [
            8,
            16,
            16,
            16
          ]
        },
        "title": {
          "text": null
        },
        "legend": {
          "enabled": false
        },
        "pane": {
          "startAngle": -90,
          "endAngle": 90,
          "center": [
            "50%",
            "76%"
          ],
          "size": "120%",
          "background": [
            {
              "outerRadius": "100%",
              "innerRadius": "76%",
              "shape": "arc",
              "backgroundColor": "#E8EDF3",
              "borderWidth": 0
            }
          ]
        },
        "yAxis": [
          {
            "min": 0,
            "max": 20,
            "minPadding": 0,
            "maxPadding": 0,
            "startOnTick": true,
            "endOnTick": false,
            "lineWidth": 0,
            "tickWidth": 0,
            "minorTickInterval": null,
            "title": {
              "text": null
            },
            "labels": {
              "distance": 14,
              "format": "{value:,.2f} M",
              "style": {
                "fontSize": "11px",
                "color": "#526174"
              }
            },
            "stops": [
              [
                0,
                "#2563EB"
              ],
              [
                1,
                "#2563EB"
              ]
            ],
            "tickPositions": [0, 20]
          }
        ],
        "plotOptions": {
          "solidgauge": {
            "animation": false,
            "radius": "100%",
            "innerRadius": "76%",
            "rounded": false,
            "overshoot": 0,
            "wrap": false,
            "dataLabels": {
              "enabled": true,
              "format": "{point.y:,.2f} M",
              "nullFormat": "No data",
              "borderWidth": 0,
              "y": -15,
              "crop": false,
              "overflow": "allow",
              "style": {
                "fontSize": "26px",
                "fontWeight": "600",
                "color": "#172B4D",
                "textOutline": "none"
              }
            }
          }
        },
        "tooltip": {
          "enabled": true,
          "headerFormat": "",
          "pointFormat": "<b>{point.y:,.6f} M users</b>"
        },
        "series": [
          {
            "type": "solidgauge"
          }
        ]
      }
  - col: 18
    explore: bre_dashboard
    fields:
    - bre_dashboard.na_gauge_label
    - bre_dashboard.ingestion_audit_success_percentage_average
    filters:
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.source_family: ingestionaudit
    height: 4
    limit: 1
    listen:
      File Type: bre_dashboard.ingestion_file_type
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
    model: bre_na
    name: daily_success
    row: 3
    show_view_names: false
    title: Daily Average — Success %
    type: looker_column
    width: 6
    note_text: 'NA-1A-T05. Average source success percentage. Gauge scale: 0–100%; full at 100%. The center always
      shows the actual value, including any value above 100%.'
    note_display: hover
    note_state: collapsed
    show_value_labels: true
    advanced_vis_config: |-
      {
        "chart": {
          "type": "solidgauge",
          "animation": false,
          "spacing": [
            8,
            16,
            16,
            16
          ]
        },
        "title": {
          "text": null
        },
        "legend": {
          "enabled": false
        },
        "pane": {
          "startAngle": -90,
          "endAngle": 90,
          "center": [
            "50%",
            "76%"
          ],
          "size": "120%",
          "background": [
            {
              "outerRadius": "100%",
              "innerRadius": "76%",
              "shape": "arc",
              "backgroundColor": "#E8EDF3",
              "borderWidth": 0
            }
          ]
        },
        "yAxis": [
          {
            "min": 0,
            "max": 100,
            "minPadding": 0,
            "maxPadding": 0,
            "startOnTick": true,
            "endOnTick": false,
            "lineWidth": 0,
            "tickWidth": 0,
            "minorTickInterval": null,
            "title": {
              "text": null
            },
            "labels": {
              "distance": 14,
              "format": "{value:,.0f}%",
              "style": {
                "fontSize": "11px",
                "color": "#526174"
              }
            },
            "stops": [
              [
                0,
                "#168A72"
              ],
              [
                1,
                "#168A72"
              ]
            ],
            "tickPositions": [
              0,
              100
            ]
          }
        ],
        "plotOptions": {
          "solidgauge": {
            "animation": false,
            "radius": "100%",
            "innerRadius": "76%",
            "rounded": false,
            "overshoot": 0,
            "wrap": false,
            "dataLabels": {
              "enabled": true,
              "format": "{point.y:,.2f}%",
              "nullFormat": "No data",
              "borderWidth": 0,
              "y": -15,
              "crop": false,
              "overflow": "allow",
              "style": {
                "fontSize": "26px",
                "fontWeight": "600",
                "color": "#172B4D",
                "textOutline": "none"
              }
            }
          }
        },
        "tooltip": {
          "enabled": true,
          "headerFormat": "",
          "pointFormat": "<b>{point.y:,.2f}%</b>"
        },
        "series": [
          {
            "type": "solidgauge"
          }
        ]
      }
  - col: 0
    explore: bre_na_ingestion_rate_comparison
    fields:
    - bre_na_ingestion_rate_comparison.ingestion_period_date
    - bre_na_ingestion_rate_comparison.files
    - bre_na_ingestion_rate_comparison.chunks
    - bre_na_ingestion_rate_comparison.records
    - bre_na_ingestion_rate_comparison.success_percentage_average
    - bre_na_ingestion_rate_comparison.expected_rc
    - bre_na_ingestion_rate_comparison.successful_rc
    - bre_na_ingestion_rate_comparison.missing_rc_percentage_average
    filters:
      bre_na_ingestion_rate_comparison.date_range: 7 days ago for 7 days
      bre_na_ingestion_rate_comparison.period: Daily
    height: 8
    legend_position: center
    limit: 5000
    listen:
      Time Period: bre_na_ingestion_rate_comparison.date_range
      Period: bre_na_ingestion_rate_comparison.period
      Pilot ID: bre_na_ingestion_rate_comparison.selected_pilot_id
      Pilot Name: bre_na_ingestion_rate_comparison.selected_pilot_name
      File Type: bre_na_ingestion_rate_comparison.file_type
      Rate Plan ID: bre_na_ingestion_rate_comparison.current_plan_number
    model: bre_na
    name: daily_ingestion_statistics
    row: 7
    series_labels:
      bre_na_ingestion_rate_comparison.files: 'Files #'
      bre_na_ingestion_rate_comparison.chunks: 'Chunks #'
      bre_na_ingestion_rate_comparison.records: 'Records #'
      bre_na_ingestion_rate_comparison.success_percentage_average: Success %
      bre_na_ingestion_rate_comparison.expected_rc: 'Expected RC #'
      bre_na_ingestion_rate_comparison.successful_rc: 'Successful RC #'
      bre_na_ingestion_rate_comparison.missing_rc_percentage_average: Missing RC %
    series_types:
      bre_na_ingestion_rate_comparison.success_percentage_average: line
      bre_na_ingestion_rate_comparison.missing_rc_percentage_average: line
    series_value_format:
      bre_na_ingestion_rate_comparison.success_percentage_average: 0.00"%"
      bre_na_ingestion_rate_comparison.missing_rc_percentage_average: 0.00"%"
    show_null_points: true
    show_value_labels: false
    show_view_names: false
    show_x_axis_label: true
    show_y_axis_labels: true
    sorts:
    - bre_na_ingestion_rate_comparison.ingestion_period_date
    stacking: normal
    title: Daily Ingestion Statistics
    type: looker_column
    width: 24
    x_axis_gridlines: false
    x_axis_label: Period
    x_axis_scale: time
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_na_ingestion_rate_comparison.files
        axisId: bre_na_ingestion_rate_comparison.files
        name: 'Files #'
      - id: bre_na_ingestion_rate_comparison.chunks
        axisId: bre_na_ingestion_rate_comparison.chunks
        name: 'Chunks #'
      - id: bre_na_ingestion_rate_comparison.records
        axisId: bre_na_ingestion_rate_comparison.records
        name: 'Records #'
      - id: bre_na_ingestion_rate_comparison.expected_rc
        axisId: bre_na_ingestion_rate_comparison.expected_rc
        name: 'Expected RC #'
      - id: bre_na_ingestion_rate_comparison.successful_rc
        axisId: bre_na_ingestion_rate_comparison.successful_rc
        name: 'Successful RC #'
      showLabels: true
      showValues: true
      type: linear
      tickDensity: default
      unpinAxis: false
    - label: Percent
      orientation: right
      series:
      - id: bre_na_ingestion_rate_comparison.success_percentage_average
        axisId: bre_na_ingestion_rate_comparison.success_percentage_average
        name: Success %
      - id: bre_na_ingestion_rate_comparison.missing_rc_percentage_average
        axisId: bre_na_ingestion_rate_comparison.missing_rc_percentage_average
        name: Missing RC %
      showLabels: true
      showValues: true
      type: linear
      tickDensity: default
      unpinAxis: false
    y_axis_gridlines: true
    note_text: NA-1A-T06. Audit LEFT JOIN Rate Comparison on pilot_id and exact last_updated_timestamp, including
      fractional seconds. Unmatched audit rows keep blank RC values. Selecting Rate Plan ID retains matching plan
      rows only. Multiple source matches repeat rows; source blend grouping and result parity await comparison.
    note_display: hover
    note_state: collapsed
  - col: 0
    explore: bre_dashboard
    fields:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.na_users_millions_sum
    - bre_dashboard.na_raw_delay_0_3_count
    - bre_dashboard.na_raw_delay_4_7_count
    - bre_dashboard.na_raw_delay_8_15_count
    - bre_dashboard.na_raw_delay_gt_15_count
    - bre_dashboard.na_raw_users_millions_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_0_7_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_7_15_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_15_30_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_gt_30_sum
    filters:
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
      bre_dashboard.source_family: postingestion
    height: 10
    interpolation: linear
    legend_position: center
    limit: 5000
    listen:
      File Type: bre_dashboard.ingestion_file_type
      Period: bre_dashboard.period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
    model: bre_na
    name: post_ingestion_quality
    note_display: hover
    note_state: collapsed
    note_text: NA-1A-T07. Preserves the documented raw-bucket COUNTs, invoice-bucket SUMs and totals in millions.
      Raw COUNT includes non-null zeros. Source CASE excludes OPOWER from Total Users. Bar/line assignment uses
      totals as lines pending visual confirmation.
    row: 15
    series_labels:
      bre_dashboard.na_users_millions_sum: Total Users (M)
      bre_dashboard.na_raw_users_millions_sum: Users Receiving Raw Data (M)
      bre_dashboard.na_raw_delay_0_3_count: Raw age 0 3 days (row count)
      bre_dashboard.na_raw_delay_4_7_count: Raw age 4 7 days (row count)
      bre_dashboard.na_raw_delay_8_15_count: Raw age 8 15 days (row count)
      bre_dashboard.na_raw_delay_gt_15_count: Raw age gt 15 days (row count)
      bre_dashboard.post_ingestion_user_invoice_with_delay_0_7_sum: Invoice age 0 7 days
      bre_dashboard.post_ingestion_user_invoice_with_delay_7_15_sum: Invoice age 7 15 days
      bre_dashboard.post_ingestion_user_invoice_with_delay_15_30_sum: Invoice age 15 30 days
      bre_dashboard.post_ingestion_user_invoice_with_delay_gt_30_sum: Invoice age gt 30 days
    show_null_points: true
    show_value_labels: false
    show_view_names: false
    show_x_axis_label: true
    show_y_axis_labels: true
    sorts:
    - bre_dashboard.ingestion_period_date
    stacking: ''
    title: Daily Post-Ingestion Data Quality Report (Only for Elec/Gas AMI)
    type: looker_column
    width: 24
    x_axis_gridlines: false
    x_axis_label: Period
    x_axis_scale: time
    y_axis_gridlines: true
    series_types:
      bre_dashboard.na_users_millions_sum: line
      bre_dashboard.na_raw_users_millions_sum: line
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_dashboard.na_raw_delay_0_3_count
        name: Raw age 0 3 days (row count)
        axisId: bre_dashboard.na_raw_delay_0_3_count
      - id: bre_dashboard.na_raw_delay_4_7_count
        name: Raw age 4 7 days (row count)
        axisId: bre_dashboard.na_raw_delay_4_7_count
      - id: bre_dashboard.na_raw_delay_8_15_count
        name: Raw age 8 15 days (row count)
        axisId: bre_dashboard.na_raw_delay_8_15_count
      - id: bre_dashboard.na_raw_delay_gt_15_count
        name: Raw age gt 15 days (row count)
        axisId: bre_dashboard.na_raw_delay_gt_15_count
      - id: bre_dashboard.post_ingestion_user_invoice_with_delay_0_7_sum
        name: Invoice age 0 7 days
        axisId: bre_dashboard.post_ingestion_user_invoice_with_delay_0_7_sum
      - id: bre_dashboard.post_ingestion_user_invoice_with_delay_7_15_sum
        name: Invoice age 7 15 days
        axisId: bre_dashboard.post_ingestion_user_invoice_with_delay_7_15_sum
      - id: bre_dashboard.post_ingestion_user_invoice_with_delay_15_30_sum
        name: Invoice age 15 30 days
        axisId: bre_dashboard.post_ingestion_user_invoice_with_delay_15_30_sum
      - id: bre_dashboard.post_ingestion_user_invoice_with_delay_gt_30_sum
        name: Invoice age gt 30 days
        axisId: bre_dashboard.post_ingestion_user_invoice_with_delay_gt_30_sum
      showLabels: true
      showValues: true
      type: linear
    - label: Users (M)
      orientation: right
      series:
      - id: bre_dashboard.na_users_millions_sum
        name: Total Users (M)
        axisId: bre_dashboard.na_users_millions_sum
      - id: bre_dashboard.na_raw_users_millions_sum
        name: Users Receiving Raw Data (M)
        axisId: bre_dashboard.na_raw_users_millions_sum
      showLabels: true
      showValues: true
      type: linear
  - col: 0
    column_limit: 200
    explore: bre_dashboard
    fields:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.application_error_code
    - bre_dashboard.na_failure_metric_value
    filters:
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
      bre_dashboard.source_family: ingestionfailures
      bre_dashboard.source_rank: <=3
    height: 9
    legend_position: center
    limit: 5000
    listen:
      File Type: bre_dashboard.ingestion_file_type
      Period: bre_dashboard.period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
      Failure Metric: bre_dashboard.na_failure_metric
    model: bre_na
    name: ingestion_failure_reasons
    note_display: hover
    note_state: collapsed
    note_text: NA-1A-T08. Retains source rank <= 3 per analysis date, pilot and ingestion type before period grouping.
      Metric switches AVG(failure_percentage) / SUM(failed_record_count).
    pivots:
    - bre_dashboard.application_error_code
    row: 25
    show_null_points: true
    show_value_labels: false
    show_view_names: false
    show_x_axis_label: true
    show_y_axis_labels: true
    sorts:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.application_error_code
    stacking: normal
    title: Daily Top Ingestion Failure Reasons
    type: looker_column
    width: 24
    x_axis_gridlines: false
    x_axis_label: Period
    x_axis_scale: time
    y_axis_gridlines: true
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_dashboard
    field: bre_dashboard.analysis_date
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
    explore: bre_dashboard
    field: bre_dashboard.period
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
  - allow_multiple_values: true
    default_value: ''
    explore: bre_dashboard
    field: bre_dashboard.ingestion_file_type
    model: bre_na
    name: File Type
    required: false
    title: File Type
    type: field_filter
    ui_config:
      display: popover
      type: tag_list
  - name: Failure Metric
    title: Failure Metric
    type: field_filter
    default_value: percentage
    allow_multiple_values: false
    required: false
    model: bre_na
    explore: bre_dashboard
    field: bre_dashboard.na_failure_metric
    ui_config:
      type: button_toggles
      display: popover
  - name: Rate Plan ID
    title: Rate Plan ID
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_rate_plan_tracker
    field: bre_na_rate_plan_tracker.current_plan_number
    ui_config:
      type: tag_list
      display: popover
  layout: newspaper
  preferred_viewer: dashboards-next
  title: BRE NA — Data Governance Ingestion
