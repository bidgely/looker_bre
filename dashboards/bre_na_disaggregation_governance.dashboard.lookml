# NA Disaggregation: data_studio_files/bre_na_disaggregation_implementation.md
---
- dashboard: bre_na_disaggregation_governance
  title: BRE NA — 3a — Data Governance Disaggregation
  description: NA Disaggregation governance. Draft pending Looker and source-report validation.
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
    name: na_3a_t01
    note_display: hover
    note_state: collapsed
    note_text: NA-3A-T01. Latest snapshot per pilot followed by reporting-date filtering. Meter, Fuel, and Module
      filters are absent from Active Users.
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
    explore: bre_na_disaggregation_invoices
    fields:
    - bre_na_disaggregation_invoices.invoices_selected_average
    - bre_na_disaggregation_invoices.invoices_average_change
    - bre_na_disaggregation_invoices.invoices_previous_average
    filters:
      bre_na_disaggregation_invoices.comparison_date_range: 7 days ago for 7 days
      bre_na_disaggregation_invoices.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_disaggregation_invoices.invoices_previous_average
    limit: 1
    listen:
      Time Period: bre_na_disaggregation_invoices.comparison_date_range
      Pilot ID: bre_na_disaggregation_invoices.pilot_id
      Pilot Name: bre_na_disaggregation_invoices.pilot_name
      Meter Type: bre_na_disaggregation_invoices.meter_type
      Fuel Type: bre_na_disaggregation_invoices.fuel_type
      Module Name: bre_na_disaggregation_invoices.module_name
    model: bre_na
    name: na_3a_t02
    note_display: hover
    note_state: collapsed
    note_text: NA-3A-T02. Source-row average of total_invoices after SRC-04 latest-row selection; compares analysis
      dates with preceding equal-length period.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Average invoices
    title: '# of Invoices Per Day - Average'
    type: single_value
    width: 6
  - col: 6
    comparison_label: vs previous equal-length period
    comparison_type: change
    explore: bre_na_disaggregation_invoices
    fields:
    - bre_na_disaggregation_invoices.invoices_selected_median
    - bre_na_disaggregation_invoices.invoices_median_change
    - bre_na_disaggregation_invoices.invoices_previous_median
    filters:
      bre_na_disaggregation_invoices.comparison_date_range: 7 days ago for 7 days
      bre_na_disaggregation_invoices.in_comparison_window: 'Yes'
    height: 4
    hidden_fields:
    - bre_na_disaggregation_invoices.invoices_previous_median
    limit: 1
    listen:
      Time Period: bre_na_disaggregation_invoices.comparison_date_range
      Pilot ID: bre_na_disaggregation_invoices.pilot_id
      Pilot Name: bre_na_disaggregation_invoices.pilot_name
      Meter Type: bre_na_disaggregation_invoices.meter_type
      Fuel Type: bre_na_disaggregation_invoices.fuel_type
      Module Name: bre_na_disaggregation_invoices.module_name
    model: bre_na
    name: na_3a_t03
    note_display: hover
    note_state: collapsed
    note_text: NA-3A-T03. Source-row median of total_invoices after SRC-04 latest-row selection; compares analysis
      dates with preceding equal-length period.
    row: 3
    show_comparison: true
    show_comparison_label: true
    show_single_value_title: true
    show_view_names: false
    single_value_title: Median invoices
    title: '# of Invoices Per Day - Median'
    type: single_value
    width: 6
  - col: 12
    explore: bre_na_disaggregation_invoices
    fields:
    - bre_na_disaggregation_invoices.gauge_label
    - bre_na_disaggregation_invoices.success_t7_sum
    filters:
      bre_na_disaggregation_invoices.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_disaggregation_invoices.date_range
      Pilot ID: bre_na_disaggregation_invoices.pilot_id
      Pilot Name: bre_na_disaggregation_invoices.pilot_name
      Meter Type: bre_na_disaggregation_invoices.meter_type
      Fuel Type: bre_na_disaggregation_invoices.fuel_type
      Module Name: bre_na_disaggregation_invoices.module_name
    model: bre_na
    name: na_3a_t04
    row: 3
    show_view_names: false
    title: Average Success % - T+7 day
    type: looker_column
    width: 6
    note_text: NA-3A-T04. SUM of source successful_itemisation_pct for SCHEDULED rows with delay_in_days = 7, as
      documented despite the Average title. Gauge fills at 100%; values above 100 remain visible.
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
            "name": "T+7 success %"
          }
        ]
      }
  - col: 18
    explore: bre_na_disaggregation_invoices
    fields:
    - bre_na_disaggregation_invoices.gauge_label
    - bre_na_disaggregation_invoices.success_t2_sum
    filters:
      bre_na_disaggregation_invoices.date_range: 7 days ago for 7 days
    height: 4
    limit: 1
    listen:
      Time Period: bre_na_disaggregation_invoices.date_range
      Pilot ID: bre_na_disaggregation_invoices.pilot_id
      Pilot Name: bre_na_disaggregation_invoices.pilot_name
      Meter Type: bre_na_disaggregation_invoices.meter_type
      Fuel Type: bre_na_disaggregation_invoices.fuel_type
      Module Name: bre_na_disaggregation_invoices.module_name
    model: bre_na
    name: na_3a_t05
    row: 3
    show_view_names: false
    title: Average Success % - T+2 day
    type: looker_column
    width: 6
    note_text: NA-3A-T05. SUM of source successful_itemisation_pct for SCHEDULED rows with delay_in_days = 2, as
      documented despite the Average title. Gauge fills at 100%; values above 100 remain visible.
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
            "name": "T+2 success %"
          }
        ]
      }
  - name: na_3a_t06
    title: Daily Invoice Ingestion vs Hybrid Disagg Processing Success %
    model: bre_na
    explore: bre_na_disaggregation_invoices_new
    type: looker_line
    fields:
    - bre_na_disaggregation_invoices_new.period_date
    - bre_na_disaggregation_invoices_new.total_invoices_max
    - bre_na_disaggregation_invoices_new.success_t2_average
    - bre_na_disaggregation_invoices_new.success_t7_average
    - bre_na_disaggregation_invoices_new.success_correction_max
    filters:
      bre_na_disaggregation_invoices_new.date_range: 7 days ago for 7 days
      bre_na_disaggregation_invoices_new.period: Daily
    listen:
      Time Period: bre_na_disaggregation_invoices_new.date_range
      Pilot ID: bre_na_disaggregation_invoices_new.pilot_id
      Pilot Name: bre_na_disaggregation_invoices_new.pilot_name
      Meter Type: bre_na_disaggregation_invoices_new.meter_type
      Fuel Type: bre_na_disaggregation_invoices_new.fuel_type
      Module Name: bre_na_disaggregation_invoices_new.module_name
      Period: bre_na_disaggregation_invoices_new.period
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_disaggregation_invoices_new.period_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_disaggregation_invoices_new.total_invoices_max: 'Total Invoice #'
      bre_na_disaggregation_invoices_new.success_t2_average: T+2 Success %
      bre_na_disaggregation_invoices_new.success_t7_average: T+7 Success %
      bre_na_disaggregation_invoices_new.success_correction_max: Correction Success %
    note_display: hover
    note_state: collapsed
    note_text: NA-3A-T06. MAX total invoices, AVG T+2 and T+7 success, and MAX ADHOC correction success. Analysis-date
      filter follows source latest-row selection.
    y_axes:
    - label: Invoices
      orientation: left
      series:
      - id: bre_na_disaggregation_invoices_new.total_invoices_max
        axisId: bre_na_disaggregation_invoices_new.total_invoices_max
        name: 'Total Invoice #'
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Success %
      orientation: right
      series:
      - id: bre_na_disaggregation_invoices_new.success_t2_average
        axisId: bre_na_disaggregation_invoices_new.success_t2_average
        name: T+2 Success %
      - id: bre_na_disaggregation_invoices_new.success_t7_average
        axisId: bre_na_disaggregation_invoices_new.success_t7_average
        name: T+7 Success %
      - id: bre_na_disaggregation_invoices_new.success_correction_max
        axisId: bre_na_disaggregation_invoices_new.success_correction_max
        name: Correction Success %
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  - name: na_3a_t07
    title: Daily Disagg Quality Report (Only for Elec AMI**)
    model: bre_na
    explore: bre_na_disaggregation_quality
    type: looker_line
    fields:
    - bre_na_disaggregation_quality.analysis_date
    - bre_na_disaggregation_quality.appliances_kwh_variance_pct_1_average
    - bre_na_disaggregation_quality.appliances_kwh_variance_pct_2_average
    - bre_na_disaggregation_quality.total_cost_deviation_pct_1_average
    - bre_na_disaggregation_quality.total_cost_deviation_pct_2_average
    - bre_na_disaggregation_quality.cost_per_kwh_deviation_pct_average
    - bre_na_disaggregation_quality.seasonal_appliance_usage_deviation_pct_average
    - bre_na_disaggregation_quality.ao_pct_non_tou_average
    - bre_na_disaggregation_quality.sh_pct_non_tou_average
    - bre_na_disaggregation_quality.other_pct_non_tou_average
    - bre_na_disaggregation_quality.solar_pct_non_tou_average
    - bre_na_disaggregation_quality.single_appliance_domination_deviation_pct_average
    - bre_na_disaggregation_quality.missing_dwelliing_pct_average
    filters:
      bre_na_disaggregation_quality.date_range: 7 days ago for 7 days
      bre_na_disaggregation_quality.period: Daily
    listen:
      Time Period: bre_na_disaggregation_quality.date_range
      Pilot ID: bre_na_disaggregation_quality.pilot_id
      Pilot Name: bre_na_disaggregation_quality.pilot_name
      Meter Type: bre_na_disaggregation_quality.meter_type
      Fuel Type: bre_na_disaggregation_quality.fuel_type
      Period: bre_na_disaggregation_quality.period
    row: 15
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_disaggregation_quality.analysis_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_disaggregation_quality.appliances_kwh_variance_pct_1_average: $/KWH Across Appliances %Var (Flag 1)
      bre_na_disaggregation_quality.appliances_kwh_variance_pct_2_average: $/KWH Across Appliances %Var (Flag 2)
      bre_na_disaggregation_quality.total_cost_deviation_pct_1_average: Total $ Across Appliances Out of Range (Flag
        1)
      bre_na_disaggregation_quality.total_cost_deviation_pct_2_average: Total $ Across Appliances Out of Range (Flag
        2)
      bre_na_disaggregation_quality.cost_per_kwh_deviation_pct_average: $/KWH Out of Range
      bre_na_disaggregation_quality.seasonal_appliance_usage_deviation_pct_average: Non-Seasonal Appliance Usage
      bre_na_disaggregation_quality.ao_pct_non_tou_average: AO I/O % Dev
      bre_na_disaggregation_quality.sh_pct_non_tou_average: SH I/O % Dev
      bre_na_disaggregation_quality.other_pct_non_tou_average: Other I/O % Dev
      bre_na_disaggregation_quality.solar_pct_non_tou_average: Zero Solar Estimation
      bre_na_disaggregation_quality.single_appliance_domination_deviation_pct_average: Single Appliance Domination
      bre_na_disaggregation_quality.missing_dwelliing_pct_average: Missing Dwelling Type
    note_display: hover
    note_state: collapsed
    note_text: NA-3A-T07. AVG of twelve source quality fields. Period selects original preaggregated source rows;
      reporting-date filter runs afterward. Module is absent from this source. Elec AMI title is retained; no undocumented
      fixed meter/fuel filter is invented.
  - name: na_3a_t08
    title: Daily Top Disagg/Itemisation Failure Reasons
    model: bre_na
    explore: bre_na_disaggregation_failures
    type: looker_column
    fields:
    - bre_na_disaggregation_failures.analysis_date
    - bre_na_disaggregation_failures.failure_percentage_average
    - bre_na_disaggregation_failures.failure_reason
    filters:
      bre_na_disaggregation_failures.date_range: 7 days ago for 7 days
      bre_na_disaggregation_failures.period: Daily
      bre_na_disaggregation_failures.source_rank: <=3
    listen:
      Time Period: bre_na_disaggregation_failures.date_range
      Pilot ID: bre_na_disaggregation_failures.pilot_id
      Pilot Name: bre_na_disaggregation_failures.pilot_name
      Meter Type: bre_na_disaggregation_failures.meter_type
      Fuel Type: bre_na_disaggregation_failures.fuel_type
      Module Name: bre_na_disaggregation_failures.module_name
      Period: bre_na_disaggregation_failures.period
    row: 23
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_disaggregation_failures.analysis_date
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_disaggregation_failures.failure_percentage_average: Failure %
    note_display: hover
    note_state: collapsed
    pivots:
    - bre_na_disaggregation_failures.failure_reason
    stacking: normal
    note_text: NA-3A-T08. AVG failure_percentage, stacked by raw failure_reason. Original rank <= 3; meter/fuel/module/date
      filters apply after ranking. Period selects the original source period rows.
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_disaggregation_invoices
    field: bre_na_disaggregation_invoices.date_range
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
    explore: bre_na_disaggregation_invoices
    field: bre_na_disaggregation_invoices.period
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
  - name: Meter Type
    title: Meter Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_invoices_new
    field: bre_na_disaggregation_invoices_new.meter_type
    ui_config:
      type: tag_list
      display: popover
  - name: Fuel Type
    title: Fuel Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_invoices_new
    field: bre_na_disaggregation_invoices_new.fuel_type
    ui_config:
      type: tag_list
      display: popover
  - name: Module Name
    title: Module Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_invoices_new
    field: bre_na_disaggregation_invoices_new.module_name
    ui_config:
      type: tag_list
      display: popover
