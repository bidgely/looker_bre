# NA NBI: data_studio_files/bre_na_nbi_implementation.md
---
- dashboard: bre_na_nbi_governance
  title: BRE NA — NBI Governance
  description: NA Data Governance NBI. Draft pending native Looker and original-report validation.
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
    name: na_8a_t01
    note_display: hover
    note_state: collapsed
    note_text: 'NA-8A-T01. Source definitions and validation notes: bre_na_nbi_implementation.md.'
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
    explore: bre_na_nbi_generation
    fields:
    - bre_na_nbi_generation.successful_users_selected_average
    - bre_na_nbi_generation.successful_users_average_change
    - bre_na_nbi_generation.successful_users_previous_average
    filters:
      bre_na_nbi_generation.comparison_date_range: 7 days ago for 7 days
      bre_na_nbi_generation.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_nbi_generation.successful_users_previous_average
    limit: 1
    listen:
      Time Period: bre_na_nbi_generation.comparison_date_range
      Pilot ID: bre_na_nbi_generation.pilot_id
      Pilot Name: bre_na_nbi_generation.pilot_name
    model: bre_na
    name: na_8a_t02
    note_display: hover
    note_state: collapsed
    note_text: 'NA-8A-T02. Source definitions and validation notes: bre_na_nbi_implementation.md.'
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average NBI insight generation
    title: '# of NBI Insight Generation - Average'
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_nbi_generation
    fields:
    - bre_na_nbi_generation.successful_users_selected_median
    - bre_na_nbi_generation.successful_users_median_change
    - bre_na_nbi_generation.successful_users_previous_median
    filters:
      bre_na_nbi_generation.comparison_date_range: 7 days ago for 7 days
      bre_na_nbi_generation.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_nbi_generation.successful_users_previous_median
    limit: 1
    listen:
      Time Period: bre_na_nbi_generation.comparison_date_range
      Pilot ID: bre_na_nbi_generation.pilot_id
      Pilot Name: bre_na_nbi_generation.pilot_name
    model: bre_na
    name: na_8a_t03
    note_display: hover
    note_state: collapsed
    note_text: 'NA-8A-T03. Source definitions and validation notes: bre_na_nbi_implementation.md.'
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median NBI insight generation
    title: '# of NBI Insight Generation - Median'
    type: single_value
    width: 6
  - col: 12
    explore: bre_na_nbi_generation
    fields:
    - bre_na_nbi_generation.gauge_label
    - bre_na_nbi_generation.nbi_200_error_pct_average
    filters:
      bre_na_nbi_generation.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_nbi_generation.date_range
      Pilot ID: bre_na_nbi_generation.pilot_id
      Pilot Name: bre_na_nbi_generation.pilot_name
    model: bre_na
    name: na_8a_t04
    row: 3
    show_view_names: false
    title: Failure Distribution - Format Error
    type: looker_column
    width: 6
    note_text: NA-8A-T04. AVG(error 200 count / total failures) displayed as percent. Zero total failures remains
      missing. Range 0–100; full arc at maximum with actual number.
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
  - col: 18
    explore: bre_na_nbi_generation
    fields:
    - bre_na_nbi_generation.gauge_label
    - bre_na_nbi_generation.nbi_300_error_pct_average
    filters:
      bre_na_nbi_generation.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_nbi_generation.date_range
      Pilot ID: bre_na_nbi_generation.pilot_id
      Pilot Name: bre_na_nbi_generation.pilot_name
    model: bre_na
    name: na_8a_t05
    row: 3
    show_view_names: false
    title: Failure Distribution - Value Error
    type: looker_column
    width: 6
    note_text: NA-8A-T05. AVG(error 300 count / total failures) displayed as percent. Zero total failures remains
      missing. Range 0–100; full arc at maximum with actual number.
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
  - name: na_8a_t06
    title: Daily NBI Generation Statistics
    model: bre_na
    explore: bre_na_nbi_generation
    type: looker_column
    fields:
    - bre_na_nbi_generation.period_date
    - bre_na_nbi_generation.total_users_nbi_generated_average
    - bre_na_nbi_generation.total_users_successful_average
    - bre_na_nbi_generation.nbi_success_pct_average
    filters:
      bre_na_nbi_generation.date_range: 7 days ago for 7 days
      bre_na_nbi_generation.period: Daily
    listen:
      Time Period: bre_na_nbi_generation.date_range
      Pilot ID: bre_na_nbi_generation.pilot_id
      Pilot Name: bre_na_nbi_generation.pilot_name
      Period: bre_na_nbi_generation.period
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_nbi_generation.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_nbi_generation.total_users_nbi_generated_average: NBI Users Base
      bre_na_nbi_generation.total_users_successful_average: 'Successful Generation #'
      bre_na_nbi_generation.nbi_success_pct_average: NBI Success %
    series_types:
      bre_na_nbi_generation.nbi_success_pct_average: line
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: 'NA-8A-T06. Source definitions and validation notes: bre_na_nbi_implementation.md.'
    y_axes:
    - label: Users
      orientation: left
      series:
      - id: bre_na_nbi_generation.total_users_nbi_generated_average
        name: NBI Users Base
      - id: bre_na_nbi_generation.total_users_successful_average
        name: 'Successful Generation #'
      showLabels: true
      showValues: true
    - label: Success %
      orientation: right
      series:
      - id: bre_na_nbi_generation.nbi_success_pct_average
        name: NBI Success %
      showLabels: true
      showValues: true
    series_colors:
      bre_na_nbi_generation.total_users_nbi_generated_average: '#5B8FF9'
      bre_na_nbi_generation.total_users_successful_average: '#148A78'
      bre_na_nbi_generation.nbi_success_pct_average: '#F6BD16'
  - name: na_8a_t07
    title: Daily NBI Users Count With Generic Tag
    model: bre_na
    explore: bre_na_nbi_generic_tags
    type: looker_line
    fields:
    - bre_na_nbi_generic_tags.period_date
    - bre_na_nbi_generic_tags.total_nbi_users_with_generic_tag_sum
    filters:
      bre_na_nbi_generic_tags.date_range: 7 days ago for 7 days
      bre_na_nbi_generic_tags.period: Daily
    listen:
      Time Period: bre_na_nbi_generic_tags.date_range
      Pilot ID: bre_na_nbi_generic_tags.pilot_id
      Pilot Name: bre_na_nbi_generic_tags.pilot_name
      Period: bre_na_nbi_generic_tags.period
    row: 15
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_nbi_generic_tags.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    stacking: ''
    note_display: hover
    note_state: collapsed
    note_text: NA-8A-T07. SUM of generic-tag users by selected analysis-date period.
  - name: na_8a_t08
    title: Daily Top NBI Failure Reasons Statistics
    model: bre_na
    explore: bre_na_nbi_generation
    type: looker_column
    fields:
    - bre_na_nbi_generation.period_date
    - bre_na_nbi_generation.total_users_with_200_errorcode_average
    - bre_na_nbi_generation.total_users_with_300_errorcode_average
    filters:
      bre_na_nbi_generation.date_range: 7 days ago for 7 days
      bre_na_nbi_generation.period: Daily
    listen:
      Time Period: bre_na_nbi_generation.date_range
      Pilot ID: bre_na_nbi_generation.pilot_id
      Pilot Name: bre_na_nbi_generation.pilot_name
      Period: bre_na_nbi_generation.period
    row: 23
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_nbi_generation.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    stacking: normal
    note_display: hover
    note_state: collapsed
    note_text: NA-8A-T08. Average source counts for the two documented error categories; no additional top-N filter.
    series_labels:
      bre_na_nbi_generation.total_users_with_200_errorcode_average: NBI_FORMAT_ERROR (200)
      bre_na_nbi_generation.total_users_with_300_errorcode_average: NBI_VALUE_ERROR (300)
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_nbi_generation
    field: bre_na_nbi_generation.date_range
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
    explore: bre_na_nbi_generation
    field: bre_na_nbi_generation.period
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
