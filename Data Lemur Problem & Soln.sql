 Problem 1.
----Swiggy Instacart Problems –(Chapter Advanced SQL with Instacart SQL CASE) 

----: Analyzing Prior Vs Current Products :---

--Products that were not frequently reordered in the past (based on data from ic_order_products_prior) but are now being reordered more frequently in the current orders (from ic_order_products_curr)

--https://datalemur.com/sql-tutorial/instacart-sql-data-analytics-case-study

--Below is the insights using CTE and JOIN with group by, order by, and having Clause--

WITH increased_reorders as (
   SELECT prod.product_id, 
       prod.product_name, 
       prod.aisle_id,
       prod.department_id, 
       dept.department, 
       aisles.aisle,
       SUM(curr_pro.reordered) as current_reordered,
       SUM(prior_pro.reordered) as prior_reordered
  FROM 
     ic_order_products_curr as curr_pro
  INNER JOIN 
     ic_order_products_prior as prior_pro
  ON 
     curr_pro.product_id= prior_pro.product_id
  INNER JOIN
      ic_products as prod
  ON 
     curr_pro.product_id=prod.product_id
  INNER JOIN 
    ic_departments as dept
  ON 
    prod.department_id=dept.department_id
  INNER JOIN 
   ic_aisles as aisles
  ON prod.aisle_id=aisles.aisle_id
   GROUP BY
      prod.product_id, 
       prod.product_name, 
       prod.aisle_id,
       prod.department_id, 
       dept.department, 
       aisles.aisle
  HAVING
      SUM(prior_pro.reordered)<10
  AND SUM(curr_pro.reordered)>=10
  ORDER BY 
     current_reordered DESC,prod.product_id DESC)
  SELECT aisle,
         COUNT(*) no_of_reorders
  from increased_reorders
   GROUP BY aisle
  ORDER BY no_of_reorders DESC;

Problem 2.

---Histogram of Tweets----

---https://datalemur.com/questions/sql-histogram-tweets---

With CTE as(SELECT 
  COUNT(tweet_id) as no_tweet,
  user_id
   FROM tweets
  where EXTRACT(year FROM tweet_date)=2022
GROUP BY user_id)
  select no_tweet, COUNT(user_id)
 FROM CTE 
  GROUP BY no_tweet;

Problem 3.

---Page With No Likes---

--https://datalemur.com/questions/sql-page-with-no-likes--

SELECT pages.page_id 
  FROM 
  pages 
  LEFT JOIN page_likes
 ON pages.page_id=page_likes.page_id
  WHERE
   page_likes.page_id IS NULL
ORDER BY pages.page_id;

Problem 4.

---Unfinished Parts---

--https://datalemur.com/questions/tesla-unfinished-parts--

SELECT 
 part, assembly_step
  FROM parts_assembly
where finish_date IS NULL;

Problem 5.

---Laptop vs. Mobile Viewership---

--https://datalemur.com/questions/laptop-mobile-viewership--

Select 
 SUM(
  CASE 
  when device_type='laptop' then 1 else 0 end) 
   as laptop_views,
  SUM(
   CASE 
  when device_type IN ('phone','tablet') then 1 else 0 end)
  as mobile_views 
   FROM viewership;

Problem 6.

---Average Post Hiatus (Part 1)---

--https://datalemur.com/questions/sql-average-post-hiatus-1--

SELECT
 user_id, 
 max(post_date::DATE)-min(post_date::DATE) as dates_difference
 FROM posts
  WHERE EXTRACT(YEAR from post_date)=2021
    GROUP BY user_id
having count(post_id)>=2;

Problem 7.

---Teams Power Users---

--https://datalemur.com/questions/teams-power-users--

SELECT 
 sender_id, COUNT(message_id) as message_count 
 FROM messages
  where EXTRACT(MONTH from sent_date)=8
   and EXTRACT(Year from sent_date)=2022
   GROUP BY sender_id
  ORDER BY message_count DESC
LIMIT 2;

