-- issue29_workload_driver.sql
-- Purpose: generate a repeatable, single-user steady-state workload for Issue #29.
-- Run this in SQLcl or SQL Developer while capturing v$sysmetric_history, v$sql,
-- and AWR snapshots in a separate session.
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET TERMOUT ON
SET TIMING ON

PROMPT Issue #29 workload driver
PROMPT Edit the DOCID and pattern values below so they match your HAL data.

-- Confirmed representative DOCID from the HAL database snapshot.
-- This record has abstracts, keywords, authors, and domains, so it is a
-- strong Golden Query seed for Issue #29.
DEFINE HAL_SCHEMA = HAL
DEFINE DURATION_MINUTES = 15
DEFINE DOCID_1 = 120300
DEFINE DOCID_2 = 120300
DEFINE DOCID_3 = 120300
DEFINE DOCID_4 = 120300
DEFINE DOCID_5 = 120300
DEFINE TITLE_PATTERN_1 = '%science%'
DEFINE TITLE_PATTERN_2 = '%database%'
DEFINE TITLE_PATTERN_3 = '%learning%'
DEFINE TITLE_PATTERN_4 = '%model%'
DEFINE TITLE_PATTERN_5 = '%analysis%'
DEFINE YEAR_START_1 = 2018
DEFINE YEAR_END_1 = 2020
DEFINE YEAR_START_2 = 2020
DEFINE YEAR_END_2 = 2022
DEFINE YEAR_START_3 = 2022
DEFINE YEAR_END_3 = 2024

PROMPT Using HAL schema owner: &HAL_SCHEMA
ALTER SESSION SET CURRENT_SCHEMA = &HAL_SCHEMA;

