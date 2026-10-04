# NA TOU: data_studio_files/bre_na_tou_implementation.md
---
- dashboard: bre_na_tou
  title: BRE NA — TOU
  description: NA Data Governance TOU. Draft pending Looker and original-report validation.
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
    name: na_4a_t01
    note_display: hover
    note_state: collapsed
    note_text: NA-4A-T01. Latest active-user snapshot per pilot, then reporting-date filtering. TOU Mode and Delay
      are absent from this source.
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
    explore: bre_na_tou
    fields:
    - bre_na_tou.successful_invoices_selected_average
    - bre_na_tou.successful_invoices_average_change
    - bre_na_tou.successful_invoices_previous_average
    filters:
      bre_na_tou.comparison_date_range: 7 days ago for 7 days
      bre_na_tou.in_comparison_window: 'Yes'
      bre_na_tou.tou_mode: COMPLETE_BILLING_CYCLE
      bre_na_tou.delay_in_days: '1'
    height: 4
    hidden_fields:
    - bre_na_tou.successful_invoices_previous_average
    limit: 1
    listen:
      Time Period: bre_na_tou.comparison_date_range
      Pilot ID: bre_na_tou.pilot_id
      Pilot Name: bre_na_tou.pilot_name
      TOU Mode: bre_na_tou.tou_mode
      Delay (Days): bre_na_tou.delay_in_days
    model: bre_na
    name: na_4a_t02
    note_display: hover
    note_state: collapsed
    note_text: NA-4A-T02. Source-row average of successful_tou_eligible_invoices; analysis-date comparison with
      the immediately preceding equal-length range. Previous zero or absent values yield no relative change.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average successful TOU aggregation
    title: '# of Successful TOU Aggregation - Average'
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_tou
    fields:
    - bre_na_tou.successful_invoices_selected_median
    - bre_na_tou.successful_invoices_median_change
    - bre_na_tou.successful_invoices_previous_median
    filters:
      bre_na_tou.comparison_date_range: 7 days ago for 7 days
      bre_na_tou.in_comparison_window: 'Yes'
      bre_na_tou.tou_mode: COMPLETE_BILLING_CYCLE
      bre_na_tou.delay_in_days: '1'
    height: 4
    hidden_fields:
    - bre_na_tou.successful_invoices_previous_median
    limit: 1
    listen:
      Time Period: bre_na_tou.comparison_date_range
      Pilot ID: bre_na_tou.pilot_id
      Pilot Name: bre_na_tou.pilot_name
      TOU Mode: bre_na_tou.tou_mode
      Delay (Days): bre_na_tou.delay_in_days
    model: bre_na
    name: na_4a_t03
    note_display: hover
    note_state: collapsed
    note_text: NA-4A-T03. Source-row median of successful_tou_eligible_invoices; analysis-date comparison with the
      immediately preceding equal-length range. Previous zero or absent values yield no relative change.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median successful TOU aggregation
    title: '# of Successful TOU Aggregation - Median'
    type: single_value
    width: 6
  - col: 12
    explore: bre_na_tou
    fields:
    - bre_na_tou.gauge_label
    - bre_na_tou.tou_success_pct_average
    filters:
      bre_na_tou.date_range: 7 days ago for 7 days
      bre_na_tou.tou_mode: COMPLETE_BILLING_CYCLE
      bre_na_tou.delay_in_days: '1'
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_tou.date_range
      Pilot ID: bre_na_tou.pilot_id
      Pilot Name: bre_na_tou.pilot_name
      TOU Mode: bre_na_tou.tou_mode
      Delay (Days): bre_na_tou.delay_in_days
    model: bre_na
    name: na_4a_t04
    row: 3
    show_view_names: false
    title: Distribution - Success
    type: looker_column
    width: 6
    note_text: NA-4A-T04. AVG of report tou_success_pct, displayed as percent. Gauge range 0–100%; full at or above maximum and actual
      numeric value retained.
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
                "#148A78"
              ],
              [
                1,
                "#148A78"
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
            "name": "Success %"
          }
        ]
      }
  - col: 18
    explore: bre_na_tou
    fields:
    - bre_na_tou.gauge_label
    - bre_na_tou.tou_failure_pct_average
    filters:
      bre_na_tou.date_range: 7 days ago for 7 days
      bre_na_tou.tou_mode: COMPLETE_BILLING_CYCLE
      bre_na_tou.delay_in_days: '1'
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_tou.date_range
      Pilot ID: bre_na_tou.pilot_id
      Pilot Name: bre_na_tou.pilot_name
      TOU Mode: bre_na_tou.tou_mode
      Delay (Days): bre_na_tou.delay_in_days
    model: bre_na
    name: na_4a_t05
    row: 3
    show_view_names: false
    title: Distribution - Failure
    type: looker_column
    width: 6
    note_text: NA-4A-T05. AVG of report tou_failure_pct, displayed as percent. Gauge range 0–100%; full at or above maximum and actual
      numeric value retained.
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
                "#DC2626"
              ],
              [
                1,
                "#DC2626"
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
            "name": "Failure %"
          }
        ]
      }
  - name: na_4a_t06
    title: Daily TOU Pipeline Run Outcomes (Available for DESC, PNM-AMI, PSEG & OGE only)
    model: bre_na
    explore: bre_na_tou
    type: looker_column
    fields:
    - bre_na_tou.period_date
    - bre_na_tou.total_tou_eligible_invoices_sum
    - bre_na_tou.total_disagg_tou_invoices_sum
    - bre_na_tou.actual_total_tou_invoices_sum
    - bre_na_tou.successful_tou_eligible_invoices_sum
    - bre_na_tou.tou_success_pct_average
    filters:
      bre_na_tou.date_range: 7 days ago for 7 days
      bre_na_tou.period: Daily
      bre_na_tou.tou_mode: COMPLETE_BILLING_CYCLE
      bre_na_tou.delay_in_days: '1'
    listen:
      Time Period: bre_na_tou.date_range
      Pilot ID: bre_na_tou.pilot_id
      Pilot Name: bre_na_tou.pilot_name
      TOU Mode: bre_na_tou.tou_mode
      Delay (Days): bre_na_tou.delay_in_days
      Period: bre_na_tou.period
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_tou.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_tou.total_tou_eligible_invoices_sum: Expected Elegible BC#
      bre_na_tou.total_disagg_tou_invoices_sum: Successful TD#
      bre_na_tou.actual_total_tou_invoices_sum: Actual Eligible BC#
      bre_na_tou.successful_tou_eligible_invoices_sum: Successful BC#
      bre_na_tou.tou_success_pct_average: Success %
    series_types:
      bre_na_tou.tou_success_pct_average: line
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: NA-4A-T06. Four source count sums as bars, and unweighted AVG report success percentage as a line. Analysis-date
      filtering and Period grouping. Source availability title retained.
    y_axes:
    - label: Billing Cycles
      orientation: left
      series:
      - id: bre_na_tou.total_tou_eligible_invoices_sum
        axisId: bre_na_tou.total_tou_eligible_invoices_sum
        name: Expected Elegible BC#
      - id: bre_na_tou.total_disagg_tou_invoices_sum
        axisId: bre_na_tou.total_disagg_tou_invoices_sum
        name: Successful TD#
      - id: bre_na_tou.actual_total_tou_invoices_sum
        axisId: bre_na_tou.actual_total_tou_invoices_sum
        name: Actual Eligible BC#
      - id: bre_na_tou.successful_tou_eligible_invoices_sum
        axisId: bre_na_tou.successful_tou_eligible_invoices_sum
        name: Successful BC#
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Success %
      orientation: right
      series:
      - id: bre_na_tou.tou_success_pct_average
        axisId: bre_na_tou.tou_success_pct_average
        name: Success %
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_tou
    field: bre_na_tou.date_range
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
    explore: bre_na_tou
    field: bre_na_tou.period
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
  - name: TOU Mode
    title: TOU Mode
    type: field_filter
    default_value: COMPLETE_BILLING_CYCLE
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_tou
    field: bre_na_tou.tou_mode
    ui_config:
      type: tag_list
      display: popover
  - name: Delay (Days)
    title: Delay (Days)
    type: field_filter
    default_value: '1'
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_tou
    field: bre_na_tou.delay_in_days
    ui_config:
      type: tag_list
      display: popover
