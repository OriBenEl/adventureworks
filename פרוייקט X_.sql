--Create a Panel

select  p.ProductID,
		p.[Name] as ProductName,
		sc.[Name] as SubCategoryName,
		c.[Name] as CategoryName,
		p.StandardCost,
		d.SalesOrderID,
		d.OrderQty,
		d.LineTotal,
		h.OrderDate,
		h.SubTotal
into PanelX
from Production.Product p 
join Production.ProductSubcategory sc
on p.ProductSubcategoryID=sc.ProductSubcategoryID
join Production.ProductCategory c
on sc.ProductCategoryID=c.ProductCategoryID
join Sales.SalesOrderDetail d
on p.ProductID=d.ProductID
join Sales.SalesOrderHeader h 
on d.SalesOrderID=h.SalesOrderID


--Checking Panel variables

select *
from PanelX

--Checking dates

select OrderDate
from PanelX
where OrderDate is null

select  min(orderdate) MinDate,
		max(orderdate) MaxDate
from PanelX

select  month(OrderDate) [month],
		year(OrderDate) year,
		count(distinct(salesorderid)) NoOfSales
from PanelX
group by year(OrderDate),month(OrderDate)
order by year(OrderDate),month(OrderDate)

--Checking OrderQty

select OrderQty
from PanelX
where OrderQty is null

select  min(OrderQty) MinOrderQty,
		max(OrderQty) MaxOrderQty
from PanelX

--Checking sum of products

select  month(OrderDate) [month],
		sum(case when year(orderdate)='2011' then orderQty else 0 end) SumOrder2011,
		sum(case when year(orderdate)='2012' then orderQty else 0 end) SumOrder2012,
		sum(case when year(orderdate)='2013' then orderQty else 0 end) SumOrder2013,
		sum(case when year(orderdate)='2014' then orderQty else 0 end) SumOrder2014
from PanelX
group by month(OrderDate) 
order by month(OrderDate) 

--Checking LineTotal

select  LineTotal
from PanelX
where LineTotal is null

select  min(LineTotal) MinLineTotal,
		max(LineTotal) MaxLineTotal
from PanelX

select  ProductName, 
		LineTotal
from PanelX
order by LineTotal desc

select  month(OrderDate) [month],
		format(sum(case when year(orderdate)='2011' then LineTotal else 0 end),'N0') SumOrder2011,
		format(sum(case when year(orderdate)='2012' then LineTotal else 0 end),'N0') SumOrder2012,
		format(sum(case when year(orderdate)='2013' then LineTotal else 0 end),'N0') SumOrder2013,
		format(sum(case when year(orderdate)='2014' then LineTotal else 0 end),'N0') SumOrder2014
from PanelX
group by month(OrderDate) 
order by month(OrderDate) 

--Checking SalesOrderID & StandardCost

select SalesOrderID
from PanelX
where StandardCost = 0

select StandardCost
from PanelX
where StandardCost is null

select  min(StandardCost) MinStandardCost,
		max(StandardCost) MaxStandardCost
from PanelX

/*select  year(h.OrderDate) [year],
		month(h.OrderDate) [month],
		p.ProductID,
		p.[Name],
		sum(d.LineTotal-p.StandardCost) gap
from Production.Product p 
join Sales.SalesOrderDetail d
on p.ProductID=d.ProductID
join sales.SalesOrderHeader h
on h.SalesOrderID=d.SalesOrderID
where d.LineTotal-p.StandardCost < 0 
group by year(h.OrderDate),month(h.OrderDate), p.ProductID, p.[name]
order by gap 

select  year(h.OrderDate) [year],
		month(h.OrderDate) [month],
		sum(d.LineTotal-p.StandardCost) gap
from Production.Product p 
join Sales.SalesOrderDetail d
on p.ProductID=d.ProductID
join sales.SalesOrderHeader h
on h.SalesOrderID=d.SalesOrderID
where d.LineTotal-p.StandardCost < 0 
group by year(h.OrderDate),month(h.OrderDate)
order by year,month */

--Checking ProductID

select  ProductID
from PanelX
where ProductID is null

select COUNT(ProductID)
from Production.Product

select COUNT(distinct(ProductID))
from PanelX

SELECT ProductID
FROM Production.Product 
order by ProductID

