CREATE TABLE shipment_master (

    shipment_id VARCHAR(20) PRIMARY KEY,
	shipment_date DATE NOT NULL,
	carrier VARCHAR(50) NOT NULL,
	weight_kg NUMERIC(10,2),
	distance_km NUMERIC(10,2),
	freight_cost NUMERIC(12,2),
	planned_delivery_date DATE,
	actual_delivery_date DATE,
	otd INTEGER
);

-- Step:1 Verify

SELECT COUNT(*)
FROM shipment_master;

-- Step 2: Carrier OTD Ranking

SELECT

    carrier,
	ROUND(
        AVG(otd)*100,
        2
    ) AS otd_pct

FROM shipment_master
GROUP BY carrier
ORDER BY otd_pct DESC;

-- Step 3: Transportation Cost Ranking

SELECT

    carrier,
	ROUND(
        AVG(freight_cost),
        2
    ) AS avg_freight_cost

FROM shipment_master
GROUP BY carrier
ORDER BY avg_freight_cost DESC;

-- Step 4: Total Spend by Carrier

SELECT

    carrier,
	ROUND(
        SUM(freight_cost),
        2
    ) AS total_spend

FROM shipment_master
GROUP BY carrier
ORDER BY total_spend DESC;

-- Step 5: Spend Percentage

SELECT

    carrier,
	ROUND(
        SUM(freight_cost),
        2
    ) AS spend,

    ROUND(
        SUM(freight_cost)*100.0
        /
        SUM(SUM(freight_cost))
        OVER(),
        2
    ) AS spend_pct

FROM shipment_master
GROUP BY carrier
ORDER BY spend DESC;

-- Step 6: Late Deliveries

SELECT

    carrier,
	COUNT(*) AS late_deliveries

FROM shipment_master

WHERE otd = 0
GROUP BY carrier
ORDER BY late_deliveries DESC;

-- Step 7: Carrier Classification

SELECT

    carrier,
	ROUND(
        AVG(otd)*100,
        2
    ) AS otd_pct,

    CASE

        WHEN AVG(otd) >= 0.95
        THEN 'Excellent'

        WHEN AVG(otd) >= 0.90
        THEN 'Good'

        WHEN AVG(otd) >= 0.85
        THEN 'Average'

        ELSE 'Poor'

    END AS carrier_rating

FROM shipment_master
GROUP BY carrier
ORDER BY otd_pct DESC;


-- Carrier Scorecard

WITH carrier_summary AS (

    SELECT

        carrier,
		ROUND(
            AVG(otd)*100,
            2
        ) AS otd_pct,

        ROUND(
            AVG(freight_cost),
            2
        ) AS avg_cost,

        ROUND(
            SUM(freight_cost),
            2
        ) AS total_spend

    FROM shipment_master
	GROUP BY carrier

),

carrier_scorecard AS (

    SELECT

        carrier,
		otd_pct,
		avg_cost,
		total_spend,

        RANK() OVER(
            ORDER BY otd_pct DESC
        ) AS service_rank,

        RANK() OVER(
            ORDER BY avg_cost
        ) AS cost_rank

    FROM carrier_summary

)

SELECT *
FROM carrier_scorecard
ORDER BY service_rank;

