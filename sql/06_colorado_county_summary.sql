-- =============================================================
-- 06 | Report: Colorado cases and deaths by county as of 2022-10-01
-- =============================================================
-- confirmed_cases and deaths are running totals, so the value on
-- the final date already equals the county's total. Summing them
-- across dates would count the same cases many times over.
-- =============================================================

SELECT
  county_name,
  confirmed_cases,
  deaths
FROM `lesson01-baim3205.mydb.dm_covid19_co`
WHERE date = '2022-10-01'
ORDER BY confirmed_cases DESC;

-- Equivalent approach: add up the daily new counts per county
-- SELECT
--   county_name,
--   SUM(dailyCases)  AS total_cases,
--   SUM(dailyDeaths) AS total_deaths
-- FROM `lesson01-baim3205.mydb.dm_covid19_co`
-- GROUP BY county_name
-- ORDER BY total_cases DESC;
