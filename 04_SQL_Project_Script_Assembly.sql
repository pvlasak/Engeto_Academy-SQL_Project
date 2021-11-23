# Section nr. 1
SELECT 
    base.`date`, base.country, base.weekend, base.season, 
    pd.population_density,
    GDP_economies.GDP_per_inhabitant,
    gini.Average_GINI,
    mortality.children_mortality_in_2019,
    median.median_age_2018,
    LE_Diff.Life_Expectancy_50year_Difference
FROM (
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
    ) base
	LEFT JOIN 
	   (
	   SELECT country,
	   population_density
	   FROM countries 
	   ) pd
	ON base.country = pd.country
	LEFT JOIN 
	   (
	   SELECT country,
	       GDP / population AS GDP_per_inhabitant
	   FROM economies
	   WHERE GDP IS NOT NULL AND `year` = 2020
	   GROUP BY country
	   ) GDP_economies
	ON  base.country = GDP_economies.country
    LEFT JOIN  ( 	
       SELECT country,
       ROUND(AVG(gini),2) Average_GINI
       FROM economies e 
       WHERE gini IS NOT NULL 
       GROUP BY country 
       ) gini
    ON  base.country = gini.country
	LEFT JOIN (
	    SELECT  
	    e.country, e.mortaliy_under5 AS children_mortality_in_2019
		FROM economies e
		WHERE e.`year` = 2019    
       ) mortality
    ON base.country = mortality.country
    LEFT JOIN (
        SELECT 
         c.country, c.median_age_2018 
        FROM countries c
    ) median
    ON base.country = median.country
    LEFT JOIN (
		SELECT 
		   base_lf.country, 
		   ROUND((base_lf.life_expectancy - a.life_expectancy),2) AS Life_Expectancy_50year_Difference
		FROM (
		   SELECT le.`year`, le.country, le.life_expectancy
		   FROM life_expectancy le
		   WHERE le.`year` = 2015 ) base_lf
		JOIN (
		   SELECT le2.`year`, le2.country, le2.life_expectancy 
		   FROM life_expectancy le2 
		   WHERE le2.`year` = 1965
		) a
		ON base_lf.country = a.country
	 ) LE_Diff
	 ON base.country = LE_Diff.country  
;

# Section nr. 2
SELECT 
	base2.country,
	base2.capital_city,
	tews.*
FROM countries base2
LEFT JOIN t_eu_weather_summary tews 
ON base2.capital_city = tews.city
WHERE base2.country = 'Austria'
;


