------------------------------------------- Problem statements and their solutions ---------------------------------------------------

-- VARIATION 1 : Retrieve highest salary (to check "group by", "patrition by", "CTE" concepts)

-- 1. Top 2 employees with highest salary
Select 
	* 
	from Employee
	order by salary desc
	limit 2;

	
-- 2. Top 2 employees with highest salary within each department
With CTE_department_id_as_window as 
(
	Select 
		*, 
		row_number() over(partition by department_id order by salary desc) row_num
		from Employee
)
Select 
	department_id, emp_id, emp_name, salary
	from CTE_department_id_as_window
	where row_num <= 2;


-- 3. Top 5 most sales generating product
Select 
	product_id, sum(sales) sales
	from Orders 
	group by product_id 
	order by 2 desc
	limit 5;


-- 4. Top 3 most sales generating product in each category
With CTE_group_by_category_and_product_id as
(
	Select 
		category, 
		product_id, 
		sum(sales) over(partition by category, product_id) net_sales_per_product 
		from Orders 
)
Select * 
	from (
			Select 
				category, product_id, net_sales_per_product, 
				row_number() over(partition by category order by net_sales_per_product desc) row_num
				from CTE_group_by_category_and_product_id
		) aggregated_sales_table 
		where row_num <= 3;


-- 5. 2nd highest salary 
Select 
	emp_id, emp_name, salary
	from Employee
	where salary = (
					Select 
						max(salary) second_highest_salary
						from Employee
						where salary < ( Select max(salary) from Employee)
					)

-- 6. 2nd highest salary department wise
Select 
	emp2.department_id, max(emp2.salary) second_highest_salary
	from Employee emp2
	where emp2.salary < (
							Select 
								max(salary)
								from Employee
								where department_id = emp2.department_id
						)
	group by emp2.department_id;


-- VARIATION 2 : YOY growth (to check "LEAD/LAG" function concepts)

-- 7. Find YOY growth for all the years
With CTE_current_year_net_sales as 
(
	Select 
		extract(year from order_date) calander_year, sum(sales) current_year_sales 
		from orders
		group by 1
		order by 1
), 
CTE_previous_year_net_sales as
(
	Select
		calander_year, 
		current_year_sales,
		lag(current_year_sales, 1, current_year_sales) over(order by calander_year) previous_year_sales
		from CTE_current_year_net_sales
)
Select 
	*, 
	round((current_year_sales - previous_year_sales) / previous_year_sales * 100, 2) YOY_sales_percent
	from CTE_previous_year_net_sales;


-- 8. Find YOY growth for all the years by category
With CTE_current_year_net_sales as 
(
	Select 
		category, extract(year from order_date) calander_year, sum(sales) current_year_sales 
		from orders
		group by 1, 2
		order by 1, 2
), 
CTE_previous_year_net_sales as
(
	Select
		category, 
		calander_year, 
		current_year_sales,
		lag(current_year_sales, 1, current_year_sales) over(partition by category order by calander_year) previous_year_sales
		from CTE_current_year_net_sales
)
Select 
	*, 
	round((current_year_sales - previous_year_sales) / previous_year_sales * 100, 2) YOY_sales_percent
	from CTE_previous_year_net_sales;


-- 9. Find products with current month sales more than previous month sales
With CTE_current_month_sales as 
(
	Select 
		product_id, 
		extract(year from order_date) calander_year, 
		extract(month from order_date) calander_month,
		sum(sales) current_month_sales 
		from orders
		where order_date >= '2021-01-01'
		group by 1, 2, 3
		order by 1, 2, 3 desc
), 
CTE_previous_month_sales as
(
	Select
		product_id, 
		calander_year, 
		calander_month, 
		current_month_sales,
		lead(current_month_sales, 1, current_month_sales) over(partition by product_id order by calander_year) previous_month_sales
		from CTE_current_month_sales
)
Select 
	*, 
	CASE
		when (current_month_sales > previous_month_sales) 
		then 'Positive monthly growth'
		when (current_month_sales < previous_month_sales) 
		then 'Negative monthly growth'
		else 'No growth'
	END Monthly_growth_indicator
	from CTE_previous_month_sales;


-- 10. Cummulative sales / running / rolling 'N' months or years sales
With CTE_yearly_sales as
(
	Select
		extract(year from order_date) calander_year, 
		sum(sales) yearly_sales 
		from Orders 
		group by 1
)
Select 
	*, 
	sum(yearly_sales) over(order by calander_year) cummulative_sales
	from CTE_yearly_sales;
	

-- 11. Cummulative sales / running / rolling 'N' months or years sales by category 
With CTE_yearly_sales as
(
	Select
		category, 
		extract(year from order_date) calander_year, 
		sum(sales) yearly_sales 
		from Orders 
		group by 1, 2
		order by 1, 2
)
Select 
	*, 
	sum(yearly_sales) over(partition by category order by calander_year) cummulative_sales
	from CTE_yearly_sales;


-- 12. Rolling 3 months sales
With CTE_yearly_sales as
(
	Select
		extract(year from order_date) calander_year, 
		extract(month from order_date) calander_month, 
		sum(sales) yearly_sales 
		from Orders 
		group by 1, 2
		order by 1, 2
)
Select 
	*, 
	sum(yearly_sales) over(partition by calander_year order by calander_year, calander_month rows between 2 preceding and current row) cummulative_sales
	from CTE_yearly_sales;