SELECT distinct(ProductID)
FROM PanelX 
order by ProductID

--Checking ProductName

select ProductName
from PanelX
where ProductName is null

select count(distinct(productname))
from PanelX

--Checking SalesOrderID

select SalesOrderID
from PanelX
where SalesOrderID is null

select COUNT(distinct(SalesOrderID))
from PanelX

select distinct(SalesOrderID) 
from PanelX
order by SalesOrderID

 

with cte_sales
as (
	select 
		SALESORDERID,
		lag(SALESORDERID) over (order by SALESORDERID) as PREVIOUS_SALESORDERID,
		SALESORDERID - lag(SALESORDERID) over (order by SALESORDERID) as 'DIFFERENCE'
	from 
    	Sales.SalesOrderHeader)

select *
from cte_sales
where [DIFFERENCE] != 1 OR [DIFFERENCE] IS NULL


select  min(SalesOrderID) MinSalesOrderID,
		max(SalesOrderID) MaxSalesOrderID
from PanelX

--Checking subtotal

select  SubTotal
from PanelX
where SubTotal is null

select  min(SubTotal) MinSubTotal,
		max(SubTotal) MaxSubTotal
from PanelX

--Checking SubCategoryName

select SubCategoryName
from PanelX
where SubCategoryName is null

select ProductID
from PanelX
where SubCategoryName is null

--Checking CategoryName

select CategoryName
from PanelX
where CategoryName is null

select ProductID
from PanelX
where CategoryName is null

/*Is there seasonality in revenues and profitability?*/
--Basic Assumptions:
--Revenues - Revenues from product sales exclude tax and shipping. Taxes represent income collected by the government, while shipping revenues should be examined separately from shipping expenses.
--Gross profit is derived from revenues as mentioned, minus the cost of goods sold.

-- TotalIncome by Quarter

select 	year(OrderDate) as 'OrderYear',
		((MONTH(OrderDate) - 1) / 3) + 1 AS 'OrderQuarter',
		format(sum(LineTotal),'n0') as 'TotalIncome'
from PanelX
group by ((MONTH(OrderDate) - 1) / 3) + 1, year(OrderDate)
order by OrderYear, ((MONTH(OrderDate) - 1) / 3) + 1

--TotalIncome by month

select 	year(OrderDate) as 'OrderYear',
		MONTH(OrderDate) AS 'OrderMonth',
		format(sum(LineTotal),'n0') as 'TotalIncome'
from PanelX
group by MONTH(OrderDate), year(OrderDate)
order by OrderYear, MONTH(OrderDate)

--Gross Profit per product

select  ProductID,
		LineTotal - (OrderQty * StandardCost) as 'Gross Profit Margin'
from PanelX
order by [Gross Profit Margin]

--Gross Profit per product by Quarter

select  ProductID,
		((MONTH(OrderDate) - 1) / 3) + 1 AS 'OrderQuarter',
		year(OrderDate) as 'OrderYear',
		sum(LineTotal - (OrderQty * StandardCost)) as 'Gross Profit Margin'
from PanelX
group by ProductID, ((MONTH(OrderDate) - 1) / 3) + 1, year(OrderDate)
order by ProductID

--Gross Profit by Quarter

select 	((MONTH(OrderDate) - 1) / 3) + 1 AS 'OrderQuarter',
		year(OrderDate) as 'OrderYear',
		format(sum(LineTotal - (OrderQty * StandardCost)), 'n0') as 'Gross Profit Margin'
from PanelX
group by ((MONTH(OrderDate) - 1) / 3) + 1, year(OrderDate)
order by OrderYear, OrderQuarter

--Gross Profit by month

select 	MONTH(OrderDate)  AS 'OrderMonth',
		year(OrderDate) as 'OrderYear',
		format(sum(LineTotal - (OrderQty * StandardCost)), 'n0') as 'Gross Profit Margin'
from PanelX
group by MONTH(OrderDate), year(OrderDate)
order by OrderYear, OrderMonth

--Gross Profit from the Total Income

select 	month(OrderDate)  as 'OrderMonth',
		year(OrderDate) as 'OrderYear',
		format(sum(LineTotal),'n0') as 'TotalIncome',
		format(sum(LineTotal - (OrderQty * StandardCost)),'n0') as 'Gross Profit Margin',
		format(sum(LineTotal - (OrderQty * StandardCost)) / sum(LineTotal),'p') as 'GrossMarginPercent'
