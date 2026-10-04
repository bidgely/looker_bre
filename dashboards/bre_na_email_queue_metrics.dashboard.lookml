# NA Email 6b: data_studio_files/bre_na_email_implementation.md
---
- crossfilter_enabled: false
  dashboard: bre_na_email_queue_metrics
  description: NA Email 6b. Separate queue metrics dashboard; native Looker and original-report validation pending.
  elements:
  - name: na_6b_t01
    title: Key KPIs - Environment Health Score (A composite score (0-100) combining success rate, backlog, and latency)
    model: bre_na
    explore: bre_na_email_queue_health
    type: single_value
    fields:
    - bre_na_email_queue_health.health_score_average
    filters:
      bre_na_email_queue_health.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_health.module_name
      Queue Name: bre_na_email_queue_health.queue_name
      Queue Type: bre_na_email_queue_health.queue_type
      Environment: bre_na_email_queue_health.environment
      Time Period: bre_na_email_queue_health.date_range
    row: 0
    col: 0
    width: 8
    height: 4
    limit: 1
    show_view_names: false
    note_text: 'NA-6B-T01. Email module scope: Emailer. Source-row average health score.'
    note_display: hover
    note_state: collapsed
  - name: na_6b_t02
    title: Key KPIs - Total Message Volume (Measures the overall data ingestion activity, indicating system workload)
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: looker_line
    fields:
    - bre_na_email_queue_hourly.bucket_hour
    - bre_na_email_queue_hourly.total_messages_received_sum
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 0
    col: 8
    width: 16
    height: 4
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T02. Email module scope: Emailer. Hourly sum of received messages.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_6b_t03
    title: Key KPIs - Msg Processing Success Rate (Percentage of messages successfully processed)
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: single_value
    fields:
    - bre_na_email_queue_hourly.success_rate_average
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 4
    col: 0
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_text: 'NA-6B-T03. Email module scope: Emailer. Source-row average success rate, as documented.'
    note_display: hover
    note_state: collapsed
    single_value_title: Rate
  - name: na_6b_t04
    title: Key KPIs - Queue Backlog Volume (Average number of messages waiting in queues. Highlights potential delays
      or bottlenecks in processing.)
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: single_value
    fields:
    - bre_na_email_queue_hourly.avg_queue_backlog_average
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 4
    col: 12
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_text: 'NA-6B-T04. Email module scope: Emailer. Average source hourly queue backlog.'
    note_display: hover
    note_state: collapsed
  - name: na_6b_t05
    title: Trends (Line charts by hour) - Message Volume Over Time
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: looker_line
    fields:
    - bre_na_email_queue_hourly.bucket_hour
    - bre_na_email_queue_hourly.total_messages_received_sum
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 8
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T05. Email module scope: Emailer. Hourly sum of received messages.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_6b_t06
    title: Trends (Line charts by hour) - Backlog Volume Over Time
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: looker_line
    fields:
    - bre_na_email_queue_hourly.bucket_hour
    - bre_na_email_queue_hourly.avg_queue_backlog_average
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 8
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T06. Email module scope: Emailer. Average source hourly queue backlog.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_6b_t07
    title: Trends (Line charts by hour) - Oldest Message Age Over Time
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: looker_line
    fields:
    - bre_na_email_queue_hourly.bucket_hour
    - bre_na_email_queue_hourly.max_latency_days_max
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 15
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T07. Email module scope: Emailer. Maximum source latency in days.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_6b_t08
    title: Trends (Line charts by hour) - Health Score by Queue Name
    model: bre_na
    explore: bre_na_email_queue_health
    type: looker_column
    fields:
    - bre_na_email_queue_health.bucket_date
    - bre_na_email_queue_health.queue_name
    - bre_na_email_queue_health.health_score_average
    filters:
      bre_na_email_queue_health.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_health.module_name
      Queue Name: bre_na_email_queue_health.queue_name
      Queue Type: bre_na_email_queue_health.queue_type
      Environment: bre_na_email_queue_health.environment
      Time Period: bre_na_email_queue_health.date_range
    row: 15
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T08. Email module scope: Emailer. Source-row average daily health score, stacked by queue
      name.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_health.bucket_date
    show_null_points: true
    legend_position: center
    x_axis_scale: time
    pivots:
    - bre_na_email_queue_health.queue_name
    stacking: normal
    column_limit: 50
  - name: na_6b_t09
    title: Trends (Line charts by hour) - Processing Efficiency
    model: bre_na
    explore: bre_na_email_queue_daily
    type: looker_line
    fields:
    - bre_na_email_queue_daily.bucket_date
    - bre_na_email_queue_daily.empty_receives_ratio_average
    filters:
      bre_na_email_queue_daily.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_daily.module_name
      Queue Name: bre_na_email_queue_daily.queue_name
      Queue Type: bre_na_email_queue_daily.queue_type
      Environment: bre_na_email_queue_daily.environment
      Time Period: bre_na_email_queue_daily.date_range
    row: 22
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T09. Email module scope: Emailer. Average daily empty-receives percentage. SRC-24 is daily;
      no hourly field exists.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_daily.bucket_date
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_6b_t10
    title: Trends (Line charts by hour) - Delayed Messages Impact
    model: bre_na
    explore: bre_na_email_queue_hourly
    type: looker_line
    fields:
    - bre_na_email_queue_hourly.bucket_hour
    - bre_na_email_queue_hourly.delayed_messages_sum
    filters:
      bre_na_email_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_email_queue_hourly.module_name
      Queue Name: bre_na_email_queue_hourly.queue_name
      Queue Type: bre_na_email_queue_hourly.queue_type
      Environment: bre_na_email_queue_hourly.environment
      Time Period: bre_na_email_queue_hourly.date_range
    row: 22
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: 'NA-6B-T10. Email module scope: Emailer. Sum of source delayed_messages.'
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_email_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
    series_labels:
      bre_na_email_queue_hourly.delayed_messages_sum: Delayed Messages
  filters:
  - name: Time Period
    title: Time Period
    type: field_filter
    default_value: 7 days ago for 7 days
    allow_multiple_values: false
    required: false
    model: bre_na
    explore: bre_na_email_queue_hourly
    field: bre_na_email_queue_hourly.date_range
    ui_config:
      type: advanced
      display: popover
  - name: Environment
    title: Environment
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_email_queue_hourly
    field: bre_na_email_queue_hourly.environment
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
    explore: bre_na_email_queue_hourly
    field: bre_na_email_queue_hourly.module_name
    ui_config:
      type: tag_list
      display: popover
  - name: Queue Name
    title: Queue Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_email_queue_hourly
    field: bre_na_email_queue_hourly.queue_name
    ui_config:
      type: tag_list
      display: popover
  - name: Queue Type
    title: Queue Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_email_queue_hourly
    field: bre_na_email_queue_hourly.queue_type
    ui_config:
      type: tag_list
      display: popover
  layout: newspaper
  preferred_viewer: dashboards-next
  title: BRE NA — Email Queue Metrics
