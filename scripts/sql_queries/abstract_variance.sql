-- This script highlights the variance in abstract character length.

CLEAR COLUMNS;
COL shortest_abstract_chars FORMAT 9,999,999 HEADING 'Shortest (Chars)';
COL longest_abstract_chars FORMAT 9,999,999 HEADING 'Longest (Chars)';
COL avg_abstract_chars FORMAT 9,999,999 HEADING 'Average (Chars)';
COL total_abstract_megabytes FORMAT 99,999.99 HEADING 'Total Size (MB)';

SELECT 
    MIN(abstract_length) AS shortest_abstract_chars,
    MAX(abstract_length) AS longest_abstract_chars,
    ROUND(AVG(abstract_length)) AS avg_abstract_chars,
    SUM(abstract_length) / 1024 / 1024 AS total_abstract_megabytes
FROM hal.article_abstracts
WHERE abstract_length > 0;
