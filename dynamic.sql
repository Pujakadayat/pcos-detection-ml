use Prod_Simulation

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + '
USE [' + name + '];

Select * from Department
'
FROM sys.databases
WHERE name like 'Prod_Simulation%'

 -- PRINT @SQL

EXEC sp_executesql @SQL;


select * from sys.databases

select * into #temp from dbo.Department


select * from #temp



Create table Employees.emp_summary(
    id int,
    att_date DATE
)

Insert into Employees.emp_summary

select 
ea.emp_id,
al.Attendance_date
from  Employees.Attendance_log ea JOIN
EMployees.Archieve_log al on ea.emp_id = al.emp_id

select * from Employees.emp_summary


select id from Employees.emp_summary


-- SCALAR USER-DEFINED FUNCTIONS

Create Function netsale(
    @quantity int,
    @list_price dec(10,2),
    @discount dec(4,2)
 )
 Returns dec(10,2)
 AS
 BEGIN
 Return @quantity * @list_price * (1- @discount);
 END;

-- Calling a Scalar Function

 select  dbo.netsale(10,120,0.1) net_sale;


 -- Modifying a scalar function

--  Alter function [schema_name].funtion_name (parameter_list)
--  Return data_type AS
--  BEGIN
--  statements
--  Return VALUE
--  End


-- Removing a scalar function

-- Drop function [schema_name].[function_name]
-- Scalar functions cannot update data.They can access data but npt a good practicw
-- SCalar functions can call other functions



-- TABLE-VALUED FUNCTION

CREATE FUNCTION udfAttendancedate (
    @employee_id INT
)
RETURNS TABLE
AS
RETURN
SELECT
emp_id,
FullName,
attendance_date
from Employees.Employee_Attendance
where 
emp_id = @employee_id


-- Executing a table-valued function
--  table valued function can return partial output
select * from udfAttendancedate((2))

Alter function udfAttendancedate(
    @startyear int,
    @endyear int
)

Returns TABLE
AS
Return 
SELECT
emp_id,
FullName,
attendance_date
from Employees.Employee_Attendance
where attendance_date between @startyear and @endyear


--- Multi-statement table-valued functions (MSTVF)

-- is a table-valued function that returns the result of multiple statements


-- combined the Attendance table and the Archieve_log table of Employees schema

CREATE FUNCTION udContacts()
RETURNS @attendance table ( 
emp_id INT,
fullname varchar(100),
attendance_Date DATE
)
AS
BEGIN
Insert into @attendance
select 
emp_id,
FullName,
attendance_date
from Employees.Employee_Attendance; 


Insert into @attendance
SELECT
emp_id,
FullName,
Attendance_date
from Employees.Archieve_log;
RETURN
END;


-- Fgjwfab

-- 1 =1 always true, so all row return garxa
select * from dbo.Department where Dept_id = 1   or 1=1

Select * from holidays 

SELECT * FROM holidays WHERE name ="" or ""="" AND startdate ="" or ""=""

-- Constraine disable garne 
-- alter table table_name
-- No Check Constraint contraintname

-- Alter table table_name
-- Drop constraint constraintname


-- Add or remove not numm constraint from existing column

-- ALTER TABLE table_name
-- ALTER COLUMN column_name data_type NOT NULL;


-- ALTER TABLE table_name
-- ALTER COLUMN column_name data_type NULL;
