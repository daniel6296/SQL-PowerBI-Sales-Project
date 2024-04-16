use sales;

# Data Exploration

select * from transactions
where currency != "INR";

select
	sum(sales_amount-cost_price) as profit
from
	transactions
where product_code= "Prod279";

Select count(*) from products;
select distinct product_type from products;

select
	(SUM(sales_amount-cost_price)/SUM(sales_amount))*100 as profit_margin
from
	transactions
Where order_date between "2020-06-01" and "2020-06-30";

select
	sum(sales_amount)
from
	transactions
where Year(order_date) < "2020";

select Count(*) from transactions;

select round(avg(sales_amount), 2) as avg_sales from transactions;

select * from markets
where markets_name= "Kochi";

alter table customers
change column customer_name custmer_name varchar(45) DEFAULT NULL;

# Extract market specific transaction detail to be exported to power bi 
select
	markets_name, custmer_name, customer_type, order_date, sales_qty, sales_amount, cost_price, profit_margin_percentage
from
	transactions t
    join
    customers c on c.customer_code= t.customer_code
    join
    markets m on t.market_code= m.markets_code
where
	markets_name= "Kanpur";

# Create unique transaction id and sales based rank for each transaction
# And create a procedure to extract transaction details for a user specified transaction id

Delimiter $

create procedure p_transaction_no (in p_trans_no INT)
Begin
with cte_trans as (
select 
	row_number() over () as trans_no,
    markets_name,custmer_name, customer_type, order_date, sales_qty, sales_amount, profit_margin_percentage,
    row_number() over (partition by custmer_name order by sales_amount desc ) as customer_rank
from
	transactions t
    join
    customers c on t.customer_code= c.customer_code
    join
    markets m on t.market_code= m.markets_code
where markets_name= 'Kochi')

select * from cte_trans where trans_no=p_trans_no;
end $

Delimiter ;

# calling the procedure for the transaction number I want to see to see the detail of that specific transaction
call p_transaction_no (1);

# Creating a ranking of market specific customer transactions to see a the list of the transactions based on their sales ranking
select 
	row_number() over () as trans_no,
    markets_name,custmer_name, customer_type, order_date, sales_qty, sales_amount, profit_margin_percentage,
    row_number() over (partition by custmer_name order by sales_amount desc) as customer_rank
from
	transactions t
    join
    customers c on t.customer_code= c.customer_code
    join
    markets m on t.market_code= m.markets_code
where markets_name= 'Kochi';

# creating a procedure to extract specific ranked transactions for each customer
Delimiter $
create procedure p_rank (in p_customer_rank int) 
Begin
with cte_rank as (
select 
	row_number() over () as trans_no,
    markets_name,custmer_name, customer_type, order_date, sales_qty, sales_amount, profit_margin_percentage,
    row_number() over (partition by custmer_name order by sales_amount desc ) as customer_rank
from
	transactions t
    join
    customers c on t.customer_code= c.customer_code
    join
    markets m on t.market_code= m.markets_code
where markets_name= 'Kochi')

select * from cte_rank where customer_rank=p_customer_rank;
end $

delimiter ;

# calling the procedure to see the #1 ranking transaction for each customer (based on sales)
call p_rank(1);

# creating a view to generate the lowest sales transaction from each market
create view v_lowest_sales as
select * from
(select 
	row_number() over () as trans_no,
    markets_name,custmer_name, customer_type, order_date, sales_qty, sales_amount, profit_margin_percentage,
    row_number() over (partition by markets_name order by sales_amount asc) as sales_rank_asc
from
	transactions t
    join
    customers c on t.customer_code= c.customer_code
    join
    markets m on t.market_code= m.markets_code) a
where sales_rank_asc=1;

select * from v_lowest_sales;

drop view if exists v_lowest_sales;

