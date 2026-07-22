---
- dashboard: itron_di_monitoring_dashboard_v2__production_pilots
  title: ITRON DI Monitoring Dashboard v2 - Production Pilots
  preferred_viewer: dashboards-next
  description: ''
  layout: newspaper
  tabs:
  - name: ''
    label: ''
  elements:
  - title: "% of active meters with no messages ingested [Primary Time Filter & Granularity]"
    name: "% of active meters with no messages ingested [Primary Time Filter & Granularity]"
    model: itron
    explore: itron_enrollment_files
    type: looker_line
    fields: [date_series.dynamic_date, itron_di_monitoring.count_meter_with_data,
      itron_enrollment_files.count_active_meters]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [itron_di_monitoring.count_meter_with_data, itron_enrollment_files.count_active_meters,
      percentage_of_active_meters_with_messages_received]
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 2
    col: 0
    width: 15
    height: 9
    tab_name: ''
  - title: Breakup of data points received per meter [Secondary Time Filter]
    name: Breakup of data points received per meter [Secondary Time Filter]
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_di_monitoring.total_entries_percentile_category,
      itron_enrollment_files.count_active_meters]
    pivots: [itron_di_monitoring.total_entries_percentile_category]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
    sorts: [date_series.dynamic_date, itron_di_monitoring.total_entries_percentile_category]
    limit: 500
    column_limit: 50
    x_axis_gridlines: true
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: true
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_active_meters,
            id: '00: 0 - itron_enrollment_files.count_active_meters', name: '00: 0'},
          {axisId: itron_enrollment_files.count_active_meters, id: '01: 1–48 - itron_enrollment_files.count_active_meters',
            name: '01: 1–48'}, {axisId: itron_enrollment_files.count_active_meters,
            id: '02: 49–96 - itron_enrollment_files.count_active_meters', name: '02:
              49–96'}, {axisId: itron_enrollment_files.count_active_meters, id: '03:
              97–144 - itron_enrollment_files.count_active_meters', name: '03: 97–144'},
          {axisId: itron_enrollment_files.count_active_meters, id: '04: 145–192 -
              itron_enrollment_files.count_active_meters', name: '04: 145–192'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '05: 193–240 -
              itron_enrollment_files.count_active_meters', name: '05: 193–240'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '06: 241–288 -
              itron_enrollment_files.count_active_meters', name: '06: 241–288'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '07: 289–336 -
              itron_enrollment_files.count_active_meters', name: '07: 289–336'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '08: 337–384 -
              itron_enrollment_files.count_active_meters', name: '08: 337–384'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '10: 433–480 -
              itron_enrollment_files.count_active_meters', name: '10: 433–480'}],
        showLabels: true, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    column_spacing_ratio:
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Displays the breakdown of total active meters in each bucket (Bucket
      derived from number of messages received per meter per day), based on the selected
      secondary time filter
    listen:
      Secondary Time Filter (Prod): date_series.continous_date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 2
    col: 15
    width: 9
    height: 9
    tab_name: ''
  - name: EV Charge Events
    type: text
    title_text: EV Charge Events
    body_text: ''
    row: 30
    col: 0
    width: 24
    height: 2
    tab_name: ''
  - title: Breakup of data points processed per meter [Secondary Time Filter]
    name: Breakup of data points processed per meter [Secondary Time Filter]
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_enrollment_files.count_active_meters,
      minutes_processed_data_category]
    pivots: [minutes_processed_data_category]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 1 month ago for 1 month
      itron_enrollment_files.active_meter: 'Yes'
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: dimension
      expression: case(when(is_null(${itron_consumption_data.data_category_15_min}),"Missing
        Data"),${itron_consumption_data.data_category_15_min})
      label: 15 Minutes Processed Data Category
      value_format:
      value_format_name:
      dimension: minutes_processed_data_category
      _kind_hint: measure
      _type_hint: string
    x_axis_gridlines: true
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: true
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_active_meters,
            id: '00: 0 - itron_enrollment_files.count_active_meters', name: '00: 0'},
          {axisId: itron_enrollment_files.count_active_meters, id: '01: 1–48 - itron_enrollment_files.count_active_meters',
            name: '01: 1–48'}, {axisId: itron_enrollment_files.count_active_meters,
            id: '02: 49–96 - itron_enrollment_files.count_active_meters', name: '02:
              49–96'}, {axisId: itron_enrollment_files.count_active_meters, id: '03:
              97–144 - itron_enrollment_files.count_active_meters', name: '03: 97–144'},
          {axisId: itron_enrollment_files.count_active_meters, id: '04: 145–192 -
              itron_enrollment_files.count_active_meters', name: '04: 145–192'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '05: 193–240 -
              itron_enrollment_files.count_active_meters', name: '05: 193–240'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '06: 241–288 -
              itron_enrollment_files.count_active_meters', name: '06: 241–288'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '07: 289–336 -
              itron_enrollment_files.count_active_meters', name: '07: 289–336'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '08: 337–384 -
              itron_enrollment_files.count_active_meters', name: '08: 337–384'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '10: 433–480 -
              itron_enrollment_files.count_active_meters', name: '10: 433–480'}],
        showLabels: true, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Secondary Time Filter (Prod): date_series.continous_date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 21
    col: 15
    width: 9
    height: 9
    tab_name: ''
  - name: Ingested Data Report
    type: text
    title_text: Ingested Data Report
    subtitle_text: Based on 3 Minutes Data Points Received from Utility
    body_text: ''
    row: 0
    col: 0
    width: 24
    height: 2
    tab_name: ''
  - name: Processes Data Report
    type: text
    title_text: Processes Data Report
    subtitle_text: Based on 15 Minutes Data Points from Bidgely
    body_text: ''
    row: 19
    col: 0
    width: 24
    height: 2
    tab_name: ''
  - title: Number of meters with EV-related messages received [Primary Time Filter
      & Granularity]
    name: Number of meters with EV-related messages received [Primary Time Filter
      & Granularity]
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_enrollment_files.count_active_meters,
      itron_appliance_data.count_unique_meter, itron_appliance_data.count_events]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      itron_appliance_data.corresponding_event_flag: ''
      date_series.continous_date: 1 month ago for 1 month
      itron_enrollment_files.active_meter: 'Yes'
      itron_appliance_data.appliance_id: '18'
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_types:
      itron_appliance_data.count_events: line
    series_labels:
      itron_appliance_data.count_unique_meter: Unique Meters with EV
      itron_appliance_data.count_events: Total EV Events
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [itron_enrollment_files.count_active_meters]
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 32
    col: 0
    width: 12
    height: 9
    tab_name: ''
  - title: EV Charge Events without its corresponding counterpart [Primary Time Filter
      & Granularity]
    name: EV Charge Events without its corresponding counterpart [Primary Time Filter
      & Granularity]
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_enrollment_files.count_active_meters,
      itron_appliance_data.count_unique_meter, itron_appliance_data.count_events]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      itron_appliance_data.corresponding_event_flag: ''
      itron_appliance_data.corresponding_event_flag_filter: 'TRUE'
      date_series.continous_date: 1 month ago for 1 month
      itron_enrollment_files.active_meter: 'Yes'
      itron_appliance_data.appliance_id: ''
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_types:
      itron_appliance_data.count_events: line
    series_labels:
      itron_appliance_data.count_events: Events without its corresponding counterpart
      itron_appliance_data.count_unique_meter: Unique Meters with events without its
        corresponding counterpart
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [itron_enrollment_files.count_active_meters]
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 32
    col: 12
    width: 12
    height: 9
    tab_name: ''
  - title: "% of active meters - Processed Data 15 Min [Primary Time Filter & Granularity] "
    name: "% of active meters - Processed Data 15 Min [Primary Time Filter & Granularity] "
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_enrollment_files.count_active_meters,
      minutes_processed_data_category]
    pivots: [minutes_processed_data_category]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 1 month ago for 1 month
      itron_enrollment_files.active_meter: 'Yes'
    sorts: [date_series.dynamic_date, minutes_processed_data_category]
    limit: 500
    column_limit: 50
    row_total: right
    dynamic_fields:
    - category: dimension
      expression: case(when(is_null(${itron_consumption_data.data_category_15_min}),"Missing
        Data"),${itron_consumption_data.data_category_15_min})
      label: 15 Minutes Processed Data Category
      value_format:
      value_format_name:
      dimension: minutes_processed_data_category
      _kind_hint: measure
      _type_hint: string
    - category: table_calculation
      label: Percent_calc
      value_format:
      value_format_name: percent_2
      calculation_type: percent_of_row
      table_calculation: percent_calc
      args:
      - itron_enrollment_files.count_active_meters
      _kind_hint: measure
      _type_hint: number
    x_axis_gridlines: true
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: true
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_active_meters,
            id: '00: 0 - itron_enrollment_files.count_active_meters', name: '00: 0'},
          {axisId: itron_enrollment_files.count_active_meters, id: '01: 1–48 - itron_enrollment_files.count_active_meters',
            name: '01: 1–48'}, {axisId: itron_enrollment_files.count_active_meters,
            id: '02: 49–96 - itron_enrollment_files.count_active_meters', name: '02:
              49–96'}, {axisId: itron_enrollment_files.count_active_meters, id: '03:
              97–144 - itron_enrollment_files.count_active_meters', name: '03: 97–144'},
          {axisId: itron_enrollment_files.count_active_meters, id: '04: 145–192 -
              itron_enrollment_files.count_active_meters', name: '04: 145–192'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '05: 193–240 -
              itron_enrollment_files.count_active_meters', name: '05: 193–240'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '06: 241–288 -
              itron_enrollment_files.count_active_meters', name: '06: 241–288'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '07: 289–336 -
              itron_enrollment_files.count_active_meters', name: '07: 289–336'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '08: 337–384 -
              itron_enrollment_files.count_active_meters', name: '08: 337–384'}, {
            axisId: itron_enrollment_files.count_active_meters, id: '10: 433–480 -
              itron_enrollment_files.count_active_meters', name: '10: 433–480'}],
        showLabels: true, showValues: true, unpinAxis: false, tickDensity: default,
        tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_types:
      incomplete_data - percent_calc: line
      Missing Data - percent_calc: line
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots:
      complete_data:
        is_entire_pivot_hidden: true
    defaults_version: 1
    hidden_fields: [itron_enrollment_files.count_active_meters]
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 21
    col: 0
    width: 15
    height: 9
    tab_name: ''
  - name: Configuration Messages
    type: text
    title_text: Configuration Messages
    body_text: ''
    row: 41
    col: 0
    width: 24
    height: 2
    tab_name: ''
  - title: Meter Enrollment Status
    name: Meter Enrollment Status
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_enrollment_files.count_enrolled_meters,
      itron_enrollment_files.count_unenrolled_meters]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 60 day ago for 60 day
      itron_enrollment_files.active_meter: ''
      itron_enrollment_files.pilot_id: '10112'
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_meters,
            id: Pecan ST - itron_enrollment_files.count_meters, name: Pecan ST - Itron
              Enrollment Files Count Meters}, {axisId: itron_enrollment_files.count_meters,
            id: TECO - itron_enrollment_files.count_meters, name: TECO - Itron Enrollment
              Files Count Meters}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: !!null '',
        orientation: right, series: [{axisId: percentage_of_active_meters_with_no_messages_received,
            id: Pecan ST - percentage_of_active_meters_with_no_messages_received,
            name: Pecan ST - Percentage of active meters with no messages received},
          {axisId: percentage_of_active_meters_with_no_messages_received, id: TECO
              - percentage_of_active_meters_with_no_messages_received, name: TECO
              - Percentage of active meters with no messages received}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
      itron_enrollment_files.count_unenrolled_meters: "#ffab40"
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 11
    col: 0
    width: 24
    height: 8
    tab_name: ''
  - title: Total Configuration Issued with Status
    name: Total Configuration Issued with Status
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_config_issued.count_users_config_issued,
      itron_config_issued.status]
    pivots: [itron_config_issued.status]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 60 day ago for 60 day
      itron_enrollment_files.active_meter: ''
      itron_enrollment_files.pilot_id: '10112'
    sorts: [date_series.dynamic_date, itron_config_issued.status]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: true
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_meters,
            id: Pecan ST - itron_enrollment_files.count_meters, name: Pecan ST - Itron
              Enrollment Files Count Meters}, {axisId: itron_enrollment_files.count_meters,
            id: TECO - itron_enrollment_files.count_meters, name: TECO - Itron Enrollment
              Files Count Meters}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: !!null '',
        orientation: right, series: [{axisId: percentage_of_active_meters_with_no_messages_received,
            id: Pecan ST - percentage_of_active_meters_with_no_messages_received,
            name: Pecan ST - Percentage of active meters with no messages received},
          {axisId: percentage_of_active_meters_with_no_messages_received, id: TECO
              - percentage_of_active_meters_with_no_messages_received, name: TECO
              - Percentage of active meters with no messages received}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 43
    col: 0
    width: 24
    height: 8
    tab_name: ''
  - title: Total Configuration confirmations Received
    name: Total Configuration confirmations Received
    model: itron
    explore: itron_enrollment_files
    type: looker_column
    fields: [date_series.dynamic_date, itron_config_confirmation.count_meter_config_confirmation,
      itron_config_confirmation.count_meters_per_day]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 60 day ago for 60 day
      itron_enrollment_files.active_meter: ''
      itron_enrollment_files.pilot_id: '10112'
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_config_confirmation.count_meters_per_day,
            id: itron_config_confirmation.count_meters_per_day, name: Count Meters
              per Day}, {axisId: itron_config_confirmation.count_meter_config_confirmation,
            id: itron_config_confirmation.count_meter_config_confirmation, name: Count
              Meter Config Confirmation}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_types:
      itron_config_confirmation.count_meter_config_confirmation: line
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 51
    col: 0
    width: 24
    height: 8
    tab_name: ''
  - title: Configuration Issued with >0 Retries
    name: Configuration Issued with >0 Retries
    model: itron
    explore: itron_enrollment_files
    type: looker_line
    fields: [date_series.dynamic_date, itron_config_issued.total_entries_sum, itron_config_issued.total_entries_with_retries_sum,
      itron_config_issued.sum_retry_counts]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 60 day ago for 60 day
      itron_enrollment_files.active_meter: ''
      itron_enrollment_files.pilot_id: '10112'
      itron_config_issued.status: ''
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_meters,
            id: Pecan ST - itron_enrollment_files.count_meters, name: Pecan ST - Itron
              Enrollment Files Count Meters}, {axisId: itron_enrollment_files.count_meters,
            id: TECO - itron_enrollment_files.count_meters, name: TECO - Itron Enrollment
              Files Count Meters}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: !!null '',
        orientation: right, series: [{axisId: percentage_of_active_meters_with_no_messages_received,
            id: Pecan ST - percentage_of_active_meters_with_no_messages_received,
            name: Pecan ST - Percentage of active meters with no messages received},
          {axisId: percentage_of_active_meters_with_no_messages_received, id: TECO
              - percentage_of_active_meters_with_no_messages_received, name: TECO
              - Percentage of active meters with no messages received}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    hidden_series: [404 - itron_config_issued.count_users_config_issued, COMPLETED
        - itron_config_issued.count_users_config_issued, CONFIG_GENERATED - itron_config_issued.count_users_config_issued,
      CANCELED - itron_config_issued.count_users_config_issued, PENDING - itron_config_issued.count_users_config_issued,
      PREPARING - itron_config_issued.count_users_config_issued, REQUEST_SENT - itron_config_issued.count_users_config_issued,
      RUNNING - itron_config_issued.count_users_config_issued, itron_config_issued.status___null
        - itron_config_issued.count_users_config_issued, PREPARED - itron_config_issued.count_users_config_issued,
      itron_config_issued.total_entries_sum, itron_config_issued.sum_retry_counts]
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
    ordering: none
    show_null_labels: false
    show_totals_labels: true
    show_silhouette: false
    totals_color: "#808080"
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 59
    col: 8
    width: 8
    height: 8
    tab_name: ''
  - title: Configuration Issued Failed on Daily Basis
    name: Configuration Issued Failed on Daily Basis
    model: itron
    explore: itron_enrollment_files
    type: looker_line
    fields: [date_series.dynamic_date, itron_config_issued.count_users_config_issued,
      itron_config_issued.status]
    pivots: [itron_config_issued.status]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 60 day ago for 60 day
      itron_enrollment_files.active_meter: ''
      itron_enrollment_files.pilot_id: '10112'
      itron_config_issued.status: ''
    sorts: [date_series.dynamic_date, itron_config_issued.status]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: true
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_meters,
            id: Pecan ST - itron_enrollment_files.count_meters, name: Pecan ST - Itron
              Enrollment Files Count Meters}, {axisId: itron_enrollment_files.count_meters,
            id: TECO - itron_enrollment_files.count_meters, name: TECO - Itron Enrollment
              Files Count Meters}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: !!null '',
        orientation: right, series: [{axisId: percentage_of_active_meters_with_no_messages_received,
            id: Pecan ST - percentage_of_active_meters_with_no_messages_received,
            name: Pecan ST - Percentage of active meters with no messages received},
          {axisId: percentage_of_active_meters_with_no_messages_received, id: TECO
              - percentage_of_active_meters_with_no_messages_received, name: TECO
              - Percentage of active meters with no messages received}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    hidden_series: [404 - itron_config_issued.count_users_config_issued, COMPLETED
        - itron_config_issued.count_users_config_issued, CONFIG_GENERATED - itron_config_issued.count_users_config_issued,
      CANCELED - itron_config_issued.count_users_config_issued, PENDING - itron_config_issued.count_users_config_issued,
      PREPARING - itron_config_issued.count_users_config_issued, REQUEST_SENT - itron_config_issued.count_users_config_issued,
      RUNNING - itron_config_issued.count_users_config_issued, itron_config_issued.status___null
        - itron_config_issued.count_users_config_issued, PREPARED - itron_config_issued.count_users_config_issued]
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 59
    col: 0
    width: 8
    height: 8
    tab_name: ''
  - title: Average time required for a successful configuration
    name: Average time required for a successful configuration
    model: itron
    explore: itron_enrollment_files
    type: looker_line
    fields: [date_series.dynamic_date, itron_config_issued.average_time_required_seconds,
      itron_config_issued.average_time_required_min, itron_config_issued.average_time_required_hh_mm_ss]
    filters:
      itron_enrollment_files.meter_id: ''
      date_series.timestamp_parameter: date
      date_series.continous_date: 60 day ago for 60 day
      itron_enrollment_files.active_meter: ''
      itron_enrollment_files.pilot_id: '10112'
      itron_config_issued.status: "-FAILED"
    sorts: [date_series.dynamic_date]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_meters,
            id: Pecan ST - itron_enrollment_files.count_meters, name: Pecan ST - Itron
              Enrollment Files Count Meters}, {axisId: itron_enrollment_files.count_meters,
            id: TECO - itron_enrollment_files.count_meters, name: TECO - Itron Enrollment
              Files Count Meters}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: !!null '',
        orientation: right, series: [{axisId: percentage_of_active_meters_with_no_messages_received,
            id: Pecan ST - percentage_of_active_meters_with_no_messages_received,
            name: Pecan ST - Percentage of active meters with no messages received},
          {axisId: percentage_of_active_meters_with_no_messages_received, id: TECO
              - percentage_of_active_meters_with_no_messages_received, name: TECO
              - Percentage of active meters with no messages received}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    hidden_series: [404 - itron_config_issued.count_users_config_issued, COMPLETED
        - itron_config_issued.count_users_config_issued, CONFIG_GENERATED - itron_config_issued.count_users_config_issued,
      CANCELED - itron_config_issued.count_users_config_issued, PENDING - itron_config_issued.count_users_config_issued,
      PREPARING - itron_config_issued.count_users_config_issued, REQUEST_SENT - itron_config_issued.count_users_config_issued,
      RUNNING - itron_config_issued.count_users_config_issued, itron_config_issued.status___null
        - itron_config_issued.count_users_config_issued, PREPARED - itron_config_issued.count_users_config_issued,
      itron_config_issued.total_entries_sum, itron_config_issued.sum_retry_counts]
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
    ordering: none
    show_null_labels: false
    show_totals_labels: true
    show_silhouette: false
    totals_color: "#808080"
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [itron_config_issued.average_time_required_seconds, itron_config_issued.average_time_required_min]
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): date_series.continous_date
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_enrollment_files.pilot_id
    row: 59
    col: 16
    width: 8
    height: 8
    tab_name: ''
  - name: Solar Generation
    type: text
    title_text: Solar Generation
    subtitle_text: ''
    body_text: ''
    row: 67
    col: 0
    width: 24
    height: 2
    tab_name: ''
  - title: Solar Generation Data
    name: Solar Generation Data
    model: itron
    explore: itron_enrollment_files
    type: looker_area
    fields: [itron_solar_uat_data.date_hour_time, itron_solar_uat_data.status, itron_solar_uat_data.distinct_uuid_count]
    pivots: [itron_solar_uat_data.status]
    filters:
      itron_enrollment_files.active_meter: ''
      itron_solar_uat_data.date: 30 days
      itron_solar_uat_data.pilot_id: ''
      itron_solar_uat_data.pilot_name: ''
      itron_solar_uat_data.status: missing,present
    sorts: [itron_solar_uat_data.date_hour_time desc, itron_solar_uat_data.status]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}"
      label: Percentage of active meters with messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_messages_received
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: 1-${itron_di_monitoring.count_meter_with_data}/${itron_enrollment_files.count_active_meters}
      label: Percentage of active meters with no messages received
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      table_calculation: percentage_of_active_meters_with_no_messages_received
      _type_hint: number
      is_disabled: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    show_totals_labels: true
    show_silhouette: false
    totals_color: "#808080"
    color_application:
      collection_id: bidgely-account-palette
      palette_id: bidgely-account-palette-categorical-0
      options:
        steps: 5
    y_axes: [{label: '', orientation: left, series: [{axisId: itron_enrollment_files.count_meters,
            id: Pecan ST - itron_enrollment_files.count_meters, name: Pecan ST - Itron
              Enrollment Files Count Meters}, {axisId: itron_enrollment_files.count_meters,
            id: TECO - itron_enrollment_files.count_meters, name: TECO - Itron Enrollment
              Files Count Meters}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}, {label: !!null '',
        orientation: right, series: [{axisId: percentage_of_active_meters_with_no_messages_received,
            id: Pecan ST - percentage_of_active_meters_with_no_messages_received,
            name: Pecan ST - Percentage of active meters with no messages received},
          {axisId: percentage_of_active_meters_with_no_messages_received, id: TECO
              - percentage_of_active_meters_with_no_messages_received, name: TECO
              - Percentage of active meters with no messages received}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, tickDensityCustom: 5,
        type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: first
      num_rows: 0
    hidden_series: [404 - itron_config_issued.count_users_config_issued, COMPLETED
        - itron_config_issued.count_users_config_issued, CONFIG_GENERATED - itron_config_issued.count_users_config_issued,
      CANCELED - itron_config_issued.count_users_config_issued, PENDING - itron_config_issued.count_users_config_issued,
      PREPARING - itron_config_issued.count_users_config_issued, REQUEST_SENT - itron_config_issued.count_users_config_issued,
      RUNNING - itron_config_issued.count_users_config_issued, itron_config_issued.status___null
        - itron_config_issued.count_users_config_issued, PREPARED - itron_config_issued.count_users_config_issued,
      itron_config_issued.total_entries_sum, itron_config_issued.sum_retry_counts]
    series_colors:
      Pecan ST - percentage_of_active_meters_with_no_messages_received: "#354053"
      missing - itron_solar_uat_data.distinct_uuid_count: "#F83E16"
      present - itron_solar_uat_data.distinct_uuid_count: "#EFEF42"
    ordering: none
    show_null_labels: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: []
    note_state: collapsed
    note_display: hover
    note_text: Based on the selected date granularity and primary time filter, this
      shows the percentage of active meters that received zero data during each corresponding
      time period
    listen:
      Primary Time Filter (Prod): itron_solar_uat_data.date
      Active Meter (Yes / No): itron_enrollment_files.active_meter
      Date Granularity: date_series.timestamp_parameter
      'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]': itron_solar_uat_data.pilot_id
    row: 69
    col: 0
    width: 24
    height: 11
    tab_name: ''
  filters:
  - name: 'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]'
    title: 'Pilot ID [10112 : TECO, 10118 : Pecan ST, 10223: LUMA, 10224: CNP]'
    type: field_filter
    default_value: '10112'
    allow_multiple_values: true
    required: false
    ui_config:
      type: checkboxes
      display: popover
    model: itron
    explore: itron_enrollment_files
    listens_to_filters: []
    field: itron_enrollment_files.pilot_id
  - name: Primary Time Filter (Prod)
    title: Primary Time Filter (Prod)
    type: field_filter
    default_value: 30 day
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
      options:
      - past
    model: itron
    explore: itron_enrollment_files
    listens_to_filters: []
    field: date_series.continous_date
  - name: Secondary Time Filter (Prod)
    title: Secondary Time Filter (Prod)
    type: field_filter
    default_value: yesterday
    allow_multiple_values: true
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
      options: []
    model: itron
    explore: itron_enrollment_files
    listens_to_filters: []
    field: date_series.continous_date
  - name: Active Meter (Yes / No)
    title: Active Meter (Yes / No)
    type: field_filter
    default_value: 'Yes'
    allow_multiple_values: true
    required: false
    ui_config:
      type: button_toggles
      display: overflow
    model: itron
    explore: itron_enrollment_files
    listens_to_filters: []
    field: itron_enrollment_files.active_meter
  - name: Date Granularity
    title: Date Granularity
    type: field_filter
    default_value: date
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: overflow
    model: itron
    explore: itron_enrollment_files
    listens_to_filters: []
    field: date_series.timestamp_parameter
