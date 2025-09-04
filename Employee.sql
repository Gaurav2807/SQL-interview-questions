drop table if exists Employee;

create table Employee(
emp_id int,
emp_name varchar(20),
department_id int,
salary int,
manager_id int,
emp_age int, 
dept_name VARCHAR(50),
age_group VARCHAR(20)
);

INSERT INTO Employee (emp_id, emp_name, department_id, salary, manager_id, emp_age, dept_name, age_group)
VALUES
(1, 'Ankit', 100, 11000, 4, 39, 'Analytics', '31-50'),
(2, 'Mohit', 100, 16500, 5, 48, 'Analytics', '31-50'),
(3, 'Vikas', 100, 11000, 4, 37, 'Analytics', '31-50'),
(4, 'Rohit', 100, 5500, 2, 16, 'Analytics', 'under 18'),
(5, 'Mudit', 200, 12000, 6, 55, 'IT', 'above 50'),
(6, 'Agam', 200, 11000, 2, 14, 'IT', 'under 18'),
(7, 'Sanjay', 200, 9000, 2, 13, 'IT', 'under 18'),
(8, 'Ashish', 200, 5000, 2, 12, 'IT', 'under 18'),
(9, 'Mukesh', 300, 6000, 6, 51, 'HR', 'above 50'),
(10, 'Roshan', 300, 5000, 5, 25, 'HR', '18-30');