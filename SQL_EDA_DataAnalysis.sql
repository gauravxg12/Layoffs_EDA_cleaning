-- EDA Exploratory Data Analysis

-- Entering into database

USE employee;

-- in this project we will do some data analysis for the dataset we cleaned called layoffs;

-- Q1 Calculate the MAXimum laid off?

SELECT MAX(total_laid_off)
FROM 
layoffs_staging2;

-- Q2 Calculate the MAXimum percentage laid off by companies?

SELECT company, MAX(Percentage_laid_off) AS `MAX_%_Laid_off`
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY company
ORDER BY `MAX_%_laid_off` DESC
;

-- Q3 Analyse how big this companies WHERE before these company went out of work?

SELECT company, percentage_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off =1
ORDER BY funds_raised_millions DESC;

-- Q4 find out companies WITH most total layoffs?

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER by 2 desc
LIMIT 10;

-- Q5 find out companies WITH most layoffs on the basis of location

SELECT location, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by location
ORDER by 2 desc
LIMIT 10;

-- Q6 find out the year WITH most layoffs

SELECT year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE year(`date`) is not null
GROUP by year(`date`)
ORDER by 2 desc;


-- Q7 Find out the companies WITH most layoffs per year?

SELECT company, year(`date`) as year, SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP by company, year(`date`)
ORDER by  2,3 desc;

-- Q8 Find out the companies WITH most layoffs per year WITH year wise layoffs of company?

WITH Company_year as(
SELECT company, year(`date`) as years, SUM(total_laid_off) as total_laid_off
FROM layoffs_staging2
GROUP by company, year(`date`)
ORDER by  2,3 desc
),
Company_year_rank as(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER by total_laid_off desc) As Ranking
FROM company_year
 )
 SELECT * FROM company_year_rank
 WHERE ranking <= 3
 AND years is not null
 ORDER by years asc, total_laid_off desc;
 
 -- Q9 On the basis of question no.8 calculate the rolling total as per month?
 
 WITH date_cte as (SELECT substring(`date`,1,7) as Dates, SUM(total_laid_off) AS total_laid_off
 FROM layoffs_staging2
 GROUP by 1
 ORDER by 2)
 
 SELECT dates, SUM(total_laid_off) OVER( ORDER by dates asc)
 AS rolling_total
 FROM Date_cte
 ORDER by dates ASC;

