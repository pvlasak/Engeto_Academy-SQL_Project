#01: prumerna denni (nikoli nocni!) teplota
SELECT
    w.city, 
    ROUND(AVG(w.temp),2) AS average_day_temperature
FROM weather w
WHERE w.time BETWEEN '09:00' AND '18:00' AND w.city IS NOT NULL
GROUP BY w.city;

# 02: pocet hodin v danem dni kdy byly srazky nenulove.
# CASE WHEN pro identifikaci duplicitnich dat. 

CREATE OR REPLACE TABLE t_weather_non_zero_rain (
SELECT 
   base.`date`, base.city,
   base.Number_of_non_zero_entries,
   # korekce duplicit
   CASE WHEN base.Number_of_non_zero_entries > 8 THEN (base.Number_of_non_zero_entries * 3) / 2 ELSE base.Number_of_non_zero_entries * 3 END AS Hours_of_rain,
   base.Rain_Started_at,
   base.Rain_Ended_at,
   HOUR(TIMEDIFF(base.Rain_Ended_at, base.Rain_Started_at)) AS timestamp_difference
FROM
	(
		SELECT
		    w.`date`, w.rain, w.`time`, w.city,
		    CAST(MIN(w.`time`) AS TIME) AS Rain_Started_at, 
		    #CAST(MAX(w.`time`) AS TIME) AS Rain_Ended_at,
		    ADDTIME (CAST(MAX(w.`time`) AS TIME), '03:00:00') AS Rain_Ended_at,
		    COUNT(w.rain) AS Number_of_non_zero_entries
		FROM weather w
		WHERE w.rain NOT LIKE '0.0 mm' AND w.city IS NOT NULL
		GROUP BY w.`date`, w.city
		ORDER BY w.city ASC
	) base
);

#
#SELECT 
#   twnzr.`date`, MAX(twnzr.TIME_RANK) AS NUMBER_OF_TIME_ENTRIES_WITH_NON_ZERO_RAIN
#FROM t_weather_non_zero_rain twnzr 
#GROUP BY twnzr.`date`;

#SELECT w.`date`, w.rain, w.`time`, w.city
#FROM weather w 
#WHERE w.`date` = '2021-01-06' AND w.city = 'Prague' AND w.rain NOT LIKE '0.0 mm';
#

# 03: Maximalni sila vetru behem dne
SELECT 
	w.`date`, w.city,
	MAX(CAST(SUBSTRING(w.wind,1,2) AS INT)) AS Max_Wind_Speed_in_kmh
FROM weather w
WHERE w.city IS NOT NULL
GROUP BY w.`date`, w.city
ORDER BY w.city ASC;

#SELECT 
#	w.`date`, w.city, w.wind
	#MAX(CAST(SUBSTRING(w.wind,1,2) AS INT)) AS Max_Wind_Speed_in_kmh
#FROM weather w
#WHERE w.`date` = '2020-01-01' AND w.city = 'Amsterdam';