Problem 8.

---Duplicate Job Listings---

--https://datalemur.com/questions/duplicate-job-listings--

WITH job_count_CTE as
 (SELECT 
  company_id,
 title,description,
 COUNT(job_id) as job_count
FROM job_listings
 GROUP BY company_id,title,description)
 SELECT COUNT(company_id)
from job_count_CTE
 where job_count>1;

Problem 9.

---Cities With Completed Trades---
--https://datalemur.com/questions/completed-trades--

SELECT city, COUNT(order_id) as total_orders
 FROM trades 
  INNER JOIN users
   ON  trades.user_id= users.user_id
   WHERE status='Completed'
   GROUP BY city
  ORDER BY total_orders DESC
  LIMIT 3;

Problem 10.
---Average Review Ratings---
--https://datalemur.com/questions/sql-avg-review-ratings--

SELECT 
 EXTRACT(MONTH from submit_date) as mth,
 product_id as product, 
 ROUND(AVG(stars),2) as avg_stars
   FROM reviews
  GROUP BY EXTRACT(MONTH from submit_date),product_id
  ORDER BY mth, product;

Problem 11.

---App Click-through Rate---

--https://datalemur.com/questions/click-through-rate--

WITH CTR_table as 
(SELECT 
 app_id, 
   SUM(CASE 
    WHEN event_type='click' then 1 else 0 end) as click_count,
   SUM(CASE WHEN event_type='impression' then 1 else 0 end)
    as impression_count
   from events
   WHERE EXTRACT(YEAR from timestamp)=2022
 GROUP BY app_id)
 SELECT
   app_id,
    ROUND((click_count*100.0)/impression_count,2) as CTR
  FROM CTR_table;

Problem 12.

---Second Day Confirmation---

--https://datalemur.com/questions/second-day-confirmation--

SELECT user_id 
  FROM emails
   INNER JOIN texts
   ON emails.email_id=texts.email_id
  WHERE  action_date= signup_date + '1 DAY' 
   AND signup_action='Confirmed';

Problem 13.

---IBM db2 Product Analytics---

WITH employee_queries as 
(SELECT  emp.employee_id as emp_id, 
  COALESCE(COUNT(DISTINCT query_id),0) as unique_queries
 FROM employees AS emp
 LEFT JOIN queries 
  ON emp.employee_id=queries.employee_id
  AND query_starttime>='2023-07-01'
    AND query_starttime<'2023-10-01'
  GROUP BY  emp.employee_id)
  SELECT unique_queries, 
     COUNT(emp_id) as employee_count
   FROM employee_queries
GROUP BY unique_queries
ORDER BY unique_queries;

Problem 14.

---Cards Issued Difference---
--https://datalemur.com/questions/cards-issued-difference--

SELECT 
 card_name, 
 (MAX(issued_amount)- MIN(issued_amount)) as difference
 FROM monthly_cards_issued
 GROUP BY card_name
  ORDER BY MAX(issued_amount)- MIN(issued_amount) DESC;

Problem 15.

---Compressed Mean---

--https://datalemur.com/questions/alibaba-compressed-mean--

WITH CTE AS(
 SELECT 
SUM(item_count::DECIMAL*order_occurrences)/
 SUM(order_occurrences) as mean 
  FROM items_per_order)
 SELECT ROUND(mean,1) from CTE;

Problem 16.

---Pharmacy Analytics (Part 1)---

--https://datalemur.com/questions/top-profitable-drugs--

SELECT drug, 
 (total_sales - cogs) as total_profit
 FROM pharmacy_sales
 ORDER BY total_sales - cogs DESC
LIMIT 3;

Problem 17.

---Pharmacy Analytics (Part 2)---

--https://datalemur.com/questions/non-profitable-drugs--

SELECT 
 manufacturer,
   COUNT(drug) as drug_count,
   ABS(SUM(total_sales-cogs)) as total_loss
FROM pharmacy_sales
 WHERE total_sales-cogs<=0
 GROUP BY manufacturer
