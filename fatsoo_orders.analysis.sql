create database fatsoo
use fatsoo;
drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-01-03'),
(3,'2021-01-08'),
(4,'2021-01-15');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-01-04 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2020-01-08 21:30:45','25km','25mins',null),
(8,2,'2020-01-10 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2020-01-11 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','2021-01-01  18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,2,'4','','2021-01-04 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


#1
select count(order_id)as total_roll_orders
 from customer_orders;
 
#2
select count(distinct customer_id) as unique_customer from 
customer_orders;

#3
select driver_id ,count(order_id) from driver_order
where cancellation not in( 'Cancellation' ,'Customer Cancellation')
 group by driver_id ;
 
 
 #4
 create view mytable as
 select * from 
 (select *, case when cancellation in('Cancellation','Customer Cancellation') 
 then 'c' else 'nc' end as total_delivered_order
 from driver_order)d where total_delivered_order ='nc';
 
select d.roll_name, count(b.roll_id) as number_of_rolls
from  customer_orders b   join 
mytable c on b.order_id=c.order_id join rolls d on d.roll_id=b.roll_id
 group by d.roll_name;
 
 #5
 
 select a.customer_id ,b.roll_name,count(a.roll_id)as rolls_ordered 
 from customer_orders a
 join rolls b on a.roll_id=b.roll_id
 group by a.customer_id,a.roll_id,roll_name order by a.customer_id,roll_name;
 
 
 #6
  create view mytable as
 select * from 
 (select *, case when cancellation in('Cancellation','Customer Cancellation') 
 then 'c' else 'nc' end as total_delivered_order
 from driver_order)d where total_delivered_order ='nc';
 
 
select a.order_id, count(a.roll_id)as numer_of_rolls from customer_orders a
join mytable b on a.order_id=b.order_id 
group by a.order_id order by  count(a.roll_id) desc limit 1;


#7
with 
new_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
as
( select order_id,customer_id,roll_id, 
case when not_include_items ="" or not_include_items is null then 0 else not_include_items end as new_include_items_orders,
case when extra_items_included="" or extra_items_included ='Nan' or extra_items_included is null then 0 else extra_items_included end as new_extra_items_included,
order_date 
from customer_orders
)
select a.customer_id,count(*)as atleast_one_items_included from new_customer_orders a join mytable b
on a.order_id=b.order_id where not_include_items !=0  or extra_items_included!=0
group by a.customer_id;

with new_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
as
( select order_id,customer_id,roll_id, 
case when not_include_items ="" or not_include_items is null then 0 else not_include_items end as new_include_items_orders,
case when extra_items_included="" or extra_items_included ='Nan' or extra_items_included is null then 0 else extra_items_included end as new_extra_items_included,
order_date 
from customer_orders
)
select a.customer_id,count(*)as not_included_any_items from new_customer_orders a join mytable b
on a.order_id=b.order_id where not_include_items =0  and extra_items_included=0
group by a.customer_id;


#8
with new_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
as
( select order_id,customer_id,roll_id, 
case when not_include_items ="" or not_include_items is null then 0 else not_include_items end as new_include_items_orders,
case when extra_items_included="" or extra_items_included ='Nan' or extra_items_included is null then 0 else extra_items_included end as new_extra_items_included,
order_date 
from customer_orders
)
select a.customer_id,count(*)as included_and_notextra_included from new_customer_orders a join mytable b
on a.order_id=b.order_id where not_include_items >0 and extra_items_included>0
group by a.customer_id;

#9
select hour(order_date),count(roll_id) as hours from customer_orders 
group by hour(order_date);

#10
with new_table as(
select weekday(order_date)as week_name,
count(distinct order_id) as number_of_orders  from customer_orders
group by weekday(order_date) order by weekday(order_date)
)
select * ,
case when week_name =0   then 'Monday' 
when week_name=4 then 'Friday'
when week_name=5 then 'Saturday' 
when week_name=6 then 'Sunday'
else week_name
end as week_day from new_table;


#11
# avg time calculate
#1=  do it with mytable which has no cancellation
#get the  minutes on pickup time and order time
#2 then get the difference of time differenceminutes 
#3 sum(minutes and  count(orders  then get the avg by minutes/orders




