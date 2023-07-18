/*After we downloaded the data from 12 months CSV files, and we saw the data, 

We will import our CSV files for the 12 months to SSMS , while we were importing files there was some files that needed to be little cleaned 
for example October month didn’t succed in importing because it has 4 columns that were having too much ##### values in time_length column , we deleted this little dirty data that was caused by error in not ordering dates in order and so when we substitute one newer date from older it caused this issue , we deleted them and continue uploading our 12 csv files, and we will just type the data type as proper in each file , but we will unite all the data types later when we create the new table that will represent the whole year , 


now after we importing the 12 tables, we notice that in general the ride_id is commonly represented by 16 characters , so we will delete those columns that will have not that number on characters :
*/

-- Sql cleaning  for ride_id that doesn't have excatly 16 characters

DELETE FROM [dbo].[202206-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202207-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202208-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202209-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202210-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202211-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202212-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202301-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202302-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202303-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202304-divvy-tripdata]
      WHERE len(ride_id) <> 16
DELETE FROM [dbo].[202305-divvy-tripdata]
      WHERE len(ride_id) <> 16
/*
(512 rows affected)

(543 rows affected)

(529 rows affected)

(463 rows affected)

(404 rows affected)

(216 rows affected)

(119 rows affected)

(127 rows affected)

(140 rows affected)

(169 rows affected)

(261 rows affected) 

(389 rows affected)*/

--now we creat new table and will name it year_data

CREATE TABLE year_data(
ride_id nvarchar(50),
rideable_type nvarchar(50),
started_at datetime2(0), -- we want to see time in yyyy-mm-dd hh:mm:ss only ,we don't need fractions of seconds
ended_at datetime2(0),
start_station_name nvarchar(100), -- I chose (100) that because we have some names more than 50 chars--
start_station_id nvarchar(100),        
end_station_name nvarchar(100),
end_station_id nvarchar(100),
start_lat decimal(10,5),   --because 5 digits after comma is enough for latitude and longitude for our case--
start_lng decimal(10,5),            --this is enough precision to locate a tree on GPS--
end_lat decimal(10,5),
end_lng decimal(10,5),
member_casual nvarchar(50),
ride_length time(0), --I only need hours and minutes and seconds--
week_day tinyint,
)

-- we insert out 12 initally cleaned tables 
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202206-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202207-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202208-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202209-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202210-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202211-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202212-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202301-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202302-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202303-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202304-divvy-tripdata]
insert into [capstone].[dbo].[year_data]
select *
FROM [capstone].[dbo].[202305-divvy-tripdata]

/* now we combined the tables of 12 monhts to 1 year table

this was the rows inserted to the new table
(768692 rows affected)

(822945 rows affected)

(785403 rows affected)

(700876 rows affected)

(558281 rows affected)

(337478 rows affected)

(181687 rows affected)

(190174 rows affected)

(190305 rows affected)

(258509 rows affected)

(426329 rows affected)

(604438 rows affected)*/

-- We ran the code 
select*
From year_data 

--and then save the results as CSV file, so that we will have a copy of this new table 
--5825117 rows created 

--now we will validate the bike types
select rideable_type
from year_data
where rideable_type not in ('electric_bike','docked_bike','classic_bike')

select member_casual
from year_data
where member_casual not in ('member','casual')

/*we validate these two columns
now we will check that we have no errors in times and no incosistat or incorrect time periods as a step of cleaning data :
*/

select started_at,ended_at
from year_data
where started_at not between '2022-06-01' and '2023-06-01'
or 
ended_at not between '2022-06-01' and '2023-06-01'
order by started_at

 --there are 121 rows that not in this range, we will delete them by following code:
delete from year_data
where 
started_at not between '2022-06-01' and '2023-06-01'
or 
ended_at not between '2022-06-01' and '2023-06-01'
/*
now we notice that there are lot of null values in stations name in start or end or both ,
we might have solution for that by benefit from lat and lng values, 
at first we want to make sure the coordinate is in proper in Chicago  and around it ,
we will look to min and max value to validate this  
*/
--we want to check stations id now-- 
select 
max(start_lat) as maximum_starting_lat,
max(start_lng) as maximum_starting_lng,
max(end_lat) as maximum_end_lat,
max(end_lng) as maximum_end_lng,
min(start_lat) as minimum_starting_lat,
min(start_lng) as minimum_starting_lng,
min(end_lat) as minimum_end_lat,
min(end_lng) as minimum_end_lng
from year_data

