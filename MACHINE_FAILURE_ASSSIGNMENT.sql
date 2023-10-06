set global local_infile=1;
show variables like 'secure_file_priv';
show variables like '%local%';
select user();
grant file on *.* to 'root'@'localhost';


create table machine_failure(UDI INT,ProductID VARCHAR(20),Type VARCHAR(4),Air_temperature_K FLOAT,
Process_temperature_K FLOAT,Rotational_speed_rpm INT,Torque_Nm FLOAT,Tool_wear_min INT,
Machine_failure INT,TWF INT,HDF INT,PWF INT,OSF INT,RNF INT);

load data  infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/machine failure.csv'
into table machine_failure
fields terminated by ',' enclosed by '"' lines terminated by '\n'
ignore 1 rows;

###cols-air,process,rot,tor,tool wear

####FIRST MOMENT BD

##MEAN
select avg(Air_temperature_K) as mean_airtemp from machine_failure;
#'300.004929788208'
select avg(Process_temperature_K) as mean_protemp from machine_failure;
#'310.0055601776123'
select 
avg(Rotational_speed_rpm) as mean_rotspeed,
avg(Torque_Nm) as mean_torque,
avg(Tool_wear_min) as mean_toolwear
from machine_failure;
### mean_rotspeed, mean_torque, mean_toolwear
###'1538.7761', '39.98690999906063', '107.9510'


###MEDIAN
select (Air_temperature_K) as med_airtemp
from(
select Air_temperature_K,row_number() over (order by Air_temperature_K) as row_num,
count(*) over () as tot_count from machine_failure) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#300.1

select (Process_temperature_K) as med_protemp
from(
select Process_temperature_K,row_number() over (order by Process_temperature_K) as row_num,
count(*) over () as tot_count from machine_failure) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#310.1

select (Rotational_speed_rpm) as med_rotsp
from(
select Rotational_speed_rpm,row_number() over (order by Rotational_speed_rpm) as row_num,
count(*) over () as tot_count from machine_failure) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#1503

select (Torque_Nm) as med_tor
from(
select Torque_Nm,row_number() over (order by Torque_Nm) as row_num,
count(*) over () as tot_count from machine_failure) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#40.1

select (Tool_wear_min) as med_toolwear
from(
select Tool_wear_min,row_number() over (order by Tool_wear_min) as row_num,
count(*) over () as tot_count from machine_failure) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#108

####MODE
select Air_temperature_K as mode_airtemp
from(
select Air_temperature_K,count(*) as freq
from machine_failure
group by Air_temperature_K
order by freq desc
limit 1) as subquery;
#300.7

select Process_temperature_K as mode_processtemp
from(
select Process_temperature_K,count(*) as freq
from machine_failure
group by Process_temperature_K
order by freq desc
limit 1) as subquery;
#310.6

select Rotational_speed_rpm as mode_rotspeed
from(
select Rotational_speed_rpm,count(*) as freq
from machine_failure
group by Rotational_speed_rpm
order by freq desc
limit 1) as subquery;
#1452

select Torque_Nm as mode_torque
from(
select Torque_Nm,count(*) as freq
from machine_failure
group by Torque_Nm
order by freq desc
limit 1) as subquery;
#40.2

select Tool_wear_min as mode_tool
from(
select Tool_wear_min,count(*) as freq
from machine_failure
group by Tool_wear_min
order by freq desc
limit 1) as subquery;
#0


######INFERENCES
#Air_temperature_K-Since both mean and median vals are almost same,we can say they are normally dist with no prescence of outliers
#Process_temperature_K-Since both the vals ,they are normally dist with no outliers.
#Rotational_speed_rpm-Since mean>median,here they are said to be positively skewed.Since there is a difference in there values,there can outliers present.
#Torque_Nm-Since they are almost similar(40 & 39.9),they can be said to be normally distributed without outliers in the data.
#Tool_wear_min-Since they are almost similar(108 & 107.9),they can be said to be normally distributed without outliers in the data.


####SECOND MOMENT BD
##variance
select 
variance(Process_temperature_K) as var_protemp, 
variance(Air_temperature_K) as var_airtemp,
variance(Rotational_speed_rpm) as var_rotspeed,
variance(Torque_Nm) as var_torque,
variance(Tool_wear_min) as var_toolwear
from machine_failure;
## var_protemp	var_airtemp	var_rotspeed	var_torque	var_toolwear
##2.2012471953377806	4.0006351054689535	32139.57276879006	99.36970199660486	4051.445198999991