from PanelX
group by month(OrderDate), year(OrderDate)
order by OrderYear, OrderMonth

/* Create 2 new tables that show the Total_Margin and the Loss Per Product */	
select  year(OrderDate) [year],
		month(OrderDate) [month],
		sum(LineTotal - StandardCost * OrderQty) as 'Gross Margin'
into Total_Margin
from PanelX
group by year(OrderDate), month(OrderDate)
order by year(OrderDate), month(OrderDate)

select  year(OrderDate) as 'Year',
		month(OrderDate) as 'Month',
		ProductID,
		ProductName,
		(sum((LineTotal)) - sum((StandardCost * OrderQty))) as 'LossPerProduct'
into Loss_Per_Product_T
from PanelX
where OrderDate> '2011-05-31 00:00:00.000'
group by year(OrderDate), month(OrderDate), ProductID, ProductName
having (sum((LineTotal)) - sum((StandardCost * OrderQty))) < 0
order by [Year], [Month]

select *,
		(abs(p.[LossPerProduct])/m.[Gross Margin]) as 'PercentofLossfromGrossMargin',
		p.[LossPerProduct] / (select sum([LossPerProduct])
							  from Loss_Per_Product_T
							) as 'PercentFromTotalLoss'
from Total_Margin M join Loss_Per_Product_T P 
	on m.[year]= P.[Year] and M.[month] = P.[Month]
order by M.[year],m.[month];


-- showing the Sum of Losses Per Month
select  m.[year],
		m.[month],
		sum(p.LossPerProduct) as 'SumLossPerMonth',
		sum(p.LossPerProduct) / (select sum([LossPerProduct])
								 from Total_Margin M join Loss_Per_Product_T P 
									on m.[year]= P.[Year] and M.[month] = P.[Month]) as 'PercentFromTotalLoss'
from Total_Margin M join Loss_Per_Product_T P 
	on m.[year]= P.[Year] and M.[month] = P.[Month]
group by m.[year], m.[month]
order by m.[year]

-- 10 % of Loss from Gross Margin
select  m.*,
		p.productID,
		p.Name,
		p.LossPerProduct,
		(abs(p.[LossPerProduct])/m.[Gross Margin]) as 'PercentofLossfromGrossMargin'
from Total_Margin M join Loss_Per_Product_T P 
	on m.[year]= P.[Year] and M.[month] = P.[Month]
where abs((p.[LossPerProduct])/m.[Gross Margin]) >= 0.1 and m.month = 3
order by PercentofLossfromGrossMargin desc

with cte_profit
	as (
		select m.*,
				p.LossPerProduct,
				(abs(p.[LossPerProduct])/m.[Gross Margin]) as 'PercentofLossfromGrossMargin'
		from Total_Margin M join Loss_Per_Product_T P 
			on m.[year]= P.[Year] and M.[month] = P.[Month]
		where abs((p.[LossPerProduct])/m.[Gross Margin]) >= 0.1
		)

select [year],
		[month],
		sum(PercentofLossfromGrossMargin) as 'PercentLossMonthly'
from cte_profit
group by [year], [month]

-- 1% of Losses Per Month
select  m.[year],
		m.[month],
		p.productID,
		p.Name,
		sum(p.LossPerProduct) as 'SumLossPerMonth',
		sum(p.LossPerProduct) / (select sum([LossPerProduct])
								 from Total_Margin M join Loss_Per_Product_T P 
									on m.[year]= P.[Year] and M.[month] = P.[Month]) as 'PercentFromTotalLoss'
from Total_Margin M join Loss_Per_Product_T P 
	on m.[year]= P.[Year] and M.[month] = P.[Month]
group by m.[year], m.[month], p.productID, p.Name
having (sum(p.LossPerProduct) / (select sum([LossPerProduct])
								 from Total_Margin M join Loss_Per_Product_T P 
									on m.[year]= P.[Year] and M.[month] = P.[Month])) >= 0.01
order by PercentFromTotalLoss desc


select m.[year],
		m.[month],
		sum(p.LossPerProduct) as 'SumLossPerMonth',
		sum(p.LossPerProduct) / (select sum([LossPerProduct])
								 from Total_Margin M join Loss_Per_Product_T P 
									on m.[year]= P.[Year] and M.[month] = P.[Month]) as 'PercentFromTotalLoss'
