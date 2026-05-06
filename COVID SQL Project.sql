--Select *
--From CovidDeaths
--order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From  CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows probability of death if you contract COVID in Canada

Select location, date, total_cases, new_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From  CovidDeaths
Where location = 'Canada'
order by 1,2

-- Looking at the Total Cases VS Population
-- Shows the percentage of population contracting COVID in Canada

Select location, date, total_cases, new_cases, population, (Total_cases/population)*100 as PercentPopulationInfected
From  CovidDeaths
Where location = 'Canada'
order by 1,2

-- Looking at countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
From  CovidDeaths
-- Where location = 'Bangladesh'
Group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From  CovidDeaths
Where Continent is not null -- Prevents viewing the data for continents
Group by location
order by TotalDeathCount desc

---- Breaking the data down by Continents

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From  CovidDeaths
Where Continent is not null
Group by continent
order by TotalDeathCount desc

---- It seems that Continent data shows North America as only US data

Select continent, location, MAX(cast(total_deaths as int)) as TotalDeathCount
From  CovidDeaths
Where continent like '%north america%'
Group by location, continent
order by TotalDeathCount desc

---- There seems to be a mistake in the data cumulating total deaths for continents

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From  CovidDeaths
Where Continent is null -- Views the data for whole continents in the location column
Group by location
order by TotalDeathCount desc


-- Looking at Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

---- Adding a column to show accumulated vaccinations for each countries

With PopvsVac(Continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as cumulative_vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (cumulative_vaccinations/population)*100 
From PopvsVac

--TEMP Table

Drop table if exists #PercentPopulationVaccinated --prevent multiple tables being created
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as cumulative_vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (cumulative_vaccinations/population)*100 
From #PercentPopulationVaccinated

 --Creating View to store data for visualization
 Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as cumulative_vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated