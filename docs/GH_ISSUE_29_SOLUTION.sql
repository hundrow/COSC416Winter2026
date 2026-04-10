-- GH_ISSUE_29_SOLUTION.sql
-- Purpose: Collect Oracle 19c evidence to satisfy Issue #29
-- (Performance-Centric Transition Plan / Performance Gate)
--
-- Recommended usage:
-- 1) Run each section in SQL Developer or SQLcl.
-- 2) Save result grids/screenshots into /docs/gh_issue_29_solution.md 
-- 3) For queries with placeholders, replace values in the comments first.

-- Optional: enforce the application schema used in the snapshot export.
-- ALTER SESSION SET CURRENT_SCHEMA = HAL;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Phase 0: Define The Performance Gate (SLOs)
-------------------------------------------------------------------------------



-- SLO-1: Golden Query Latency (P95)
-- These five queries are the workload set for Issue #29.
-- Run them repeatedly during the 15-minute steady-state window, then use
-- the SQL_IDs that appear in V$SQL and AWR for latency and plan stability.
-- DOCID is VARCHAR2(50) in HAL tables; bind as a string value. 120300
-- Optional helper to get a known DOCID in this environment:
--   SELECT docid FROM HAL.research_articles WHERE ROWNUM = 1;

-- Q1: Publication profile by DOCID (point lookup + abstract join)
SELECT ra.*,
       aa.*
FROM HAL.research_articles ra
LEFT JOIN HAL.article_abstracts aa
  ON aa.docid = ra.docid
WHERE ra.docid = :docid;
-- times:
-- run 1: elapsed_sec_total=0.161
-- run 2: elapsed_sec_total=0.073
-- run 3: elapsed_sec_total=0.074

-- Q2: Keyword rows for one publication (keyword retrieval path)
SELECT *
FROM HAL.article_keywords
WHERE docid = :docid
ORDER BY docid;
-- times:
-- run 1: elapsed_sec_total=0.056
-- run 2: elapsed_sec_total=0.047
-- run 3: elapsed_sec_total=0.039

-- Q3: Author rows for one publication (authorship retrieval path)
SELECT *
FROM HAL.article_authors
WHERE docid = :docid
ORDER BY docid;
-- times:
-- run 1: elapsed_sec_total=0.054
-- run 2: elapsed_sec_total=0.044
-- run 3: elapsed_sec_total=0.051

-- Q4: Publication trend by year (aggregation path)
SELECT publish_year,
       COUNT(*) AS article_count
FROM HAL.research_articles
WHERE publish_year BETWEEN :start_year AND :end_year
GROUP BY publish_year
ORDER BY publish_year;
-- times:
-- run 1: elapsed_sec_total=0.050
-- run 2: elapsed_sec_total=0.043
-- run 3: elapsed_sec_total=0.049

-- Q5: Domain mapping by publication (domain lookup path)
SELECT 'EN' AS domain_language,
       COUNT(*) AS domain_rows
FROM HAL.article_domains_en
WHERE docid = :docid
UNION ALL
SELECT 'FR' AS domain_language,
       COUNT(*) AS domain_rows
FROM HAL.article_domains_fr
WHERE docid = :docid;
-- times:
-- run 1: elapsed_sec_total=0.056
-- run 2: elapsed_sec_total=0.040
-- run 3: elapsed_sec_total=0.045


-- SLO-2/3/4 when V$SYSMETRIC* returns no rows in this environment.
-- Captures a 60-second delta window using cumulative counters.
SET SERVEROUTPUT ON
DECLARE
  t1_calls NUMBER; t2_calls NUMBER;
  t1_execs NUMBER; t2_execs NUMBER;
  t1_comm  NUMBER; t2_comm  NUMBER;
  t1_roll  NUMBER; t2_roll  NUMBER;
  b1 NUMBER; b2 NUMBER; i1 NUMBER; i2 NUMBER;
  r1w NUMBER; r2w NUMBER; r1t NUMBER; r2t NUMBER;
BEGIN
  SELECT MAX(CASE WHEN name='user calls' THEN value END),
         MAX(CASE WHEN name='execute count' THEN value END),
         MAX(CASE WHEN name='user commits' THEN value END),
         MAX(CASE WHEN name='user rollbacks' THEN value END)
    INTO t1_calls, t1_execs, t1_comm, t1_roll
  FROM v$sysstat
  WHERE name IN ('user calls','execute count','user commits','user rollbacks');

  SELECT MAX(CASE WHEN stat_name='BUSY_TIME' THEN value END),
         MAX(CASE WHEN stat_name='IDLE_TIME' THEN value END)
    INTO b1, i1
  FROM v$osstat
  WHERE stat_name IN ('BUSY_TIME','IDLE_TIME');

  SELECT SUM(CASE WHEN event IN ('db file sequential read','db file scattered read') THEN total_waits ELSE 0 END),
         SUM(CASE WHEN event IN ('db file sequential read','db file scattered read') THEN time_waited_micro ELSE 0 END)
    INTO r1w, r1t
  FROM v$system_event;

  DBMS_LOCK.SLEEP(60);

  SELECT MAX(CASE WHEN name='user calls' THEN value END),
         MAX(CASE WHEN name='execute count' THEN value END),
         MAX(CASE WHEN name='user commits' THEN value END),
         MAX(CASE WHEN name='user rollbacks' THEN value END)
    INTO t2_calls, t2_execs, t2_comm, t2_roll
  FROM v$sysstat
  WHERE name IN ('user calls','execute count','user commits','user rollbacks');

  SELECT MAX(CASE WHEN stat_name='BUSY_TIME' THEN value END),
         MAX(CASE WHEN stat_name='IDLE_TIME' THEN value END)
    INTO b2, i2
  FROM v$osstat
  WHERE stat_name IN ('BUSY_TIME','IDLE_TIME');

  SELECT SUM(CASE WHEN event IN ('db file sequential read','db file scattered read') THEN total_waits ELSE 0 END),
         SUM(CASE WHEN event IN ('db file sequential read','db file scattered read') THEN time_waited_micro ELSE 0 END)
    INTO r2w, r2t
  FROM v$system_event;

  DBMS_OUTPUT.PUT_LINE('SLO2_calls_per_min=' || ROUND(t2_calls - t1_calls, 2));
  DBMS_OUTPUT.PUT_LINE('SLO2_execs_per_min=' || ROUND(t2_execs - t1_execs, 2));
  DBMS_OUTPUT.PUT_LINE('SLO2_tx_per_min=' || ROUND((t2_comm - t1_comm) + (t2_roll - t1_roll), 2));

  IF (b2 - b1) + (i2 - i1) > 0 THEN
    DBMS_OUTPUT.PUT_LINE('SLO3_host_cpu_pct=' || ROUND(100 * (b2 - b1) / ((b2 - b1) + (i2 - i1)), 2));
  ELSE
    DBMS_OUTPUT.PUT_LINE('SLO3_host_cpu_pct=N/A');
  END IF;

  IF (r2w - r1w) > 0 THEN
    DBMS_OUTPUT.PUT_LINE('SLO4_read_wait_ms=' || ROUND((r2t - r1t) / (r2w - r1w) / 1000, 3));
  ELSE
    DBMS_OUTPUT.PUT_LINE('SLO4_read_wait_ms=N/A');
  END IF;
END;
/
SET SERVEROUTPUT OFF
-- output from run 1:
-- SLO2_calls_per_min=59
-- SLO2_execs_per_min=975823
-- SLO2_tx_per_min=0
-- SLO3_host_cpu_pct=51,55
-- SLO4_read_wait_ms=N/A
-- output from run 2:
-- SLO2_calls_per_min=59
-- SLO2_execs_per_min=988450
-- SLO2_tx_per_min=0
-- SLO3_host_cpu_pct=52,78
-- SLO4_read_wait_ms=N/A


-- SLO-5: Top wait-event pressure (non-idle)
-- Interprets share of total non-idle wait time from cumulative system events.
WITH non_idle AS (
  SELECT event,
         time_waited_micro,
         CASE
           WHEN SUM(time_waited_micro) OVER () > 0
             THEN ROUND(100 * time_waited_micro / SUM(time_waited_micro) OVER (), 2)
           ELSE 0
         END AS pct_non_idle_wait
  FROM v$system_event
  WHERE wait_class <> 'Idle'
)
SELECT event,
       ROUND(time_waited_micro / 1000000, 2) AS waited_seconds,
       pct_non_idle_wait
