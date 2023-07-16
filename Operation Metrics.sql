create database operation_analytics;

use operation_analytics;

/************************************/

create table job_data(
job_id int,
actors_id int,
event varchar(255),
language varchar(255),
time_spent int,
org varchar(255),
ds date);

/************************************/

INSERT INTO job_data (ds, job_id, actor_id, event, language, time_spent, org)
VALUES ('2020-11-30', 21, 1001, 'skip', 'English', 15, 'A'),
       ('2020-11-30', 22, 1006, 'transfer', 'Arabic', 25, 'B'),
       ('2020-11-29', 23, 1003, 'decision', 'Persian', 20, 'C'),
       ('2020-11-28', 23, 1005,'transfer', 'Persian', 22, 'D'),
       ('2020-11-28', 25, 1002, 'decision', 'Hindi', 11, 'B'),
       ('2020-11-27', 11, 1007, 'decision', 'French', 104, 'D'),
       ('2020-11-26', 23, 1004, 'skip', 'Persian', 56, 'A'),
       ('2020-11-25', 20, 1004, 'transfer', 'Italian', 45, 'C');

/************************************/

select * from job_data;

/************************************/

/*Number of jobs reviewed: Amount of jobs reviewed over time.
Your task: Calculate the number of jobs reviewed per hour per day for November 2020?*/

SELECT ds AS Date_Reviewed,
ROUND (COUNT(*) / (SUM(time spent) / 3600)) AS Jobs_Per_Hour
FROM job_data
WHERE ds BETWEEN "2020-11-01" AND "2020-11-30"
GROUP BY ds;

/************************************/

/*Throughput: It is the no. of events happening per second.
Your task: Let’s say the above metric is called throughput. 
Calculate 7 day rolling average of throughput? 
For throughput, do you prefer daily metric or 7-day rolling and why?*/

SELECT ds AS "Date", jobs_reviewed as "Jobs_Reviewed",
ROUND(AVG(jobs_reviewed)OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2)
AS "7 Day_Rolling AVG"
FROM (SELECT ds, COUNT(DISTINCT job_id) AS "Jobs_Reviewed"
FROM job_data
WHERE ds BETWEEN "2020-11-01" AND "2020-11-30"
GROUP BY ds
ORDER BY ds) a;

SELECT ds AS "Date", jobs_reviewed as "Jobs_Reviewed",
ROUND(AVG(jobs_reviewed)OVER(ORDER BY ds ROWS BETWEEN 0 PRECEDING AND 0 FOLLOWING),2)
AS "Daily Metric"
FROM (SELECT ds, COUNT(DISTINCT job_id) AS "Jobs_Reviewed"
FROM job_data
WHERE ds BETWEEN "2020-11-01" AND "2020-11-30"
GROUP BY ds
ORDER BY ds) a;

/************************************/

/*Percentage share of each language: Share of each language for different contents.
Your task: Calculate the percentage share of each language in the last 30 days?*/

SELECT DISTINCT language,
ROUND((COUNT(event) OVER(PARTITION BY language ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
/ COUNT(*) OVER(ORDER BY ds ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) * 100, 2) as Percentage
FROM (SELECT * FROM job_data CROSS JOIN a
WHERE datediff(m,DATE(ds)) BETWEEN 0 AND 30)a1
ORDER BY language ASC;

/************************************/

/*Duplicate rows: Rows that have the same value present in them.
Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?*/

SELECT *, COUNT(*) as duplicates
FROM job_data
GROUP BY ds, job_id, actor_id, event, language, time_spent, org
HAVING 
(COUNT(ds) > 1) AND 
(COUNT(job_id) > 1) AND
(COUNT(actor_id) > 1) AND 
(COUNT(event) > 1) AND
(COUNT(language) > 1) AND 
(COUNT(time_spent) > 1) AND
(COUNT(org) > 1);
