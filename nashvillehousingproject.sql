/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM nashvillehousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

With example_date_conversion
AS
	(
Select sale_date, sale_date::timestamp
From nashvillehousing
	)
Select sale_date::date
FROM nashvillehousing


Alter Table nashvillehousing 
Alter Column sale_date TYPE date



--Find nulls in the property_address columns and fill them matching parcel_id by using an inner join

Select *
From nashvillehousing
Where property_address IS NULL
Order By parcel_id


Select a.parcel_id, a.property_address, b.parcel_id, b.property_address, coalesce(a.property_address, b.property_address)
From nashvillehousing a
JOIN nashvillehousing b 
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
Where a.property_address is null	


UPDATE nashvillehousing
SET property_address = coalesce(a.property_address, b.property_address)
From nashvillehousing a
JOIN nashvillehousing b 
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
Where a.property_address is null	



--Breaking out address into individual columns (address, city, state)

Select 
	substring(property_address,1, strpos(property_address,',')-1) as address,
	substring(property_address,strpos(property_address,',')+1,Length(property_address)) as city
From nashvillehousing


Alter Table nashvillehousing 
Add property_split_address varchar(50)


Alter Table nashvillehousing
Add property_split_city varchar(50)


Update nashvillehousing
Set property_split_address = substring(property_address,1, strpos(property_address,',')-1)


Update nashvillehousing
Set property_split_city = substring(property_address,strpos(property_address,',')+1,Length(property_address))


Select owner_address, parcel_id
From nashvillehousing
order by parcel_id


Select 
	substring(owner_address,1, strpos(owner_address,',')-1) as address,
	Left(Trim(substring(owner_address,strpos(owner_address,',')+1,Length(owner_address))),-4) as city,
	Right(Trim(owner_address),2) as state
From nashvillehousing


Alter Table nashvillehousing 
Add owner_split_address varchar(50)


Alter Table nashvillehousing
Add owner_split_city varchar(50)


Alter Table nashvillehousing
Add owner_split_state varchar(50)


Update nashvillehousing
Set owner_split_address = 	substring(owner_address,1, strpos(owner_address,',')-1)


Update nashvillehousing
Set owner_split_city = 	Left(Trim(substring(owner_address,strpos(owner_address,',')+1,Length(owner_address))),-4)


Update nashvillehousing
Set owner_split_state = 	Right(Trim(owner_address),2)



--Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(sold_as_vacant)
From nashvillehousing


Select
CASE 
WHEN sold_as_vacant = 'Y' Then 'Yes'
Else 'No'
End as sold_as_vacant
From nashvillehousing


Update nashvillehousing
Set sold_as_vacant = 	CASE 
						WHEN sold_as_vacant = 'Y' Then 'Yes'
						Else 'No'
						End



--Remove Duplicates

---First, check for duplicates
With RowNumCTE 
AS 
(
Select *,
	Row_Number() Over(
	Partition By parcel_id, property_address, sale_price, legal_reference Order By unique_id) row_num
From nashvillehousing
)
Select *
From RowNumCTE
Where row_num > 1

---Delete duplicates from table:

Delete From nashvillehousing
Where unique_id IN
	(Select unique_id
	From 
		(Select unique_id, 
		ROW_NUMBER() OVER(PARTITION BY parcel_id,property_address,sale_price,legal_reference Order By unique_id) as row_num
		From nashvillehousing) n
		Where n.row_num > 1);
			
			
					
--Delete Unused Columns

Select *
From nashvillehousing


Alter Table nashvillehousing
Drop Column property_address,
Drop Column owner_address,
Drop Column tax_district



