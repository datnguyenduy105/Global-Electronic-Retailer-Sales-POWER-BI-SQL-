WITH rename_column AS (
  SELECT 
    CustomerKey AS customer_id
    , Gender AS gender
    , Name AS customer_name
    , City AS city
    , `State Code` AS state_code
    , State AS state_name
    , `Zip Code` AS zip_code
    , Country AS country
    , Continent AS continent
    , Birthday AS birthday
  FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.Customers` 
)

, handle_null AS (
  SELECT
    * EXCEPT (continent)
    , IFNULL(continent, 'Undefined') AS continent
  FROM rename_column
)

, enrich AS (
  SELECT 
  *
  , DATE_DIFF(CURRENT_DATE(), birthday, YEAR) AS age
  , CASE
      WHEN (DATE_DIFF(CURRENT_DATE(), birthday, YEAR)) <= 18 THEN '0 - 18'
      WHEN (DATE_DIFF(CURRENT_DATE(), birthday, YEAR)) <= 34 THEN '18 - 34'
      WHEN (DATE_DIFF(CURRENT_DATE(), birthday, YEAR)) <= 49 THEN '35 - 49'
      WHEN (DATE_DIFF(CURRENT_DATE(), birthday, YEAR)) <= 64 THEN '50 - 64'
      WHEN (DATE_DIFF(CURRENT_DATE(), birthday, YEAR)) > 65 THEN '65 - ~'
      ELSE 'Undefined'
      END
      AS age_group
  FROM handle_null
)

SELECT 
  *
FROM enrich
