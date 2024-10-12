#### January 31st's rolling 3 day average of total transaction amount processed per day
```sql
SELECT 
    TO_CHAR(transaction_date, 'YYYY-MM-DD') AS transaction_date,
    total_amount,
    rolling_3_day_avg
FROM
(WITH daily_totals AS (
    SELECT 
        DATE(transaction_time) AS transaction_date,
        SUM(transaction_amount) AS total_amount
    FROM transactions
    GROUP BY DATE(transaction_time)
)
SELECT 
    transaction_date,
    total_amount,
    AVG(total_amount) OVER (ORDER BY transaction_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_day_avg
FROM daily_totals
) daily_rolling_avgs
WHERE transaction_date = '2021-01-31'
```
