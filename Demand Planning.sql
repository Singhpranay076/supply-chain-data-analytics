CREATE TABLE demand_planning (
    sku VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    demand_month VARCHAR NOT NULL,
    actual_demand INT NOT NULL,
    forecast_demand INT NOT NULL,
    
    PRIMARY KEY (sku, demand_month)
);

-- Forecast Error

SELECT
    sku,
    demand_month,
    actual_demand - forecast_demand AS error
FROM demand_planning;

-- MAPE

SELECT
    sku,
    ROUND(
        AVG(
            ABS(actual_demand - forecast_demand)
            * 100.0
            / NULLIF(actual_demand,0)
        ),
        2
    ) AS mape
FROM demand_planning
GROUP BY sku;

-- WAPE

SELECT
    sku,
    ROUND(
        SUM(ABS(actual_demand - forecast_demand))
        * 100.0
        / NULLIF(SUM(actual_demand),0),
        2
    ) AS wape
FROM demand_planning
GROUP BY sku;

-- Forecast Bias

SELECT
    sku,
    SUM(actual_demand - forecast_demand) AS bias
FROM demand_planning
GROUP BY sku;

-- 1. Tracking Signal

SELECT
    sku,
    ROUND(
        SUM(actual_demand - forecast_demand)::numeric
        /
        NULLIF(
            AVG(ABS(actual_demand - forecast_demand)),
            0
        ),
        2
    ) AS tracking_signal
FROM demand_planning
GROUP BY sku;

-- 2. Monthly Demand Trend

SELECT
    sku,
    demand_month,
    actual_demand
FROM demand_planning
ORDER BY sku, demand_month;

-- 3. Moving Average

SELECT
    sku,
    demand_month,
    actual_demand,

    AVG(actual_demand)
    OVER(
        PARTITION BY sku
        ORDER BY demand_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3m

FROM demand_planning;

-- 4. Month-over-Month Growth

SELECT
    sku,
    demand_month,
    actual_demand,

    LAG(actual_demand)
    OVER(
        PARTITION BY sku
        ORDER BY demand_month
    ) AS prev_month

FROM demand_planning;

-- 5. Best Forecasted SKUs

SELECT
    sku,
    ROUND(
        AVG(
            ABS(actual_demand - forecast_demand)
            *100.0
            / NULLIF(actual_demand,0)
        ),
        2
    ) AS mape
FROM demand_planning
GROUP BY sku
ORDER BY mape;

-- 6. Worst Forecasted SKUs

SELECT
    sku,
    ROUND(
        AVG(
            ABS(actual_demand - forecast_demand)
            *100.0
            / NULLIF(actual_demand,0)
        ),
        2
    ) AS mape
FROM demand_planning
GROUP BY sku
ORDER BY mape DESC;

