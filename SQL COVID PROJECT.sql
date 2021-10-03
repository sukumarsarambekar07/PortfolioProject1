Select * 
From [Portfolio Project ]..['Covid deaths']
Where continent is not NULL
order by 3,4
--Select * 
--From [Portfolio Project ]..['Covid Vaccinations']
--order by 3,4
-- Select Data that we are to be using
Select Location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project ]..['Covid deaths']
order by 1,2
--Looking at the Total Cases vs Total Deaths
--Shows the likekyhood of dying if you contract covid in your country 
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ]..['Covid deaths']
Where location like '%states%'
order by 1,2

--Looking at the Total cases Vs Population
--Shows what percentage of population got covid
Select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ]..['Covid deaths']
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rated compared to population
Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project ]..['Covid deaths']
--Where location like '%states%'
Group By Location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location,MAX (cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..['Covid deaths']
--Where location like '%states%'
Where continent is not NULL
Group By Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY THE CONTINENT


Select continent,MAX (cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..['Covid deaths']
--Where location like '%states%'
Where continent is  not NULL
Group By continent
order by TotalDeathCount desc

--Showing The Continents with the Highest Death Counts per Population


Select Location,MAX (cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..['Covid deaths']
--Where location like '%states%'
Where continent is not NULL
Group By Location
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases)as total_cases,SUM (cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From [Portfolio Project ]..['Covid deaths']
--Where location like '%states%'
where continent is not null 
order by 1,2
--LOOKING AT TOTAL POPULATION VS VACCINATIONS

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project ]..['Covid deaths'] dea
join [Portfolio Project ]..['Covid Vaccinations'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


--USE A CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project ]..['Covid deaths'] dea
join [Portfolio Project ]..['Covid Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentageofPopulationVaccinated
Create Table #PercentageofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert  #PercentageofPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project ]..['Covid deaths'] dea
join [Portfolio Project ]..['Covid Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--CREATING VIEW FOR STORING DATA FOR VISUALIZING LATER


USE [Portfolio Project ]
GO
/****** Object:  View [dbo].[PercentPopulationVaccinated]    Script Date: 03-10-2021 18:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create view [dbo].[PercentPopulationVaccinated] as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project ]..['Covid deaths'] dea
join [Portfolio Project ]..['Covid Vaccinations'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

--order by 2,3
GO

  

  




 

