-- View 1: Carrier performance summary
CREATE OR REPLACE VIEW `dependable-link-470810-e6.logistics_analytics.carrier_performance` AS
SELECT
    delivery_partner,
    COUNT(delivery_id) AS total_deliveries,
    ROUND(SAFE_DIVIDE(COUNTIF(delivery_status = 'delivered'), COUNT(delivery_id)) * 100, 1) AS success_rate_pct,
    ROUND(SAFE_DIVIDE(COUNTIF(delayed = TRUE), COUNT(delivery_id)) * 100, 1) AS delay_rate_pct,
    ROUND(SAFE_DIVIDE(COUNTIF(delivery_status = 'failed'), COUNT(delivery_id)) * 100, 1) AS failure_rate_pct,
    ROUND(AVG(IF(delayed = TRUE, delay_hours, NULL)), 2) AS avg_delay_hours_when_late,
    ROUND(AVG(delivery_rating), 2) AS avg_rating,
    ROUND(AVG(cost_per_km), 2) AS avg_cost_per_km,
    ROUND(AVG(cost_per_kg), 2) AS avg_cost_per_kg
FROM `dependable-link-470810-e6.logistics_analytics.shipments_cleaned`
GROUP BY delivery_partner;

-- View 2: Regional bottleneck view
CREATE OR REPLACE VIEW `dependable-link-470810-e6.logistics_analytics.region_performance` AS
SELECT
    region,
    COUNT(delivery_id) AS total_deliveries,
    ROUND(SAFE_DIVIDE(COUNTIF(delayed = TRUE), COUNT(delivery_id)) * 100, 1) AS delay_rate_pct,
    ROUND(AVG(IF(delayed = TRUE, delay_hours, NULL)), 2) AS avg_delay_hours_when_late,
    ROUND(AVG(cost_per_km), 2) AS avg_cost_per_km
FROM `dependable-link-470810-e6.logistics_analytics.shipments_cleaned`
GROUP BY region;

-- View 3: Weather impact on delays
CREATE OR REPLACE VIEW `dependable-link-470810-e6.logistics_analytics.weather_impact` AS
SELECT
    weather_condition,
    COUNT(delivery_id) AS total_deliveries,
    ROUND(SAFE_DIVIDE(COUNTIF(delayed = TRUE), COUNT(delivery_id)) * 100, 1) AS delay_rate_pct,
    ROUND(AVG(IF(delayed = TRUE, delay_hours, NULL)), 2) AS avg_delay_hours_when_late
FROM `dependable-link-470810-e6.logistics_analytics.shipments_cleaned`
GROUP BY weather_condition;