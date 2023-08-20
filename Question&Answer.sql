-- 1. Who is the senior most employee based on job title?

---- Approach 1
SELECT CONCAT(FirstName,' ',LastName) as Name
	, Title
	, Levels
FROM Employee
WHERE Title LIKE '%Senior%'

---- Approach 2
SELECT CONCAT(FirstName,' ',LastName) as Name
	, Title
	, Levels  
FROM Employee
WHERE Levels = ( SELECT TOP 1 Levels FROM Employee ORDER BY Levels DESC)

--2. Which country has the highest sum of invoice totals?

SELECT TOP 1 BillingCountry
	, COUNT(BillingCountry) as NumberOfInvoice
FROM Invoice
GROUP BY BillingCountry
ORDER BY NumberOfInvoice DESC

--3. What are CustomerIds that fell in top 3 values of total invoice?

SELECT *
FROM Invoice
WHERE Total IN (SELECT TOP 3 Total FROM Invoice GROUP BY Total ORDER BY Total DESC)
ORDER BY Total DESC

--4. Who is the customer spending the most money?
SELECT TOP 1 Inv.CustomerId
	, CONCAT(Cus.FirstName, ' ', Cus.LastName) as CustomerName
	, SUM(Inv.Total) as TotalSpent
FROM Invoice Inv
LEFT JOIN Customer cus 
ON Cus.CustomerId = Inv.CustomerId
GROUP BY Inv.CustomerId, CONCAT(Cus.FirstName, ' ', Cus.LastName)
ORDER BY TotalSpent DESC

--5. Return the email, first name, last name of all Rock Music listeners. Return the list ordered alphabetically by email starting with A.
SELECT DISTINCT cus.Email
	, cus.FirstName
	, cus.LastName
FROM Customer cus
LEFT JOIN Invoice inv
ON inv.CustomerId = cus.CustomerId
LEFT JOIN InvoiceLine invl
ON invl.InvoiceId = inv.InvoiceId
LEFT JOIN Track tra
ON tra.TrackId = invl.TrackId
LEFT JOIN Genre gen
ON gen.GenreId = tra.GenreId
WHERE gen.name = 'Rock'
ORDER BY cus.Email ASC


--6. Which composer have written the most rock music in the dataset? 
WITH Rock_Composer AS (
	 SELECT value AS Composer
	 FROM Track
	 CROSS APPLY STRING_SPLIT(Composer, ',') 
	 LEFT JOIN Genre ON Genre.GenreId = Track.GenreId
	 WHERE value IS NOT NULL
	 AND Genre.Name = 'Rock' 
)
SELECT TOP 1 Composer
	, COUNT(Composer) as RockTracks
FROM Rock_Composer
GROUP BY Composer
ORDER BY RockTracks DESC


--7.Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT Name
	, Miliseconds 
FROM Track
WHERE Miliseconds > (SELECT AVG(Miliseconds) FROM Track)

--9. How much amount spent by each customer on artists? Return customer name, artist name and total spent.
WITH Customers_Spent_On_Artists AS (
	SELECT inv.CustomerId
		, CONCAT( cus.FirstName,' ', cus.LastName) as CustomerName
		, art.Name as ArtistName
		, inv.total 
	FROM Invoice inv
	LEFT JOIN Customer cus
		ON cus.CustomerId = inv.CustomerId
	LEFT JOIN InvoiceLine invl
		ON invl.InvoiceId = inv.InvoiceId
	LEFT JOIN Track tra
		ON tra.TrackId = invl.TrackId
	LEFT JOIN Album alb
		ON alb.AlbumId = tra.AlbumId
	LEFT JOIN Artist art
		ON art.ArtistId = alb.ArtistId
)
SELECT CustomerId
	, CustomerName
	, ArtistName
	, SUM(total) as TotalSpent
FROM Customers_Spent_On_Artists
GROUP BY CustomerId, CustomerName, ArtistName
ORDER BY TotalSpent DESC

--10. In each country, what is the most popular music genre which has the highest amount of purchases and the highest amount of money spent on ?
WITH Country_Genre_purchase_totalspent as (
		SELECT inv.BillingCountry
			, gen.Name as GenreName
			, SUM(inv.Total) as TotalSpent
			, COUNT(inv.InvoiceId) as Purchases
		FROM Invoice inv
		LEFT JOIN InvoiceLine invl
		ON invl.InvoiceId = inv.InvoiceId
		LEFT JOIN Track tra
		ON Tra.TrackId = invl.TrackId
		LEFT JOIN Genre gen
		ON gen.GenreId = tra.GenreId
		GROUP BY inv.BillingCountry, gen.Name 
)
, Rank_Genre_In_Countries AS (
	SELECT BillingCountry
		, GenreName
		, TotalSpent
		, Purchases
	, DENSE_RANK() OVER (PARTITION BY BillingCountry ORDER BY TotalSpent DESC) as Money_Ranking
	, DENSE_RANK() OVER (PARTITION BY BillingCountry ORDER BY Purchases DESC) as Purchases_Ranking
	FROM Country_Genre_purchase_totalspent
)
--- Get the genres having the highest amount of purchases, in each country
SELECT BillingCountry
	, GenreName
FROM Rank_Genre_In_Countries
WHERE Purchases_Ranking = 1

--- To get the genres having the highest amount of total spent on
-----replace WHERE clause with "WHERE Money_Ranking = 1"

--11. Return the top customer and how much they spent on music for each country
WITH Customer_Country_TotalSpent AS (
		SELECT CONCAT(Cus.FirstName,' ', Cus.LastName) AS CustomerName
			, Inv.BillingCountry
			, SUM(Inv.Total) AS TotalSpent
		FROM Invoice Inv
		LEFT JOIN Customer Cus
		ON Cus.CustomerId = Inv.CustomerId
		GROUP BY CONCAT(Cus.FirstName,' ', Cus.LastName), Inv.BillingCountry
)
, Rank_Customer AS (
		SELECT * 
			, DENSE_RANK() OVER (PARTITION BY BillingCountry ORDER BY TotalSpent DESC) AS Rank_SpentAmount
		FROM Customer_Country_TotalSpent
)
SELECT BillingCountry, CustomerName, TotalSpent
FROM Rank_Customer
WHERE Rank_SpentAmount = 1
