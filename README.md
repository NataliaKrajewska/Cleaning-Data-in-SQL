# Nashville Housing 

<h2>Table of Contents</h2>

- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning Steps](#data-cleaning-steps)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Results](#results)

<h2>Project Overview</h2>
This project aims to clean and transform raw data in SQL to make it more usable for analysis and pave the way for deep insights.

<h2>Problem Statement</h2>

- What is the number of properties sold per city?
- What is the number of properties owned by each owner?
- What is the number of properties sold in each year?
- What is the number of properties in cheap, average and expensive price category?

<h2>Data Source</h2>
The dataset used for this project is the "Nashville_Housing.xlsx" file, containing detailed information about Nashville's real estate market.

<h2>Tools</h2>

- SQL Server

<h2>Data Cleaning Steps</h2>

1. Data loading and inspection.
2. Date Format Standardization: Converting the "SaleDate" column to a consistent date format and creates a new column "SaleDateConverted".

```sql
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
```

3. Populating Property Address Data: Filling missing property addresses based on ParcelID matches with non-null addresses.

```sql
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

```

4. Breaking Out Property Address: Splitting the "Property Address" column into individual columns for address, city, and state.

```sql
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

```

5. Breaking Out Owner Address: Dividing the "Owner Address" column into columns for address, city, and state.

```sql
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

```

6. Changing 'Y' and 'N' to 'Yes' and 'No': Replacing 'Y' with 'Yes' and 'N' with 'No' in the "SoldAsVacant" column.

```sql
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

```

7. Removing Duplicates.

```sql
WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER (
	    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 LegalReference
        ORDER BY UniqueID
	) row_num
FROM PortfolioProject.dbo.NashvilleHousing
) 
DELETE
FROM RowNumCTE
WHERE row_num > 1

```

8. Deleting Unused Columns.

```
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

``` 

<h2>Exploratory Data Analysis</h2>

1. Properties per City: Counting the number of properties sold per city and presenting the data in descending order of properties sold.

```sql
SELECT PropertySplitCity, COUNT(PropertySplitCity) AS Properties_Sold
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY Properties_Sold DESC
```

2. Properties per Owner: Counting the number of properties owned by each owner, excluding cases with null owner names.

```sql
SELECT OwnerName, COUNT(OwnerName) AS Properties_Owned
FROM PortfolioProject.dbo.NashvilleHousing
WHERE OwnerName IS NOT NULL
GROUP BY OwnerName
ORDER BY COUNT(OwnerName) desc
```

3. Sold Properties per Year: Counting the number of properties sold in each year and presenting the data in descending order.

```sql
SELECT YEAR(SaleDateConverted) AS year, COUNT(SaleDateConverted) AS Properties_Sold
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY YEAR(SaleDateConverted)
ORDER BY Properties_Sold DESC
```

4. Creating Price Categories: Dividing the data into price categories ("Cheap," "Average," "Expensive") based on the SalePrice column and counting properties in each category.

```sql
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
```

<h2>Results</h2>

The analysis provided deeper insights into the structure of the Nashville housing market by identifying data patterns. The generated insights offered valuable information regarding the distribution of properties across different cities, the involvement of individual property owners, and sales trends over years across various price categories.
