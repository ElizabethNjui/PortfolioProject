
/*
Covid 19 Data Exploration

Skills Used: Joins, CTE, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
--order by 3,4


Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null

--Looking at Total Cases VS Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null


--Looking at Total Cases vs Population
--Shows what percentage of population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null




--Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentagePopInfected desc


--Showing Countries with highest death count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing Continents with highest death counts

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS


Select  SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
 --Group by date
 order by 1,2


 
Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
 Group by date
 order by 1,2

 --Joining CovidVaccinations Table
 --Looking at total population vs vaccination
 --Percentage of population that has received at least one Covid Vaccine

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 From PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- Using CTE to perform calculation on Partition By in previous query

with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/population)
from PopvsVac

-- Using TEMP TABLE to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopVaccinated


--Creating View to store data for later visualization

Create View PercentPopVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

--View Table
Select *
From PercentPopVaccinated 
