-- =============================================================
-- 04 | Remove trailing whitespace from county_name
-- =============================================================
-- The public data stores county names with a trailing space
-- ('Boulder County '), so an exact filter on 'Boulder County'
-- returns no rows. TRIM fixes the values in place.
-- =============================================================

-- Before: only the padded string matches
SELECT COUNT(*) AS rows_found
FROM `lesson01-baim3205.mydb.dw_covid19`
WHERE county_name = 'Boulder County ';

UPDATE `lesson01-baim3205.mydb.dw_covid19`
SET county_name = TRIM(county_name)
WHERE TRUE;

-- After: the clean string matches
SELECT COUNT(*) AS rows_found
FROM `lesson01-baim3205.mydb.dw_covid19`
WHERE county_name = 'Boulder County';