from Total_Margin M join Loss_Per_Product_T P 
	on m.[year]= P.[Year] and M.[month] = P.[Month]
group by m.[year], m.[month]
having (sum(p.LossPerProduct) / (select sum([LossPerProduct])
								 from Total_Margin M join Loss_Per_Product_T P 
									on m.[year]= P.[Year] and M.[month] = P.[Month])) >= 0.01
order by PercentFromTotalLoss desc


select sum([LossPerProduct]) SumLossPerProduct
from Total_Margin M join Loss_Per_Product_T P 
	on m.[year]= P.[Year] and M.[month] = P.[Month]

	   
select  sum(LineTotal - (OrderQty * StandardCost)) as 'GrossMargin'
from PanelX


-- CategoryName and SubCategoryName of Loss Per Month

with cte_Sub
	as (
		select m.[year],
				m.[month],
				p.productID,
				p.Name,
				sum(p.LossPerProduct) as 'SumLossPerMonth',
				sum(p.LossPerProduct) / (select sum([LossPerProduct])
										 from Total_Margin M join Loss_Per_Product_T P 
											on m.[year]= P.[Year] and M.[month] = P.[Month]) as 'PercentFromTotalLoss'
		from Total_Margin M join Loss_Per_Product_T P 
			on m.[year]= P.[Year] and M.[month] = P.[Month]
		group by m.[year], m.[month], p.productID, p.Name
		having (sum(p.LossPerProduct) / (select sum([LossPerProduct])
										 from Total_Margin M join Loss_Per_Product_T P 
											on m.[year]= P.[Year] and M.[month] = P.[Month])) >= 0.01
		)

select  distinct(px.ProductName), 
		px.SubCategoryName,
		px.CategoryName
from PanelX px
where exists (select ProductID
				from cte_Sub
				where  productName=px.ProductName
			  ) 

/*
--EDA

select  month(sh.OrderDate) [month],
		sum(case when year(sh.orderdate)='2011' then sd.orderQty else 0 end)*2 SumOrder2011,
		sum(case when year(sh.orderdate)='2012' then sd.orderQty else 0 end) SumOrder2012,
		sum(case when year(sh.orderdate)='2013' then sd.orderQty else 0 end) SumOrder2013,
		sum(case when year(sh.orderdate)='2014' then sd.orderQty else 0 end)*2 SumOrder2014
into SumOrdersQty
from Sales.SalesOrderDetail sd
join Sales.SalesOrderHeader sh
on sd.SalesOrderID=sh.SalesOrderID
group by month(sh.OrderDate) 
order by month(sh.OrderDate) 

--הטבלה עצמה שמציגה עבור כל שנה סכום כמות הזמנה פר חודש
select *
from SumOrdersQty

union 

select  13 as 'avg',
		AVG(SumOrder2011) Avg2011,
		AVG(SumOrder2012) Avg2012,
		AVG(SumOrder2013) Avg2013,
		AVG(SumOrder2014) Avg2014
from SumOrdersQty

union

select  14 as 'stdev',
		stdev(SumOrder2011) stdev2011,
		stdev(SumOrder2012) stdev2012,
		stdev(SumOrder2013) stdev2013,
		stdev(SumOrder2014) stdev2014
from SumOrdersQty

--כמות הזמנות כל חודש

select  month(OrderDate) [month],
		count(case when year(orderdate)='2011' then SalesOrderID end)*2 countOrder2011,
		count(case when year(orderdate)='2012' then SalesOrderID  end) countOrder2012,
		count(case when year(orderdate)='2013' then SalesOrderID  end) countOrder2013,
		count(case when year(orderdate)='2014' then SalesOrderID  end)*2 countOrder2014
into CountSalesQty
from Sales.SalesOrderHeader
group by month(OrderDate) 
order by month(OrderDate)	

--הטבלה עצמה שמציגה עבור כל שנה את כמות ההזמנות פר חודש
select *
from CountSalesQty

union 

select  13 as 'avg',
		AVG(countOrder2011) Avg2011,
		AVG(countOrder2012) Avg2012,
		AVG(countOrder2013) Avg2013,
		AVG(countOrder2014) Avg2014
from CountSalesQty

union

select  14 as 'stdev',
		stdev(countOrder2011) stdev2011,
		stdev(countOrder2012) stdev2012,
		stdev(countOrder2013) stdev2013,
		stdev(countOrder2014) stdev2014
from CountSalesQty

*/

