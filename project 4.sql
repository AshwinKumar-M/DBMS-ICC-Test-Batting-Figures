
-- Part A
Use ICCproject4;

select * from test_batting;

-- 2.	Remove the column 'Player Profile' from the table.

alter table  test_batting drop column `player profile`; 

-- 3.	Extract the country name and player names from the given data and store it in separate columns for further usage.



alter table test_batting add column Player_name varchar(30),add column Country varchar(20);

update test_batting set player_name = substr(player,1,instr(player,'(')-1),
						Country =  substr(player,instr(player,'(')+1 ,(length(substr(player,instr(player,'(')+1)) - 1));


-- 4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.

alter table test_batting add column end_year int after span ,add column start_year int after span;


update test_batting set start_year = substring_index(span,'-',1),
						end_year = substring_index(span,'-',-1);
                        
-- 5.	The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player had completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.


alter table test_batting add column HS_NO int after HS  ,add column High_score int after HS;

update test_batting set High_score = substring_index(HS,'*',1),
						HS_NO = case when substring_index(HS,'*',-1) ='' then 1 
else 0 end;


-- 6.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for India.


select * from (
select Player_name,Avg ,row_number()over(order by Avg desc)as batting_order,Country ,span from test_batting
where start_year <= 2019  and end_year >= 2019
and Country like '%India%') t
where batting_order < 7;


-- 7.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have the highest number of 100s across all matches for India.

select * from (
select Player_name,`100` ,row_number()over(order by `100` desc)as batting_order,Country ,span from test_batting
where start_year <= 2019  and end_year >= 2019
and Country like '%India%') t
where batting_order < 7;

-- 8.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using 2 selection criteria of your own for India.

-- I have  selected RUNS and High_score as Selection Criteria

select * from (
select Player_name,runs,high_score ,row_number()over(order by runs desc,high_score desc)as batting_order,Country ,span from test_batting
where start_year <= 2019  and end_year >= 2019
and Country like '%India%') t
where batting_order < 7;

-- 9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for South Africa.

create view Batting_Order_GoodAvgScorers_SA as
select * from (
select Player_name,Avg ,row_number()over(order by Avg desc)as batting_order,Country ,span from test_batting
where start_year <= 2019  and end_year >= 2019
and Country like '%SA%') t
where batting_order < 7;

select * from Batting_Order_GoodAvgScorers_SA;

-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for South Africa.

create view Batting_Order_HighestCenturyScorers_SA as  
select * from (
select Player_name,`100` ,row_number()over(order by `100` desc)as batting_order,Country ,span from test_batting
where start_year <= 2019  and end_year >= 2019
and Country like '%SA%') t
where batting_order < 7;

select * from Batting_Order_HighestCenturyScorers_SA;


-- 11.	Using the data given, Give the number of player_played for each country.

select COuntry ,count(country) as number_of_players
from test_batting
group by 1; 

-- 12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent
select  * 
from test_batting;


select case when country like '%PAK%' or country in ('Bdesh','AFG') or country like '%India%'
or country like '%SL%'
then 'Asian' else 'Non_Asian' end as Continent ,count(player) as no_of_players
from test_batting
group by 1;


-- Part B

use supply_chain;

-- 1) Company sells the product at different discounted rates. 
-- Refer actual product price in product table and selling price in the order item table. 
-- Write a query to find out total amount saved in each order then display the orders from highest to lowest amount save

SELECT orderid, sum((p.unitprice-oi.unitprice) * oi.quantity)  total_amount_saved from orderitem oi
join product p
on  oi.productid = p.id
group by 1
order by 2 desc;

-- 2 .	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. 
-- Help him to pick: 
-- a. List few products that he should choose based on demand.
-- b. Who will be the competitors for him for the products suggested in above questions.


select oi.productid , sum(oi.quantity) as sales ,p.productname,s.companyname as competitor from orderitem oi
join  product  p
on p.id = oi.productid
join supplier s
on s.id = p.supplierid
 group by 1 
 having sales > 1000
 order by sales desc;
 
 
 -- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
-- ●	Both customer and supplier belong to the same country
-- ●	Customer who does not have supplier in their country
-- ●	Supplier who does not have customer in their country

select concat(firstname,' ',lastname)contactname,city,country,phone  from  customer c where exists ( select country from supplier where country = c.country)
union
(select contactname,city,country,phone from  supplier s where exists
 ( select country from customer where country = s.country))

union
(select concat(firstname,' ',lastname)contactname,city,country,phone  from  customer c
 where not exists ( select country from supplier where country = c.country))
union

(select contactname,city,country,phone from  supplier s 
where not exists ( select country from customer where country = s.country));

-- All the rows from both supplier and customer is being asked
select contactname,city,country,phone from  supplier 
union
select concat(firstname,' ',lastname)contactname,city,country,phone  from  customer ;


/* 4 . Every supplier supplies specific products to the customers. 
Create a view of suppliers and total sales made by their products and write a query on this view to 
find out top 2 suppliers 
(using windows function RANK() in each country by total sales done by the products. */


-- only considering quantity sold as sales 

create view sup_rank1 as
select s.* , sum(oi.quantity) total_sales,rank()over(order by sum(oi.quantity)  desc) as rk from orderitem oi
join product p 
	on p.id = oi.productid
join supplier s
	on s.id = p.supplierid 
group by 1;

select * from sup_rank1 where rk <3; 
-- considering total revenue as sales by calculating unitprice * quantity  
create view sup_rank2 as
select s.* , sum(oi.unitprice * oi.quantity) total_sales,rank()over(order by sum(oi.unitprice*oi.quantity)  desc) as rk from orderitem oi
join product p 
	on p.id = oi.productid
join supplier s
	on s.id = p.supplierid 
group by 1;

select * from sup_rank2 where rk <3;


-- 5 Find out for which products, UK is dependent on other countries for the supply. 
-- List the countries which are supplying these products in the same list


select distinct oi.productid,p.productname,c.country as buying_country
,s.companyname as supplier_name
, s.country as Supplying_country
from orderitem oi
join orders o on oi.orderid = o.id 
join customer c
on c.id = o.customerid and country = 'UK'
join product p
on p.id = oi.productid 
join supplier s
on s.id = p.supplierid
where s.country != 'UK'
;

/*
6.	Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
‘customer’ table attributes -
Id, FirstName,LastName,Phone
‘customer_backup’ table attributes - 
Id, FirstName,LastName,Phone

Create a trigger in such a way that It should insert the details into the  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.

*/
-- since Customer  table already exist in the database ,I will create a table with diffrent name 

create table customer1 (
ID int ,
firstname varchar(20),
lastname varchar(20),
phone varchar(20) 
);

create table customer_backup (
ID int ,
firstname varchar(20),
lastname varchar(20),
phone varchar(20)
);
-- Populating the customer table to check  the tigger condition
insert  into customer1
select Id,firstname,lastname,phone from customer;
select * from customer1;


create trigger customer_backup_after_delete 
before delete on customer1 for each row
insert into customer_backup 
select id,firstname,lastname,phone from customer1 where ID = old.ID;

drop trigger customer_backup_after_delete;

delete from customer1 where id = 3;
