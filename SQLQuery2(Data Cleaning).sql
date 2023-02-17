--Cleaning the data
-----------------------------------------------------------------
select *
from PortfolioProject.dbo.[Housing Data]
-------------------------------------------------------------------
--Standardising Data Format

select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.[Housing Data]
-----------------------------------------------------------------
--Adding the new date as a new column to the data
ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add SaleDateConverted Date;

Update PortfolioProject.dbo.[Housing Data]
Set SaleDateConverted = CONVERT(Date, SaleDate)
---------------------------------------------------------------------------
--Populating the property address in the data
select *
from PortfolioProject.dbo.[Housing Data]
--where PropertyAddress is null
order by ParcelID
----------------------------------------------------------------------
--Doing a selfjoin to work on duplicate propertyaddress and to fill in the null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Housing Data] a
JOIN PortfolioProject.dbo.[Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
------------------------------------------------------------------------------------------------
--updating the propertyAddress into the data 

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Housing Data] a
JOIN PortfolioProject.dbo.[Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
----------------------------------------------------------------------------------
--Breaking out Address into individual culumns(Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.[Housing Data]
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))as Address
from PortfolioProject.dbo.[Housing Data]
--------------------------------------------------------------------------------------------------------
--creating the column


ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
--------------------------------------------------------------------------------------------------------------


--Another way for creatng a new column
select OwnerAddress
from PortfolioProject.dbo.[Housing Data]

select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.[Housing Data]

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
Set OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.[Housing Data]


----------------------------------------------------------------------------------
 --Change Y and N to Yes and No in "Sold as Vacant" field using the CASE function
--checking the numbers of Y and N that we have in the data.
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.[Housing Data]
group by SoldAsVacant
--order by 2
--creating a case statement

select SoldAsVacant,
CASE WHEN  SoldAsVacant ='Y' THEN 'Yes'
     WHEN  SoldAsVacant ='N' THEN 'No'
	 ELSE  SoldAsVacant
	 END
From PortfolioProject.dbo.[Housing Data]

Update PortfolioProject.dbo.[Housing Data]
Set SoldAsVacant = CASE WHEN  SoldAsVacant ='Y' THEN 'Yes'
     WHEN  SoldAsVacant ='N' THEN 'No'
	 ELSE  SoldAsVacant
	 END
From PortfolioProject.dbo.[Housing Data]

----------------------------------------------------------------------
--Removing Duplicates

WITH RowNumCTE AS(
Select *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID, 
	                PropertyAddress, 
					SalePrice, 
					SaleDate,
	                LegalReference
	                ORDER BY UniqueID) row_num

From PortfolioProject.dbo.[Housing Data]

)
--ordering by ParcelID
DELETE 
from RowNumCTE
Where row_num > 1
--Order by PropertyAddress

------------------------------------------------------------------------
--Deleting unused Columns

select *
from PortfolioProject.dbo.[Housing Data]

ALTER TABLE PortfolioProject.dbo.[Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.[Housing Data]
DROP COLUMN SaleDate

