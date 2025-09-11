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
	

-- VARIATION 3 : Cummulative sales / running / rolling 'N' months or years sales (to check 'windows functions' working, specially 'order by' in it)

-- 10. Find cummulative year sales
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
	

-- 11. Find cummulative year sales by category 
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


-- VARIATION 4 : Pivoting -> Convert rows to columns (to check the interviewee's understanding of arrangement of data)

-- 13. Sales by category per year side by side
Select  
	extract(year from order_date) calander_year,
	sum(case when category = 'Furniture' then sales else 0 end) Furniture_sales, 
	sum(case when category = 'Office Supplies' then sales else 0 end) Office_supplies_sales, 
	sum(case when category = 'Technology' then sales else 0 end) Technology_sales 
	from orders 
	group by 1
	

-- VARIATION 5 : Result of inner / left joins etc.

-- 14. Write a query to find PersonID, Name, Number of friends, sum of marks of person who have friends with total score greater than 100
Select 
	P.PersonID Person_ID, P.Name Person_name, count(*) Total_friends, sum(P.Score) Friends_score 
	from Person P 
	inner join Friend F
	on P.personid = F.pid
	Group by 1, 2
	having sum(P.Score) > 100;


-- 15. Management wants to see all the users that haven't logged in in past 5 months (returns : Username)
Select 
	U.user_name User_name 
	from users U 
	inner join 
	(
		Select 
			user_id, max(login_timestamp) last_login
			from logins
			group by 1
			having max(login_timestamp) < (Select max(login_timestamp) from logins) - interval '5 months'
	) L
	on L.user_id = U.user_id;
	
-----------------------------------------------------------------  OR --------------------------------------------------------------
									
Select 
	distinct user_id
	from logins 
	where user_id not in 
	(
		Select 
			user_id 
			from logins 
			where login_timestamp > (Select max(login_timestamp) from logins) - interval '5 months'
	)


-- 16. For the Business unit's quarterly analysis, calculate how many users and how many sessions were there at each quarter, order by quarter from newest to older (returns : First day of quarter, user_count, session_count)
With CTE_Quarters as 
(
	Select 
		user_id, login_timestamp, session_id, 
		CASE 
			when extract(month from login_timestamp) between 1 and 3 then 'Q1'  
			when extract(month from login_timestamp) between 4 and 6 then 'Q2' 
			when extract(month from login_timestamp) between 7 and 9 then 'Q3' 
			when extract(month from login_timestamp) between 10 and 12 then 'Q4' 
		END	Quarters 
		from logins
)
Select 
	Quarters, 
	DATE_TRUNC('month', min(login_timestamp)) first_day_of_quarter, 
	count(distinct user_id) user_count, 
	count(session_id) session_count
	from CTE_Quarters 
	group by Quarters 
	order by Quarters desc;


-- 17. Display user IDs that logged in in January 2024 but not in November 2023 (returns : User_id)
Select 
	distinct user_id 
	from logins 
	where login_timestamp between '2024-01-01' and '2024-01-31' 
	and user_id not in (Select distinct user_id from logins where login_timestamp between '2023-11-01' and '2023-11-30')


-- 18. Display percentage change in Sessions from the last quarter (returns : First day of quarter, Current session count, Previous session count, Percentage change in sessions)
With CTE_Session_count_per_quarter as
(
	Select  
		DATE_TRUNC('month', min(login_timestamp)) first_day_of_quarter, 
		count(session_id) current_quarter_session_count
		from logins
		group by date_trunc('quarter', login_timestamp) /*date trunc gets you first day of the parameter passed*/
)
Select 
	*, 
	LAG(current_quarter_session_count, 1) over(order by first_day_of_quarter) previous_quarter_session_count, 
	(current_quarter_session_count - (LAG(current_quarter_session_count, 1) over(order by first_day_of_quarter))) * 100 / (LAG(current_quarter_session_count, 1) over(order by first_day_of_quarter))  percentage_change
	from CTE_Session_count_per_quarter;


-- 19. Display the user that had the highest session score each day (return : Date, user_name, score)
With CTE_max_session as 
(
Select 
	user_id, 
	login_timestamp, 
	max(session_score) 
	from logins
	group by login_timestamp, user_id	
)
Select * 
	from 
		(
			Select 
				*, 
				row_number() over(partition by login_timestamp) rn 
				from CTE_max_session
		)
	where rn = 1;


-- 20. To identify the users that had a session for every single day since their first login [make assumption is needed] (return : user_id)
Select 
	user_id, 
	min(login_timestamp) :: date first_login, 
	current_date - (min(login_timestamp) :: date) date_difference, 
	count(distinct login_timestamp) distinct_logins_within_day
	from logins 
	group by user_id 
	having count(distinct login_timestamp) = current_date - (min(login_timestamp) :: date);




