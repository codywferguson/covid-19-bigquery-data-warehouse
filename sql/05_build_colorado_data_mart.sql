-- =============================================================
-- 05 | Build the Colorado data mart dm_covid19_co
-- =============================================================
-- A state-level subset of the warehouse for Colorado reporting.
-- =============================================================

CREATE OR REPLACE TABLE `lesson01-baim3205.mydb.dm_covid19_co` AS
SELECT *
FROM `lesson01-baim3205.mydb.dw_covid19`
WHERE state = 'CO';

-- Check: should return a single row, CO
SELECT DISTINCT state
FROM `lesson01-baim3205.mydb.dm_covid19_co`;
