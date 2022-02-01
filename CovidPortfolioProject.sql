--Selecting data to be used in exploration

SELECT continent, location, date, total_cases, new_cases,  total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT null
ORDER BY location, date

--Looking at Total Cases vs Total Deaths in the Philippines
SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Philippines'
ORDER BY location, date

-- Looking at Total cases vs Population
SELECT location, date, total_cases, population, (Total_cases/population)*100 as PercentofPopulationInfected
FROM CovidDeaths
WHERE location = 'Philippines'
ORDER BY location, date

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestIn, MAX((total_cases/population))*100 InfectionRate
FROM CovidDeaths
--WHERE location = 'Philippines'
GROUP BY location, population	
ORDER BY InfectionRate DESC

-- Showing the countries with the Highest Death Count per population
SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population	
ORDER BY TotalDeathCount DESC

-- Data per continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date,  sum(new_cases) AS SumNewCases, SUM(cast(new_deaths AS bigint)) AS SumNewDeaths, SUM(cast(new_deathsA)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs. vaccination
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Without CTE
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3


--Creating Tableau to store data for DataViz
CREATE VIEW RollingPeopleVaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3
