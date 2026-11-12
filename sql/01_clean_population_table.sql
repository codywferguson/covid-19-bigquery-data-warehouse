-- =============================================================
-- 01 | Clean the county population table (ETL: Transform)
-- =============================================================
-- Source: covid_county_population_usafacts.csv, loaded to BigQuery
-- as mydb.covid_county.
--
-- Problem: countyFIPS loaded as an INTEGER, which strips leading
-- zeros (Alabama's 01001 became 1001). The public covid19_usafacts
-- tables store FIPS as a 5-character STRING, so the tables won't join
-- until the codes match.
-- =============================================================

-- Check how each FIPS field is typed
SELECT column_name, data_type
FROM `lesson01-baim3205.mydb.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'covid_county'
  AND column_name = 'countyFIPS';

SELECT column_name, data_type
FROM `bigquery-public-data.covid19_usafacts.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'summary'
  AND column_name = 'county_fips_code';

-- Give the table a descriptive name
ALTER TABLE `lesson01-baim3205.mydb.covid_county`
RENAME TO covid_county_population_usafacts;

-- Add a STRING column for the corrected code (DDL)
ALTER TABLE `lesson01-baim3205.mydb.covid_county_population_usafacts`
ADD COLUMN county_fips STRING;

-- Copy the integer codes in as text (DML)
UPDATE `lesson01-baim3205.mydb.covid_county_population_usafacts`
SET county_fips = CAST(countyFIPS AS STRING)
WHERE TRUE;

-- Restore leading zeros on 1 to 4 character codes
UPDATE `lesson01-baim3205.mydb.covid_county_population_usafacts`
SET county_fips = LPAD(county_fips, 5, '0')
WHERE LENGTH(county_fips) BETWEEN 1 AND 4;

-- Drop the original integer column
ALTER TABLE `lesson01-baim3205.mydb.covid_county_population_usafacts`
DROP COLUMN countyFIPS;
