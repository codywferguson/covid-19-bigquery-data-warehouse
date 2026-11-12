# COVID-19 Data Warehouse in Google BigQuery

An end-to-end business intelligence pipeline built in BigQuery SQL. The project combines live public COVID-19 data with an external county population file, cleans and joins them into a data warehouse table, engineers daily metrics with window functions, and publishes a state-level data mart for reporting.

**Tools:** Google BigQuery, SQL (DDL, DML, window functions), Jupyter

## Pipeline

```
bigquery-public-data.covid19_usafacts.summary ──┐
                                                ├──► dw_covid19 ──► dm_covid19_co ──► county summary report
covid_county_population_usafacts.csv ───────────┘   (warehouse)     (Colorado mart)
```

| Step | File | BI phase |
|---|---|---|
| 1 | `sql/01_clean_population_table.sql` | Transform: fix FIPS codes so the tables can join |
| 2 | `sql/02_validate_population_table.sql` | Validate: row count, population total, join check |
| 3 | `sql/03_build_data_warehouse.sql` | Load: build `dw_covid19` with engineered features |
| 4 | `sql/04_clean_county_names.sql` | Clean: strip trailing whitespace from county names |
| 5 | `sql/05_build_colorado_data_mart.sql` | Data mart: Colorado subset `dm_covid19_co` |
| 6 | `sql/06_colorado_county_summary.sql` | Report: cases and deaths by county as of 2022-10-01 |

## Data issues I found and fixed

**FIPS codes lost their leading zeros.** BigQuery loaded the CSV's county FIPS codes as integers, so Alabama's `01001` arrived as `1001`. The public dataset stores FIPS as 5-character strings, so nothing joined. I added a STRING column, cast the codes into it, padded them back to five characters with `LPAD`, and dropped the original column.

**County names carried a trailing space.** The public data stores `'Boulder County '` with a space at the end, so an exact filter on `'Boulder County'` returned zero rows. A single `UPDATE ... SET county_name = TRIM(county_name)` fixed the warehouse table.

**Cases and deaths are running totals.** The source reports cumulative counts. Summing them across dates would inflate totals many times over, so the report reads each county's value on the final date. I also engineered daily columns that turn the running totals into new counts per day.

## Feature engineering with LAG()

`dw_covid19` adds four columns using `LAG()` over a named window that partitions by state and county and orders by date:

| Column | Meaning |
|---|---|
| `priorDayCases`, `priorDayDeaths` | The running total one day earlier |
| `dailyCases`, `dailyDeaths` | New cases and deaths on that date (today's total minus yesterday's) |

```sql
LAG(p.confirmed_cases) OVER (state_county) AS priorDayCases,
p.confirmed_cases - LAG(p.confirmed_cases) OVER (state_county) AS dailyCases
...
WINDOW state_county AS (
  PARTITION BY p.state, p.county_name
  ORDER BY p.date
)
```

Defining the window once keeps all four columns on identical "same county, previous day" logic.

## Sample output

Top Colorado counties by confirmed cases as of October 1, 2022:

| County | Confirmed cases | Deaths |
|---|---:|---:|
| El Paso County | 221,943 | 1,795 |
| City and County of Denver | 211,121 | 1,436 |
| Arapahoe County | 185,753 | 1,285 |

## Data sources

- [USAFacts COVID-19 data](https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/) via the BigQuery public dataset `bigquery-public-data.covid19_usafacts`
- `data/covid_county_population_usafacts.csv`, USAFacts county population estimates

## Running it

1. Create a BigQuery dataset (this project uses `mydb`) and load `data/covid_county_population_usafacts.csv` as a table named `covid_county`.
2. Replace `lesson01-baim3205` with your own project ID.
3. Run the files in `sql/` in numeric order.

Built as part of Business Data Management (BAIM 3205) at CU Boulder's Leeds School of Business.
