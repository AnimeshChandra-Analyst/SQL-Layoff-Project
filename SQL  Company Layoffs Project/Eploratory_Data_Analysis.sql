-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging2;

-- Maximum total laid off and maximum percentage of layoffs
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that were completely laid off or shut down
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Starting in around the beggining of covid and going 3 years
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Which industry was hit the hardest
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- Which country had the most layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Number of layoffs by Year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Stage of companies and the layoffs 
SELECT Stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY Stage
ORDER BY 2 DESC;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Progression of Layoffs

SELECT SUBSTRING(`date`, 6 , 2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`, 6 , 2);

-- Grouping all layoffs by each month from 2020 to 2023
SELECT SUBSTRING(`date`, 1 , 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1 , 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Progression of total Layoffs month by month wordwide using CTE
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1 , 7) AS `MONTH`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1 , 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_layoffs,
 SUM(total_layoffs) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Layoffs per month by Company
SELECT company, `date`,  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`;

-- BY Year

SELECT company, YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

SELECT company, YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

SELECT company, YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`);

-- ranking companies with highest number of layoffs each year
WITH Company_Year  (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER ( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;


-- Top 5 companies with most layoffs each year

WITH Company_Year  (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER ( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank 
WHERE Ranking <= 5 ;

-- Top 5 Industries with most layoffs each year

WITH Industry_Year  (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`),  SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER ( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Industry_Year_Rank 
WHERE Ranking <= 5 ;