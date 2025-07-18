-- Create table --

USE walmartanalysis;
CREATE TABLE IF NOT EXISTS walmartsales(
		invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
		branch VARCHAR(5) NOT NULL,
		city VARCHAR(30) NOT NULL,
		customer_type VARCHAR(30) NOT NULL,
		gender VARCHAR(30) NOT NULL,
		product_line VARCHAR(100) NOT NULL,
		unit_price DECIMAL(10,2) NOT NULL,
		quantity INT NOT NULL,
		tax_pct FLOAT(6,4) NOT NULL,
		total DECIMAL(12, 4) NOT NULL,
		date DATETIME NOT NULL,
		time TIME NOT NULL,
		payment VARCHAR(15) NOT NULL,
		cogs DECIMAL(10,2) NOT NULL,
		gross_margin_pct FLOAT(11,9),
		gross_income DECIMAL(12, 4),
		rating FLOAT(2, 1)
);

select * from walmartanalysis.walmartsales;

--------------------------- Feature Engineering ----------------------------------

-- Time of day --

alter table walmartsales
add column time_of_day  varchar(20);

update walmartsales
set time_of_day = (
	case
	when time between '00:00:00' and '12:00:00' then 'Morning'
	when time between '12:00:01' and '16:00:00' then 'Afternoon'
	else 'Evening'
end);

-- Day name --

alter table walmartsales
add column day_name  varchar(5);

update walmartsales
set day_name = substring(dayname(date),1,3);

-- Month name --

alter table walmartsales
add column month_name varchar(5);

update walmartsales
set month_name = substring(monthname(date),1,3);

--------------------------- Generic questions ----------------------------------

-- Q1. How many unique cities does the data have? --

select count(distinct city)
from walmartsales;

-- 3

-- Q2. In which city is each branch? --

select distinct city, branch
from walmartsales;

-- Yangon	A
-- Naypyitaw	C
-- Mandalay	B

--------------------------- Product questions ----------------------------------

-- Q1. How many unique product lines does the data have? --

select count(distinct product_line)
from walmartsales;

-- 6

-- Q2. What is the most common payment method? --

select payment, count(payment) as payment_count
from walmartsales
group by payment
order by payment_count desc;

-- Cash

-- Q3. What is the most selling product line? --

select product_line, count(product_line) as product_line_count
from walmartsales
group by product_line
order by product_line_count desc limit 1;

-- Fashion accessories	178

-- Q4. What is the total revenue by month? --

select month_name, sum(total) as total_revenue
from walmartsales
group by month_name;

-- Mar	108867.1500
-- Jan	116291.8680
-- Feb	95727.3765

-- Q5. Which month had the largest COGS? --

select month_name, sum(cogs) as total_cogs
from walmartsales
group by month_name
order by total_cogs desc limit 1;

-- Jan	110754.16

-- Q6. Which product line had the largest revenue? --

select product_line, sum(total) as total_revenue
from walmartsales
group by product_line
order by total_revenue desc limit 1;

-- Food and beverages	56144.8440

-- Q7. Which city has the largest revenue?

select city, sum(total) as total_revenue
from walmartsales
group by city
order by total_revenue desc limit 1;

-- Naypyitaw	110490.7755

-- Q8. Which product line had the largest VAT? --

select product_line, avg(tax_pct) as tax
from walmartsales
group by product_line
order by tax desc limit 1;

-- Home and lifestyle	16.03033124

-- Q9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select product_line,
CASE
	when avg(total) > (select avg(total) from walmartsales) then "Good"
	else "Bad"
end as Remark
from walmartsales
group by product_line;

-- Food and beverages	Good
-- Health and beauty	Good
-- Sports and travel	Good
-- Fashion accessories	Bad
-- Electronic accessories	Bad

-- Q10. Which branch sold more products than average product sold?

select branch
from walmartsales
group by branch
having sum(quantity) > (select avg(quantity) from walmartsales)
order by sum(quantity) desc limit 1;

-- A

-- Q11. What is the most common product line by gender?

select gender, product_line, count(gender) as gender_cnt
from walmartsales
group by product_line, gender
order by gender_cnt desc;

-- Female	Fashion accessories	96
-- Male	Health and beauty	88

-- Q12. What is the average rating of each product line?

select product_line, avg(rating) as prod_rating
from walmartsales
group by product_line;

-- Food and beverages	7.11322
-- Health and beauty	6.98344
-- Sports and travel	6.85951
-- Fashion accessories	7.02921
-- Home and lifestyle	6.83750
-- Electronic accessories	6.90651

--------------------------- Sales questions ----------------------------------

-- Q1. Number of sales made in each time of the day per weekday

select  day_name, time_of_day, count(*) as total_sales
from walmartsales
where day_name != 'Sat' and day_name != 'Sun'
group by day_name, time_of_day
order by total_sales desc;

-- Tue	Evening	69
-- Wed	Afternoon	61
-- Wed	Evening	58
-- Fri	Afternoon	58
-- Mon	Evening	56
-- Thu	Evening	56
-- Tue	Afternoon	53
-- Fri	Evening	51
-- Thu	Afternoon	49
-- Mon	Afternoon	48
-- Tue	Morning	36
-- Thu	Morning	33
-- Fri	Morning	29
-- Wed	Morning	22
-- Mon	Morning	20

-- Q2. Which customer type brings the most revenue?

select customer_type, sum(total) as total_rev
from walmartsales
group by customer_type
order by total_rev desc limit 1;

-- Member	163625.1015

-- Q3. Which city has the largest tax percent/ VAT (Value Added Tax)?

select city, avg(tax_pct) as VAT
from walmartsales
group by city
order by VAT desc limit 1;

-- Naypyitaw	16.09010850

-- Q4. Which customer type pays the most in VAT?

select customer_type, avg(tax_pct) as VAT
from walmartsales
group by customer_type
order by VAT desc limit 1;

-- Member	15.61457214

--------------------------- Customer questions ----------------------------------

-- Q1. How many unique customer types does the data have?

select count(distinct customer_type)
from walmartsales;

-- 2

-- Q2. How many unique payment methods does the data have?

select count(distinct payment)
from walmartsales;

-- 3

-- Q3. What is the most common customer type?

select customer_type, count(customer_type)
from walmartsales
group by customer_type
order by count(customer_type) desc limit 1;

-- Member	499

-- Q4. Which customer type buys the most?

select customer_type, sum(quantity) as total_qty
from walmartsales
group by customer_type
order by total_qty desc limit 1;

-- Member	2773

-- Q5. What is the gender of most of the customers?

select gender, count(gender)
from walmartsales
group by gender
order by count(gender) desc limit 1;

-- Male	498

-- Q6. What is the gender distribution per branch?

select branch, gender, count(gender)
from walmartsales
group by branch, gender;

-- A	Male	179
-- C	Female	177
-- C	Male	150
-- B	Female	160
-- B	Male	169
-- A	Female	160