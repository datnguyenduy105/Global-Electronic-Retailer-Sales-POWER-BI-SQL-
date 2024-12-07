WITH rename_column AS (
SELECT
  Date AS date
  , Currency AS currency 
  , Exchange AS units_per_usd
FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.Exchange_Rates` 
)

, cast_type AS(
  SELECT
    *  EXCEPT(units_per_usd)
    , CAST(units_per_usd AS NUMERIC) AS units_per_usd
  FROM rename_column
)

SELECT 
  *
FROM cast_type
