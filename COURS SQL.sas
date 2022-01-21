libname orion 'C:\SAS\Master2\Programmation 4\SQL\Cours_SQL';

/*****************PARTIE 1***************************/
/******************Basic Queries*********************/


*Level 1

4. Eliminating Duplicates

Write a query that generates a report that displays the cities where the Orion Star employees reside.
The report should do the following:
• include the title Cities Where Employees Live
• display one unique row per City
• use the orion.Employee_Addresses table;


proc sql number;
	title 'Cities Where Employees Live';
	select distinct city
	from orion.Employee_Addresses;
quit;
title;



*Level 2

5. Subsetting Data
Write a query that generates a report that displays Orion Star employees whose charitable
contributions exceed $90.00. The report should have the following characteristics:
• include the title Donations Exceeding $90.00 in 2007
• display Employee_ID, Recipients, and the new column Total that represents the total
charitable contribution for each employee over the four quarters
• use the orion.Employee_donations table
• include only employees whose charitable contribution Total for all four quarters exceeds $90.00
Hint: The total charitable contribution is calculated by adding the amount of Qtr1, Qtr2, Qtr3,
and Qtr4. Use the SUM function to ensure that missing values are ignored.;

proc sql;
	title 'Donations Exceeding $90.00 in 2007';
	select Employee_ID, Recipients, sum(Qtr1,Qtr2,Qtr3,Qtr4) as Total
	from orion.employee_donations
	where calculated Total gt 90;
quit;
title;



*Level 2

2. Calculating a Column
Write a query that generates the report below. The report should do the following:
• display Employee_ID, Employee_Gender, Marital_Status, Salary, and a new
column (Tax) that is one-third of the employee's salary
• use the orion.Employee_Payroll table;

proc sql;
	select Employee_ID, Employee_Gender, Marital_Status, Salary, Salary/3 as Tax
	from orion.employee_payroll;
quit;



*Level 3. Conditional Processing

Create a report that displays Employee_ID, Level, Salary, and Salary_Range using the orion.Staff table.
Level and Salary_Range are two new columns in the report. The report should also only contain salary information 
for the Orion Star executives. 
Conditionally assign values to the two new columns as follows:;

proc freq data=orion.staff;
	table job_title;
run;

*-1 dans le scan represente le dernier mot de la chaine;
proc sql number;
select Employee_ID, Salary, job_title,

	case 
		when scan(job_title,-1,' ')= 'Manager' then 'Manager' 
		when scan(job_title,-1,' ')= 'Director' then 'Director'
		when scan(job_title,-1,' ')= 'Officer' | scan(job_title,-1,' ')='President' then 'Executive'
		else 'NA'
	end as Level,

	case
		when calculated Level='Manager' and salary lt 52000 then 'Low'
		when calculated Level='Manager' and salary between 52000 and 72000 then 'Medium'
		when calculated Level='Manager' and salary gt 72000 then 'High'

		when calculated level='Director' and salary lt 108000 then 'Low'
		when calculated Level='Director' and salary between 108000 and 135000 then 'Medium'
		when calculated Level='Director' and salary gt 135000 then 'High'

		when calculated level='Executive' and salary lt 240000 then 'Low'
		when calculated level='Executive' and salary between 240000 and 300000 then 'Medium'
		when calculated level='Executive' and salary gt 300000 then 'High'

	end as Salary_Range 

from orion.staff
where calculated Level not in ('NA');
quit;
			


*Level 3

6. Subsetting Data Using the ESCAPE Clause
Create a report that displays the Employee_ID and Recipients for all employees who
contributed 90% of their charitable contributions to a single company that was incorporated (Inc.).
Use the orion.Employee_donations table. Add a title to the report as shown in the output
below.
Hint: Use the ESCAPE clause in the WHERE clause to solve this problem.;

proc sql;
	select Employee_ID, Recipients
	from orion.employee_donations
	where Recipients like "% Inc. 90/%%"ESCAPE"/";
