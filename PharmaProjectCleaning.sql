select * from [pharma-data]

--creat a copy--
select *
into pharma_copy
from [pharma-data]

select * from pharma_copy

/*********************************
1. DATA QUALITY CHECK
*********************************/

--1.1 Standardizing data----
select distinct distributor from pharma_copy

select *
from pharma_copy
where Distributor like 'Rohan%'

select distinct Customer_Name from pharma_copy

select distinct City from pharma_copy

--1.2 changing quntity column from decimal to int

select distinct cast(Quantity as int)
from pharma_copy

alter table pharma_copy
alter column Quantity int;

------

select distinct Sales_Team
from pharma_copy

--1.3 checking and removing dupplicates

with duplicates as(
select *,
      ROW_NUMBER() over(partition by [Distributor]
      ,[Customer_Name]
      ,[City]
      ,[Country]
      ,[Latitude]
      ,[Longitude]
      ,[Channel]
      ,[Sub_channel]
      ,[Product_Name]
      ,[Product_Class]
      ,[Quantity]
      ,[Price]
      ,[Sales]
      ,[Month]
      ,[Year]
      ,[Name_of_Sales_Rep]
      ,[Manager]
      ,[Sales_Team]
	  order by [Distributor]
      ,[Customer_Name]
      ,[City]
      ,[Country]
      ,[Latitude]
      ,[Longitude]
      ,[Channel]
      ,[Sub_channel]
      ,[Product_Name]
      ,[Product_Class]
      ,[Quantity]
      ,[Price]
      ,[Sales]
      ,[Month]
      ,[Year]
      ,[Name_of_Sales_Rep]
      ,[Manager]
      ,[Sales_Team]) as row_num
from pharma_copy)
delete from duplicates 
where row_num >1    ---deleted 4 rows

--1.4 Null Values Check


select sum(case when Distributor is null then 1 else 0 end) as col1,
       sum(case when Customer_Name is null then 1 else 0 end) as col2,
	   sum(case when City is null then 1 else 0 end) as col3,
	   sum(case when Country is null then 1 else 0 end) as col4,
	   sum(case when Latitude is null then 1 else 0 end) as col5,
	   sum(case when Longitude is null then 1 else 0 end) as col6,
	   sum(case when Channel is null then 1 else 0 end) as col7,
	   sum(case when Sub_channel is null then 1 else 0 end) as col8,
	   sum(case when Product_Name is null then 1 else 0 end) as col9,
	   sum(case when Product_Class is null then 1 else 0 end) as col10,
	   sum(case when Quantity is null then 1 else 0 end) as col11,
	   sum(case when Price is null then 1 else 0 end) as col12,
	   sum(case when Sales is null then 1 else 0 end) as col13,
	   sum(case when [Month] is null then 1 else 0 end) as col14,
	   sum(case when [Year] is null then 1 else 0 end) as col15,
	   sum(case when Name_of_Sales_Rep is null then 1 else 0 end) as col16,
	   sum(case when Manager is null then 1 else 0 end) as col17,
	   sum(case when Sales_Team is null then 1 else 0 end) as col18
from pharma_copy;

select * from pharma_copy
where Sales is null
-- Replace null values in Sales col by "quantity*price"

select Quantity*Price as Sales_new,
       Sales
from pharma_copy
where Sales is null

--another way

with sales_adj as (
select Quantity*Price as Sales_new
from pharma_copy)
update pharma_copy
set Sales=sales_new
from sales_adj
where pharma_copy.Sales is null

/*********************************
2. DATA TYPE MODIFICATIONS
*********************************/

--2.1- Fixing date and creat a date column contains month and year
alter table pharma_copy
ADD Full_Date date

alter table pharma_copy
alter column Full_Date nvarchar(50)

alter table pharma_copy
alter column [Year] nvarchar(50)

update pharma_copy
set Full_Date= CONCAT([Month],' ',[Year])

select CONVERT(date,Full_Date)
from pharma_copy

 update pharma_copy
 set Full_Date = CONVERT(date,Full_Date)


 --2.2 Exploring the date
 select * from pharma_copy


 select Country,[Year],
        sum(cast(Sales as bigint)) as total_sales
from pharma_copy
group by [Year],Country
order by [Year]                              ---error as the col type is int and the result is big, so use bigint--



/*********************************
3. DATA EXPLORATION 
*********************************/

--3.1 Country and Cities Exploration
select top 5
       City, Country,
       sum(Sales) as total_sales
from pharma_copy
group by City, Country
order by total_sales desc;
    ----
select top 5
       city,country,
	   sum(sales) as tota_sales
from pharma_copy
where Country ='Germany'
group by City,Country
order by tota_sales desc;
     ------
select top 5
       city,country,
	   sum(sales) as total_sales
from pharma_copy
where country ='Poland'
group by city,country
order by total_sales desc;
      ----
select [Month],
       [Year],
	   sum(sales) as total_sales
from pharma_copy
where [Year]='2020' 
group by [Month],[Year]
order by total_sales desc;

--3.2 Teams Exploration

      --team sales
select Sales_Team,
       SUM(cast(Sales as bigint)) as total_sales
from pharma_copy
group by Sales_Team
order by total_sales desc;
      -- 2024 sales by rep and team
select Sales_Team,
       Name_of_Sales_Rep,
	   SUM(Sales) as total_sales_2020
from pharma_copy
where Year=2020
group by Sales_Team, Name_of_Sales_Rep
order by Sales_Team;

--3.3 Product and Product Class Exploration

      --Product Class
select Product_Class,
       count(distinct Product_Name) as Products_Count,
	   SUM(cast(Sales as bigint)) as Total_Sales
from pharma_copy
group by Product_Class;

      --Product
select Top 10
       Product_Name,
       SUM(cast(Sales as bigint)) as Total_Sales
from pharma_copy
group by Product_Name
order by Total_Sales desc;

--3.4 Customers Exploration
select COUNT( distinct Distributor) as Distributors_Count,
       COUNT( distinct Customer_Name) as Customer_Count
from pharma_copy;

select Top 10
       Customer_Name,
       SUM(cast(Sales as bigint)) as Total_Sales
from pharma_copy
group by Customer_Name
order by Total_Sales desc;

--3.5 Sales Trend

select Year,
       SUM(cast(Sales as bigint)) as Total_Sales
from pharma_copy
group by Year
order by Year;

