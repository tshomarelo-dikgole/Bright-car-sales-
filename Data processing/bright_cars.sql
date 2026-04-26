-- select* limit 100
SELECT*
FROM `car_data.car_sales`
LIMIT
  100;

-- Check for duplicate VIN
SELECT*
  COUNT(vin) AS count_of_vin
FROM `car_data.car_sales`
GROUP BY
  vin
HAVING
  COUNT(vin) > 1
ORDER BY
  COUNT(vin) DESC;

-- Clean duplicate vin by keeping 1 vin based on the most recent entry based on sale date for each vin
SELECT
  *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY vin ORDER BY PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate) DESC ) AS record_rank
  FROM`car_data`.`car_sales` )
WHERE
  record_rank = 1;

-- check missing odometer
SELECT *
FROM `car_data`.`car_sales`
WHERE
  odometer IS NULL;

-- • Which car makes and models generate the most revenue
SELECT make,
       model,
  SUM(sellingprice) AS total_revenue
FROM `car_data`.`car_sales` 
GROUP BY
  make,
  model
ORDER BY
  SUM(sellingprice) DESC;

-- calculate profit margin and group by make.model.year.region and color
SELECT
     make,
     model,
     year,
     state 
     color,
  AVG((sellingprice - mmr) / sellingprice) AS profit_margin
FROM`car_data`.`car_sales` 
WHERE
  sellingprice IS NOT NULL
  AND sellingprice != 0
  AND mmr IS NOT NULL
GROUP BY
  make,
  model,
  year,
  state,
  color;

-- models generating most revenue
SELECT
    model,
  SUM(sellingprice) AS total_revenue
FROM `car_data`.`car_sales` 
WHERE
  model IS NOT NULL
GROUP BY
   model
ORDER BY
  SUM(sellingprice) DESC;

-- calculate relationship between price vs milage vs year
SELECT year,
  AVG(sellingprice) AS average_selling_price,
  AVG(odometer) AS average_mileage
FROM`car_data`.`car_sales` 
GROUP BY
    year
ORDER BY
    year;


---- Group transactions by time periods (month) 
SELECT
 saledate,
 FORMAT_TIMESTAMP('%B', SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', CAST(saledate AS STRING))) AS sale_month_name
FROM `car_data`.`car_sales`;

-- Group transactions by time periods (day) 
SELECT
 saledate,
 FORMAT_TIMESTAMP('%A', SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', CAST(saledate AS STRING))) AS sale_day_name
FROM `car_data`.`car_sales`;

-- Group transactions by year
SELECT
  EXTRACT(YEAR
  FROM
    PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
FROM`car_data`.`car_sales`;

-- categorise cars by performance tiers 
SELECT
  year,
  make,
  model,
  sellingprice,
  mmr,
  (sellingprice - mmr) / mmr AS margin,
  CASE
    WHEN (sellingprice - mmr) / mmr >= 0.15 THEN 'High Margin'
    WHEN (sellingprice - mmr) / mmr >= 0.07
  AND (sellingprice - mmr) / mmr < 0.15 THEN 'Medium Margin'
    ELSE 'Low Margin'
END
  AS margin_tier
FROM
  `car_data`.`car_sales` 
WHERE
  mmr IS NOT NULL
  AND mmr > 0
  AND sellingprice IS NOT NULL;



-- generate final syntax 
SELECT
  year,
  make,
  MODEL,
  trim,
  body,
  transmission,
  vin,
  state,
  condition,
  odometer,
  color,
  interior,
  seller,
  mmr,
  sellingprice,
  saledate,
   FORMAT_TIMESTAMP('%B', SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', CAST(saledate AS STRING))) AS sale_month_name,
  FORMAT_TIMESTAMP('%A', SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', CAST(saledate AS STRING))) AS sale_day_name,
   EXTRACT(YEAR
  FROM
    PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate) AS sale_timestamp,
  ROW_NUMBER() OVER (PARTITION BY vin ORDER BY PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate) DESC ) AS record_rank,
  SAFE_DIVIDE(sellingprice - mmr, sellingprice) AS profit_margin,
  CASE
    WHEN SAFE_DIVIDE(sellingprice - mmr, mmr) >= 0.15 THEN 'High Margin'
    WHEN SAFE_DIVIDE(sellingprice - mmr, mmr) >= 0.07
  AND SAFE_DIVIDE(sellingprice - mmr, mmr) < 0.15 THEN 'Medium Margin'
    ELSE 'Low Margin'
END
  AS margin_tier,
  CASE
    WHEN odometer >= 100000 THEN 'Low Mileage'  -- Assuming 'Low Mileage' means high odometer based on sample values
    WHEN odometer BETWEEN 50000
  AND 99999 THEN 'Medium Mileage'
    WHEN odometer BETWEEN 10001 AND 49999 THEN 'High Mileage'
    ELSE 'Very High Mileage'  -- For odometer <= 10000
END
  AS mileage_category
FROM
  `bright-car-sales-494419`.`car_data`.`car_sales`;



