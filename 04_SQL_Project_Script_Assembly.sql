# Section nr. 1
CREATE OR REPLACE VIEW v_religion_percentage_per_country AS (
SELECT 
     base.`year`, base.country, a.religion,
     ROUND((a.population / base.total_population * 100),2) AS percentage_value_religion
FROM (
     SELECT r.`year`, r.country,
     SUM(r.population) AS total_population
     FROM religions r
     WHERE r.`year` = 2020
     GROUP BY r.country
) base
RIGHT JOIN (
     SELECT r2.`year`, r2.country, r2.religion, r2.population
     FROM religions r2
     WHERE r2.`year` = 2020) a
ON base.country = a.country
);

SELECT 
    base.`date`, base.country, base.weekend, base.season, 
    covid_19_values.confirmed,
    covid_19_values.tests_performed,
    covid_19_values.confirmed_per_100k,
    covid_19_values.percentage_of_positive_tests,
    pd.population_density,
    GDP_economies.GDP_per_inhabitant,
    gini.Average_GINI,
    mortality.children_mortality_in_2019,
    median.median_age_2018,
    LE_Diff.Life_Expectancy_50year_Difference,
    christianity_prctg.percentage_value_religion AS 'Christianity Percentage',
    islam_prctg.percentage_value_religion AS 'Islam Percentage',
    unaff_rel_prctg.percentage_value_religion AS 'Unaffiliated Religions Percentage',
    hinduism_prctg.percentage_value_religion AS 'Hinduism Percentage',
    buddhism_prctg.percentage_value_religion AS 'Buddhism Percentage',
    folk_rel_prctg.percentage_value_religion AS 'Folk Religions',
    oth_rel_prctg.percentage_value_religion AS 'Other Religions',
    judaism_prctg.percentage_value_religion AS 'Judaism',
    weather_info.*
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
    SELECT
	   base1.*,
	   tests.tests_performed,
	   (base1.confirmed / pop.population)*100000 AS confirmed_per_100k,
	   (base1.confirmed / tests.tests_performed)*100 AS percentage_of_positive_tests
	FROM (
		SELECT
		cbd.`date`, cbd.country, cbd.confirmed
		FROM covid19_basic_differences cbd
	    ) base1
	LEFT JOIN (
		SELECT  
		ct.country, ct.`date`, ct.tests_performed 
		FROM covid19_tests ct 
		WHERE ct.tests_performed IS NOT NULL
		) tests
	ON base1.country = tests.country
	AND base1.`date` = tests.`date`
	LEFT JOIN (
	    SELECT
	    	c.country, c.population
	    FROM countries c
	    WHERE c.population > 0 AND c.population IS NOT NULL
	   ) pop
	ON base1.country = pop.country
    ) covid_19_values
    ON base.country = covid_19_values.country
    AND base.`date` = covid_19_values.`date`
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
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Christianity'
     ) christianity_prctg
   ON base.country = christianity_prctg.country 
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Islam'
     ) islam_prctg
   ON base.country = islam_prctg.country
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Unaffiliated Religions'
     ) unaff_rel_prctg
   ON base.country = unaff_rel_prctg.country
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Hinduism'
     ) hinduism_prctg
   ON base.country = hinduism_prctg.country
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Buddhism'
     ) buddhism_prctg
   ON base.country = buddhism_prctg.country
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Folk Religions'
     ) folk_rel_prctg
   ON base.country = folk_rel_prctg.country
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Other Religions'
     ) oth_rel_prctg
   ON base.country = oth_rel_prctg.country
   LEFT JOIN 
     (
       SELECT 
           vrppc.country, vrppc.percentage_value_religion 
       FROM v_religion_percentage_per_country vrppc 
       WHERE religion = 'Judaism'
     ) judaism_prctg
   ON base.country = judaism_prctg.country
   LEFT JOIN 
      (
		SELECT 
			base2.country,
			base2.capital_city,
			tews.*
		FROM countries base2
		LEFT JOIN t_eu_weather_summary tews 
		ON base2.capital_city = tews.city
       ) weather_info
    ON base.country = weather_info.country
    AND base.`date` = weather_info.`date`
;



