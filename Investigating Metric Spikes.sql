/*Case Study 2 (Investigating metric spike)
The structure of the table with the definition of each column that you must work on is present in the project image*/

/*Table-1: users
This table includes one row per user, with descriptive information about that user’s account.*/

/*Table-2: events
This table includes one row per event, where an event is an action that a user has taken. These events include login events, messaging events, search events, events logged as users progress through a signup funnel, events around received emails.*/

/*Table-3: email_events
This table contains events specific to the sending of emails. It is similar in structure to the events table above.*/

/*Use the dataset attached in the Dataset section below the project images then answer the questions that follows*/

/*****************************************************/

/*User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?*/

SELECT EXTRACT(WEEK FROM occurred_at) AS WeekNum,
COUNT(DISTINCT user_id) AS "Weekly Active Users"
FROM events
GROUP BY WeekNum ORDER BY WeekNum;

/*****************************************************/

/*User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for product?*/

/*Quarterly User Growth */

WITH quarterly_data AS (
    SELECT
        YEAR(created_at) AS year,
        CEILING(MONTH(created_at) / 3.0) AS quarter,
        COUNT(DISTINCT user_id) AS user_counts
    FROM users
    GROUP BY year, quarter
)
SELECT
    q1.year,
    q1.quarter,
    q1.user_counts
FROM quarterly_data q1
ORDER BY q1.year, q1.quarter;

/*Monthly User Growth */

SELECT
YEAR (created_at) AS year,
MONTH(created_at) AS month,
COUNT(DISTINCT user_id) AS user_counts
FROM users
GROUP BY year, month;

/*****************************************************/

/*Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?*/

select first,
SUM(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) AS week_0,
SUM(CASE WHEN week_number = 1 THEN 1 ELSE 0 END) AS week_1,
SUM(CASE WHEN week_number = 2 THEN 1 ELSE 0 END) AS week_2,
SUM(CASE WHEN week_number = 3 THEN 1 ELSE 0 END) AS week_3,
SUM(CASE WHEN week_number = 4 THEN 1 ELSE 0 END) AS week_4,
SUM(CASE WHEN week_number = 5 THEN 1 ELSE 0 END) AS week_5,
SUM(CASE WHEN week_number = 6 THEN 1 ELSE 0 END) AS week_6,
SUM(CASE WHEN week_number = 7 THEN 1 ELSE 0 END) AS week_7,
SUM(CASE WHEN week_number = 8 THEN 1 ELSE 0 END) AS week_8,
SUM(CASE WHEN week_number = 9 THEN 1 ELSE 0 END) AS week_9
from (select m.user_id, m.login_week, n.first as first,
(m.login_week-first) as week_number 
from (SELECT user_id, WEEK(occured_at) AS login_week FROM events GROUP BY user_id, week(occured_at)) m,
(SELECT user_id, min(week(occured_at)) AS first FROM events GROUP BY user_id) n
where m.user_id=n.user_id) as with_week_number
group by first
order by first;

/*****************************************************/

/*Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
Your task: Calculate the weekly engagement per device?*/

WITH weekly_engagement AS (
SELECT user_id, device, date_format(occured_at, '%Y-%u') AS week,
COUNT(*) AS engagement
FROM events
WHERE event_type = 'engagement'
GROUP BY user_id, device, week
)
SELECT device, week, SUM(engagement) AS weekly_engagement
FROM weekly_engagement
GROUP BY device, week
ORDER BY weekly_engagement DESC;


/*****************************************************/

/*Email Engagement: Users engaging with the email service.
Your task: Calculate the email engagement metrics?*/

SELECT
  WEEK(occurred_at) AS week,
  COUNT(DISTINCT user_id) AS num_users,
  SUM(action = 'sent_weekly_digest') AS time_weekly_digest_sent,
  SUM(action = 'email_open') AS time_email_open,
  SUM(action = 'email_clickthrough') AS time_email_clickthrough
FROM email_events
GROUP BY week
ORDER BY week;

/*****************************************************/