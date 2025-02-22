/*

Data Cleaning through SQL Queries

*/

SELECT *
FROM ProjectPortfolio..NashvilleHousing

-- Standardize SaleDate field (Date format)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM ProjectPortfolio..NashvilleHousing;

--Populate Property Address Data

SELECT *
FROM ProjectPortfolio..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Breaking out address into individual columns (Address, City, State)
-- Workig on PROPERTYADDRESS

SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM ProjectPortfolio..NashvilleHousing

-- WORKING ON OWNERADDRESS

SELECT OwnerAddress
FROM ProjectPortfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM ProjectPortfolio..NashvilleHousing

-- Change Y and N to Yes and No in SoldAsVacant Field

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM ProjectPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
SoldAsVacant,
CASE
	When SoldAsVacant ='Y' THEN 'Yes'
	When SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
END
FROM ProjectPortfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE
		When SoldAsVacant ='Y' THEN 'Yes'
		When SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
	END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--Delete Unused Columns

SELECT *
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN SaleDate