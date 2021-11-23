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
