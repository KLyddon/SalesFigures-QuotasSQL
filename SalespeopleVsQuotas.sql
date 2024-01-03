SELECT Name, JobTitle, ManagerTitle, ManagerName, spby.Year, TotalSales, SalesQuota FROM
(SELECT
	e1.BusinessEntityID,
	CONCAT(p1.FirstName, ' ', p1.LastName) AS Name,
	e1.JobTitle,
	CASE
		WHEN e2.JobTitle IS NULL
		AND e1.OrganizationLevel = 1 THEN 'Chief Executive Officer'
		ELSE e2.JobTitle
	END AS ManagerTitle,
	CASE
		WHEN e1.OrganizationLevel = 1 THEN (
		SELECT
			CONCAT(p.FirstName, ' ', p.LastName)
		FROM
			AdventureWorks2016.HumanResources.Employee e
		JOIN AdventureWorks2016.Person.Person p ON
			e.BusinessEntityID = p.BusinessEntityID
		WHERE
			e.OrganizationLevel IS NULL
		)
		ELSE CONCAT(p2.FirstName, ' ', p2.LastName)
	END AS ManagerName,
	YEAR(soh.OrderDate) AS Year,
	SUM(TotalDue) AS "TotalSales"
FROM
	AdventureWorks2016.HumanResources.Employee e1
FULL JOIN AdventureWorks2016.HumanResources.Employee e2 ON
	e1.OrganizationNode.GetAncestor(1)= e2.OrganizationNode
JOIN AdventureWorks2016.Person.Person p1 ON
	e1.BusinessEntityID = p1.BusinessEntityID
FULL JOIN AdventureWorks2016.Person.Person p2 ON
	e2.BusinessEntityID = p2.BusinessEntityID
JOIN AdventureWorks2016.Sales.SalesOrderHeader soh ON
	e1.BusinessEntityID = soh.SalesPersonID 
WHERE
	e1.BusinessEntityID IS NOT NULL
GROUP BY 
	e1.BusinessEntityID, p1.FirstName, p1.LastName, e1.JobTitle, e2.JobTitle, e1.OrganizationLevel, p2.FirstName, p2.LastName, YEAR(soh.OrderDate)) AS spby
JOIN 
(SELECT BusinessEntityID, YEAR(QuotaDate) AS Year, SUM(SalesQuota) AS SalesQuota FROM AdventureWorks2016.Sales.SalesPersonQuotaHistory spqh
GROUP BY BusinessEntityID, YEAR(QuotaDate)) q
ON spby.BusinessEntityID = q.BusinessEntityID AND spby.Year = q.Year
ORDER BY spby.BusinessEntityID;