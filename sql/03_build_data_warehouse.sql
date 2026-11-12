-- =============================================================
-- 03 | Build the data warehouse table dw_covid19 (ETL: Load)
-- =============================================================
-- Joins daily county COVID-19 counts to county population and
-- feature-engineers four columns with the LAG() window function.
--
-- confirmed_cases and deaths are cumulative running totals.
--   priorDayCases / priorDayDeaths = the running total one day earlier
--   dailyCases / dailyDeaths       = new cases / deaths on that date
--
-- A named WINDOW defines the partition and sort once, so all four
-- columns use the same "previous day in the same county" logic.
-- Each county's first date has no prior row, so LAG returns NULL there.
-- =============================================================

CREATE OR REPLACE TABLE `lesson01-baim3205.mydb.dw_covid19` AS

SELECT
  p.*,
  c.population,
  LAG(p.confirmed_cases) OVER (state_county) AS priorDayCases,
  LAG(p.deaths)          OVER (state_county) AS priorDayDeaths,
  p.confirmed_cases - LAG(p.confirmed_cases) OVER (state_county) AS dailyCases,
  p.deaths          - LAG(p.deaths)          OVER (state_county) AS dailyDeaths

FROM `bigquery-public-data.covid19_usafacts.summary` AS p
INNER JOIN `lesson01-baim3205.mydb.covid_county_population_usafacts` AS c
  ON p.county_fips_code = c.county_fips
 AND p.state = c.State

WHERE p.date <= '2022-10-01'

WINDOW state_county AS (
  PARTITION BY p.state, p.county_name
  ORDER BY p.date
)

ORDER BY p.state, p.county_name, p.date;
