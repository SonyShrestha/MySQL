-- Author: Sony Shrestha
-- Date: 2021-07-27
-- Description: From Course: Lynda - MySQL Advanced Analytics Tips Tricks Techniques
create database website;
use website;

DROP TABLE IF EXISTS `website_visits` ;

CREATE TABLE `website_visits` (
  `ID` int(11) NOT NULL,
  `CUSTOMER_NAME` varchar(255) DEFAULT NULL,
  `CUSTOMER_TYPE` int(11) DEFAULT NULL,
  `DATE_STARTED` datetime DEFAULT NULL,
  `DURATION` double DEFAULT NULL,
  `GENDER` varchar(45) DEFAULT NULL,
  `AGE` int(11) DEFAULT NULL,
  `SALARY` int(11) DEFAULT NULL,
  `REVIEW_DURATION` double DEFAULT NULL,
  `RELATED_DURATION` double DEFAULT NULL,
  `PURCHASED` int(11) DEFAULT 0,
  `IS_MALE` int(11) DEFAULT NULL,
  `IS_FEMALE` int(11) DEFAULT NULL,
  `VIEWED_REVIEW` int(11) DEFAULT NULL,
  `VIEWED_RELATED` int(11) DEFAULT NULL,
  `AGE_RANGE` varchar(255) DEFAULT NULL,
  `SALARY_RANGE` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



-- For fast loading of data 
# Disable these to avoid extra work
set unique_checks = 0;
set foreign_key_checks = 0;
set sql_log_bin=0;
set autocommit = 0;



# load data from csv
LOAD DATA INFILE 
'D:/website_visit_data.csv'
INTO table `website_visits` 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


# LOAD DATA FROM CSV FILE
-- Use this if you want to perform some sort of field mapping and cases when loading data from CSV to Table
LOAD DATA INFILE 
'D:/website_visit_data.csv'
INTO table `website_visits` 
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@ID, @CUSTOMER_NAME ,@CUSTOMER_TYPE, @DATE_STARTED, @DURATION,@GENDER,@AGE,@SALARY,@REVIEW_DURATION,@RELATED_DURATION,@PURCHASED )
set 
ID=@ID,
CUSTOMER_NAME=@CUSTOMER_NAME,
CUSTOMER_TYPE=@CUSTOMER_TYPE,
DATE_STARTED=@DATE_STARTED,
DURATION=@DURATION,
GENDER=@GENDER,
AGE=@AGE,
SALARY=@SALARY,
REVIEW_DURATION=(SELECT CASE WHEN LENGTH(@REVIEW_DURATION)=0 THEN 0 ELSE @REVIEW_DURATION END),
RELATED_DURATION=(SELECT CASE WHEN LENGTH(@RELATED_DURATION)=0 THEN 0 ELSE @RELATED_DURATION END);




set unique_checks = 1;
set foreign_key_checks = 1;
set sql_log_bin = 1;
set autocommit = 1;




-- Returns index at which given substring is found in given field
select customer_name,instr(CUSTOMER_NAME,',') from website.website_visits; 


-- Replace , with space
set sql_safe_updates=0;
update website.website_visits set customer_name=replace(customer_name,',',' ');


select * from website.website_visits;


-- update is_male,is_female
update website.website_visits
set 
is_male=case when gender='Male' then 1 else 0 end,
is_female=case when gender='Female' then 1 else 0 end,
viewed_review=case when review_duration>0 then 1 else 0 end,
viewed_related=case when related_duration>0 then 1 else 0 end;



select * from website.website_visits;


-- Age binning
update website.website_visits
set age_range=concat(floor(age/10)*10,'-',floor(age/10)*10+10);


-- Update Salary Range
update website.website_visits
set salary_range= 
case 
when salary<50 then '<50K'
when salary>=50 and salary<=150 then '50-150K'
else '>150K' end ;



-- Convert Rows to Column and Column to rows
-- Converting Columns to Rows is achieved by using UNION
select * from website.website_visits;

select ID,CUSTOMER_NAME,'Viewed Review' as description, REVIEW_DURATION from website.website_visits
where REVIEW_DURATION>0
UNION 
select ID,CUSTOMER_NAME,'Viewed Related Product' as description, RELATED_DURATION from website.website_visits
where RELATED_DURATION>0
ORDER BY 1;


-- Converting Rows to Columns
select 
AGE_RANGE,
sum(case when gender='Male' then 1 else 0 end) as male_count,
sum(case when gender='Female' then 1 else 0 end) as female_count from website.website_visits
group by AGE_RANGE;



-- Statistical Functions
select 
count(1),
sum(salary),
avg(salary),
min(salary),
max(salary),
STDDEV_SAMP(salary),
STDDEV_POP(salary),
VAR_SAMP(SALARY),
var_pop(SALARY),
VARIANCE(SALARY)
from website.website_visits;


-- Values can be set into variable in this way
select 
@_count:=count(1),
@_sum:=sum(salary)
from website.website_visits;


select @_count,@_sum;


-- find percentile value
SHOW VARIABLES LIKE '%group_concat%';
SET group_concat_max_len=100000000;

SELECT  
substring_index(substring_index(GROUP_CONCAT(salary ORDER BY salary SEPARATOR ','),',', 25/100 * COUNT(*) + 1 ),',',-1)
FROM   website.website_visits;