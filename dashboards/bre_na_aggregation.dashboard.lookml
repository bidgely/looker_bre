# NA Aggregation: data_studio_files/bre_na_aggregation_implementation.md
---
- dashboard: bre_na_aggregation
  title: BRE NA — Aggregation
  description: NA Data Governance Aggregation. Source-row statistics and quality metrics; draft pending Looker and
    source-report validation.
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
    name: na_2_t01
    note_display: hover
    note_state: collapsed
    note_text: NA-2-T01. Latest active-user snapshot per pilot, then reporting-date filtering. File Granularity
      is absent from this source.
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
    explore: bre_na_aggregation
    fields:
    - bre_na_aggregation.datapoints_selected_average
    - bre_na_aggregation.datapoints_average_change
    - bre_na_aggregation.datapoints_previous_average
    filters:
      bre_na_aggregation.comparison_date_range: 7 days ago for 7 days
      bre_na_aggregation.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_aggregation.datapoints_previous_average
    limit: 1
    listen:
      Time Period: bre_na_aggregation.comparison_date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
    model: bre_na
    name: na_2_t02
    note_display: hover
    note_state: collapsed
    note_text: NA-2-T02. Source-row average; reporting-date comparison with the preceding equal-length range. Zero
      or absent previous value gives no percentage change.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average raw datapoints
    title: '# of Raw Datapoints Per Day (Average)'
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_aggregation
    fields:
    - bre_na_aggregation.datapoints_selected_median
    - bre_na_aggregation.datapoints_median_change
    - bre_na_aggregation.datapoints_previous_median
    filters:
      bre_na_aggregation.comparison_date_range: 7 days ago for 7 days
      bre_na_aggregation.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_aggregation.datapoints_previous_median
    limit: 1
    listen:
      Time Period: bre_na_aggregation.comparison_date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
    model: bre_na
    name: na_2_t03
    note_display: hover
    note_state: collapsed
    note_text: NA-2-T03. Source-row median; reporting-date comparison with the preceding equal-length range. Zero
      or absent previous value gives no percentage change.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median raw datapoints
    title: '# of Raw Datapoints Per Day (Median)'
    type: single_value
    width: 6
  - col: 12
    explore: bre_na_aggregation
    fields:
    - bre_na_aggregation.gauge_label
    - bre_na_aggregation.total_meters_average
    filters:
      bre_na_aggregation.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_aggregation.date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
    model: bre_na
    name: na_2_t04
    row: 3
    show_view_names: false
    title: Daily Averages — Meters/Day
    type: looker_column
    width: 6
    note_text: NA-2-T04. Unweighted source-row average. Display range 0–1,500,000; at or above maximum the arc is
      full and the actual value remains visible. Display maximum is not a target.
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
            "max": 1500000,
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
              "format": "{value:,.0f}",
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
            "tickPositions": [
              0,
              1500000
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
              "format": "{point.y:,.2f}",
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
          "pointFormat": "<b>{point.y:,.2f} meters</b>"
        },
        "series": [
          {
            "type": "solidgauge",
            "name": "Meters/Day"
          }
        ]
      }
  - col: 18
    explore: bre_na_aggregation
    fields:
    - bre_na_aggregation.gauge_label
    - bre_na_aggregation.success_perc_average
    filters:
      bre_na_aggregation.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_aggregation.date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
    model: bre_na
    name: na_2_t05
    row: 3
    show_view_names: false
    title: Daily Averages — Availability
    type: looker_column
    width: 6
    note_text: NA-2-T05. Unweighted source-row average. Display range 0–100; at or above maximum the arc is full
      and the actual value remains visible. Availability uses the user-confirmed actual / expected × 100 formula.
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
            "type": "solidgauge",
            "name": "Availability %"
          }
        ]
      }
  - name: na_2_t06
    title: Daily Aggregated Raw Data Statistics (T+7)
    model: bre_na
    explore: bre_na_aggregation
    type: looker_column
    fields:
    - bre_na_aggregation.period_date
    - bre_na_aggregation.total_expected_datapoints_sum
    - bre_na_aggregation.total_datapoints_sum
    - bre_na_aggregation.success_perc_average
    - bre_na_aggregation.total_negative_consumption_datapoints_sum
    - bre_na_aggregation.total_meters_sum
    filters:
      bre_na_aggregation.date_range: 7 days ago for 7 days
      bre_na_aggregation.period: Daily
    listen:
      Time Period: bre_na_aggregation.date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
      Period: bre_na_aggregation.period
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_aggregation.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_aggregation.total_expected_datapoints_sum: Expected Datapoints
      bre_na_aggregation.total_datapoints_sum: Actual Datapoints Received
      bre_na_aggregation.success_perc_average: Data Availability %
      bre_na_aggregation.total_negative_consumption_datapoints_sum: 'Unique Users #'
      bre_na_aggregation.total_meters_sum: 'Unique Meters #'
    note_display: hover
    note_state: collapsed
    note_text: 'NA-2-T06. Filters reporting_date and groups analysis_date. Preserves source rows; no extra T+7 restriction.
      Unique Users # intentionally uses SUM(total_negative_consumption_datapoints), confirmed by the user. Availability
      uses the user-confirmed actual / expected × 100 formula.'
    stacking: ''
    series_types:
      bre_na_aggregation.success_perc_average: line
      bre_na_aggregation.total_negative_consumption_datapoints_sum: line
      bre_na_aggregation.total_meters_sum: line
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_na_aggregation.total_expected_datapoints_sum
        axisId: bre_na_aggregation.total_expected_datapoints_sum
        name: Expected Datapoints
      - id: bre_na_aggregation.total_datapoints_sum
        axisId: bre_na_aggregation.total_datapoints_sum
        name: Actual Datapoints Received
      - id: bre_na_aggregation.total_negative_consumption_datapoints_sum
        axisId: bre_na_aggregation.total_negative_consumption_datapoints_sum
        name: 'Unique Users #'
      - id: bre_na_aggregation.total_meters_sum
        axisId: bre_na_aggregation.total_meters_sum
        name: 'Unique Meters #'
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Availability %
      orientation: right
      series:
      - id: bre_na_aggregation.success_perc_average
        axisId: bre_na_aggregation.success_perc_average
        name: Data Availability %
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  - name: na_2_t07
    title: Daily Aggregated Raw Data Quality (User) (T+7)
    model: bre_na
    explore: bre_na_aggregation
    type: looker_line
    fields:
    - bre_na_aggregation.period_date
    - bre_na_aggregation.negative_consumption_users_sum
    - bre_na_aggregation.total_negative_consumption_users_sum
    - bre_na_aggregation.zero_consumption_users_sum
    - bre_na_aggregation.total_zero_consumption_users_sum
    - bre_na_aggregation.missing_datapoint_users_sum
    filters:
      bre_na_aggregation.date_range: 7 days ago for 7 days
      bre_na_aggregation.period: Daily
    listen:
      Time Period: bre_na_aggregation.date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
      Period: bre_na_aggregation.period
    row: 15
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_aggregation.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_aggregation.negative_consumption_users_sum: Users With At-least One -ve RAW Datapoint
      bre_na_aggregation.total_negative_consumption_users_sum: Users With Net -ve Consumption for the Day
      bre_na_aggregation.zero_consumption_users_sum: Users with at least one 0 consumption datapoint
      bre_na_aggregation.total_zero_consumption_users_sum: Users with net 0 consumption for the day
      bre_na_aggregation.missing_datapoint_users_sum: Users with at least one missing datapoint
    note_display: hover
    note_state: collapsed
    note_text: NA-2-T07. Filters reporting_date and groups analysis_date. Preserves source rows; no extra T+7 restriction.
  - name: na_2_t08
    title: Daily Aggregated Raw Data Quality (Meter) (T+7)
    model: bre_na
    explore: bre_na_aggregation
    type: looker_line
    fields:
    - bre_na_aggregation.period_date
    - bre_na_aggregation.negative_consumption_meters_sum
    - bre_na_aggregation.total_negative_consumption_meters_sum
    - bre_na_aggregation.zero_consumption_meters_sum
    - bre_na_aggregation.total_zero_consumption_meters_sum
    - bre_na_aggregation.missing_datapoint_meters_sum
    filters:
      bre_na_aggregation.date_range: 7 days ago for 7 days
      bre_na_aggregation.period: Daily
    listen:
      Time Period: bre_na_aggregation.date_range
      Pilot ID: bre_na_aggregation.pilot_id
      Pilot Name: bre_na_aggregation.pilot_name
      File Granularity: bre_na_aggregation.duration
      Period: bre_na_aggregation.period
    row: 23
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_aggregation.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_aggregation.negative_consumption_meters_sum: Meters With At-least One -ve RAW Datapoint
      bre_na_aggregation.total_negative_consumption_meters_sum: Meters With Net -ve Consumption for the Day
      bre_na_aggregation.zero_consumption_meters_sum: Meters with at least one 0 consumption datapoint
      bre_na_aggregation.total_zero_consumption_meters_sum: Meters with net 0 consumption for the day
      bre_na_aggregation.missing_datapoint_meters_sum: Meters with at least one missing datapoint
    note_display: hover
    note_state: collapsed
    note_text: NA-2-T08. Filters reporting_date and groups analysis_date. Preserves source rows; no extra T+7 restriction.
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_aggregation
    field: bre_na_aggregation.date_range
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
    explore: bre_na_aggregation
    field: bre_na_aggregation.period
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
  - name: File Granularity
    title: File Granularity
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_aggregation
    field: bre_na_aggregation.duration
    ui_config:
      type: tag_list
      display: popover