FROM non_idle
ORDER BY pct_non_idle_wait DESC
FETCH FIRST 20 ROWS ONLY;
-- "EVENT","WAITED_SECONDS","PCT_NON_IDLE_WAIT"
-- "free buffer waits",4109,85,29,26
-- "direct path write temp",2524,73,17,97
-- "local write wait",1255,1,8,93
-- "control file parallel write",1084,18,7,72
-- "direct path write",807,32,5,75
-- "Data file init write",734,11,5,23
-- "write complete waits",660,31,4,7
-- "direct path sync",482,01,3,43
-- "external table read",354,76,2,53
-- "DLM cross inst call completion",332,73,2,37
-- "direct path read",296,29,2,11
-- "db file single write",208,02,1,48
-- "log file switch (checkpoint incomplete)",205,15,1,46
-- "db file sequential read",181,54,1,29
-- "Disk file operations I/O",174,02,1,24
-- "log buffer space",114,78,0,82
-- "enq: CR - block range reuse ckpt",107,65,0,77
-- "resmgr:cpu quantum",99,24,0,71
-- "enq: RO - fast object reuse",65,42,0,47
-- "direct path read temp",35,47,0,25


-- SLO-6: Plan stability for critical SQL (plan hash consistency)
-- Capture the SQL_IDs of the workload statements above after running them.
-- Replace the bind placeholders below with the observed SQL_ID values from V$SQL.
WITH golden_sql AS (
  SELECT :sql_id_1 AS sql_id FROM dual
  UNION ALL SELECT :sql_id_2 FROM dual
  UNION ALL SELECT :sql_id_3 FROM dual
  UNION ALL SELECT :sql_id_4 FROM dual
  UNION ALL SELECT :sql_id_5 FROM dual
)
SELECT sql_id,
       COUNT(DISTINCT plan_hash_value) AS distinct_plan_hashes,
       LISTAGG(TO_CHAR(plan_hash_value), ', ')
         WITHIN GROUP (ORDER BY plan_hash_value) AS observed_plan_hashes
FROM v$sql
WHERE sql_id IN (SELECT sql_id FROM golden_sql)
GROUP BY sql_id
ORDER BY sql_id;

