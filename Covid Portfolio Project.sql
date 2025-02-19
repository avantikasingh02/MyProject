SELECT * 
FROM ProjectPortfolio..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total deaths
-- Shows the probability of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF (total_cases, 0)) * 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of people got covid
SELECT location, date, total_cases, population,(total_cases/population) * 100 AS PeopleInfectedPercentage
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2

-- Looking at the countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population) * 100) AS PeopleInfectedPercentage
FROM ProjectPortfolio..CovidDeaths
GROUP BY location, population
ORDER BY PeopleInfectedPercentage DESC

-- Looking at the countries with Highest Death Count per population
SELECT location, MAX(total_Deaths) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by Continent
SELECT continent, MAX(total_Deaths) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the continents with Highest Death count per population
SELECT continent, population, MAX(total_Deaths) AS TotalDeathCount, MAX((total_deaths/population) * 100) AS PercentageOfPeopleDied
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY PercentageOfPeopleDied DESC

--Global Numbers
SELECT 
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Joining the two tables

SELECT *
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.date = vac.date;

-- Looking at Total Population vs Vaccinations
With PopvsVac (Continent, location, date, population,new_vaccinations, CumulativeCountOfVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS CumulativeCountOfVaccination
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (CumulativeCountOfVaccination/population)*100
FROM PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeCountOfVaccination numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS CumulativeCountOfVaccination
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativeCountOfVaccination/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS CumulativeCountOfVaccination
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