select *
from Production.Product

select *
from Sales.SalesOrderDetail

select *
from Sales.SalesOrderHeader

-- Top 3 losses products
with cte_test2
	as (
		select m.[year],
					m.[month],
					p.[Name],
					sum(p.LossPerProduct) as 'SumLossPerMonth',
					sum(p.LossPerProduct) / (select sum([LossPerProduct])
											 from Total_Margin M join Loss_Per_Product_T P 
												on m.[year]= P.[Year] and M.[month] = P.[Month]) as 'PercentFromTotalLoss'
			from Total_Margin M join Loss_Per_Product_T P 
				on m.[year]= P.[Year] and M.[month] = P.[Month]
			group by m.[year], m.[month], p.[Name]
			)
select FORMAT(sum(case when [name] like '%Mountain-100%' then SumLossPerMonth else 0 end),'C') as 'Mountain-100',
	 FORMAT(sum(case when [name] like '%Touring-1000%' then SumLossPerMonth else 0 end),'C') as 'Touring-1000',
	 FORMAT(sum(case when [name] like '%Road-650%' then SumLossPerMonth else 0 end),'C') as 'Road-650',
	 FORMAT(sum(SumLossPerMonth),'C') as 'TotalLoss',
	FORMAT(( sum(case when [name] like '%Mountain-100%' then SumLossPerMonth else 0 end) + 
				sum(case when [name] like '%Touring-1000%' then SumLossPerMonth else 0 end) + 
				sum(case when [name] like '%Road-650%' then SumLossPerMonth else 0 end) ) /
				(sum(SumLossPerMonth)),'P') as 'Percent3ProductFromTotalLoss'
				
from cte_test2

--Bikes from all products

select CategoryName,
		count(*) as 'NuOfItems'
from PanelX
group by CategoryName

select distinct *
from PanelX
where CategoryName = 'Bikes'

select distinct SubCategoryName,
				CategoryName
from PanelX
where CategoryName = 'Bikes'

with cte_test2
	as (
		select m.[year],
					m.[month],
					p.[Name],
					sum(p.LossPerProduct) as 'SumLossPerMonth',
					sum(p.LossPerProduct) / (select sum([LossPerProduct])
											 from Total_Margin M join Loss_Per_Product_T P 
												on m.[year]= P.[Year] and M.[month] = P.[Month]) as 'PercentFromTotalLoss'
			from Total_Margin M join Loss_Per_Product_T P 
				on m.[year]= P.[Year] and M.[month] = P.[Month]
			group by m.[year], m.[month], p.[Name]
			)
select sum(case when [name] like '%Mountain-100%' then SumLossPerMonth else 0 end) as 'Mountain-100',
	 sum(case when [name] like '%Touring-1000%' then SumLossPerMonth else 0 end) as 'Touring-1000',
	 sum(case when [name] like '%Road-650%' then SumLossPerMonth else 0 end) as 'Road-650',
	 sum(SumLossPerMonth) as 'TotalLoss',
	 	sum(SumLossPerMonth) - (  sum(case when [name] like '%Mountain-100%' then SumLossPerMonth else 0 end) +  sum(case when [name] like '%Touring-1000%' then SumLossPerMonth else 0 end) + sum(case when [name] like '%Road-650%' then SumLossPerMonth else 0 end) ) as 'Other',
	( sum(case when [name] like '%Mountain-100%' then SumLossPerMonth else 0 end) +  sum(case when [name] like '%Touring-1000%' then SumLossPerMonth else 0 end) + sum(case when [name] like '%Road-650%' then SumLossPerMonth else 0 end) ) /(sum(SumLossPerMonth)) as 'Percent3ProductFromTotalLoss'
		
from cte_test2



select *
from PanelX

select h.SalesOrderID,OrderDate,SubTotal,LineTotal
from Sales.SalesOrderHeader H join Sales.SalesOrderDetail D
	on h.SalesOrderID = d.SalesOrderID
/*group by YEAR(h.OrderDate),MONTH(h.OrderDate)*/