quit;
	






/*****************************PARTIE 2************************************/
/***********************Displaying Query Results**************************/




*Level 1
1. Enhancing Output with Titles and Formats
Open program s103e01 and modify the query.
a. Select only the Employee_ID, Salary, and Tax columns.
b. Display the Tax and Salary columns using the COMMA10.2 format.
c. Order the report by Salary in descending order.
d. Add this title to the report: Single Male Employee Salaries.;

proc sql; 
	Title'Single Male Employee Salaries';
   select Employee_ID, 
          Salary format=COMMA10.2 , 
		  Salary/3 format=COMMA10.2 as Tax 
      from orion.Employee_Payroll
	  where Marital_Status="S"
			and Employee_Gender ="M" 
			and Employee_Term_Date is missing
	order by salary desc;
quit;
Title;


*Level 2
2. Using Formats to Limit the Width of Columns in the Output
Write a query that retrieves the Supplier_Name, Product_Group, and Product_Name
columns from the table orion.Product_dim.
a. Add this title to the report: Australian Clothing Products.
b. Include only rows where Product_Category = "Clothes" and Supplier_Country
= "AU" (Australia).
c. To enable the report to print in portrait orientation, use formats to limit the width of
column
Supplier_Name to 18, Product_Group to 12, and Product_Name to 30 characters.
d. Label the columns Supplier, Group, and Product, respectively.
e. Order the report by Product_Name.;

proc sql;
	title 'Australian Clothing Products';
	select Supplier_Name format=$18. 'Supplier',
			Product_Group format=$12. 'Group',
			Product_Name format=$30. 'Product'
	from orion.product_dim
	where Product_Category = "Clothes"
		and Supplier_Country= "AU"
	order by Product_Name;
quit;
title;


*Level 3
3. Enhancing Output with Multiple Techniques
Create a report that displays Customer_ID, the customer’s name written asCustomer_LastName,
Customer_FirstName, and Gender, as well as the customer’s age as of 31DEC2007. Use the
data contained in the orion.Customer table. Include only U.S. customers who were more than 50
years old on 31DEC2007.
Present the data ordered by descending age, last name, and first name. Give the report an
appropriate title. Limit the space used to display the customer’s name to a maximum of 20
characters, so that the report can be printed in portrait orientation. The Customer_ID values must
be displayed with leading zeros as shown in this sample report.;

proc sql number;
	select Customer_ID format=z7.,
			catx(', ',Customer_LastName,Customer_FirstName) 
				as Name 'Last Name, First Nname' format=$20., 
			Gender,
			INTCK("year",Birth_Date,'31DEC2007'd) as age
	from orion.customer
	where Country='US'
		and calculated age gt 50
	order by age desc, Customer_LastName, Customer_FirstName;
quit; 









*Level 1
4. Summarizing Data
Create a report that displays the number of employees residing in each city.
a. Use the City column and the COUNT(*) function.
b. Use the orion.Employee_Addresses table.
c. Group the data and order the output by City.
d. Add this title to the report: Cities Where Employees Live.;

proc sql number;
	select City, Count(City) as NB_Employee
	from orion.Employee_Addresses
	group by City
	order by City;
quit;



*Level 1
5. Using SAS Functions
Create a report that includes each employee’s age at time of employment.
a. The report should contain the columns Employee_ID, Birth_Date,
Employee_Hire_Date, and Age.
b. Obtain the data for the report from the orion.Employee_Payroll table.
c. Calculate Age as INT((Employee_Hire_Date - Birth_Date)/365.25).
d. Add this title to the report: Age at Employment.
e. Display Birth_Date and Employee_Hire_Date values using the MMDDYY10. format.
f. Label each column as shown in the following sample report:;


proc sql;
	title'Age at employment';
	select Employee_ID 'Employee ID', 
			Birth_Date format=MMDDYY10. 'Birth Date',
			Employee_Hire_Date format=MMDDYY10. 'Hire Date',
			intck("year",Birth_Date,Employee_Hire_Date) as Age
	from orion.Employee_Payroll;
