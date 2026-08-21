-- View 1: Weekly demand aggregation
CREATE OR REPLACE VIEW `dependable-link-470810-e6.supply_chain_demo.weekly_demand` AS
SELECT
    product_id,
    category,
    region,
    store_type,
    supplier_id,
    supplier_name,
    lead_time_days,
    FORMAT_DATE('%Y-%W', date) AS year_week,
    SUM(sales_units) AS weekly_units_sold,
    AVG(sales_units) AS avg_daily_sales,
    AVG(future_demand) AS avg_forecasted_future_demand
FROM `dependable-link-470810-e6.supply_chain_demo.sales_with_supply_data`
GROUP BY product_id, category, region, store_type, supplier_id, supplier_name, lead_time_days, year_week;

-- View 2: Demand variability per product
CREATE OR REPLACE VIEW `dependable-link-470810-e6.supply_chain_demo.demand_stats` AS
SELECT
    product_id,
    AVG(weekly_units_sold) AS avg_weekly_demand,
    STDDEV(weekly_units_sold) AS stdev_weekly_demand
FROM `dependable-link-470810-e6.supply_chain_demo.weekly_demand`
GROUP BY product_id;

-- View 3: Safety stock & reorder point
CREATE OR REPLACE VIEW `dependable-link-470810-e6.supply_chain_demo.reorder_calc` AS
SELECT
    d.product_id,
    ANY_VALUE(wd.category) AS category,
    ANY_VALUE(wd.region) AS region,
    ANY_VALUE(wd.supplier_name) AS supplier_name,
    ANY_VALUE(wd.lead_time_days) AS lead_time_days,
    d.avg_weekly_demand,
    d.stdev_weekly_demand,
    ROUND(1.65 * d.stdev_weekly_demand * SQRT(ANY_VALUE(wd.lead_time_days) / 7.0), 1) AS safety_stock,
    ROUND((d.avg_weekly_demand / 7.0 * ANY_VALUE(wd.lead_time_days))
          + (1.65 * d.stdev_weekly_demand * SQRT(ANY_VALUE(wd.lead_time_days) / 7.0)), 1) AS reorder_point
FROM `dependable-link-470810-e6.supply_chain_demo.demand_stats` d
JOIN `dependable-link-470810-e6.supply_chain_demo.weekly_demand` wd ON d.product_id = wd.product_id
GROUP BY d.product_id, d.avg_weekly_demand, d.stdev_weekly_demand;