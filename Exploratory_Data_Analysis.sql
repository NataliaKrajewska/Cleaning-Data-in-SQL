
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------
--Properties Per City
----------------------------------------------------------------------------------------------------------------------------------

SELECT PropertySplitCity, COUNT(PropertySplitCity) AS Properties_Sold
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY Properties_Sold DESC

----------------------------------------------------------------------------------------------------------------------------------
--Properties Per Owner
----------------------------------------------------------------------------------------------------------------------------------

SELECT OwnerName, COUNT(OwnerName) AS Properties_Owned
FROM PortfolioProject.dbo.NashvilleHousing
WHERE OwnerName IS NOT NULL
GROUP BY OwnerName
ORDER BY COUNT(OwnerName) desc

----------------------------------------------------------------------------------------------------------------------------------
--Sold Properties Per Year
----------------------------------------------------------------------------------------------------------------------------------

SELECT YEAR(SaleDateConverted) AS year, COUNT(SaleDateConverted) AS Properties_Sold
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY YEAR(SaleDateConverted)
ORDER BY Properties_Sold DESC

----------------------------------------------------------------------------------------------------------------------------------
-- Creating Price Categories
----------------------------------------------------------------------------------------------------------------------------------

WITH PriceCat AS (
SELECT *,
		CASE
			WHEN SalePrice <= 100000 THEN 'Cheap'
			WHEN SalePrice > 100000 AND SalePrice <= 1000000 THEN 'Average'
			ELSE 'Expensive'
		END AS Price_Category
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT Price_Category, COUNT([UniqueID]) AS Total_Properties
FROM PriceCat
GROUP BY Price_Category