quit;
title;


*Level 2
6. Summarizing Data
a. Using data contained in the orion.Customer table, create a report that shows the
following
statistics for each country:
1) total number of customers
2) total number of male customers
3) total number of female customers
4) percent of all customers that are male (Percent Male)
b. Add this title to the report: Customer Demographics: Gender by Country.
c. Arrange the report by value of Percent Male so that the country with the lowest
value is listed first, with the remaining countries following in ascending order.;


proc sql;
	title 'Customer Demographics: Gender by Country';
	select  country,
			sum((find(gender,'M', 'i') gt 0)) as Men,
			sum((find(gender,'F','i') gt 0)) as Women,
			count(customer_id) as Customer,
			calculated Men/calculated Customer as Percent_male 'Percent Male' format=percent8.
	from orion.Customer
	group by country
	order by Percent_male, country;
quit;
title;



*Level 2
7. Summarizing Data in Groups
Use the orion.Customer table to determine the number of Orion Star customers of
each gender in each country.
Display columns titled Country, Male Customers, and Female Customers.
Display only those countries that have more female customers than male customers.
Order the report by descending female customers.
Add this title to the report: Countries with more Female than Male Customers.;


proc sql;
	select country,
			sum(gender='M') as Male,
			sum(gender='F') as Female
	from orion.Customer
	group by country
	having female gt male
	order by female desc;
quit;
			


*Level 3
8. Advanced Summarizing Data in Groups
Use the orion.Employee_Addresses table to create a report that displays the
countries and cities where Orion Star employees reside, and the number of
employees in each city.
Include only one row per country/city combination.
Display the values in country/city order, and give the report an appropriate
title.;


proc sql;
	select upcase(country) as Countr 'Country',
			propcase(city), 
			count(employee_id)
	from orion.Employee_Addresses
	group by countr, city
	order by countr, city;
quit;




/***************PARTIE 4**********************/
/*****************SQL Joins*******************/


*Level 1

1. Inner Joins
Produce a report containing Employee_Name and calculated years of service (YOS) as of
December 31, 2007, by joining orion.Employee_Addresses and orion.Employee_Payroll
on Employee_ID.
Label the columns and provide two title lines, as shown in the sample output. Limit the
report to employees where YOS > 30.
Order the output alphabetically by Employee_Name.
• The orion.Employee_Addresses table contains the Employee_Name column.
• The orion.Employee_Payroll table contains the Employee_Hire_Date column.
• Both orion.Employee_Addresses and orion.Employee_Payroll contain columns named
Employee_ID.
• Use TITLE1 and TITLE2 statements to produce title lines as indicated in the sample
report:;

proc sql;
	select Employee_Name,
			intck('year',Employee_Hire_Date,'31dec2007'd) 'Year of service' as YOS
	from  orion.Employee_Addresses as p,
		orion.Employee_Payroll as m
	where p.Employee_ID=m.Employee_ID
		and calculated YOS gt 30
	order by Employee_Name;
quit;


*Level 2
2. Outer Joins
Join orion.Sales and orion.Employee_Addresses on
Employee_ID to create a report showing the names and
cities of all Orion Star employees, and if an employee is
in Sales, the job title.
Present the report in alphabetical order by city, job title,
and name.
• The orion.Sales table contains a record for every
employee in the Sales Department and
includes columns Employee_ID and Job_Title.
• The orion.Employee_Addresses table contains a
record for every employee and includes Employee_ID,
Employee_Name, and City.;


proc sql;
	select Employee_Name,City, job_title
	from  orion.Employee_Addresses as m left join orion.Sales as p
		on m.Employee_ID=p.Employee_ID
	order by City, job_title, Employee_Name;
quit;



