CREATE TABLE warehouse_transactions (

    transaction_id VARCHAR(20) PRIMARY KEY,
	transaction_date DATE NOT NULL,
	warehouse VARCHAR(50) NOT NULL,
	sku VARCHAR(50) NOT NULL,
	system_qty INTEGER NOT NULL,
	physical_qty INTEGER NOT NULL,
	picker VARCHAR(50) NOT NULL,
	pick_qty INTEGER NOT NULL,
	pick_time_minutes INTEGER NOT NULL,
	storage_area_sqm NUMERIC(10,2) NOT NULL,
	used_area_sqm NUMERIC(10,2) NOT NULL

);

-- Warehouse_transactions

SELECT COUNT(*)
FROM warehouse_transactions;

-- Inventory Accuracy (Physical Qty / System Qty)

SELECT

    warehouse,
	ROUND(
        AVG(
            physical_qty * 100.0
            / system_qty
        ),
        2
    ) AS inventory_accuracy

FROM warehouse_transactions
GROUP BY warehouse
ORDER BY inventory_accuracy DESC;

-- Space Utilization (Used Area / Storage Area)

SELECT

    warehouse,
	ROUND(
        AVG(
            used_area_sqm * 100.0
            /
            storage_area_sqm
        ),
        2
    ) AS utilization_pct

FROM warehouse_transactions
GROUP BY warehouse
ORDER BY utilization_pct DESC;

-- Picking Productivity (Pick Qty / Pick Time)

SELECT

    picker,
	ROUND(
        AVG(
            pick_qty * 1.0
            /
            pick_time_minutes
        ),
        2
    ) AS productivity

FROM warehouse_transactions
GROUP BY picker
ORDER BY productivity DESC;

--- Top 5 Pickers

SELECT

    picker,
	ROUND(
        AVG(
            pick_qty * 1.0
            /
            pick_time_minutes
        ),
        2
    ) AS productivity

FROM warehouse_transactions
GROUP BY picker
ORDER BY productivity DESC
LIMIT 5;

-- Bottom 5 Pickers

SELECT

    picker,
	ROUND(
        AVG(
            pick_qty * 1.0
            /
            pick_time_minutes
        ),
        2
    ) AS productivity

FROM warehouse_transactions
GROUP BY picker
ORDER BY productivity
LIMIT 5;

-- First Operational KPI Classification

SELECT

    warehouse,
	ROUND(
        AVG(
            physical_qty*100.0/system_qty
        ),
        2
    ) AS accuracy,

    CASE

        WHEN AVG(
            physical_qty*100.0/system_qty
        ) >= 98

        THEN 'Excellent'

        WHEN AVG(
            physical_qty*100.0/system_qty
        ) >= 95

        THEN 'Good'

        ELSE 'Poor'

    END AS warehouse_rating

FROM warehouse_transactions
GROUP BY warehouse;


-- Warehouse Scorecard

-- Step 1: Create Warehouse Summary CTE

WITH warehouse_summary AS (

    SELECT

        warehouse,
		ROUND(
            AVG(
                physical_qty*100.0/
                system_qty
            ),
            2
        ) AS accuracy,

        ROUND(
            AVG(
                used_area_sqm*100.0/
                storage_area_sqm
            ),
            2
        ) AS utilization

    FROM warehouse_transactions
	GROUP BY warehouse

)

SELECT *
FROM warehouse_summary;


-- Step 2: Add Warehouse Rating

WITH warehouse_summary AS (

    SELECT

        warehouse,
		ROUND(
            AVG(
                physical_qty*100.0/
                system_qty
            ),
            2
        ) AS accuracy,

        ROUND(
            AVG(
                used_area_sqm*100.0/
                storage_area_sqm
            ),
            2
        ) AS utilization

    FROM warehouse_transactions
	GROUP BY warehouse

)

SELECT

    warehouse,
	accuracy,
 	utilization,

    CASE

        WHEN accuracy >= 98
        THEN 'Excellent'

        WHEN accuracy >= 95
        THEN 'Good'

        ELSE 'Poor'

    END AS warehouse_rating

FROM warehouse_summary;

--- Step 3: Create Warehouse Rank

WITH warehouse_summary AS (

    SELECT

        warehouse,
		ROUND(
            AVG(
                physical_qty*100.0/
                system_qty
            ),
            2
        ) AS accuracy,

        ROUND(
            AVG(
                used_area_sqm*100.0/
                storage_area_sqm
            ),
            2
        ) AS utilization

    FROM warehouse_transactions
	GROUP BY warehouse

)

SELECT

    warehouse,
	accuracy,
	utilization,

    RANK() OVER(
        ORDER BY accuracy DESC
    ) AS warehouse_rank

FROM warehouse_summary;