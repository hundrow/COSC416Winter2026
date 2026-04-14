-- This script highlights the top published domains by their total volume.

CLEAR COLUMNS;
COL domain_label FORMAT A55 HEADING 'Research Domain' TRUNC;
COL article_count FORMAT 9,999,999 HEADING 'Total Articles';
COL percentage_of_database FORMAT 99.99 HEADING '% of Database';

SELECT domain_label, 
       COUNT(domain_label) AS article_count,
       ROUND((COUNT(domain_label) / (SELECT COUNT(docid) FROM hal.research_articles)) * 100, 2) AS percentage_of_database
FROM hal.article_domains_en
WHERE domain_label IS NOT NULL
GROUP BY domain_label
ORDER BY article_count DESC
FETCH FIRST 15 ROWS ONLY;