*Level 2
3. Joining Multiple Tables
Create a report showing Orion Star Internet customers residing in the U.S. or Australia
who purchased foreign manufactured products, that is, a product that was not
manufactured in their country of residence. The report should be titled US and Australian
Internet Customers Purchasing Foreign Manufactured Products and should display the
customers’ names and the number of foreign purchases made. Present the information so
that those with the largest number of purchases appear at the top of the report, and
customers who have the same number of purchases are displayed in alphabetical order.
Employee_ID 99999999 is a dummy ID that can be used to identify Internet orders. The
data that you need can be found in the listed columns of the following tables:

• orion.Product_Dim contains Product_ID & Supplier_Country
• orion.Order_Fact contains Product_ID & Customer_ID
• orion.Customer contains Customer_ID & Country;



proc sql;
title 'US and Australian Internet Customers Purchasing Foreign Manufactured Products';
	select c.customer_name as Name, 
			count(*) as purchases
	from orion.Product_Dim as a,
		orion.order_fact as b, 
		orion.customer as c
	where a.product_ID=b.product_ID 
		and b.customer_ID=c.customer_ID
		and country in('US','AU') 
		and b.employee_ID=99999999 
		and c.country ne a.supplier_country
	group by customer_name
	order by purchases desc, Name;
quit;




*Level 3
4. Joining Multiple Tables
Create a report of Orion Star employees with more than 30 years of service as of December 31,
2007. Display the employee’s name, years of service, and the employee’s manager’s name.
Order the report alphabetically by manager name, by descending years of service, and then
alphabetically by employee name. Label the columns and title the report as shown in the sample
output.
The data that you need can be found in the listed columns of the following tables:
• orion.Employee_Addresses contains Employee_ID & Employee_Name
• orion.Employee_Payroll contains Employee_ID & Employee_Hire_Date
• orion.Employee_Organization contains Employee_ID & Manager_ID (Employee_ID of the
person’s manager);


proc sql;
title1 'Employees with more than 30 years of service';
title2 'as of december 31, 2007';
	select t1.employee_name , 
		int(('31dec2007'd-employee_hire_date)/365.25) as YOS 'Years of Service', 
		t4.employee_name as manager_name
	from orion.employee_addresses as t1,
		orion.employee_payroll as t2,
		orion.employee_organization as t3,
		orion.employee_addresses as t4
	where t1.employee_ID=t2.employee_ID 
		and t2.employee_ID=t3.employee_ID 
		and t3.manager_ID=t4.employee_ID 
		and calculated YOS>30 
	order by manager_name, YOS desc, employee_name;
quit;






/****************PARTIE 5**************/
/**********Set Operators***************/


*Level 1
1. Using the EXCEPT Operator
Create a report that displays the employee identification numbers of employees who have
phone numbers, but do not appear to have address information.
The orion.Employee_phones table contains Employee_ID and Phone_Number.
If an employee’s address is on file, the orion.Employee_Addresses table contains the
Employee_ID value and address information.
The query should:
• Use the column Employee_ID from orion.Employee_phones.
• Use the appropriate SET operator.
• Use the column Employee_ ID from orion.Employee_Addresses.;


proc sql;
	select employee_id
	from orion.Employee_phones
	except
	select employee_id
	from orion.Employee_Addresses;
quit;


*Level 1
2. Using the INTERSECT Operator
Create a report that shows the Customer_ID of all customers who placed orders.
The orion.Order_fact table contains information about the orders that were placed by
Orion Star customers, including Customer_ID.
The orion.Customer table contains information about all Orion Star customers, including
Customer_ID.
The query should do the following:
• Use the column Customer_ID from orion.Order_fact.
• Use the appropriate SET operator.
• Use the column Customer_ ID from orion.Customer.;


proc sql;
	select Customer_ID
	from orion.Order_fact
	intersect
	select Customer_ID
	from orion.Customer;
quit;


*Level 2
3. Using the EXCEPT Operator to Count Rows
Create a report that displays the total count of
employees who did not make any charitable donations.
The orion.Employee_organization table contains a
record for every employee in the Orion Star organization
and includes the employee identification numbers.
The orion.Employee_donations table contains records
only for employees who made charitable donations,
including the Employee_ID value.;