-------------------------------------------------------------------------------
-- Phase 1: Baseline Performance Review (Issue #29 item 1)
-------------------------------------------------------------------------------
-- Objective: produce a defensible healthy-state baseline package using Linux telemetry, SQL workload evidence, and OEM/AWR evidence for the same 15-minute window.




-------------------------------------------------------------------------------
-- Phase 2: Capacity and Scalability Plan (Issue #29 item 2)
-------------------------------------------------------------------------------
-- Objective: determine the practical breaking point of the current configuration by increasing load from the validated 15-minute baseline and recording when response time, CPU, or I/O headroom begins to collapse.

-- Run workload on multiple sessions IE: 2, 4, 8, 16, etc. until we see first failing limit
-- SQL> SET DEFINE OFF
-- SQL> HOST for n in 2 4 8 16; do \
--         echo "Starting batch: $n sessions"; \
--         j=1; \
--         while [ $j -le $n ]; do \
--           sqlplus -L HAL/"letmein"@//localhost:1521/ORCLPDB.localdomain @scripts/issue29_workload_driver.sql & \
--           j=$((j+1)); \
--         done; \
--         wait; \
--         echo "Batch complete: $n sessions"; \
--       done
-- SQL> SET DEFINE ON

-------------------------------------------------------------------------------
-- Phase 3: Operational Runbooks (Tuning Focus) (Issue #29 item 3)
-------------------------------------------------------------------------------

-- 5.1 Current top non-idle wait classes
SELECT wait_class,
       ROUND(time_waited / 100, 2) AS waited_seconds,
       total_waits
FROM v$system_wait_class
WHERE wait_class <> 'Idle'
ORDER BY time_waited DESC;

-- 5.2 If "db file sequential read" appears as top wait, inspect SQL contributors
SELECT ash.sql_id,
       COUNT(*) AS ash_samples,
       MIN(ash.sample_time) AS first_seen,
       MAX(ash.sample_time) AS last_seen
FROM v$active_session_history ash
WHERE ash.event = 'db file sequential read'
GROUP BY ash.sql_id
ORDER BY ash_samples DESC
FETCH FIRST 20 ROWS ONLY;

-------------------------------------------------------------------------------
-- Phase 4: Knowledge Transfer on Execution Plans (Issue #29 item 4)
-------------------------------------------------------------------------------

-- Replace SQL_ID list with the SQL_IDs observed for the five Golden Queries.
-- Snapshot examples from docs/db_snapshot/30_top_sql_by_elapsed.csv:
-- dzq5p8kvryx86, 6ymkph9ukt8pj, 1d87tbb8tw990, 29ncfz4uzkf0f, 9fndv6q3mqzc7
SELECT sql_id,
       plan_hash_value,
       parsing_schema_name,
       module,
       action,
       executions,
       ROUND(elapsed_time / 1000000, 2) AS elapsed_sec_total,
       ROUND(cpu_time / 1000000, 2) AS cpu_sec_total
FROM v$sql
WHERE sql_id IN (
  'dzq5p8kvryx86',
  '6ymkph9ukt8pj',
  '1d87tbb8tw990',
  '29ncfz4uzkf0f',
  '9fndv6q3mqzc7'
)
ORDER BY elapsed_time DESC;

-- 6.2 Plan line details from AWR history for one SQL_ID
-- Replace :SQL_ID_BIND with a real SQL_ID in your client bind variable syntax.
SELECT p.sql_id,
       p.plan_hash_value,
       p.id,
       p.parent_id,
       p.operation,
       p.options,
       p.object_owner,
       p.object_name,
       p.cardinality,
       p.cost
FROM dba_hist_sql_plan p
WHERE p.sql_id = :SQL_ID_BIND
ORDER BY p.plan_hash_value, p.id;

-- phase 2: Capacity and Scalability Plan
-- Section 4.1:
SELECT resource_name, current_utilization, max_utilization, limit_value FROM v$resource_limit WHERE resource_name IN ('processes', 'sessions', 'transactions', 'enqueue_locks') ORDER BY resource_name;
-- Section 4.2:
SELECT TO_CHAR(sample_time, 'YYYY-MM-DD HH24:MI') AS minute_bucket, COUNT(*) AS active_sessions FROM v$active_session_history GROUP BY TO_CHAR(sample_time, 'YYYY-MM-DD HH24:MI') ORDER BY minute_bucket DESC FETCH FIRST 60 ROWS ONLY;
-- Section 4.2:
SELECT sql_id, plan_hash_value, executions, ROUND(elapsed_time / 1000000, 2) AS elapsed_sec_total, ROUND(cpu_time / 1000000, 2) AS cpu_sec_total, ROUND(buffer_gets / NULLIF(executions, 0), 2) AS buffer_gets_per_exec, ROUND(rows_processed / NULLIF(executions, 0), 2) AS rows_per_exec, parsing_schema_name, module FROM v$sql WHERE parsing_schema_name = 'HAL' AND executions > 0 ORDER BY elapsed_time DESC FETCH FIRST 20 ROWS ONLY;
-- Section 5.1:
SELECT wait_class, ROUND(time_waited / 100, 2) AS waited_seconds, total_waits FROM v$system_wait_class WHERE wait_class <> 'Idle' ORDER BY time_waited DESC;
-- Section 5.2:
SELECT ash.sql_id, COUNT(*) AS ash_samples, MIN(ash.sample_time) AS first_seen, MAX(ash.sample_time) AS last_seen FROM v$active_session_history ash WHERE ash.event = 'db file sequential read' GROUP BY ash.sql_id ORDER BY ash_samples DESC FETCH FIRST 20 ROWS ONLY;
-- Section 6.1:
SELECT sql_id, plan_hash_value, parsing_schema_name, module, action, executions, ROUND(elapsed_time / 1000000, 2) AS elapsed_sec_total, ROUND(cpu_time / 1000000, 2) AS cpu_sec_total FROM v$sql WHERE sql_id IN ('dzq5p8kvryx86', '6ymkph9ukt8pj', '1d87tbb8tw990', '29ncfz4uzkf0f', '9fndv6q3mqzc7') ORDER BY elapsed_time DESC;

