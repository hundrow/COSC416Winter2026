-- FILE NAME SUGGESTION: db_snapshot_for_agents.sql
-- Run as a user with dictionary access (SELECT_CATALOG_ROLE is usually enough for most views below).
-- Recommended in SQLcl; works in SQL Developer with minor formatting differences.

-- ========== Session setup ==========
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON
SET PAGESIZE 50000
SET LINESIZE 32767
SET LONG 100000
SET LONGCHUNKSIZE 100000
SET TRIMSPOOL ON
SET TERMOUT ON
SET VERIFY OFF

-- SQLcl supports this directly. In SQL Developer, you can keep it or remove it.
SET SQLFORMAT csv

-- Change this path if needed
DEFINE SNAP_DIR = '/home/ajohnson/BCIS/okc2025-26/cosc416/CODE/COSC416Winter2026/docs/db_snapshot'

PROMPT Creating output folder path (ensure it exists if your client does not auto-create)

-- ========== 0) Environment ==========
SPOOL "&&SNAP_DIR./00_environment.csv"
SELECT name AS db_name, dbid, cdb, log_mode, open_mode FROM v$database;
SELECT instance_name, host_name, version, startup_time, status FROM v$instance;
SELECT banner_full FROM v$version ORDER BY banner_full;
SPOOL OFF

-- ========== 1) Init parameters ==========
SPOOL "&&SNAP_DIR./01_parameters_key.csv"
SELECT name, value, isdefault
FROM v$parameter
WHERE name IN (
  'memory_target',
  'memory_max_target',
  'sga_target',
  'sga_max_size',
  'pga_aggregate_target',
  'db_cache_size',
  'shared_pool_size',
  'large_pool_size',
  'processes',
  'sessions',
  'open_cursors',
  'optimizer_mode',
  'db_block_size',
  'undo_tablespace',
  'undo_retention',
  'awr_pdb_autoflush_enabled'
)
ORDER BY name;
SPOOL OFF

SPOOL "&&SNAP_DIR./02_parameters_nondefault.csv"
SELECT name, value, isdefault
FROM v$parameter
WHERE isdefault = 'FALSE'
ORDER BY name;
SPOOL OFF

SPOOL "&&SNAP_DIR./03_spparameter_explicit.csv"
SELECT name, value, isspecified
FROM v$spparameter
WHERE isspecified = 'TRUE'
ORDER BY name;
SPOOL OFF

-- ========== 2) Capacity and limits ==========
SPOOL "&&SNAP_DIR./10_resource_limits.csv"
SELECT resource_name, current_utilization, max_utilization, limit_value
FROM v$resource_limit
ORDER BY resource_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./11_tablespace_usage.csv"
SELECT
  df.tablespace_name,
  ROUND(SUM(df.bytes)/1024/1024,2) AS alloc_mb,
  ROUND(SUM(NVL(fs.bytes,0))/1024/1024,2) AS free_mb,
  ROUND((SUM(df.bytes)-SUM(NVL(fs.bytes,0)))/1024/1024,2) AS used_mb
FROM dba_data_files df
LEFT JOIN (
  SELECT tablespace_name, file_id, SUM(bytes) bytes
  FROM dba_free_space
  GROUP BY tablespace_name, file_id
) fs
ON df.tablespace_name = fs.tablespace_name
AND df.file_id = fs.file_id
GROUP BY df.tablespace_name
ORDER BY df.tablespace_name;
SPOOL OFF

-- ========== 3) Schema inventory (replace HAL with your schema if needed) ==========
DEFINE APP_SCHEMA = 'HAL'

SPOOL "&&SNAP_DIR./20_tables.csv"
SELECT owner, table_name, num_rows, blocks, last_analyzed
FROM dba_tables
WHERE owner = '&APP_SCHEMA'
ORDER BY table_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./21_columns.csv"
SELECT owner, table_name, column_id, column_name, data_type, data_length, nullable
FROM dba_tab_columns
WHERE owner = '&APP_SCHEMA'
ORDER BY table_name, column_id;
SPOOL OFF

SPOOL "&&SNAP_DIR./22_indexes.csv"
SELECT owner, index_name, table_name, uniqueness, status
FROM dba_indexes
WHERE owner = '&APP_SCHEMA'
ORDER BY table_name, index_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./23_index_columns.csv"
SELECT index_owner, index_name, table_owner, table_name, column_position, column_name
FROM dba_ind_columns
WHERE table_owner = '&APP_SCHEMA'
ORDER BY table_name, index_name, column_position;
SPOOL OFF

SPOOL "&&SNAP_DIR./24_constraints.csv"
SELECT owner, table_name, constraint_name, constraint_type, status, validated
FROM dba_constraints
WHERE owner = '&APP_SCHEMA'
ORDER BY table_name, constraint_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./25_fk_relationships.csv"
SELECT
  a.owner,
  a.table_name,
  a.constraint_name,
  c_pk.owner AS referenced_owner,
  c_pk.table_name AS referenced_table
FROM dba_constraints a
JOIN dba_constraints c_pk
  ON a.r_owner = c_pk.owner
 AND a.r_constraint_name = c_pk.constraint_name
WHERE a.owner = '&APP_SCHEMA'
  AND a.constraint_type = 'R'
ORDER BY a.table_name, a.constraint_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./26_invalid_objects.csv"
SELECT owner, object_type, object_name, status
FROM dba_objects
WHERE owner = '&APP_SCHEMA'
  AND status <> 'VALID'
ORDER BY object_type, object_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./27_segment_sizes.csv"
SELECT owner, segment_name, segment_type, tablespace_name, ROUND(bytes/1024/1024,2) AS mb
FROM dba_segments
WHERE owner = '&APP_SCHEMA'
ORDER BY bytes DESC;
SPOOL OFF

-- ========== 4) Performance snapshot ==========
SPOOL "&&SNAP_DIR./30_top_sql_by_elapsed.csv"
SELECT *
FROM (
  SELECT sql_id,
         plan_hash_value,
         parsing_schema_name,
         executions,
         ROUND(elapsed_time/1000000,2) AS elapsed_sec_total,
         ROUND(cpu_time/1000000,2) AS cpu_sec_total
  FROM v$sql
  WHERE parsing_schema_name = 'HAL'
    AND executions > 0
  ORDER BY elapsed_time DESC
)
WHERE ROWNUM <= 20;
SPOOL OFF

SPOOL "&&SNAP_DIR./31_top_wait_events_non_idle.csv"
SELECT *
FROM (
  SELECT
    event,
    wait_class,
    total_waits,
    ROUND(time_waited_micro/1000000,2) AS time_waited_sec
  FROM v$system_event
  WHERE wait_class <> 'Idle'
  ORDER BY time_waited_micro DESC
)
WHERE ROWNUM <= 30;
SPOOL OFF

SPOOL "&&SNAP_DIR./32_sysmetric_recent.csv"
SELECT begin_time, end_time, metric_name, ROUND(value,3) AS value
FROM v$sysmetric_history
WHERE metric_name IN (
  'Host CPU Utilization (%)',
  'Executions Per Sec',
  'User Calls Per Sec',
  'Transactions Per Sec',
  'Average Read I/O Time',
  'Average Write I/O Time'
)
ORDER BY begin_time DESC, metric_name;
SPOOL OFF

SPOOL "&&SNAP_DIR./33_awr_snapshots_recent.csv"
SELECT snap_id, dbid, instance_number, begin_interval_time, end_interval_time
FROM dba_hist_snapshot
ORDER BY snap_id DESC
FETCH FIRST 30 ROWS ONLY;
SPOOL OFF

PROMPT Snapshot export complete.