ORDER BY total_loss DESC ;

Problem 18.

---Pharmacy Analytics (Part 3)---

--https://datalemur.com/questions/total-drugs-sales--

SELECT 
 manufacturer, 
  CONCAT('$',ROUND(SUM(total_sales)/1000000),' million') as sale
  FROM pharmacy_sales
   GROUP BY manufacturer
  ORDER BY SUM(total_sales) DESC;

Problem 19.

---Patient Support Analysis  (Part 1)---

--https://datalemur.com/questions/frequent-callers--

WITH CTE as (SELECT policy_holder_id,
 COUNT(case_id) as case_count 
    FROM callers
    GROUP BY policy_holder_id)
  SELECT COUNT(policy_holder_id)
   FROM CTE 
    WHERE case_count>=3;

Problem 20.

---Who Made Quota?---

--https://datalemur.com/questions/oracle-sales-quota--

WITH CTE as (SELECT 
 deals.employee_id as emp_id, 
  SUM(deal_size) as total_deal,quota
  FROM deals INNER JOIN 
   sales_quotas
  ON deals.employee_id=sales_quotas.employee_id
  GROUP BY deals.employee_id,quota
  )
SELECT emp_id,
  CASE when total_deal>quota 
 then 'yes' else 'no' END as made_quota
 FROM CTE 
  ORDER BY emp_id;

Problem 21.

---Well Paid Employees---

--https://datalemur.com/questions/sql-well-paid-employees--

SELECT 
  emp.employee_id as emp_id,
  emp.name as emp_name
   FROM employee AS emp
    INNER JOIN employee as mgr
  ON mgr.employee_id=emp.manager_id
  WHERE emp.salary>mgr.salary;

Problem 22.

---Data Science Skills---

--https://datalemur.com/questions/matching-skills--

SELECT 
 candidate_id 
  FROM candidates
  WHERE skill IN('Python','Tableau','PostgreSQL')
GROUP BY candidate_id 
HAVING COUNT(skill)=3
ORDER BY candidate_id ASC;

Problem 23.

---Tweets' Rolling Averages---

--https://datalemur.com/questions/rolling-average-tweets--

