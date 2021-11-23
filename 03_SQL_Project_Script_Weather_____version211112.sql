#prumerna denni (nikoli nocni!) teplota
SELECT
    w.city, 
    ROUND(AVG(w.temp),2) AS average_day_temperature
FROM weather w
WHERE w.time BETWEEN '09:00' AND '18:00' AND w.city IS NOT NULL
GROUP BY w.city;

#pocet hodin v danem dni kdy byly srazky nenulove. 

CREATE OR REPLACE TABLE t_weather_non_zero_rain (
SELECT
    w.`date`, w.rain, w.`time`,w.city,
    MIN(w.`time`) AS Rain_Started_at, 
    MAX(w.`time`) AS Rain_Ended_at, 
    COUNT(w.rain) AS Number_of_rain_entries,
    (COUNT(w.rain) * 3) AS Number_of_rainy_hours,
    CASE WHEN 
    #RANK () OVER (PARTITION BY w.`date` ORDER BY w.`time`) AS TIME_RANK
FROM weather w
WHERE w.rain NOT LIKE '0.0 mm' AND w.city IS NOT NULL
GROUP BY w.`date`, w.city
ORDER BY w.city ASC
);

SELECT 
   twnzr.`date`, MAX(twnzr.TIME_RANK) AS NUMBER_OF_TIME_ENTRIES_WITH_NON_ZERO_RAIN
FROM t_weather_non_zero_rain twnzr 
GROUP BY twnzr.`date`;

SELECT w.`date`, w.rain, w.`time`, w.city
FROM weather w 
WHERE w.`date` = '2020-01-04' AND w.city = 'Amsterdam' AND w.rain NOT LIKE '0.0 mm';
