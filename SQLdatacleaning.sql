
Select * from portfolioproject..nashvillehousingdata

--Standardizing date format

Select SaleDate
from portfolioproject..nashvillehousingdata

Update nashvillehousingdata SET SaleDate=convert(date,SaleDate)

ALTER TABLE nashvillehousingdata 
ADD SaleDateconv date

update nashvillehousingdata 
set SaleDateconv=convert(date,SaleDate)

Select SaleDateconv
from portfolioproject..nashvillehousingdata

--populate property address date

Select *
from portfolioproject..nashvillehousingdata
where PropertyAddress is NULL

Select *
from portfolioproject..nashvillehousingdata
order by ParcelID

-- if two parcelids are same we are updating the null address with the same parcel id address

-- performing join operations to do that

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from portfolioproject..nashvillehousingdata a
join portfolioproject..nashvillehousingdata b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
Set PropertyAddress=ISNULL(a.propertyaddress,b.PropertyAddress)
from portfolioproject..nashvillehousingdata a
join portfolioproject..nashvillehousingdata b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--- breaking out address into individual columns(address,city,state)

Select PropertyAddress
from portfolioproject..nashvillehousingdata

select 
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as address1
from portfolioproject..nashvillehousingdata

ALTER TABLE nashvillehousingdata 
ADD propertycityaddress nvarchar(255);

update nashvillehousingdata 
set propertycityaddress=substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) 

ALTER TABLE nashvillehousingdata 
ADD Propertysplitaddress nvarchar(255);

update nashvillehousingdata 
set Propertysplitaddress=substring(propertyaddress,1,charindex(',',propertyaddress)-1)

select *
from portfolioproject..nashvillehousingdata


select OwnerAddress
from portfolioproject..nashvillehousingdata


---- using parsename to seperate address, parsename does things backwards and it only works with dot operator.
--- so first we replace comma with dot and display in the 3,2,1 order

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from portfolioproject..nashvillehousingdata

ALTER TABLE nashvillehousingdata 
ADD ownersplitaddress nvarchar(255);

update nashvillehousingdata 
set ownersplitaddress=PARSENAME(replace(owneraddress,',','.'),3)

ALTER TABLE nashvillehousingdata 
ADD ownersplitcity nvarchar(255);

update nashvillehousingdata 
set ownersplitcity=PARSENAME(replace(owneraddress,',','.'),2)

ALTER TABLE nashvillehousingdata 
ADD ownersplitstate nvarchar(255);

update nashvillehousingdata 
set ownersplitstate=PARSENAME(replace(owneraddress,',','.'),1)

select *
from portfolioproject..nashvillehousingdata

--- changing Y and N to YEs and NO in "sold as vacant" field

select distinct(soldasvacant),count(soldasvacant)
from portfolioproject..nashvillehousingdata
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant='Y' THEN 'Yes'
	 when SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 end
from portfolioproject..nashvillehousingdata

update nashvillehousingdata
set SoldAsVacant=case when SoldAsVacant='Y' THEN 'Yes'
	 when SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 end
from portfolioproject..nashvillehousingdata


--- REMOVE Duplicates
--Adding a PARTITION BY clause on the recovery_model_desc column, will restart the numbering when the recovery_model_desc value changes.
-- row_number function checks if any two rows has same parcelid,propertyaddress,saleprice,saledate,legalreference. If any two rows have the same values it will name that row number as 
---2,3.. etcc.
--- 
select * ,
		ROW_NUMBER() over(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					      UniqueID)row_num

from portfolioproject..nashvillehousingdata
order by ParcelID

WITH ROwNumCTE AS(
select * ,
		ROW_NUMBER() over(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					      UniqueID)row_num
						  
from portfolioproject..nashvillehousingdata
)
select *
from ROwNumCTE
where row_num>1

--- delete unused columns

alter table portfolioproject..nashvillehousingdata
drop column owneraddress,taxdistrict, propertyaddress

select * 
from portfolioproject..nashvillehousingdata

alter table portfolioproject..nashvillehousingdata
drop column saledate