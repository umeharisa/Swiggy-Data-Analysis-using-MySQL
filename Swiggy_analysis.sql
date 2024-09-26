/*1. Find customers who have never ordered*/
Use swiggy;
select name from swiggy.users 
where user_id not in 
(select user_id from swiggy.orders);

/*Average price/dish*/
Use swiggy;
select food.f_name as Food, avg(menu.price) as Average_Price from menu 
inner join food on food.f_id=menu.f_id
group by food.f_name;

/*Find top restaurants in terms of number of orders for a given month*/
Use swiggy;
select r.r_name, monthname(o.date) as 'month', count(order_id) as 'orders_count' from orders o
join restaurants r on r.r_id=o.r_id 
group by r.r_name,month
order by month asc,orders_count desc;

/*Restaurants with monthly sales > 1000 for a given month*/
Use swiggy;
select r.r_name as 'Restaurant',monthname(o.date) as 'month',sum(o.amount) as 'Revenue' from orders o
join restaurants r on r.r_id=o.r_id 
group by Restaurant,month
having Revenue > 1000
order by Revenue desc;

/*Show all orders with order details for a particular customer in a particular date range*/
Use swiggy;
SELECT o.order_id, monthname(o.date) as 'Month', u.name, r.r_name, f.f_name FROM orders o
join order_details od on o.order_id = od.order_id
join users u on o.user_id = u.user_id
join restaurants r on o.r_id - r.r_id
join food f on od.f_id = f.f_id where u.user_id =
(select user_id from users where name like 'Nitish' and (date >'2022-06-10' and date <'2022-07-10'));

/*Find restaurants with max repeated customers*/
Use swiggy;
select r.r_name, count(*) as 'Loyal_Customers' 
from 
		(select  o.r_id,o.user_id,count(o.user_id) as 'Visits' from orders o
		group by o.r_id,o.user_id
		having visits > 1) t 
        
join restaurants r on r.r_id =t.r_id 
group by r.r_name
order by Loyal_Customers desc limit 1;

/*Find most loyal customers for all restaurant*/
Use swiggy;
select r.r_name,u.name from (
select  o.r_id,o.user_id,count(o.user_id) as 'Visits' from orders o
group by o.r_id,o.user_id
having visits > 1) t join users u on u.user_id = t.user_id
join restaurants r on r.r_id = t.r_id
order by r.r_name; 
		
        
/*month over month revenue growth of swiggy*/
Use swiggy;
select Month, ((Revenue-prev)/prev)*100 as Growth from (
	with sales as (
	select monthname(o.date) as 'Month',sum(o.amount) as 'Revenue' from orders o
	group by Month
	)
	select Month, Revenue, lag(Revenue,1) over (order by revenue) as Prev from sales
) t;

/* Month on month revenue growth of each restaurant*/
Use swiggy;
select t.r_name, t.months, t.revenue, t.Prev, ((revenue-prev)/prev)*100 as Growth from(
with sales as (
select r.r_name,monthname(o.date) as 'months',sum(o.amount) as 'revenue' from orders o
join restaurants r on o.r_id=r.r_id
group by r.r_name,months
order by r.r_name
)
select r_name,months, revenue, lag(revenue,1) over (partition by r_name order by r_name,months Desc) as Prev from sales
)t;


/*Customer favourite food*/
use swiggy;
with temp as 
(
	select o.user_id,od.f_id,count(o.order_id) as 'frequency' from orders o 
	join order_details od on o.order_id=od.order_id
	
	group by o.user_id,od.f_id
)
select u.name, f.f_name from temp t1
join users u on u.user_id = t1.user_id 
join food f on f.f_id = t1.f_id where t1.frequency = 
(select max(frequency) from temp t2 where t2.user_id = t1.user_id)