SELECT 
 user_id,
  tweet_date,
   ROUND(AVG(tweet_count) OVER(
   PARTITION BY user_id
   ORDER BY tweet_date 
   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)as rolling_avg_3d
  FROM tweets

Problem 24.

---Highest-Grossing Items---

--https://datalemur.com/questions/sql-highest-grossing--

WITH ranked_spending_CTE AS
  (SELECT 
   category, 
   product, 
   SUM(spend) as total_spend, 
   RANK() OVER(
   PARTITION BY category
   ORDER BY SUM(spend) DESC) as ranking 
FROM product_spend
   WHERE EXTRACT(YEAR from transaction_date)=2022
GROUP BY category, product)
 SELECT
   category, 
   product, 
   total_spend
 FROM ranked_spending_CTE
  WHERE ranking <=2;

Problem 25.

---Top 5 Artists---

--https://datalemur.com/questions/top-fans-rank--

WITH ranking_table AS (
 SELECT 
  artist_name,
  DENSE_RANK() OVER(
   ORDER BY COUNT(songs.song_id) DESC) AS artist_rank
  FROM artists 
  INNER JOIN songs
    ON artists.artist_id=songs.artist_id
  INNER JOIN global_song_rank as g_rank
    ON songs.song_id=g_rank.song_id
  WHERE rank<=10
  GROUP BY artist_name)
SELECT artist_name,artist_rank
  FROM ranking_table
  WHERE artist_rank <=5
  ORDER BY artist_rank;

Problem 26.

---Supercloud Customer---

--https://datalemur.com/questions/supercloud-customer--

WITH supercloud_cust AS (
 SELECT 
  customer_id,
  COUNT(DISTINCT product_category) as category_count
 FROM customer_contracts as customer
 INNER JOIN products
   ON customer.product_id=products.product_id
  GROUP BY customer_id)
SELECT
 customer_id 
FROM supercloud_cust
 WHERE category_count=
  (SELECT COUNT(DISTINCT product_category) from products);

Problem 27.

---Odd and Even Measurements---

--https://datalemur.com/questions/odd-even-measurements--

WITH ranked_measurement AS (
SELECT 
   (measurement_time::DATE) as measurement_day, 
    measurement_value,
    ROW_NUMBER() OVER(
    PARTITION BY (measurement_time::DATE)
    ORDER BY measurement_time) as measurement_num
  FROM measurements)
SELECT 
   measurement_day,
   SUM(measurement_value) FILTER(WHERE measurement_num%2=0) AS even_sum,
   SUM(measurement_value) FILTER(WHERE measurement_num%2=1) AS odd_sum
  FROM ranked_measurement
  GROUP BY measurement_day;

Problem 28.

---Histogram of Users and Purchases---

--https://datalemur.com/questions/histogram-users-purchases--

WITH latest_transaction_CTE AS (
 SELECT 
   transaction_date,
   user_id,
   COUNT(product_id) as purchase_count, 
   RANK() OVER(
   PARTITION BY user_id
   ORDER BY transaction_date DESC) AS ranking
  FROM user_transactions
  GROUP BY user_id, transaction_date)
 SELECT 
    transaction_date,
    user_id,
    purchase_count
  FROM latest_transaction_CTE
   WHERE ranking=1
  ORDER BY transaction_date;

Problem 29.

---Card Launch Success---

--https://datalemur.com/questions/card-launch-success--

WITH card_launch_CTE AS (
 SELECT 
   card_name,
   issued_amount, 
   make_date(issue_year, issue_month,1) as issue_date,
   MIN(make_date(issue_year, issue_month,1)) OVER(
   PARTITION BY card_name) AS launch_date
 FROM monthly_cards_issued)
 SELECT
   card_name,
   issued_amount
  FROM card_launch_CTE
  WHERE issue_date=launch_date
  ORDER BY issued_amount DESC;

Problem 30.

---User's Third Transaction---

--https://datalemur.com/questions/sql-third-transaction--

WITH transaction_ranking AS(
  SELECT 
   user_id,
   spend,
   transaction_date,
   RANK() OVER(
    PARTITION BY user_id
    ORDER BY transaction_date) as ranking
  FROM transactions)
  SELECT 
    user_id,
    spend,
    transaction_date
  FROM transaction_ranking 
  WHERE ranking=3;

Problem 31.

---Second Highest Salary---

--https://datalemur.com/questions/sql-second-highest-salary--

WITH salary_ranking AS (
SELECT 
   employee_id,
   salary,
   DENSE_RANK()  OVER(ORDER BY salary DESC) as ranking
FROM employee)
 SELECT 
 salary 
 from salary_ranking
 WHERE ranking=2;

Problem 32.

---Sending vs. Opening Snaps---

--https://datalemur.com/questions/time-spent-snaps--

WITH activity_type AS (
  SELECT 
     age_bucket,
   SUM(time_spent) FILTER(WHERE activity_type='open') as opening_time,
   SUM(time_spent) FILTER(WHERE activity_type='send') as sending_time
 FROM activities JOIN age_breakdown as age_bre
 ON activities.user_id=age_bre.user_id
 WHERE activity_type IN ('open','send')
   GROUP BY
      age_bucket)
 SELECT 
     age_bucket,
      ROUND((100.0*sending_time)/(sending_time+opening_time),2) AS send_perc,
      ROUND((100.0*opening_time)/(sending_time+opening_time),2) AS open_perc
  FROM activity_type ;

Problem 33.

---Top Three Salaries---

--https://datalemur.com/questions/sql-top-three-salaries--

WITH salary_distribution AS (
SELECT 
  department_name, 
  salary,
  name,
  dense_rank() OVER(
  PARTITION BY department_name
  ORDER BY salary DESC) AS salary_ranking
 FROM employee 
 INNER JOIN department
 ON employee.department_id=department.department_id)
 SELECT 
  department_name,
  name,
  salary FROM salary_distribution
 WHERE salary_ranking<=3;

Problem 34.

---Signup Activation Rate---

--https://datalemur.com/questions/signup-confirmation-rate--

SELECT 
 ROUND(COUNT(texts.email_id)::DECIMAL
    /COUNT(emails.email_id),2) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';

Problem 35.

---Compressed Mode---

--https://datalemur.com/questions/alibaba-compressed-mode--

SELECT 
    item_count 
  FROM items_per_order
  where order_occurrences=
    (SELECT 
     MAX(order_occurrences) as max_order
  FROM items_per_order)
  ORDER BY item_count;

Problem 36.

---International Call Percentage---

--https://datalemur.com/questions/international-call-percentage--

WITH CTE2 AS (WITH caller_type AS (
SELECT
   caller.country_id, 
   receiver.country_id,
   CASE WHEN caller.country_id!=receiver.country_id 
   THEN 'international' ELSE 'national' END  as call_type
  FROM phone_calls AS calls
  LEFT JOIN phone_info AS caller  
  ON calls.caller_id=caller.caller_id
  LEFT JOIN phone_info AS receiver
  ON calls.receiver_id=receiver.caller_id)
  SELECT COUNT(call_type) FILTER (WHERE call_type='international') as int_call,
       COUNT(call_type) AS total_calls
  FROM caller_type)
 SELECT ROUND(int_call*100.0/total_calls,1) as international_call_pct
  FROM CTE2;

Problem 37.

---Patient Support Analysis---

--https://datalemur.com/questions/uncategorized-calls-percentage--

WITH na_call_CTE AS (
SELECT  
     COUNT(case_id) FILTER (WHERE call_category='n/a')
     AS na_call,
     COUNT(case_id) FILTER (WHERE call_category IS NULL)
     AS emplty_call,
     COUNT(case_id) AS total_calls
  FROM callers)
  SELECT ROUND((na_call+emplty_call)*100.0/total_calls,1) as call_per
  FROM na_call_CTE;

Problem 38.

---Swapped Food Delivery---

--https://datalemur.com/questions/sql-swapped-food-delivery--

WITH order_count AS (
  SELECT 
    COUNT(order_id) as total_orders
  FROM orders
  )
SELECT 
 CASE 
   WHEN order_id % 2 != 0 AND total_orders=order_id then order_id
   WHEN order_id % 2 != 0 AND total_orders!=order_id then order_id +1
   ELSE order_id -1 
  END AS corrected_order_id, item
 FROM orders
  CROSS JOIN order_count
 ORDER BY  corrected_order_id;

Problem 39.

---FAANG Stock Min-Max (Part 1)---

--https://datalemur.com/questions/sql-bloomberg-stock-min-max-1--

WITH highest_price AS (
  SELECT 
    ticker,
    TO_CHAR(date,'Mon-yyyy') as highest_mth,
    MAX(open) as highest_open,
    ROW_NUMBER() OVER(
    PARTITION BY ticker
    ORDER BY open DESC) AS row_num
  FROM stock_prices
GROUP BY ticker,TO_CHAR(date,'Mon-yyyy'),open),
lowest_price AS (
SELECT 
    ticker,
    TO_CHAR(date,'Mon-yyyy') as lowest_mth,
    MIN(open) as lowest_open,
    ROW_NUMBER() OVER(
    PARTITION BY ticker
    ORDER BY open) AS row_num_2
  FROM stock_prices
GROUP BY ticker,TO_CHAR(date,'Mon-yyyy'),open)
  SELECT 
    highest_price.ticker,
    highest_mth,
    highest_open,
    lowest_mth,
    lowest_open
  FROM highest_price 
  INNER JOIN lowest_price 
  ON highest_price.ticker =lowest_price.ticker
  AND row_num=1
  AND row_num_2=1
  ORDER BY highest_price






