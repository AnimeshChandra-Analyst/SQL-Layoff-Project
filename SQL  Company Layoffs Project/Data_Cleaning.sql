-- Data Cleaning

SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null or Blank values
-- 4. Remove any columns

-- Creating a copy of the raw data for cleaning
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Getting count of rows partitioned on the given columns
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging;

-- Finding exact rows with duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage,
 country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECt *
FROM duplicate_cte
WHERE row_num > 1;

-- Checking if the result is accurate
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';



-- Creating a new table with the row_num values and deleting the ones > 1

DROP TABLE IF EXISTS `layoffs_staging2`;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



SELECT *
FROM layoffs_staging2;

-- Inserting data including row_num column

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage,
 country, funds_raised_millions) AS row_num
FROM layoffs_staging;


-- Filtering

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 0;

DELETE  -- Duplicates deleted
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data

SELECT company, TRIM(Company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- updating the crypto industries into 1

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2;

-- LOCATION and COUNTRY
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)  -- Trailing to remove the . from USA
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT *
FROM layoffs_staging2;

-- Formatting Date

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SET sql_mode = '';
-- Changing data type of date from text to DATE

select *
from layoffs_staging2;


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- NULL anad Blank Values

select *
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

select DISTINCT *
from layoffs_staging2
WHERE industry IS NULL
OR industry = '';

select  *
from layoffs_staging2
WHERE company = 'Airbnb';

select  *
from layoffs_staging2
WHERE company LIKE 'Bally%';


 SELECT t1.industry, t2.industry
 FROM layoffs_staging2 AS t1
 JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

select  *
from layoffs_staging2;



select *
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- deleting the rou_num row
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;