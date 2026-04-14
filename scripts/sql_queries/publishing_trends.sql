-- This script highlights publishing trends over the years 1990 and 2026.
-- Widen the range to find more.

CLEAR COLUMNS;
COL publish_year FORMAT 9999 HEADING 'Year';
COL articles_published FORMAT 9,999,999 HEADING 'Total Articles';
COL previous_year_count FORMAT 9,999,999 HEADING 'Prev Year Count';
COL year_over_year_growth FORMAT S9,999,999 HEADING 'YoY Growth';

SELECT publish_year, 
       COUNT(*) AS articles_published,
       LAG(COUNT(*), 1) OVER (ORDER BY publish_year) AS previous_year_count,
       COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY publish_year) AS year_over_year_growth
FROM hal.research_articles
WHERE publish_year IS NOT NULL 
  AND publish_year BETWEEN 1990 AND 2026 
GROUP BY publish_year
ORDER BY publish_year DESC;
