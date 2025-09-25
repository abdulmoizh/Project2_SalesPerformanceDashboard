select * from sales;

-- Monthly revenue by city
WITH months AS (
    SELECT unnest(ARRAY[
        'January','February','March','April','May','June',
        'July','August','September','October','November','December'
    ]) AS month
)
SELECT 
    m.month,
    c.city,
    COALESCE(SUM(s.total_revenue), 0) AS monthly_revenue
FROM months m
CROSS JOIN (SELECT DISTINCT city FROM sales) c
LEFT JOIN sales s 
    ON s.month = m.month AND s.city = c.city
GROUP BY m.month, c.city
ORDER BY 
    DATE_PART('month', TO_DATE(m.month, 'Month')), 
    c.city;
-- Top 10 products by revenue

SELECT 
    product_name,
    SUM(total_revenue) AS total_revenue
FROM sales
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Orders per sales channel

SELECT 
    channel,
    COUNT(DISTINCT order_id) AS total_orders
FROM sales
GROUP BY channel
ORDER BY total_orders DESC;

-- 4. Average order value (AOV) per category

SELECT 
    category,
    SUM(total_revenue) / COUNT(DISTINCT order_id) AS avg_order_value
FROM sales
GROUP BY category
ORDER BY avg_order_value DESC;

-- 5. Month-over-month revenue growth

WITH monthly_revenue AS (
    SELECT 
        month,
        SUM(total_revenue) AS revenue
    FROM sales
    GROUP BY month
)
SELECT 
    month,
    revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY 
            TO_DATE(month, 'Month'))) 
        / NULLIF(LAG(revenue) OVER (ORDER BY TO_DATE(month, 'Month')), 0) * 100, 
    2) AS mom_growth_percent
FROM monthly_revenue
ORDER BY TO_DATE(month, 'Month');
