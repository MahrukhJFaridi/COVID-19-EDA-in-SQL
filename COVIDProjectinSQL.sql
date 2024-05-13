
--COVID-19 Data Exploration

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4




--Identifying the data that is to be studied

SELECT
	location,
	date,
	total_cases,
	new_cases, 
	total_deaths, 
	population

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2




--Analyzing the comparison of Total Cases and the Total Deaths in the United States
--Displays the likelihood of dying upon contracting COVID
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	death_percentage = (CAST(total_deaths as float)/CAST(total_cases as float))*100

FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United States'
ORDER BY 2



--Analyzing the comparison of Total Cases and the Population in the United States
--Displays the percentage of population that got diagnosed with COVID
SELECT
	location,
	date,
	total_cases,
	population,
	percent_population_infected = (total_cases/population)*100

FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United States'
ORDER BY 2




--Examining the Nations with the Highest Infection Rates relative to their Populations
SELECT
	location,
	population,
	highest_infection_count = MAX(total_cases),
	percent_population_infected = MAX((total_cases/population))*100

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC




--Examining Nations with the Highest Death Count per Population
SELECT
	location,
	total_death_count = MAX(CAST(total_deaths as bigint))
	

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC




--Examining Continents with Highest Death Count per Population
SELECT
	continent,
	total_death_count = SUM(CAST(new_deaths as bigint))
	

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC  




--Displays the percentage of people sent to the ICU out of all patients in the United States
SELECT 
location,
date,
population,
icu_patients,
hosp_patients,
percentage_people_icu_admission= CONVERT(float,icu_patients)/CONVERT(float,hosp_patients) *100


FROM PortfolioProject..CovidDeaths 
WHERE location= 'United States'




--Analyzing the comparison between Total Population and People Fully Vaccinated in the United States
--Shows that almost 70% of the population in the United States is Fully Vaccinated

SELECT	
dea.location,
dea.population,
percentage_people_fullyvaccinated= MAX(CONVERT(bigint,people_fully_vaccinated))/dea.population*100

FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON vac.location=dea.location
	AND vac.date=dea.date

WHERE dea.location='United States' AND vac.location= 'United States'
	AND vac.continent IS NOT NULL AND dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY 1




--Analyzing the comparison between Total Population and People Fully Vaccinated in the World
SELECT	
dea.location,
dea.population,
percentage_people_fullyvaccinated= MAX(CONVERT(bigint,people_fully_vaccinated))/dea.population*100

FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON vac.location=dea.location
	AND vac.date=dea.date

WHERE vac.continent IS NOT NULL AND dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY 1





--Utilizing a CTE to analyze what percent of population of each country received atleast one vaccine.

WITH PopulationvsVaccinations (continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
people_vaccinated= SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date)

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND vac.continent IS NOT NULL
)


SELECT
*, 
perc_ppl_vaccinated_atleast_once = (people_vaccinated/population)*100
FROM PopulationvsVaccinations





-- Using Temp Table to to analyze what percent of population of each country received atleast one vaccine.

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
people_vaccinated= SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date)

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null AND vac.continent IS NOT NULL



SELECT
*, 
perc_ppl_vaccinated_atleast_once = (people_vaccinated/population)*100
FROM #PercentPopulationVaccinated




--Creating Views to store above queries for Visualizations in Tableau

--View for what percent of population of each country received atleast one vaccine.
CREATE VIEW PercentPopulationVaccinated AS

SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
people_vaccinated= SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date)

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND vac.continent IS NOT NULL



SELECT
*, 
perc_ppl_vaccinated_atleast_once = (people_vaccinated/population)*100
FROM PercentPopulationVaccinated


--View for what percentage of population of each country is fully vaccinated
CREATE VIEW PercentPeopleFullyVaccinated AS
SELECT	
dea.location,
dea.population,
percentage_people_fullyvaccinated= MAX(CONVERT(bigint,people_fully_vaccinated))/dea.population*100

FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON vac.location=dea.location
	AND vac.date=dea.date

WHERE vac.continent IS NOT NULL AND dea.continent IS NOT NULL
GROUP BY dea.location, dea.population


SELECT *
FROM PercentPeopleFullyVaccinated
ORDER BY 1



--View for nations with highest infection rates
CREATE VIEW PercPopulationInfected AS
SELECT
	location,
	population,
	highest_infection_count = MAX(total_cases),
	percent_population_infected = MAX((total_cases/population))*100

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population


 SELECT *
 FROM PercPopulationInfected
 ORDER BY 4 DESC



 --View for Nations with the Highest Death Count
 CREATE VIEW CountriesDeathCount AS

SELECT
	location,
	total_death_count = MAX(CAST(total_deaths as bigint))
	

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
SELECT *
FROM CountriesDeathCount
ORDER BY 2 DESC