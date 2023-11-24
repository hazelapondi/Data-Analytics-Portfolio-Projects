SELECT
	*
FROM
	[Portfolio Project]..CovidDeaths$
WHERE 
	continent IS NOT NULL
ORDER BY
	3,4;

SELECT
	*
FROM
	[Portfolio Project]..CovidVaccinations$
ORDER BY
	3,4;

SELECT
	Location, 
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
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE 
	location like '%states%'
ORDER BY
	1,2;

--Looking at Total Cases vs Population
--Shows what percentage of the population got covid

SELECT
	Location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as DeathPercentage
FROM
	[Portfolio Project]..CovidDeaths$
WHERE
	location like '%states%'
ORDER BY
	1,2;

--Looking at Countries with highest Infection Rate compared to Population

SELECT
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentPopulationInfected
FROM
	[Portfolio Project]..CovidDeaths$
--WHERE location LIKE '%states%'
GROUP BY
	Location, 
	Population
ORDER BY
	PercentPopulationInfected DESC;

--Showing the Countries with the highest death count per Population

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT
	location, 
	MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM
	[Portfolio Project]..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	TotalDeathCount DESC;

--Showing continents with the highest death count per population

SELECT
	continent,
	MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM
	[Portfolio Project]..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	TotalDeathCount DESC;

--GLOBAL NUMBERS
SELECT
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM
	[Portfolio Project]..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE
	continent IS NOT NULL
--GROUP BY date 
ORDER BY
	1,2;

--Looking at Total Population vs Vaccinations

--USE CTE

WITH PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)AS(
	SELECT
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	FROM
		[Portfolio Project]..CovidDeaths$ AS dea
	JOIN
		[Portfolio Project]..CovidVaccinations$ AS vac
	ON 
		dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	)
SELECT
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM
	PopvsVac;

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	Continent nvarchar(255),
	Location nvarchar(255)
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric,
)

INSERT INTO
SELECT
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	[Portfolio Project]..CovidDeaths$ AS dea
JOIN
	[Portfolio Project]..CovidVaccinations$ AS vac
ON
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM
	#PercentPopulationVaccinated;

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
	SELECT
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	FROM
		[Portfolio Project]..CovidDeaths$ AS dea
	JOIN
		[Portfolio Project]..CovidVaccinations$ AS vac
	ON
		dea.location = vac.location
		AND dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT
	*
FROM
	PercentPopulationVaccinated;
