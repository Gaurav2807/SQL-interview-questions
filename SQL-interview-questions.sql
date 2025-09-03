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

