-- golden_queries.sql

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

