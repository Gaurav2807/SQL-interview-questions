------------------------------------------- Problem statements and their solutions ---------------------------------------------------

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




