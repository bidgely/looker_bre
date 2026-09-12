# Dynamic suggestion values only; query-time UNION, never persisted.
include: "/views/bre/bre_ingestion_audit.view.lkml"
include: "/views/bre/bre_post_ingestion.view.lkml"
include: "/views/bre/bre_ingestion_failures.view.lkml"
view: bre_ingestion_filter_values {
  derived_table: {
    sql:
      SELECT DISTINCT ingestion_type
      FROM (
        SELECT ingestion_type FROM ${bre_ingestion_audit.SQL_TABLE_NAME}
        UNION
        SELECT ingestion_type FROM ${bre_post_ingestion.SQL_TABLE_NAME}
        UNION
        SELECT ingestion_type FROM ${bre_ingestion_failures.SQL_TABLE_NAME}
      ) types
      WHERE ingestion_type IS NOT NULL
    ;;
  }
  dimension: ingestion_type {
    primary_key: yes
    hidden: yes
    type: string
    description: "Distinct raw ingestion types across the three Ingestion source families."
    sql: ${TABLE}.ingestion_type ;;
  }
  dimension: file_type {
    type: string
    description: "Dynamic File Type choices with BILLING and OPOWER combined as Billing."
    sql: CASE WHEN ${ingestion_type} IN ('BILLING', 'OPOWER') THEN 'Billing' WHEN ${ingestion_type} = 'CONSUMPTION' THEN 'Consumption' WHEN ${ingestion_type} = 'USER_META' THEN 'User_Meta' ELSE ${ingestion_type} END ;;
  }
}
