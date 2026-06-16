CREATE TABLE purchase_orders (

    PO_Number VARCHAR(20),
    PO_date DATE,
	Supplier VARCHAR(50),
	SKU VARCHAR(50),
	Ordered_Qty INTEGER,
	Received_Qty INTEGER,
	Unit_Cost NUMERIC,
	PO_Value NUMERIC,
	Expected_Delivery_Date DATE,
	Actual_Delivery_Date DATE,
	Lead_Time_Days INTEGER,
	Fill_Rate NUMERIC,
	OTIF INTEGER
);

-- Query 1: Row Count

SELECT COUNT(*)
FROM purchase_orders;

-- Query 2: View Sample Data

SELECT *
FROM purchase_orders
LIMIT 10;

-- Query 3: Supplier-wise PO Count

SELECT
    Supplier,
    COUNT(*) AS PO_count
FROM purchase_orders
GROUP BY Supplier
ORDER BY PO_count DESC;

-- Query 4: Supplier-wise Spend

SELECT
    Supplier,
    ROUND(SUM(po_value),2) AS Total_spend
FROM purchase_orders
GROUP BY Supplier
ORDER BY Total_spend DESC;

-- Query 5: Supplier OTIF

SELECT
    Supplier,
    ROUND(
        AVG(OTIF)*100,
        2
    ) AS otif_pct
FROM purchase_orders
GROUP BY Supplier
ORDER BY otif_pct DESC;

-- Query 6: Supplier Fill Rate

SELECT
    Supplier,
    ROUND(
        AVG(Fill_Rate)*100,
        2
    ) AS Fill_Rate_pct
FROM purchase_orders
GROUP BY Supplier
ORDER BY Fill_Rate_pct DESC;

-- Query 7: Supplier Lead Time

SELECT
    Supplier,
    ROUND(
        AVG(Lead_Time_Days),
        2
    ) AS Avg_Lead_Time
FROM purchase_orders
GROUP BY Supplier
ORDER BY Avg_Lead_Time;

--Query 8 - Suppliers Below OTIF Target

SELECT
    Supplier,
    ROUND(AVG(OTIF)*100,2) AS otif_pct
FROM purchase_orders
GROUP BY Supplier
HAVING AVG(OTIF) < 0.90
ORDER BY otif_pct;

-- Query 9 — Late Deliveries Only

SELECT *
FROM purchase_orders
WHERE OTIF = 0;

-- Query 10 — Count Late Deliveries by Supplier

SELECT
    Supplier,
    COUNT(*) AS Late_Deliveries
FROM purchase_orders
WHERE OTIF = 0
GROUP BY Supplier
ORDER BY Late_Deliveries DESC;

-- Query 11 — Supplier Performance Classification

SELECT

    Supplier,
	ROUND(
        AVG(OTIF)*100,
        2
    	) AS otif_pct,

    CASE
		WHEN AVG(OTIF) >= 0.95
        THEN 'Excellent'

        WHEN AVG(OTIF) >= 0.90
        THEN 'Good'

        WHEN AVG(OTIF) >= 0.85
        THEN 'Average'

        ELSE 'Poor'

    END AS Performance

FROM purchase_orders

GROUP BY Supplier

ORDER BY otif_pct DESC;


-- Query 12 — High Value Purchase Orders

SELECT
    PO_Number,
    Supplier,
    PO_Value
FROM purchase_orders
WHERE PO_Value > 1000000
ORDER BY PO_Value DESC;

-- Query 13 — Rank Suppliers by Spend

SELECT
    Supplier,
    ROUND(SUM(PO_Value),2) AS Total_spend,

    RANK() OVER(
        ORDER BY SUM(PO_Value) DESC
    ) AS Spend_Rank

FROM purchase_orders
GROUP BY Supplier;

-- Query 14 — Rank Suppliers by OTIF

SELECT

    Supplier,
	ROUND(
        AVG(OTIF)*100,
        2
    ) AS otif_pct,

    RANK() OVER(
        ORDER BY AVG(OTIF) DESC
    ) AS otif_rank

FROM purchase_orders
GROUP BY Supplier;

-- Query 15 — Spend Contribution %

SELECT

    Supplier,
	ROUND(
        SUM(PO_Value),
        2
    ) AS Spend,

    ROUND(
        SUM(PO_Value)*100.0
        /
        SUM(SUM(PO_Value))
        OVER(),
        2
    ) AS Spend_pct

FROM purchase_orders

GROUP BY Supplier
ORDER BY Spend DESC;


--- Create a Supplier Risk Score using CTEs 

WITH supplier_summary AS (

    SELECT
        Supplier,
        ROUND(SUM(PO_Value),2) AS spend,
        ROUND(
            SUM(PO_Value)*100.0 /
            SUM(SUM(PO_Value)) OVER(),
            2
        ) AS spend_pct,
        ROUND(AVG(OTIF)*100,2) AS otif
    FROM purchase_orders
    GROUP BY Supplier

),

supplier_risk AS (

    SELECT
        Supplier,
        spend_pct,
        otif,

        CASE

            WHEN spend_pct >= 20
                 AND OTIF < 90
            THEN 'High Risk'

            WHEN spend_pct >= 15
                 AND OTIF < 90
            THEN 'Medium Risk'

            ELSE 'Low Risk'

        END AS risk_level

    FROM supplier_summary

)

SELECT *
FROM supplier_risk
ORDER BY spend_pct DESC;