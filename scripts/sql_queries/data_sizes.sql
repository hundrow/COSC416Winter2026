--This script highlights the size of the tables in both number of rows and estimated bytes

CLEAR COLUMNS;
SET LINESIZE 120;
SET PAGESIZE 100;

COLUMN table_name FORMAT A25 HEADING 'Table Name';
COLUMN num_rows   FORMAT 99,999,999 HEADING 'Row Count';
COLUMN avg_row_len FORMAT 999,999 HEADING 'Avg Row (Bytes)';
COLUMN estimated_mb FORMAT 999,999.99 HEADING 'Estimated MB';

SELECT
    table_name,
    num_rows,
    avg_row_len,
    ROUND((num_rows * avg_row_len) / 1024 / 1024, 2) AS estimated_mb
FROM all_tables
WHERE owner = 'HAL'
  AND table_name IN (
    'ARTICLE_AUTHORS',
    'ARTICLE_KEYWORDS',
    'ARTICLE_COLLECTIONS',
    'ARTICLE_DOMAINS_EN',
    'ARTICLE_ABSTRACTS',
    'RESEARCH_ARTICLES'
)
ORDER BY estimated_mb DESC;
