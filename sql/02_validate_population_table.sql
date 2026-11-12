-- =============================================================
-- 02 | Validate the cleaned population table
-- =============================================================

-- Row count
SELECT COUNT(*) AS row_count
FROM `lesson01-baim3205.mydb.covid_county_population_usafacts`;

-- Total population (sanity check against the published US figure)
SELECT SUM(population) AS us_population
FROM `lesson01-baim3205.mydb.covid_county_population_usafacts`;

-- Confirm the population table now joins to the public data
SELECT COUNT(*) AS row_count
FROM `bigquery-public-data.covid19_usafacts.summary` AS covid19_public
INNER JOIN `lesson01-baim3205.mydb.covid_county_population_usafacts` AS covid_county
  ON covid19_public.county_fips_code = covid_county.county_fips
 AND covid19_public.state = covid_county.State
WHERE covid19_public.date <= '2022-10-01';
