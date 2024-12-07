WITH rename_column AS (
  SELECT 
    StoreKey AS store_id
    , Country AS country
    , State AS state_name
    , `Square Meters` AS square_meters
    , `Open Date` AS open_date
  FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.Stores` 
)

, handle_null AS (
  SELECT
    * EXCEPT (square_meters)
    , IFNULL(square_meters, 0) AS square_meters
  FROM rename_column
)

, enrich AS(
  SELECT
    *
    , DATE_DIFF(CURRENT_DATE(), open_date, YEAR) AS store_age
    , CASE
        WHEN square_meters <= 500 THEN '0 - 500'
        WHEN square_meters <= 1000 THEN '500 - 1000'
        WHEN square_meters <= 1500 THEN '1000 - 1500'
        WHEN square_meters > 1500 THEN '1500 - ~'
        ELSE 'Undefined'END
        AS store_size_m2
  FROM handle_null
)

SELECT 
  *
FROM enrich
