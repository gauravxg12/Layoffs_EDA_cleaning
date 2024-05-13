-- SQL Project - Data Cleaning
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Employee is our database we are grouping table in.

Use employee;

SELECT * 
FROM layoffs;

-- First of all we want to create a Stage table so that our real data dont get affected
CREATE TABLE layoffs_staging 
LIKE layoffs;

-- This Syntax creates table column for us.
-- Now lets insert data into this table 

INSERT INTO layoffs_staging 
SELECT * FROM layoffs;


-- STEP 1. Remove Duplicates

-- Checking for any duplicates through windows- ranking function
SELECT *
FROM layoffs_staging
;

-- Here we have to select all columns as their should be no duplicates

SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;

-- Now as we know our duplicates
-- We can delete our data in MYSQL with cte's or we can create a new table with row_number as its column.

ALTER TABLE layoffs_staging ADD row_num INT;

SELECT * FROM layoffs_staging;

CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging;

-- now that we have this we can delete rows were row_num is greater than 2

DELETE FROM layoffs_staging2
WHERE row_num >= 2;


-- STEP 2. Standardize Data

SELECT * 
FROM layoffs_staging2;

Select company from layoffs_staging2;

-- as we can see their is TRIM issue we have spoted in company column
-- so we need to update it 

UPDATE layoffs_staging2
SET company = trim(company);

-- Let's also fix the date columns:
SELECT *
FROM layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- everything looks good except apparently we have some "United States" and some "United States." 
-- with a period at the end. Let's standardize this.

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- In here Crypto has multiple different variations. We need to standardize that - 
-- let's say all to Crypto as cryptocurrency and Crypto are one another same thing

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- now that's taken care of lets check it
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- STEP 3. Look at Null Values

-- In this data we have many null values we need to get rid of it and standardize the data

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR  industry = ''
ORDER BY industry;

-- Now as we can see we have null values in industry as for airbnb
-- So lets look into its data

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';

-- In the first step we set empty spaces to null so that we can update them easily
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ' ';

-- now we need to fill those nulls , as we can see one Airbnb has industry data in it and other doesn’t  so we can do this for all null values  

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- after this three steps taken place we are sorted with our null values
-- So, lets remove columns and rows which are not required 

-- STEP 4. remove any columns and rows we need to

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- we can see we have many null values in total_laid_off column
-- now lets check percentage_laid_off

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- we have now cleaned out data and also standerized in a proper way we dont need the row_num
-- column so we need to drop it 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final result 
SELECT * 
FROM layoffs_staging2;
