# Cleaning-Data-in-SQL

<h2>Table of Contents</h2>

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning Steps](#data-cleaning-steps)

<h2>Project Overview</h2>
This project aims to tramsform raw data in SQL to make it more usable for analysis.

<h2>Data Sources</h2>
The dataset used for this project is the "Nashville_Housing.xlsx" file, containing detailed information about Nashville's real estate market.

<h2>Tools</h2>

- SQL Server

<h2>Data Cleaning Steps</h2>

1. Data loading and inspection
2. Date Format Standardization: converting the "SaleDate" column to a consistent date format and creates a new column "SaleDateConverted"
3. Populating Property Address Data: filling missing property addresses based on ParcelID matches with non-null addresses
4. Breaking Out Property Address: splitting the "Property Address" column into individual columns for address, city, and state
5. Breaking Out Owner Address: dividing the "Owner Address" column into columns for address, city, and state
6. Changing 'Y' and 'N' to 'Yes' and 'No': replacing 'Y' with 'Yes' and 'N' with 'No' in the "SoldAsVacant" column
7. Removing Duplicates
8. Deleting Unused Columns
