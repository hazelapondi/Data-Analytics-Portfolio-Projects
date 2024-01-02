SELECT *
FROM
	[Portfolio Project]..CovidDeaths$
WHERE 
	continent IS NOT NULL
ORDER BY
	3,4;


SELECT *
FROM
	[Portfolio Project]..CovidVaccinations$
ORDER BY
	3,4;


SELECT
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM
	[Portfolio Project]..CovidDeaths$
ORDER BY
	1,2;


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE 
	location LIKE '%states%'
ORDER BY
	1,2;


--Looking at Total Cases vs Population
--Shows what percentage of the population got covid

SELECT
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 AS death_percentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	location LIKE '%states%'
ORDER BY
	1,2;


--Looking at Countries with highest Infection Rate compared to Population

SELECT
	location, 
	population, 
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM
	[Portfolio Project]..CovidDeaths$
GROUP BY
	location, 
	population
ORDER BY
	percent_population_infected DESC;


--Showing the Countries with the highest death count per Population

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT
	location, 
	MAX(CAST(total_deaths AS int)) AS total_death_count
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	total_death_count DESC;


--Showing continents with the highest death count per population

SELECT
	continent,
	MAX(CAST(total_deaths AS int)) AS total_death_count
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	total_death_count DESC;


--GLOBAL NUMBERS
SELECT
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	continent IS NOT NULL 
ORDER BY
	1,2;


--Looking at Total Population vs Vaccinations

--USE CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)AS(
	SELECT
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS rolling_people_vaccinated
	FROM
		[Portfolio Project]..CovidDeaths$ AS dea
	JOIN
		[Portfolio Project]..CovidVaccinations$ AS vac
	ON 
		dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	)
SELECT
	*, 
	(rolling_people_vaccinated/population)*100
FROM
	pop_vs_vac;


--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated(
	continent NVARCHAR(255),
	location NVARCHAR(255)
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rolling_people_vaccinated NUMERIC,
)

INSERT INTO
SELECT
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM
	[Portfolio Project]..CovidDeaths$ AS dea
JOIN
	[Portfolio Project]..CovidVaccinations$ AS vac
ON
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
SELECT
	*, 
	(rolling_people_vaccinated/population)*100
FROM
	#percent_population_vaccinated;


--Creating View to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS
	SELECT
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM
		[Portfolio Project]..CovidDeaths$ AS dea
	JOIN
		[Portfolio Project]..CovidVaccinations$ AS vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL

SELECT *
FROM
	percent_population_vaccinated;
