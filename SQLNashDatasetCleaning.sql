SELECT * FROM dbo.NASHDataset


SELECT SaleDate FROM nashville_housing.dbo.NashDataset


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM nashville_housing.dbo.NashDataset

 UPDATE NashDataset
 SET SaleDate = CONVERT(Date, SaleDate)

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM nashville_housing.dbo.NashDataset

 ALTER TABLE NashDataset
 ADD SaleDate2 Date

 UPDATE NashDataset
 SET SaleDate2 = CONVERT(Date, SaleDate)
 
SELECT SaleDate2, CONVERT(Date, SaleDate)
FROM nashville_housing.dbo.NashDataset

ALTER TABLE NashDataset
DROP COLUMN SaleDateConverted

SELECT PropertyAddress 
FROM NashDataset


SELECT PropertyAddress 
FROM NashDataset
WHERE PropertyAddress is null


SELECT *
FROM NashDataset
ORDER BY ParcelID

-- USE SELF JOIN TO POPULATE Propertyaddress having same ParcelID

SELECT *
FROM NashDataset l
JOIN NashDataset m
ON l.ParcelID = m.ParcelID
And l.UniqueID <> m.UniqueID

SELECT l.ParcelID,l.PropertyAddress, m.ParcelID,m.PropertyAddress
FROM NashDataset l
JOIN NashDataset m
ON l.ParcelID = m.ParcelID
And l.UniqueID <> m.UniqueID

SELECT l.ParcelID,l.PropertyAddress, m.ParcelID,m.PropertyAddress
FROM NashDataset l
JOIN NashDataset m
ON l.ParcelID = m.ParcelID
And l.UniqueID <> m.UniqueID
where l.PropertyAddress is null

SELECT l.ParcelID,l.PropertyAddress, m.ParcelID,m.PropertyAddress,ISNULL(l.PropertyAddress,m.PropertyAddress)
FROM NashDataset l
JOIN NashDataset m
ON l.ParcelID = m.ParcelID
And l.UniqueID <> m.UniqueID
where l.PropertyAddress is null

UPDATE l
SET PropertyAddress = ISNULL(l.PropertyAddress,m.PropertyAddress)
FROM NashDataset l
JOIN NashDataset m
ON l.ParcelID = m.ParcelID
And l.UniqueID <> m.UniqueID
where l.PropertyAddress is null

SELECT l.ParcelID,l.PropertyAddress, m.ParcelID,m.PropertyAddress,ISNULL(l.PropertyAddress,m.PropertyAddress)
FROM NashDataset l
JOIN NashDataset m
ON l.ParcelID = m.ParcelID
And l.UniqueID <> m.UniqueID
where l.PropertyAddress is null

SELECT PropertyAddress
FROM NashDataset
where PropertyAddress is null
------------------------------------------------------------------------------------

SELECT 
SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress))) as Address
FROM NashDataset

SELECT 
SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress))) as Address,
CHARINDEX(',',PropertyAddress)
FROM NashDataset

SELECT 
SUBSTRING(PropertyAddress,1,(CHARINDEX(',',PropertyAddress))) as Address,
(CHARINDEX(',',PropertyAddress))-1
FROM NashDataset


SELECT 
SUBSTRING(PropertyAddress,1,((CHARINDEX(',',PropertyAddress)))-1) as Address
FROM NashDataset


SELECT 
SUBSTRING(PropertyAddress,1,((CHARINDEX(',',PropertyAddress)))-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
FROM NashDataset

ALTER TABLE NashDataset
 ADD PropertyDivideAddress Nvarchar(255)

 UPDATE NashDataset
 SET PropertyDivideAddress = SUBSTRING(PropertyAddress,1,((CHARINDEX(',',PropertyAddress)))-1)


 ALTER TABLE NashDataset
 ADD PropertyDivideCity Nvarchar(255)

 UPDATE NashDataset
 SET PropertyDivideCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

 SELECT * FROM NashDataset

 SELECT OwnerAddress
 FROM NashDataset

 SELECT
 PARSENAME(OwnerAddress,1)
 FROM NashDataset
 -- nothing changes since Parsename looks for periods or dots

 
 SELECT
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM NashDataset

 ALTER TABLE NashDataset
 ADD Owner_address_only Nvarchar(255)

 UPDATE NashDataset
 SET Owner_address_only = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 
 ALTER TABLE NashDataset
 ADD Owner_address_City Nvarchar(255)

 UPDATE NashDataset
 SET Owner_address_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


 
 
 ALTER TABLE NashDataset
 ADD Owner_address_state Nvarchar(255)

 UPDATE NashDataset
 SET Owner_address_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 SELECT * FROM NashDataset

 --------------------------------------------------------------

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM NashDataset GROUP BY SoldAsVacant 

  SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM NashDataset GROUP BY SoldAsVacant order by 2

 --- replace y and n with yes and no

 SELECT SoldAsVacant,
 CASE When SoldAsVacant = 'Y' Then 'YES'
      When SoldAsVacant = 'N' Then 'NO'
	  ELSE SoldAsVacant
	  END
FROM NashDataset

ALTER TABLE NashDataset
ADD Sold_As_Vacant Varchar(255)

UPDATE NashDataset
SET Sold_As_Vacant = CASE When SoldAsVacant = 'Y' Then 'YES'
      When SoldAsVacant = 'N' Then 'NO'
	  ELSE SoldAsVacant
	  END

SELECT * FROM NashDataset

SELECT DISTINCT(Sold_As_Vacant), COUNT(Sold_As_Vacant)
FROM NashDataset GROUP BY Sold_As_Vacant ORDER BY 2

ALTER TABLE NashDataset
DROP COLUMN SoldAsVacant
----------------------------------------------------------------
---- WRITE CTE and do some windows function to find where there are duplicate values


SELECT *,
ROW_NUMBER() OVER (
-- partition on things that should be unique to each row
PARTITION BY ParcelID, PropertyAddress,SaleDate2,LegalReference,LandUse,SalePrice,YearBuilt
ORDER BY UniqueID) row_num
FROM NashDataset ORDER BY ParcelID


WITH RowsCTE AS (
SELECT *,
ROW_NUMBER() OVER (
-- partition on things that should be unique to each row
PARTITION BY ParcelID, PropertyAddress,SaleDate2,LegalReference,LandUse,SalePrice,YearBuilt
ORDER BY UniqueID) row_num
FROM NashDataset 
)
SELECT * FROM RowsCTE 
WHERE row_num >1
ORDER BY PropertyAddress


WITH RowsCTE AS (
SELECT *,
ROW_NUMBER() OVER (
-- partition on things that should be unique to each row
PARTITION BY ParcelID, PropertyAddress,SaleDate2,LegalReference,LandUse,SalePrice,YearBuilt
ORDER BY UniqueID) row_num
FROM NashDataset 
)
DELETE FROM RowsCTE 
WHERE row_num >1
)

WITH RowsCTE AS (
SELECT *,
ROW_NUMBER() OVER (
-- partition on things that should be unique to each row
PARTITION BY ParcelID, PropertyAddress,SaleDate2,LegalReference,LandUse,SalePrice,YearBuilt
ORDER BY UniqueID) row_num
FROM NashDataset 
)
SELECT * FROM RowsCTE 
WHERE row_num >1
ORDER BY PropertyAddress

-------------------------------------------------

ALTER TABLE NashDataset
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

SELECT * FROM NashDataset


