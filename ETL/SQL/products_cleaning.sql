WITH rename_column AS (
SELECT 
  ProductKey AS product_id
  , `Product Name` AS product_name
  , Brand AS brand
  , Color AS product_color
  , `Unit Cost USD` AS unit_cost_usd
  , `Unit Price USD` AS unit_price_usd
  , SubcategoryKey AS subcategory_id
  , Subcategory AS subcategory
  , CategoryKey AS category_id
  , Category AS category
FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.Products` 
)

, cast_type AS (
SELECT 
  * EXCEPT(unit_cost_usd, unit_price_usd)
  , CAST(unit_cost_usd AS NUMERIC) AS unit_cost_usd
  , CAST(unit_price_usd AS NUMERIC) AS unit_price_usd
FROM rename_column
)

SELECT 
  *
FROM cast_type


