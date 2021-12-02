# Engeto_Academy-SQL_Project
I will track here the SQL project activity within Engeto Data Academy

1. 01_SQL_Project_Script_Weekend_Season_V01
----------------------------------------
      File contains MariaDB code that creates a new table containing following output data:
          a. date
          b. country .
          c. weekend column - assigns 1 value to rows where day from "date" column corresponds to weekend, 0 for working day
          d. season column  - assigns 0 for spring season, 1 for summer, 2 for autumn, 3 for winter
      
     UPDATE 24-11-2021:
 		number of confirmed cases and performed test are summarized for each day and country
		percentage value of positive tests is calculated
		number of confirmed cases per 100 000 inhabitants is calculated.

2. 02_SQL_Project_Script_Country_Variables_V01
----------------------------------------
      SQL code provides following output:
      a. View named "v_hustota_zalidneni" is created as simple SELECT command from "countries" table. 
          output is: country and population_density
      b. SELECT outputs GDP per inhabitant as GDP/population for each individual country
      c. average GINI coefficient for each individual country in range between 1960 and 2020 rounded to 2 digits
      d. Child mortality in 2019 as per *SELECT e.mortaliy_under5 for each individual country
          Year 2019 was selected since this is the last year that data are available for and Covid-19 pandemic started in 2019. 
      e. median age in 2018 from countries table
      f. percentage value for each religion in every single country in 2020
         Year 2020 is the most critical time period from Covid19 pandemic perspective and vaccination was not available at this time.  
      g. Life expectancy delta value between 1965 and 2015 was calculated for every single country
         Command uses JOIN keyword. 
         
 3. 03_SQL_Project_Script_Weather_V01
----------------------------------------
      a. Scripts calculates average temperature for each city, it filters time range 8:00-18:00 and lines where city is NULL by using WHERE clause
         Data are grouped by city.
         Average temperature is rouded to 2 decimal digits. 
         
         --> SUBSTRING() function allows to extract only first 2 characters from the text string
         --> TRIM() - prefixes and suffixes were removed. 
         --> CAST() - changes the data type to INTEGER
         --> ROUND() - rounds the resultant number to 2 decimal digits. 
         
      b. Hours of rain Calculation
          Sub-select: named "base"
          ===========
          date, city, rain and time columns are selected. 
          The column named "rain" in weather table is text data type variable. 
          Non-zero rain entries are filtered by WHERE clause in combination with LIKE + cities with NULL entry are excluded as well. 
          data are grouped by date and city and ordered ascending by city name. 
          Two additional columns were created:
                - Rain started at -> as minimum for each date and city. Data type is changed by CAST function to TIME 
                - Rain ended at -> as maximum for each date and city + 3 hours. Data type is changed by CAST function to TIME
                                          SQL code assumes that the rain continued for next 3 hours after occurence of last non-zero entry. 
          It calculates number of non-zero rain entries as "Number_of_non_zero_entries" by COUNT() function - 
                  => Assumption: 1 Entry corresponds to rain duration length of 3 hours. 
          
        Common Expression Table: named "weather_non_zero_rain"
        =======================
        It uses WITH keyword to select the data from subselected "base":
             date, city, Number_of_non_zero_entries, 
        
        The CASE WHEN condition is defined to search for duplicities in the rain entries - especially Prague and Vienna cities have got rain duplicities for given date. 
              Maximum number of rain entries can´t be higher than 8, higher value indicates duplicity in the data entry.
              Number of rain enties are multiplied by 3 and new column "Hours_of_rain" is gained as result of CASE WHEN condition. 
        
        Values in Rain_Started_at and Rain_Ended_at are substracted by using of fuction TIMEDIFF and new column "timestamp_difference" is defined. 
       
        Final SELECT from Common Expression Table:
        ===========================================
        all data from common expresssion table are selected and new column named "continuous_rain" is added:
            CASE WHEN function checks if the "timestamp_difference is equal" to "Hours_of_rain" which may indicate if the rain was continous during the whole day or not. 
                  This information can be further used for reduction of number of hours for those days where the rain was not continous. Any specific scaling factor < 1 can be defined for 
                  hours calculation for those days -> is not implemented at the moment. 
       
       c. Maximal wind speed for every day and city 
          Data are grouped by date and city. 
         --> MAX function is searching for maximum value of each data set defined by date and city. 
         --> SUBSTRING() function allows to extract only first 2 characters from the text string
         --> TRIM() - prefixes and suffixes were removed. 
         --> CAST() - changes the data type to INTEGER in this special case
         --> ROUND() - rounds the result to 2 decimal digits. 
         
     03_SQL_Project_Script_Weather_V02
----------------------------------------
      
         Script extension which fixes different names in table countries and weather.
         Extra SQL command sequence is written to get city names, that are defined in the "weather" table but are not included in the "countries" table. 
          --> in total 11 city names are not consistent, which makes problems during the joining process. 
         In order to fix it a new table named "t_EU_Weather_Summary" is created and it includes the information about the maximal wind speed for each day,
         as well as the info about the hours of rain and average temperature during the day.
         
         -> UPDATE command changes the city names according to table "countries" to allow table JOIN.
         Weather information is available only for the european countries!

         
	04_SQL_Project_Script_Assembly - Final SQL file that can be executed. 
 -----------------------------------------------------------------------------
	File consists of 4 Parts:
	A. table including weather information for european coutries named "t_EU_Weather_Summary"
	B. "t_EU_Weather_Summary" is updated and names of 11 cities are changed in order to match with the table named "countries"
	C. CREATE VIEW is defined to extract data from religion table and to output religion percentage value for each religion.
	D. Main SQL Section:
		- base table is defined using data from table named 'covid19_basic_differences'
				-> "date" column is analyzed like described in 2f.
		- data regarding covid-19 values are joined
				-> number of confirmed cases
				-> number of total performed tests
				-> number of confirmed per 100000 inhabitants of population
				-> percentage value of positive tests performed. 
		- data from 2. 02_SQL_Project_Script_Country_Variables_V01 are joined.
  				-> population density
				-> GDP per inhabitant
				-> GINI coefficient
				-> children mortality
				-> median age in 2018
				-> Life expectancy difference in range between 2015 and 1965
		- religion percentage for every single religion joined referencing created view from C.
		- weather data for european countries from new table named "t_EU_Weather_Summary"
 




   
             
