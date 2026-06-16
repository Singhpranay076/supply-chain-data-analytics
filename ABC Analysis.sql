CREATE TABLE inventory_master (

    item_code VARCHAR(20) PRIMARY KEY,
	item_name VARCHAR(100),
	unit_price NUMERIC(10,2),

    jan INTEGER,
    feb INTEGER,
    mar INTEGER,
    apr INTEGER,
    may INTEGER,
    jun INTEGER,
    jul INTEGER,
    aug INTEGER,
    sep INTEGER,
    oct INTEGER,
    nov INTEGER,
    dec INTEGER,

    annual_usage_qty INTEGER,
	transactions INTEGER,
	last_movement_date DATE

);

SELECT
    item_code,
    item_name,
    annual_usage_qty,
    unit_price,
    annual_usage_qty * unit_price AS annual_value
FROM inventory_master
ORDER BY annual_value DESC
LIMIT 10;


-- Step:1  Annual Value

SELECT
    item_code,
    annual_usage_qty,
    unit_price,

    annual_usage_qty * unit_price
    AS annual_value

FROM inventory_master;


-- Step 2 — Running Total

WITH inventory_value AS (

    SELECT

        item_code,
        item_name,

        annual_usage_qty * unit_price
        AS annual_value

    FROM inventory_master

)

SELECT

    item_code,
	item_name,
	annual_value,

    SUM(annual_value)
    OVER(
        ORDER BY annual_value DESC
    ) AS running_value

FROM inventory_value
ORDER BY annual_value DESC;

--- Step 3 — Cumulative %

WITH inventory_value AS (

    SELECT

        item_code,
        item_name,

        annual_usage_qty * unit_price
        AS annual_value

    FROM inventory_master

)

SELECT

    item_code,

    annual_value,

    ROUND(

        SUM(annual_value)
        OVER(
            ORDER BY annual_value DESC
        )

        *100.0

        /

        SUM(annual_value)
        OVER()

    ,2)

    AS cumulative_pct

FROM inventory_value
ORDER BY annual_value DESC;


-- Step 4 — ABC Classification

WITH inventory_value AS (

    SELECT

        item_code,
        item_name,

        annual_usage_qty * unit_price
        AS annual_value

    FROM inventory_master

),

abc_data AS (

    SELECT

        item_code,
		item_name,
		annual_value,

        ROUND(

            SUM(annual_value)
            OVER(
                ORDER BY annual_value DESC
            )

            *100.0

            /

            SUM(annual_value)
            OVER()

        ,2)

        AS cumulative_pct

    FROM inventory_value

)

SELECT

    item_code,
	item_name,
	annual_value,
	cumulative_pct,

    CASE

        WHEN cumulative_pct <= 80
        THEN 'A'

        WHEN cumulative_pct <= 95
        THEN 'B'

        ELSE 'C'

    END AS abc_category

FROM abc_data
ORDER BY annual_value DESC;

Step 5 — ABC Summary

WITH inventory_value AS (

    SELECT

        item_code,
        item_name,

        annual_usage_qty * unit_price
        AS annual_value

    FROM inventory_master

),

abc_data AS (

    SELECT

        item_code,

        ROUND(

            SUM(annual_value)
            OVER(
                ORDER BY annual_value DESC
            )

            *100.0

            /

            SUM(annual_value)
            OVER()

        ,2)

        AS cumulative_pct

    FROM inventory_value

)

SELECT

    CASE

        WHEN cumulative_pct <= 80
        THEN 'A'

        WHEN cumulative_pct <= 95
        THEN 'B'

        ELSE 'C'

    END AS abc_category,

    COUNT(*) AS sku_count

FROM abc_data
GROUP BY abc_category
ORDER BY abc_category;