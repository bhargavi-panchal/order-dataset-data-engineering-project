create table df_orders(
	[order_id] int primary key
	, [order_date] date
	,[ship_mode] varchar(20)
	,[segment] varchar(20)
	,[country] varchar(20)
	,[city] varchar(20)
	,[state] varchar(20)
	,[postal_code] varchar(20)
	,[region] varchar(20)
	,[category] varchar(20)
	,[sub_category] varchar(20)
	,[product_id] varchar(50)
	,[quantity] int
	,[discount_price] decimal(7,2)
	,[sale_price] decimal(7,2)
	,[profit] decimal(7,2)
);



-- top 10 highest revenue generating products

select top 10 product_id, sum(sale_price) as revenue
from df_orders
group by product_id
order by revenue desc;



-- top 5 highest selling products in each region;



with cte as (
select 
region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id
),
cte2 as (
select 
* , rank() over( partition by region order  by sales desc) as rnk 
from cte
)
select * from cte2
where rnk <=5
;

-- find month over month growth comparison for 2022 and 2023 sales 
--eg jan 2022 vs jan 2023

with cte as (
select 
YEAR(order_date) as Year 
, MONTH(order_date) as month
, sum	(sale_price) as sale_price
from df_orders
group by YEAR(order_date), MONTH(order_date)
)
select 
month,
sum(case when Year='2022' then sale_price else 0 end) as sales_2022,
sum(case when Year='2023' then sale_price else 0 end) as sales_2023
from cte
group by month
order by month;


-- for each category which month had highest sales
--category month

select category,year, month
from 
(
select * , row_number() over( partition by category order by total_sales DESC) as rn
from
(
select category, year(order_date)as year, month(order_date) as month , sum(sale_price) as total_sales
from df_orders
group by category,year(order_date),month(order_date)
) A
) B
WHERE rn=1
;



--which subcategory had highest growth by profit in 2023 compare to 2022

--subcategory profit 2023 profit 22



with cte as (
select 
sub_category,year(order_date) as year, 
sum(profit) as total_profit
from masters.dbo.df_orders
group by sub_category,year(order_date)
--order by sub_category,year(order_date) 
),
cte_2 as (select 
sub_category,
sum(case when year='2022' then total_profit else 0 end) as profit_22,
sum(case when year='2023' then total_profit else 0 end) as profit_23
from cte
group by sub_category)

select
top 1 
profit_23- profit_22 as difference, sub_category
from cte_2
order by difference desc
;