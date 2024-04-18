use master;
select * from orders;

--find top 10 highest reveue generating products 

select top 10 product_id, sum(sale_price) as total_reveue
from orders 
group by product_id
order by total_reveue desc;


--find top 5 highest selling products in each region


with cte as (
select region, product_id, sum(sale_price) as total_reveue
from orders 
group by region, product_id),
final_cte as (
select *, ROW_NUMBER() over(partition by region order by total_reveue desc ) as rn
from cte)
select region, product_id, total_reveue
from final_cte 
where rn <= 5;


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as (
select year(order_date) as yr, month(order_date) as mth, sum(sale_price) as growth_per_mth
from orders
group by year(order_date), month(order_date) ),
cte2 as (
select mth, sum(case when yr = 2022 then growth_per_mth else 0 end ) as sales_2022,
sum(case when yr = 2023 then growth_per_mth else 0 end ) as sales_2023
from cte
group by mth)
select * from cte2;


--for each category which month had highest sales
with cte as (
select category, year(order_date) as yr, MONTH(order_date) as mth, sum(sale_price) as sales_per_month
from orders
group by category, year(order_date), MONTH(order_date)
),
final_cte as (
select *, ROW_NUMBER() over(partition by category order by sales_per_month desc) as rn
from cte)
select category, yr, mth, sales_per_month
from final_cte
where rn = 1;


--which sub category had highest growth by profit in 2023 compare to 2022
 
with cte as (
select sub_category, year(order_date) as yr, sum(sale_price) as total_profit_per_year
from orders
group by sub_category, year(order_date) ),
cte2 as (
select c1.sub_category, c1.total_profit_per_year as sales_2022, c2.total_profit_per_year as sales_2023 --, ROW_NUMBER() over(partition by c1.sub_category order by c1.yr desc) as rn
from cte c1
inner join cte c2
on c1.sub_category = c2.sub_category and c1.yr <> c2.yr and c1.yr < c2.yr)
select top 1 *, sales_2023 - sales_2022 as growth
from cte2
where sales_2023 > sales_2022
order by growth desc;