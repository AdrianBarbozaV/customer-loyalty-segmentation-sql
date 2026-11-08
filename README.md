# Customer Loyalty Segmentation (SQL)

SQL analysis that segments the customers of a rental business into loyalty tiers using an RFM-style approach (**R**ecency, **F**requency, **M**onetary value).

## Business question
Which customers are the most valuable, which are at risk, and how should the business treat each group?

## Approach
The query is built as a chain of CTEs, each one a clear step:
1. **Reference date:** latest rental date in the database
2. **Customer summary:** joins 6 tables (payment, customer, address, city, country, rental) to get total rentals, total paid and last rental date per customer
3. **Recency:** days since each customer's last rental
4. **Benchmarks:** global averages for rentals, spending and recency
5. **Scoring:** one point for each metric where the customer beats the average
6. **Segmentation:** loyalty tier from the score, plus a sub-segment that explains *why* a customer scored 1 point

| Points | Tier | Meaning |
|---|---|---|
| 3 | Estrella (Star) | Above average in all three dimensions |
| 2 | Leal (Loyal) | Above average in two dimensions |
| 1 | Potencial (Potential) | Sub-segmented: big spender but infrequent, frequent but low spend, or new/recent customer |
| 0 | Inactivo (Inactive) | Below average in all dimensions |

## SQL concepts used
CTEs (`WITH`), multi-table `JOIN`s, `CROSS JOIN`, aggregations with `GROUP BY`, `CASE` logic, date arithmetic (`julianday`)

## How to run
Open `data/dvdrental.db` (SQLite) in DB Browser for SQLite, DBeaver or VS Code and run `customer_loyalty_segmentation.sql`.

*Academic project, Technical Degree in Data Analysis, Universidad CENFOTEC.*
