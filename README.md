# Engeto_Academy-SQL_Project
I will track here the SQL project activity within Data academy

1. 01_SQL_Project_Script_Weekend_Season_V01
      File contains MariaDB code that creates a new table containing following output data:
          a. date
          b. country .
          c. weekend column - assigns 1 value to rows where day from date corresponds to weekend, 0 for working day
          d. season column  - assigns 0 for spring season, 1 for summer, 2 for autumn, 3 for winter


2. 02_SQL_Project_Script_Country_Variables_V01
      SQL code provides following output:
      a. View named "v_hustota_zalidneni" is created as simple SELECT command from "countries" table. 
          output is: country and population_density
      b. SELECT outputs GDP per inhabitant as GDP/population for each individual country
      c. average GINI coefficient for each individual country between 1960 and 2020 rouded to 2 digits
      d. Child mortality in 2019 as per SELECT e.mortaliy_under5 for each individual country
          Year 2019 was selected since this is the last year when the data are available and Covid-19 pandemic started in 2019 as well. 
      e. median age in 2018 from countries table
      f. percentage value for each religion in every single country in 2020
         Covid-19 was the most critical year and vaccination was not available.  
      g. Life expectancy delta value between 1960 and 2015 was calculated for every single country
         Command uses JOIN keyword. 
         
 3. 03_SQL_Project_Script_Weather_V01
      a. Scripts calculates average temperature for each city, it filters time range 8:00-18:00  and lines where city is NULL by using WHERE clause
         Data are grouped by city.
         Average temperature is rouded to 2 decimal digits. 
         
         --> SUBSTRING() function allows to extract only first 2 characters from the text string
         --> TRIM() - prefixes and suffixes were removed. 
         --> CAST() - changes the data type to INTEGER in this special case
         --> ROUND() - rounds the result to 2 decimal digits. 
         
      b. Hours of rain calculation
          Sub-select: named "base"
          ===========
          date, city, rain and time columns are selected. 
          The column named "rain" in weather table is text data type. 
          Non-zero rain entries are filtered by WHERE command in combination with LIKE,+ city with NULL entry is excluded as well. 
          data are grouped by date and city and ordered ascending by city name. 
          Two additional columns were created:
                - Rain started at -> as minimum for each date and city. Data type is changed by CAST function to TIME 
                - Rain ended at -> as maximum for each date and city + 3 hours. Data type is changed by CAST function to TIME
                                          SQL code assumes that the rain continued for next 3 hours after last non-zero entry. 
          It calculates number of non-zero rain entries as "Number_of_non_zero_entries" by COUNT() function - 
                  => Assumption: 1 Entry corresponds to rain duration length of 3 hours. 
          
        Common Expression Table: named "weather_non_zero_rain"
        =======================
        It uses WITH keyword to select the data from subselect "base":
             date, city, Number_of_non_zero_entries, 
        
        The CASE WHEN condition is defined to search for duplicities in the rain entries - especially Prague and Vienna cities have got rain duplicities for given date. 
              Maximum number of rain entries can´t be higher than 8, higher value indicates duplicity in the data entry.
              Number of rain enties are multiplied by 3 and new column "Hours_of_rain" is gained as result of CASE WHEN condition. 
        
        Values in Rain_Started_at and Rain_Ended_at are substracted by using of fuction TIMEDIFF and new column "timestamp_difference" is defined. 
       
        Final SELECT from Common Expression Table:
        ===========================================
        all data from common expresssion table are selected and new column named "continuous_rain" is added:
            CASE WHEN function checks if the "timestamp_difference is equal" to "Hours_of_rain" which may indicate if the rain was continous during the whole day or not. 
                  This information can be further used for reduction of number of hours for days where the was not continous. Any specific factor can be defined for 
                  hours calculation for those days -> is not implemented until now. 
       
       c. Maximal wind speed for every day and city 
          Data are grouped by date and city. 
         --> MAX function is searching for maximum value of each data set defined by date and city. 
         --> SUBSTRING() function allows to extract only first 2 characters from the text string
         --> TRIM() - prefixes and suffixes were removed. 
         --> CAST() - changes the data type to INTEGER in this special case
         --> ROUND() - rounds the result to 2 decimal digits. 
         
          
        
   
             
