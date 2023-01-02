/*
Cleaning Data in SQL Queries
*/


Select * 
from PortfolioProjects..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate , Convert(date,SaleDate)
from PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
Set SaleDate = Convert(date,SaleDate) 
--The update function does not work here for changing the type of the column. However we can alter table, add new column and update it accordingly or we can 
--directly alter the type of the column itself

--Type1 - This will just alter the dedicated column and change its type to the required one along with the values, no new column is added
Alter table PortfolioProjects.dbo.NashvilleHousing
ALter column SaleDate Date;

Select * 
from PortfolioProjects..NashvilleHousing

--Type2 - This will add a new column and then update the new column with the old column specified along with the new type.
--Alter table PortfolioProjects.dbo.NashvilleHousing
--Drop Column SaleDateConverted;

Alter table PortfolioProjects.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProjects.dbo.NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate) 

Select * 
from PortfolioProjects..NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select * 
from PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress
from PortfolioProjects..NashvilleHousing t1
Join PortfolioProjects..NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	and t1.[UniqueID ] != t2.[UniqueID ]
where t1.PropertyAddress is null

--to check whether the t2.propertyaddress gets populated in t1.propertyaddress, we will use ISNULL(variable to be checked,variable/string from which value is updated)
Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
from PortfolioProjects..NashvilleHousing t1
Join PortfolioProjects..NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	and t1.[UniqueID ] != t2.[UniqueID ]
where t1.PropertyAddress is null

--updating the table, as we performed join we use alias and not actual table name
Update t1
set PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
from PortfolioProjects..NashvilleHousing t1
Join PortfolioProjects..NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	and t1.[UniqueID ] != t2.[UniqueID ]

Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress
from PortfolioProjects..NashvilleHousing t1
Join PortfolioProjects..NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	and t1.[UniqueID ] != t2.[UniqueID ]
where t1.PropertyAddress is null 

--the above query gives null rows, which means all the empty property addresses are populated with respected values 

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


--Splitting the property address using the SUBSTRING function
Select PropertyAddress 
from PortfolioProjects..NashvilleHousing

--We are going to use the Substring function to divide the address using the delimiter given in it.
--We will also use CharIndex to determine the position of the delimiter and use it accurately as per the requirement.
--CHARINDEX(',',PropertyAddress) this gives the position/location of the delimiter(',')
Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProjects..NashvilleHousing

Alter table PortfolioProjects.dbo.NashvilleHousing
Add PropertyAddress_Address nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing
Add PropertyAddress_City nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
Set PropertyAddress_Address = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Update PortfolioProjects..NashvilleHousing
Set PropertyAddress_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProjects..NashvilleHousing

--Splitting the owner address using the PARSENAME (generally used where there are delimiters used is .)
--Also PARSENAME executes backwards, so the first (.) to be executed or (,) replaced by (.) needs to mentioned as last
Select OwnerAddress 
From PortfolioProjects..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProjects..NashvilleHousing

Alter table PortfolioProjects.dbo.NashvilleHousing
Add OwnerAddress_Address nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing
Add OwnerAddress_City nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing
Add OwnerAddress_State nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
Set OwnerAddress_Address = PARSENAME(Replace(OwnerAddress,',','.'),3)
Update PortfolioProjects.dbo.NashvilleHousing
Set OwnerAddress_City = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update PortfolioProjects.dbo.NashvilleHousing
Set OwnerAddress_State = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(soldasvacant), Count(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
Group by SoldAsVacant

--in the above query we can see that, out of 4 values, Yes and No are the most densely populated than Y and N. We can change it to Yes and No.
--For doing this we can use the Case function here, where we can define to change the values on certain conditions.

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
End
From PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
				   End
		   
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
Group by SoldAsVacant


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RownumCTE AS(
Select *,
ROW_NUMBER() Over (
			 Partition By ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID
			 ) row_num
From PortfolioProjects..NashvilleHousing
--order by ParcelID
)
--Delete
--From RownumCTE
--where row_num > 1
--order by ParcelID    Order by does not works with Delete function

Select *
From RownumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

--Lets say, we created new columns for the property address, owner address and sale date in a seperated way which is more comfortable.
--Therefore we have no further need of the old columns for those, hence we can delete these columns as they are of no use further.
--But just make sure that you dont delete anything from the raw data or table, Always discuss what is required or make a copy of raw data and then delete.
--To update the table by deleting the unused columns, first seperate the old columns into new ones

Select 
PARSENAME(Replace(PropertyAddress,',','.'),2),
PARSENAME(Replace(PropertyAddress,',','.'),1),
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProjects..NashvilleHousing2

Alter table PortfolioProjects.dbo.NashvilleHousing2
Add PropertyAddress_Address nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing2
Add PropertyAddress_City nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing2
Add OwnerAddress_Address nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing2
Add OwnerAddress_City nvarchar(255);

Alter table PortfolioProjects.dbo.NashvilleHousing2
Add OwnerAddress_State nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing2
Set PropertyAddress_Address = PARSENAME(Replace(PropertyAddress,',','.'),2)

Update PortfolioProjects.dbo.NashvilleHousing2
Set PropertyAddress_City = PARSENAME(Replace(PropertyAddress,',','.'),1)
 
Update PortfolioProjects.dbo.NashvilleHousing2
Set OwnerAddress_Address = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update PortfolioProjects.dbo.NashvilleHousing2
Set OwnerAddress_City = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update PortfolioProjects.dbo.NashvilleHousing2
Set OwnerAddress_State = PARSENAME(Replace(OwnerAddress,',','.'),1)

Alter Table PortfolioProjects..NashvilleHousing2
Drop Column OwnerAddress, PropertyAddress,TaxDistrict,SaleDate

--Alter Table PortfolioProjects..NashvilleHousing2
--Drop Column SaleDate

Select *
From PortfolioProjects..NashvilleHousing2


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
