SELECT * From CovidDeaths
Order by 3, 4
Select * From CovidVaccinations
Order by 3, 4
Select Data that we are going  to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your contry
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 As DeathPercentage
From CovidDeaths
Where location like '%france%'
Order by 1, 2


--Looking at Total cases vs population 
--Shows what percentage of population got Covid
Select Location, date, Population, total_cases, (total_cases / population) * 100 As PercentpopulationInfected
From CovidDeaths
Where location like '%france%'
Order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases / population) * 100 As PercentpopulationInfected
From CovidDeaths
--Where location like '%france%'
Group by location, Population
Order by PercentpopulationInfected DESC


--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%france%'
Where continent is not NULL
Group by location
Order by TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%france%'
Where continent is NULL
Group by location
Order by TotalDeathCount DESC


--Showing continents with  highest death count per population 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%france%'
Where continent is not NULL
Group by continent
Order by TotalDeathCount DESC


--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%france%'
WHERE continent IS NOT NULL
--Group by date
Order by 1, 2
Select * From CovidVaccinations
ORDER BY 3


--Looking at Total Population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated / Population) * 100
from CovidDeaths as dea
join CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations,RollingpeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated / Population) * 100
from CovidDeaths as dea
join CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
)
select *, (RollingpeopleVaccinated / Population) * 100 from PopvsVac


--TEMP TABLE
Drop Table if exists #Percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric)
Insert into #Percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated / Population) * 100
from CovidDeaths as dea
join CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
select *, (RollingpeopleVaccinated / Population) * 100 
From #Percentpopulationvaccinated


--Creationg View to store data for later visualization
Create View Percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated / Population) * 100
from CovidDeaths as dea
join CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select * from Percentpopulationvaccinated