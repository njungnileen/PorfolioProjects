
Select *
From PorfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PorfolioProject..Covidvaccinations
--order by 3,4

--Select the data tobe used 

Select location, date, total_cases, new_cases, total_deaths, population 
From PorfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking for Total cases Vs Total Deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
From PorfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking for Total cases Vs population
--This shows what percentage of pop got Covid
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentagePop 
From PorfolioProject..CovidDeaths  
Where location like '%states%'
order by 1,2

--looking at countries with highest infection rate
Select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population)*100 AS PercentagePopInfected 
From PorfolioProject..CovidDeaths  
Where continent is not null
Group by location, population
order by PercentagePopInfected desc

--Showing the countries with highest deathcount pop
Select location, MAX(cast (total_deaths as int)) AS TotalDeathCount 
From PorfolioProject..CovidDeaths  
Where continent is not null
Group by location
order by TotalDeathCount desc

--Lets Break It down to continents 
Select continent, MAX(cast (total_deaths as int)) AS TotalDeathCount 
From PorfolioProject..CovidDeaths  
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing The continent with the highest DeathCount per pop
Select continent, MAX(cast (total_deaths as int)) AS TotalDeathCount 
From PorfolioProject..CovidDeaths  
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int))as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--Total Cases
Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int))as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--Looking at the Tot Pop Vs Vaccinations 
--USE CTE
With PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated) AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PorfolioProject..CovidDeaths as dea 
Join PorfolioProject..Covidvaccinations as vac
     On dea. location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PorfolioProject..CovidDeaths as dea 
Join PorfolioProject..Covidvaccinations as vac
     On dea. location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PorfolioProject..CovidDeaths as dea 
Join PorfolioProject..Covidvaccinations as vac
     On dea. location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

select *
From PercentPopulationVaccinated