/*
after we took the maximum value for each lng and lat , (41.55000,-88.11000) and check on google map, we found the location is still in Chicago, we the values are reliable 

speaking on latitude and longitude, I think it is better to combine the columns to form the coordinates as (Latittude,longitude), so I will combine the columns of start_lat and start_lng as start_cord , and will also combine end_lat and end_lng as end_cord 
*/
--we created new column 
ALTER TABLE [dbo].[year_data]
ADD start_cord VARCHAR(50), --we make it char because it won’t stay float anymore--
    end_cord VARCHAR(50);

--then we make our code to combine the two 4 old columns into the new 2 columns 
UPDATE [dbo].[year_data]
   SET 
   start_cord = concat(start_lat,',',start_lng),
   end_cord = concat(end_lat,',',end_lng);

--we will delete the old 4 columns of coordinates 
ALTER TABLE year_data
DROP COLUMN start_lat
ALTER TABLE year_data
DROP COLUMN start_lng
ALTER TABLE year_data
DROP COLUMN end_lat
ALTER TABLE year_data
DROP COLUMN end_lng

/*now my hypotheses if there is any values of start_start_station_name or start_station_id or start_cord we can examinate later if we can find one of them based on the other two values, but if non of these three exist , we will delete the entire ride row  */
select start_station_name,start_station_id,start_cord
from year_data
where 
start_station_name is null  
and                                            
start_station_id is null
and
len(start_cord) <> 18  
/*
I chose 18 char as following :
7 numbers in each side , which means total 14 
The ‘ , ‘ 
The two commas 
And the negative singe in the lng side 

The result was: 591 rows
We will delete them
*/

--we executed the same code but on end_stations 

select end_station_name,end_station_id,end_cord
from year_data
where 
end_station_name is null  
and                                            
end_station_id is null
and
len(end_cord) <> 18  
--we found 479 row, we delete them

/*now , I want to check the ride_length if it has any null values, which probably might be due to more than 24 hours ride duration */

select count(*) as count_the_rides
from year_data
where ride_length is null

--the result were only  195, small number we delete and ignore !

/*now we will backup again our work since we made lot of steps so far in out cleaning and processing 
we want to fill the tons of empty cells in cells that in stations names and IDs 
first we want to have a look on the maximum number of chars*/

select 
max(len(start_station_name)) as max_start_station_char,
max(len(end_station_name)) as max_end_station_char,
max(len(start_station_id)) as max_end_station_id_char,
max(len(end_station_id)) as max_end_station_id_char
from year_data

--the results are quite untestable for names , but for stations IDs are not , so we’ll look into that 
--if we apply this code:
--we will tirm spaces as following
update year_data 
set end_station_id =
REPLACE(SUBSTRING(end_station_id, 1, 12), ' ', '')

select len(start_station_id) as length_char,
count(*) as counting
from year_data
group by len(start_station_id)
/*
length_char	counting
9	9
3	312842
12	2468845
6	198281
10	7949
4	13854
5	1978305
NULL	833297
2	2848
11	1577

I can’t know for sure if there is a special format for the station ID , so I won’t edit it , 
Let’s explore more about the dataset we have , 

now we will check if each station_name has it unique station_id value by implementing this code:
for starting stations: */
SELECT start_station_name, COUNT(DISTINCT start_station_id) AS distinct_ids
FROM year_data
GROUP BY start_station_name
HAVING COUNT(DISTINCT start_station_id) > 1   
/*The result: showed me there are 16 start stations that has more than one ID 
Let’s look if this is the case with ending station */

--For ending stations: 
SELECT end_station_name, COUNT(DISTINCT end_station_id) AS distinct_ids
FROM year_data
GROUP BY end_station_name
HAVING COUNT(DISTINCT end_station_id) > 1
/*
The result was much more than starting stations so we won’t count much on station_id since they are repeated a lot on many stations !

For further explorers we want to know the month, the day, and the hour that the rides started  
We apply this code to create the new columns: 
*/

alter table year_data
add 
start_month int,
start_day varchar(20),
start_hour int

--then we insert our data as following: 
update year_data
set
start_month = datepart(month,started_at),
start_day = datename(weekday,started_at),
start_hour = datepart(hour,started_at)

--we won’t need the week_day column anymore , we will delete it:
alter table year_data
drop column week_day

/*
before we backup, we will write following code to make sure that columns that we checked or created don’t have nulls which are the columns that we will work on heavily in our analysis: 
*/




select *
from year_data
where 
ride_id is null
or
rideable_type is null 
or 
member_casual is null 
or
ride_length is null
or
start_cord is null
or 
end_cord is null
/*
no rows in results , now we back up and export it as CSV file to further analysis and watch some plots 