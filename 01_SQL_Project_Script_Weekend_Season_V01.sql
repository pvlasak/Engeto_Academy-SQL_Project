CREATE OR REPLACE TABLE t_weekend_and_season AS (
    SELECT cbd.`date`, cbd.country,
    CASE WHEN WEEKDAY(cbd.`date`) in (5, 6) THEN 1 ELSE 0 END AS weekend,
    CASE WHEN MONTH(cbd.`date`) IN (1,2) THEN 3 WHEN MONTH(cbd.`date`) IN (7,8) THEN 1 WHEN MONTH(cbd.`date`) IN (10,11) THEN 2 
    WHEN (MONTH(cbd.`date`) = 3 AND DAYOFMONTH(cbd.`date`) < 21) THEN 3
    WHEN (MONTH(cbd.`date`) = 3 AND DAYOFMONTH(cbd.`date`) >= 21) THEN 0
    WHEN (MONTH(cbd.`date`) = 6 AND DAYOFMONTH(cbd.`date`) < 21) THEN 0
    WHEN (MONTH(cbd.`date`) = 6 AND DAYOFMONTH(cbd.`date`) >= 21) THEN 1
    WHEN (MONTH(cbd.`date`) = 9 AND DAYOFMONTH(cbd.`date`) < 21) THEN 1
    WHEN (MONTH(cbd.`date`) = 9 AND DAYOFMONTH(cbd.`date`) >= 21) THEN 2
    WHEN (MONTH(cbd.`date`) = 12 AND DAYOFMONTH(cbd.`date`) < 21) THEN 2
    WHEN (MONTH(cbd.`date`) = 12 AND DAYOFMONTH(cbd.`date`) >= 21) THEN 3
    END AS season
    FROM covid19_basic_differences cbd 
 );
 
SELECT * FROM t_weekend_and_season twas 
WHERE date = '2020-03-21';

# Script combines data from 3 different table and calculates number of confirmed cases per 100000 inhabitants
# and the percentage value of all positive tests performed. 
# 
SELECT
   base.*,
   tests.tests_performed,
   (base.confirmed / pop.population)*100000 AS confirmed_per_100k,
   (base.confirmed / tests.tests_performed)*100 AS percentage_of_positive_tests
FROM (
	SELECT
	cbd.`date`, cbd.country, cbd.confirmed
	FROM covid19_basic_differences cbd
    ) base
LEFT JOIN (
	SELECT  
	ct.country, ct.`date`, ct.tests_performed 
	FROM covid19_tests ct 
	WHERE ct.tests_performed IS NOT NULL
	) tests
ON base.country = tests.country
AND base.`date` = tests.`date`
LEFT JOIN (
    SELECT
    	c.country, c.population
    FROM countries c
    WHERE c.population > 0 AND c.population IS NOT NULL
   ) pop
ON base.country = pop.country
;