proc sql;
	select count(*) 'Nombre employe qui ont pas fait de dons'
	from (select employee_id 
	from orion.Employee_organization
	except
	select  employee_id 
	from orion.Employee_donations);
quit;







*4. Using the INTERSECT Operator to Count Rows
Create a report that shows the total number of
customers who placed orders.
The orion.Order_fact table contains information about
the orders that were placed by Orion Star customers,
including Customer_ID.
The orion.Customer table contains information on all
Orion Star customers, including Customer_ID.;

proc sql;
	select count(*) 'Nombre de clients ayant donnees des ordres'
	from (select Customer_ID
	from orion.Order_fact
	intersect
	select Customer_ID
	from orion.Customer table);
quit;



*Level 3
5. Using the EXCEPT Operator with a Subquery
Create a report that displays the employee identification numbers and
names of sales representatives who did not sell any products in 2007.
The orion.Sales table contains the Employee_ID values of all sales
representatives.
The orion.Order_fact table contains the Employee_ID value of the
salesperson, and other information about all sales that were made.
The orion.Employee_Addresses table contains the Employee_ID and
Employee_Name values of all Orion Star employees.
Provide a title for the report as indicated in the sample output, and
include the row number as part of the report.

Créez un rapport qui affiche les numéros d'identification des employés et les noms des commerciaux
qui n'ont vendu aucun produit en 2007.
La table orion.Sales contient les valeurs Employee_ID de tous les commerciaux.
La table orion.Order_fact contient la valeur Employee_ID du
vendeur et d’autres informations sur toutes les ventes effectuées.
La table orion.Employee_Addresses contient le Employee_ID et
Les valeurs Employee_Name de tous les employés Orion Star.
Donnez un titre au rapport comme indiqué dans l'exemple de sortie, et
inclure le numéro de ligne dans le rapport.;


proc sql number;
	select employee_id ,employee_name from orion.Employee_Addresses
	where employee_id in 
		(select employee_id from orion.sales where job_title like "%Rep%" except
		select employee_id from  orion.Order_fact where year(order_date)=2007)
	order by employee_name;
quit;




*6. Using the INTERSECT Operator with a Subquery
Create a report that includes Customer_ID and Customer_Name for all
customers who placed orders.
The orion.Order_fact table contains information about the orders that
were placed by Orion Star customers, including Customer_ID.
The orion.Customer table contains information on all Orion Star
customers, including Customer_ID and Customer_Name.;


proc sql number;
	select Customer_ID, Customer_Name from orion.Customer
	where Customer_ID in
		(select Customer_ID from orion.Order_fact 
		intersect
		select Customer_ID from orion.Customer);
quit;



		*Level 1
7. Using the UNION Operator
Create a report that displays the total salary for female and male sales representatives
and the total number of female and male sales representatives.
The orion.Salesstaff table contains information on all the Orion Star sales representatives,
including Salary and Gender.
The query should do the following:
• Create the first row of the report. Use the constant text Total Paid to ALL Female Sales
Representatives, SUM(Salary), and the total number of rows using the COUNT(*)
function. Summarize data in the orion.Salesstaff table for those rows that have Gender =
'F' and Job_Title containing 'Rep'.
• Use the appropriate SET operator.
• Create the second row of the report. Use the constant text Total Paid to ALL Male Sales
Representatives, SUM(Salary), and the total number of rows using the COUNT(*)
function. Summarize data in the orion.Salesstaff table for those rows that have Gender =
'M' and Job_Title containing 'Rep'.
• Provide a title for the report as shown below.;






*Level 1
8. Using the OUTER UNION Operator with the CORR Keyword
Create a report that displays the sales data for the first and second quarters of 2007.
The orion.Qtr1_2007 table contains the sales data for the first quarter, and the
orion.Qtr2_2007 table contains the sales data for the second quarter.;
