-- COVID19 Portfolio Project by Kevin Largey

SELECT *
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that will be used and order by country and date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID_Portfolio_Project..COVID19_Deaths
ORDER BY 1,2

-- Compare Total Cases vs. Total Deaths
-- Indicates percent chance of dying if infected with COVID19 (US)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE location like '%states%'
ORDER BY 1,2

-- Compare Total Cases vs Population
-- Indicates percent of population infected with COVID19 (US)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE location like '%states%'
ORDER BY 1,2

-- Determine countries with highest infection rates
SELECT location, population, MAX(total_cases) AS peak_infections, MAX(total_cases/population)*100 AS infection_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
GROUP BY location, population
ORDER BY 4 DESC

-- Determine countries with highest death rate
SELECT location, population, MAX(cast(total_deaths AS INT)) AS total_death_count, MAX(total_deaths/population)*100 AS death_rate_population
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_deaths DESC

-- Indicates deaths by continent

SELECT continent, MAX(cast(total_deaths AS INT)) AS total_death_count
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--SELECT location, MAX(cast(total_deaths AS INT)) AS total_death_count
--FROM COVID_Portfolio_Project..COVID19_Deaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY total_death_count DESC

-- Indicates global death by day
SELECT date, SUM(new_cases) AS global_cases, SUM(cast(new_deaths AS INT)) AS global_deaths, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS global_death_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Indicates overall death rate
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths AS INT)) AS global_deaths, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS global_death_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Indicates rolling vaccinations by country
-- USE CTE
WITH population_vs_vaccinated (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	   SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vaccinations
FROM COVID_Portfolio_Project..COVID19_Deaths cd
JOIN COVID_Portfolio_Project..COVID19_Vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_total_vaccinations/population)*100 AS percent_vaccinated
FROM population_vs_vaccinated

-- Temp table
DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vaccinations numeric
)
INSERT INTO #Percent_Population_Vaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	   SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vaccinations
FROM COVID_Portfolio_Project..COVID19_Deaths cd
JOIN COVID_Portfolio_Project..COVID19_Vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
SELECT *, (rolling_total_vaccinations/population)*100 AS percent_vaccinated
FROM #Percent_Population_Vaccinated

--Creates view to store data for visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	   SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vaccinations
FROM COVID_Portfolio_Project..COVID19_Deaths cd
JOIN COVID_Portfolio_Project..COVID19_Vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM Percent_Population_Vaccinated


-- NEW FOR TABLEAU PROJECT

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS death_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM COVID_Portfolio_Project..COVID19_Deaths
WHERE continent IS NULL
AND location NOT IN ('world', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count desc

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
GROUP BY location, population
ORDER BY infection_rate desc

SELECT location, population, date, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM COVID_Portfolio_Project..COVID19_Deaths
GROUP BY location, population, date
ORDER BY infection_rate desc