DECLARE
  TYPE t_varchar2_list IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
  TYPE t_number_list IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  l_docids         t_varchar2_list;
  l_patterns       t_varchar2_list;
  l_year_starts     t_number_list;
  l_year_ends       t_number_list;
  l_cycle_count     PLS_INTEGER := 0;
  l_window_end      TIMESTAMP := SYSTIMESTAMP + NUMTODSINTERVAL(&DURATION_MINUTES, 'MINUTE');
  l_rows            NUMBER;
  l_doc_slot        PLS_INTEGER;
  l_year_slot       PLS_INTEGER;
  l_start_ts        TIMESTAMP := SYSTIMESTAMP;
  l_start_tick_cs   PLS_INTEGER := DBMS_UTILITY.GET_TIME;

  FUNCTION stop_requested RETURN BOOLEAN IS
    l_elapsed_seconds NUMBER;
  BEGIN
    -- Enforce deadline using both wall-clock timestamp and elapsed centiseconds.
    -- DBMS_UTILITY.GET_TIME is monotonic within the DB session and avoids clock drift surprises.
    l_elapsed_seconds := (DBMS_UTILITY.GET_TIME - l_start_tick_cs) / 100;
    RETURN (SYSTIMESTAMP >= l_window_end) OR (l_elapsed_seconds >= (&DURATION_MINUTES * 60));
  END stop_requested;

  PROCEDURE assert_table_access(p_table_name IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_table_name || ' WHERE 1 = 0' INTO l_rows;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -942 THEN
        RAISE_APPLICATION_ERROR(
          -20001,
          'Missing table/view access: ' || p_table_name ||
          '. Connect as the HAL schema or create a synonym/grant for this object.'
        );
      ELSE
        RAISE;
      END IF;
  END assert_table_access;
BEGIN
  DBMS_APPLICATION_INFO.SET_MODULE('ISSUE29_WORKLOAD', 'INIT');

  l_docids(1) := '&DOCID_1';
  l_docids(2) := '&DOCID_2';
  l_docids(3) := '&DOCID_3';
  l_docids(4) := '&DOCID_4';
  l_docids(5) := '&DOCID_5';

  l_patterns(1) := '&TITLE_PATTERN_1';
  l_patterns(2) := '&TITLE_PATTERN_2';
  l_patterns(3) := '&TITLE_PATTERN_3';
  l_patterns(4) := '&TITLE_PATTERN_4';
  l_patterns(5) := '&TITLE_PATTERN_5';

  l_year_starts(1) := &YEAR_START_1;
  l_year_starts(2) := &YEAR_START_2;
  l_year_starts(3) := &YEAR_START_3;

  l_year_ends(1) := &YEAR_END_1;
  l_year_ends(2) := &YEAR_END_2;
  l_year_ends(3) := &YEAR_END_3;

  DBMS_OUTPUT.PUT_LINE('Workload window starts at ' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF3'));
  DBMS_OUTPUT.PUT_LINE('Workload window ends   at ' || TO_CHAR(l_window_end, 'YYYY-MM-DD HH24:MI:SS.FF3'));

  assert_table_access('research_articles');
  assert_table_access('article_abstracts');
  assert_table_access('article_keywords');
  assert_table_access('article_authors');
  assert_table_access('article_domains_en');
  assert_table_access('article_domains_fr');

  DBMS_APPLICATION_INFO.SET_MODULE('ISSUE29_WORKLOAD', 'RUNNING');

  WHILE NOT stop_requested LOOP
    l_cycle_count := l_cycle_count + 1;
    l_doc_slot := MOD(l_cycle_count - 1, 5) + 1;
    l_year_slot := MOD(l_cycle_count - 1, 3) + 1;

    EXIT WHEN stop_requested;

    EXECUTE IMMEDIATE q'[
      SELECT COUNT(*)
      FROM (
        SELECT ra.docid,
               ra.title_1,
               ra.title_2,
               ra.publish_year,
               aa.abstract_text
        FROM research_articles ra
        LEFT JOIN article_abstracts aa
          ON aa.docid = ra.docid
        WHERE ra.docid = :1
      )
    ]' INTO l_rows USING l_docids(l_doc_slot);

    EXIT WHEN stop_requested;

    EXECUTE IMMEDIATE q'[
      SELECT COUNT(*)
      FROM article_keywords
      WHERE docid = :1
    ]' INTO l_rows USING l_docids(l_doc_slot);

    EXIT WHEN stop_requested;

    EXECUTE IMMEDIATE q'[
      SELECT COUNT(*)
      FROM article_authors
      WHERE docid = :1
    ]' INTO l_rows USING l_docids(l_doc_slot);

    EXIT WHEN stop_requested;

    EXECUTE IMMEDIATE q'[
      SELECT COUNT(*)
      FROM (
        SELECT publish_year,
               COUNT(*) AS article_count
        FROM research_articles
        WHERE publish_year BETWEEN :1 AND :2
        GROUP BY publish_year
      )
    ]' INTO l_rows USING l_year_starts(l_year_slot), l_year_ends(l_year_slot);

    EXIT WHEN stop_requested;

    EXECUTE IMMEDIATE q'[
      SELECT COUNT(*)
      FROM (
        SELECT 'EN' AS domain_language,
               COUNT(*) AS domain_rows
        FROM article_domains_en
        WHERE docid = :1
        UNION ALL
        SELECT 'FR' AS domain_language,
               COUNT(*) AS domain_rows
        FROM article_domains_fr
        WHERE docid = :1
      )
    ]' INTO l_rows USING l_docids(l_doc_slot), l_docids(l_doc_slot);

    IF MOD(l_cycle_count, 10000) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Completed ' || l_cycle_count || ' cycles at ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS'));
    END IF;
  END LOOP;

  DBMS_APPLICATION_INFO.SET_MODULE('ISSUE29_WORKLOAD', 'FINISHED');

  DBMS_OUTPUT.PUT_LINE('Finished after ' || l_cycle_count || ' cycles at ' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF3'));
  DBMS_OUTPUT.PUT_LINE('Elapsed seconds: ' || TO_CHAR(ROUND((DBMS_UTILITY.GET_TIME - l_start_tick_cs) / 100, 2)));
END;
/

PROMPT Workload driver finished.