##STD
select 
stddev(Process_temperature_K) as std_protemp, 
stddev(Air_temperature_K) as std_airtemp,
stddev(Rotational_speed_rpm) as std_rotspeed,
stddev(Torque_Nm) as std_torque,
stddev(Tool_wear_min) as std_toolwear
from machine_failure;
# std_protemp	std_airtemp	std_rotspeed	std_torque	std_toolwear
#1.4836600673125164	2.000158770065255	179.2751314845148	9.968435283263108	63.6509638497328

######INFERENCES
#Process_temperature_K, Air_temperature_K, Torque_Nm - Here the std values are comparitively less compared to the other std vals,so the data spread is less
#and the points are more clustered around the mean.
#Rotational_speed_rpm, Tool_wear_min -Here the std values are very large,so the data is highly variable and is far from the mean
#It can also indicate the prescence of outliers in it.

#RANGE
select 
max(Process_temperature_K)-min(Process_temperature_K) as r_protemp, 
max(Air_temperature_K)-min(Air_temperature_K) as r_airtemp,
max(Rotational_speed_rpm)-min(Rotational_speed_rpm) as r_rotspeed,
max(Torque_Nm)-min(Torque_Nm) as r_torque,
max(Tool_wear_min)-min(Tool_wear_min) as r_toolwear
from machine_failure;
## r_protemp	r_airtemp	r_rotspeed	r_torque	r_toolwear
##8.0999755859375	9.20001220703125	1718	72.79999852180481	253

###THIRD MOMENT BD
##SKEWNESS
select
 sum(power(Air_temperature_K-(select avg(Air_temperature_K) from machine_failure),3))/
(count(*) *power((select stddev(Air_temperature_K) from machine_failure),3)) as skew
from machine_failure;
#0.11425680383772466

select
 sum(power(Process_temperature_K-(select avg(Process_temperature_K) from machine_failure),3))/
(count(*) *power((select stddev(Process_temperature_K) from machine_failure),3)) as skew
from machine_failure;
#0.01502488349446522

select
 sum(power(Rotational_speed_rpm-(select avg(Rotational_speed_rpm) from machine_failure),3))/
(count(*) *power((select stddev(Rotational_speed_rpm) from machine_failure),3)) as skew
from machine_failure;
#1.9928720166048368

select
 sum(power(Torque_Nm-(select avg(Torque_Nm) from machine_failure),3))/
(count(*) *power((select stddev(Torque_Nm) from machine_failure),3)) as skew
from machine_failure;
#-0.009515170189557984

select
 sum(power(Tool_wear_min-(select avg(Tool_wear_min) from machine_failure),3))/
(count(*) *power((select stddev(Tool_wear_min) from machine_failure),3)) as skew
from machine_failure;
#0.027288145044007204

######INFERENCES
#Air_temperature_K, Process_temperature_K, Tool_wear_min - Since the values are almost close to zero,we can say that these are almost normally distributed and is symmetric.The tais are even.
#Rotational_speed_rpm - Since the value is positive,it is positively skewed and the tails are longer on the right side.
#Torque_Nm -Since the value is negative, it is negatively skewed with the tail being longer on the left side.


###KURTOSIS
select
sum(power(Air_temperature_K-(select avg(Air_temperature_K) from machine_failure),4))/
(count(*) *power((select stddev(Air_temperature_K) from machine_failure),4))-3 as kurt
from machine_failure;
#-0.8361437098452749


select
 sum(power(Process_temperature_K-(select avg(Process_temperature_K) from machine_failure),4))/
(count(*) *power((select stddev(Process_temperature_K) from machine_failure),4))-3 as kurt
from machine_failure;
#-0.5000848435465675


select
 sum(power(Rotational_speed_rpm-(select avg(Rotational_speed_rpm) from machine_failure),4))/
(count(*) *power((select stddev(Rotational_speed_rpm) from machine_failure),4))-3 as kurt
from machine_failure;
#7.388649004260019


select
 sum(power(Torque_Nm-(select avg(Torque_Nm) from machine_failure),4))/
(count(*) *power((select stddev(Torque_Nm) from machine_failure),4))-3 as kurt
from machine_failure;
#-0.013833933344572724

select
 sum(power(Tool_wear_min-(select avg(Tool_wear_min) from machine_failure),4))/
(count(*) *power((select stddev(Tool_wear_min) from machine_failure),4))-3 as kurt
from machine_failure;
#-1.166753784684022


######INFERENCES
#Air_temperature_K, Tool_wear_min, Process_temperature_K - These have negative values.Hence they have wider peak and the tails are light with less extreme values.
#Torque_Nm-Here even if the value is negative we can say that these are very close to normal distribtion as it is 0.01.Hence they are almost symmetric and has lighter tails.
#Rotational_speed_rpm-Since the value is positive ,we can say that these have sharper peaks with heavier tails and have more extreme values.








