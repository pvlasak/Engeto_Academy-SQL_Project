# A. creates view showing the density of population
CREATE OR REPLACE VIEW v_hustota_zalidneni AS (
   SELECT country,
   population_density
FROM countries 
);

# B. selects data and calculates the GDP per inhabitant
SELECT country,
       GDP / population AS GDP_per_inhabitant,
       gini
FROM economies
WHERE GDP IS NOT NULL AND `year` = 2020
GROUP BY country;

# C. Selects GINI coefficient
SELECT country, 
       ROUND(AVG(gini),2) Average_GINI
FROM economies e 
WHERE gini IS NOT NULL
GROUP BY country;

# D. Selects child mortality in 2019, data for 2020 are not available
SELECT  
     e.country, e.mortaliy_under5 AS children_mortality_in_2019
FROM economies e
WHERE e.`year` = 2019;

# E. Median Age 2018
SELECT 
    c.country, c.median_age_2018 
FROM countries c;

# F. Calculates the percentage value for each individual religion 
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
)
# G. script solves the difference between life expectancy in 2015 and 1965
SELECT 
   base.country, 
   ROUND((base.life_expectancy - a.life_expectancy),2) AS Life_Expectancy_50year_Difference
FROM (
   SELECT le.`year`, le.country, le.life_expectancy
   FROM life_expectancy le
   WHERE le.`year` = 2015 ) base
JOIN (
   SELECT le2.`year`, le2.country, le2.life_expectancy 
   FROM life_expectancy le2 
   WHERE le2.`year` = 1965
) a
ON base.country = a.country;
