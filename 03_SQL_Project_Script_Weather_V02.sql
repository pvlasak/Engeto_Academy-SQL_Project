# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#01: prumerna denni (nikoli nocni!) teplota
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

SELECT
    w.city, 
    ROUND(AVG(CAST(TRIM(SUBSTRING(w.temp,1,2)) AS INT)),2) AS average_day_temperature
FROM weather w
WHERE CAST(w.`time` AS TIME) BETWEEN '08:00' AND '18:00' AND w.city IS NOT NULL
GROUP BY w.city;


#
#SELECT
#    w.`date`, w.city, 
#    CAST(SUBSTRING(w.wind,1,2) AS INT) AS temperature_as_int
#FROM weather w
#WHERE w.city = 'Prague';


#SELECT
#    w.`date`, w.city, 
#    CAST(TRIM(SUBSTRING(w.wind,1,2)) AS INT) AS average_wind
#FROM weather w
#WHERE w.city = 'Prague' AND w.`date` = '2020-08-30';

#SELECT
#    w.`date`, w.city, 
#    CAST(SUBSTRING(w.wind,1,2) AS INT) AS average_wind
#FROM weather w
#WHERE w.city = 'Prague' AND w.`date` = '2020-08-30';

#SELECT DISTINCT 
#	city
#FROM weather w 

# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# 02: pocet hodin v danem dni kdy byly srazky nenulove.
# CASE WHEN pro identifikaci duplicitnich dat. 
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

WITH weather_non_zero_rain AS (
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
)
SELECT 
     *,
     CASE WHEN ((CAST(Hours_of_rain AS INT) - timestamp_difference) != 0) THEN 0 ELSE 1 END AS continuous_rain
FROM weather_non_zero_rain;


#
#SELECT 
#   twnzr.`date`, MAX(twnzr.TIME_RANK) AS NUMBER_OF_TIME_ENTRIES_WITH_NON_ZERO_RAIN
#FROM t_weather_non_zero_rain twnzr 
#GROUP BY twnzr.`date`;

#SELECT w.`date`, w.rain, w.`time`, w.city
#FROM weather w 
#WHERE w.`date` = '2021-01-06' AND w.city = 'Prague' AND w.rain NOT LIKE '0.0 mm';
#
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# 03: Maximalni sila vetru behem dne
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SELECT 
	w.`date`, w.city,
	MAX(CAST(TRIM(SUBSTRING(w.wind,1,2)) AS INT)) AS Max_Wind_Speed_in_kmh
FROM weather w
WHERE w.city IS NOT NULL
GROUP BY w.`date`, w.city
ORDER BY w.city ASC;

#SELECT 
#	w.`date`, w.city, w.wind
	#MAX(CAST(SUBSTRING(w.wind,1,2) AS INT)) AS Max_Wind_Speed_in_kmh
#FROM weather w
#WHERE w.`date` = '2020-01-01' AND w.city = 'Athens';


# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#04 - New Table based on data from weather table - 01 - 03
# xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

CREATE OR REPLACE TABLE t_EU_Weather_Summary AS (
SELECT 
    rain_information.`date`, rain_information.city, 
    rain_information.Number_of_non_zero_entries,
    rain_information.Hours_of_rain,
    rain_information.Rain_Started_at,
    rain_information.Rain_Ended_at,
    rain_information.timestamp_difference,
    rain_information.continuous_rain,
    temp_info.average_day_temperature,
    wind_info.Max_Wind_Speed_in_kmh
FROM (
		WITH weather_non_zero_rain AS (
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
			)   base
		)
		SELECT 
		     *,
		     CASE WHEN ((CAST(Hours_of_rain AS INT) - timestamp_difference) != 0) THEN 0 ELSE 1 END AS continuous_rain
	   FROM weather_non_zero_rain wi
      )  rain_information
LEFT JOIN 
		    (
				SELECT
				    w.city, 
		    		ROUND(AVG(CAST(TRIM(SUBSTRING(w.temp,1,2)) AS INT)),2) AS average_day_temperature
				FROM weather w
				WHERE CAST(w.`time` AS TIME) BETWEEN '08:00' AND '18:00' AND w.city IS NOT NULL
				GROUP BY w.city
			) temp_info
ON rain_information.city = temp_info.city
LEFT JOIN
          (
		        SELECT 
				w.`date`, w.city,
				MAX(CAST(TRIM(SUBSTRING(w.wind,1,2)) AS INT)) AS Max_Wind_Speed_in_kmh
				FROM weather w
				WHERE w.city IS NOT NULL
				GROUP BY w.`date`, w.city
				ORDER BY w.city ASC
          ) wind_info
ON rain_information.city = wind_info.city
)
;

UPDATE t_EU_Weather_Summary
       SET city = 'Athenai'
       WHERE city = 'Athens';
UPDATE t_EU_Weather_Summary
       SET city = 'Bruxelles [Brussel]'
       WHERE city = 'Brussels';
UPDATE t_EU_Weather_Summary
       SET city = 'Bucuresti'
       WHERE city = 'Bucharest';
UPDATE t_EU_Weather_Summary
       SET city = 'Helsinki'
       WHERE city = 'Helsinki [Helsingfors]';
UPDATE t_EU_Weather_Summary
       SET city = 'Kyiv'
       WHERE city = 'Kiev';
UPDATE t_EU_Weather_Summary
       SET city = 'Lisboa'
       WHERE city = 'Lisbon';
UPDATE t_EU_Weather_Summary
       SET city = 'Luxembourg [Luxemburg/L'
       WHERE city = 'Luxembourg';
UPDATE t_EU_Weather_Summary
       SET city = 'Praha'
       WHERE city = 'Prague';
UPDATE t_EU_Weather_Summary
       SET city = 'Roma'
       WHERE city = 'Rome';
UPDATE t_EU_Weather_Summary
       SET city = 'Wien'
       WHERE city = 'Vienna'; 
UPDATE t_EU_Weather_Summary
       SET city = 'Warszawa'
       WHERE city = 'Warsaw';
      
      
SELECT *
FROM t_EU_Weather_Summary
WHERE city = 'Kyiv';
      

# Cities which are not included in the country table but are specified in the weather table. 
SELECT DISTINCT
c.capital_city, w.city
FROM countries c 
RIGHT JOIN weather w 
ON c.capital_city = w.city
WHERE c.capital_city IS NULL
ORDER BY w.city ASC;

# Cities which are not included in the weather table but are specified in the country table. 
SELECT DISTINCT
c.capital_city, w.city
FROM countries c 
LEFT JOIN weather w 
ON c.capital_city = w.city
WHERE w.city IS NULL
ORDER BY c.capital_city ASC;

# Selects distinct cities from countries table. 
SELECT DISTINCT 
   c.capital_city 
FROM countries c;

# Selects distinct cities from countries.  
SELECT DISTINCT 
   city
FROM weather w;