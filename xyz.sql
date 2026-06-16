-- Step 1: Calculate Average Demand

SELECT

    item_code,

    (
        jan + feb + mar + apr + may + jun +
        jul + aug + sep + oct + nov + dec
    ) / 12.0 AS avg_demand

FROM inventory_master;

-- Step 2: Calculate Standard Deviation

WITH monthly_demand AS (

    SELECT item_code, jan AS demand FROM inventory_master
    UNION ALL
    SELECT item_code, feb FROM inventory_master
    UNION ALL
    SELECT item_code, mar FROM inventory_master
    UNION ALL
    SELECT item_code, apr FROM inventory_master
    UNION ALL
    SELECT item_code, may FROM inventory_master
    UNION ALL
    SELECT item_code, jun FROM inventory_master
    UNION ALL
    SELECT item_code, jul FROM inventory_master
    UNION ALL
    SELECT item_code, aug FROM inventory_master
    UNION ALL
    SELECT item_code, sep FROM inventory_master
    UNION ALL
    SELECT item_code, oct FROM inventory_master
    UNION ALL
    SELECT item_code, nov FROM inventory_master
    UNION ALL
    SELECT item_code, dec FROM inventory_master

)

SELECT

    item_code,

    ROUND(AVG(demand),2) AS avg_demand,

    ROUND(STDDEV(demand),2) AS demand_stddev

FROM monthly_demand
GROUP BY item_code;

-- Step 3: Calculate CV


WITH monthly_demand AS (

    SELECT item_code, jan AS demand FROM inventory_master
    UNION ALL
    SELECT item_code, feb FROM inventory_master
    UNION ALL
    SELECT item_code, mar FROM inventory_master
    UNION ALL
    SELECT item_code, apr FROM inventory_master
    UNION ALL
    SELECT item_code, may FROM inventory_master
    UNION ALL
    SELECT item_code, jun FROM inventory_master
    UNION ALL
    SELECT item_code, jul FROM inventory_master
    UNION ALL
    SELECT item_code, aug FROM inventory_master
    UNION ALL
    SELECT item_code, sep FROM inventory_master
    UNION ALL
    SELECT item_code, oct FROM inventory_master
    UNION ALL
    SELECT item_code, nov FROM inventory_master
    UNION ALL
    SELECT item_code, dec FROM inventory_master

),

xyz_data AS (

    SELECT

        item_code,

        AVG(demand) AS avg_demand,

        STDDEV(demand) AS demand_stddev,

        STDDEV(demand) / NULLIF(AVG(demand),0)
        AS cv

    FROM monthly_demand

    GROUP BY item_code

)

SELECT *
FROM xyz_data;


-- Step 4: XYZ Classification

WITH monthly_demand AS (

    SELECT item_code, jan AS demand FROM inventory_master
    UNION ALL
    SELECT item_code, feb FROM inventory_master
    UNION ALL
    SELECT item_code, mar FROM inventory_master
    UNION ALL
    SELECT item_code, apr FROM inventory_master
    UNION ALL
    SELECT item_code, may FROM inventory_master
    UNION ALL
    SELECT item_code, jun FROM inventory_master
    UNION ALL
    SELECT item_code, jul FROM inventory_master
    UNION ALL
    SELECT item_code, aug FROM inventory_master
    UNION ALL
    SELECT item_code, sep FROM inventory_master
    UNION ALL
    SELECT item_code, oct FROM inventory_master
    UNION ALL
    SELECT item_code, nov FROM inventory_master
    UNION ALL
    SELECT item_code, dec FROM inventory_master

),

xyz_data AS (

    SELECT

        item_code,

        ROUND(AVG(demand),2) AS avg_demand,

        ROUND(STDDEV(demand),2) AS demand_stddev,

        ROUND(
            STDDEV(demand)
            /
            NULLIF(AVG(demand),0)
        ,2) AS cv

    FROM monthly_demand
	GROUP BY item_code

)

SELECT

    item_code,

    avg_demand,

    demand_stddev,

    cv,

    CASE

        WHEN cv <= 0.50 THEN 'X'

        WHEN cv <= 1.00 THEN 'Y'

        ELSE 'Z'

    END AS xyz_category

FROM xyz_data
ORDER BY cv;

-- XYZ Summary

WITH monthly_demand AS (

    SELECT item_code, jan AS demand FROM inventory_master
    UNION ALL
    SELECT item_code, feb FROM inventory_master
    UNION ALL
    SELECT item_code, mar FROM inventory_master
    UNION ALL
    SELECT item_code, apr FROM inventory_master
    UNION ALL
    SELECT item_code, may FROM inventory_master
    UNION ALL
    SELECT item_code, jun FROM inventory_master
    UNION ALL
    SELECT item_code, jul FROM inventory_master
    UNION ALL
    SELECT item_code, aug FROM inventory_master
    UNION ALL
    SELECT item_code, sep FROM inventory_master
    UNION ALL
    SELECT item_code, oct FROM inventory_master
    UNION ALL
    SELECT item_code, nov FROM inventory_master
    UNION ALL
    SELECT item_code, dec FROM inventory_master

),

xyz_data AS (

    SELECT

        item_code,

        STDDEV(demand)
        /
        NULLIF(AVG(demand),0) AS cv

    FROM monthly_demand

    GROUP BY item_code

)

SELECT

    CASE

        WHEN cv <= 0.50 THEN 'X'
        WHEN cv <= 1.00 THEN 'Y'
        ELSE 'Z'

    END AS xyz_category,

    COUNT(*) AS sku_count

FROM xyz_data
GROUP BY xyz_category
ORDER BY xyz_category;

