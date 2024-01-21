-- Selecting data to be used


USE PortfolioProject

SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM CovidDeaths
ORDER BY 1,2


-- Total Case vs Total Deaths
-- Shows likelihood of dying by contracting COVID in Country


SELECT location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows percentage of population with cases of COVID


SELECT location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 AS CasePercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population


SELECT location, 
	population, 
	MAX(total_cases) AS highest_infection_count, 
	MAX((total_cases/population))*100 AS PopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfected DESC


-- Countries with the Highest Deatch Count per Population
-- total_deaths needed to be cast to int to provide accurate information, set as VARCHAR(255)


SELECT location,
	MAX(cast(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  total_death_count DESC


-- Breakdown by Continent
-- Continents with the Highest Death Counts per Population


SELECT continent,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


--Global Numbers


SELECT SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS deathpercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Population vs Vaccinations


SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS rolling_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinated)
AS 

(
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS rolling_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_vaccinated/population)*100
FROM PopvsVac



-- Temp Table


-- DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS rolling_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_vaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View for data visualization


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS rolling_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated

