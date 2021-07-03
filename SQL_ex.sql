
SELECT * FROM SQL_EXPLORE.dbo.covid_death$

ORDER BY 3,4;



--SELECT * FROM SQL_EXPLORE..covid_vaccin$
--ORDER BY 3,4;


SELECT 
location
, date
, total_cases
, new_cases
, total_deaths
, population
FROM SQL_EXPLORE.dbo.covid_death$
ORDER BY 1,2;


---looking at total cases and total death per location 


SELECT  
MAX(CONVERT(int, total_cases)) AS current_total_cases
, MAX(CONVERT(int, total_deaths)) AS current_total_deaths
FROM SQL_EXPLORE..covid_death$
WHERE 
location LIKE '%Viet%' ;


SELECT
location
, total_cases
, total_deaths
, (total_deaths/total_cases)*100
FROM SQL_EXPLORE..covid_death$;

--looking at total cases / population per location

SELECT
location
, date
, total_cases
, population
, (total_cases/population)*100
FROM SQL_EXPLORE..covid_death$
WHERE  location LIKE '%Viet%';

----which county with highest infection rate in the world 

SELECT
location
, population
, MAX(total_cases) as Highest_cases
, MAX((total_cases/population))*100 as Highest_percent_infecttion
FROM SQL_EXPLORE..covid_death$
GROUP BY location, population
ORDER BY Highest_percent_infecttion desc;


--- Showing country with highest deaths count in the world 


SELECT
location
, population
, MAX(CONVERT(float,total_deaths)) as highest_deaths

FROM SQL_EXPLORE..covid_death$
GROUP BY location, population
ORDER BY highest_deaths DESC;

---- showing continent with highest deaths in the world

SELECT 
continent
, MAX(CONVERT(float,total_deaths)) as highest_deaths_continent
FROM 
SQL_EXPLORE..covid_death$ 
WHERE continent is NOT NULL
GROUP BY continent
ORDER by highest_deaths_continent desc;

--- Which continent with high_vaccination

SELECT 
de.continent
, MAX(CONVERT(float, va.total_vaccinations)) highest_vaccination 
FROM SQL_EXPLORE.dbo.covid_death$ de
	JOIN 
	SQL_EXPLORE.dbo.covid_vaccin$	va
	ON de.location = va.location AND de.date = va.date 
WHERE 
de.continent IS NOT NULL
GROUP BY de.continent
ORDER BY highest_vaccination DESC	;

------- CREATE view table to store data
CREATE VIEW population_vaccine AS
SELECT 
de.continent
, de.location
, de.date
, de.population
, va.new_vaccinations
, SUM(CONVERT(float, va.new_vaccinations)) OVER (PARTITION BY de.location) AS Rollingpeoplevaccin
FROM SQL_EXPLORE.dbo.covid_death$ de
	JOIN 
	SQL_EXPLORE.dbo.covid_vaccin$	va
	ON de.location = va.location AND de.date = va.date 
WHERE 
de.continent IS NOT NULL;


SELECT * fROM population_vaccine ;

--DROP VIEW population_vaccine ;

--- CREATE TEMP_TABLE
CREATE TABLE #TEMP_POPULATION_VACCINE
(
	continent nvarchar(50),
	location  nvarchar(50),
	date datetime, 
	population float,
	new_vaccinations float, 
	Rollingpeoplevaccin float
);


INSERT INTO #TEMP_POPULATION_VACCINE

SELECT 
de.continent
, de.location
, de.date
, de.population
, va.new_vaccinations
, SUM(CONVERT(float, va.new_vaccinations)) OVER (PARTITION BY de.location) AS Rollingpeoplevaccin
FROM SQL_EXPLORE.dbo.covid_death$ de
	JOIN 
	SQL_EXPLORE.dbo.covid_vaccin$	va
	ON de.location = va.location AND de.date = va.date 
WHERE 
de.continent IS NOT NULL;


SELECT * FROM #TEMP_POPULATION_VACCINE ;

