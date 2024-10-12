#### January 31's rolling 3 day average of total transaction amount processed per day
```sql
WITH daily_totals AS (
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
```
