select *
from PortfolioProject..CovidDeaths$
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

--select the data that I am going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1, 2


--Total cases vs Total Deaths 
--shows the likelihood of dying if you contract covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
and continent is not null
order by 1, 2

--percentage of population that has covis
select location, date, total_cases, population, (total_cases /population) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
and continent is not null
order by 1, 2

--countries with highest infection rate compared to poulation

select continent, location, population, Max(total_cases) as highestcount, max((total_cases /population)) * 100 as percentageofpopulation
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent, location, population
order by 1, 2

--countries with the highest deaths and coverting total death to int
select continent, location, Max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent, location
order by totaldeathcount desc

--by continent 

select continent, Max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent
order by totaldeathcount desc


--Global Numbers 
select date, SUM(new_cases) as totalcases , sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/ sum
(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2


--total table population vs vaccination
select  deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by deaths.location order by deaths.location, deaths.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccinations$ vac
on deaths.location = vac.location
and deaths.date = vac.date
where deaths.continent is not null
order by 2,3


-- USING A CTE
with popvsvac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select  deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by deaths.location order by deaths.location, deaths.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccinations$ vac
on deaths.location = vac.location
and deaths.date = vac.date
where deaths.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)* 100
from popvsvac

--temp table
--drop table if exists 
Create Table  #ThePercentageofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #ThePercentageofPopulationVaccinated
select  deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by deaths.location order by deaths.location, deaths.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccinations$ vac
on deaths.location = vac.location
and deaths.date = vac.date
where deaths.continent is not null

select * ,(RollingPeopleVaccinated/population)*100
from #ThePercentageofPopulationVaccinated

--creating view to store data for populations

Create view ThePercentageofPopulationVaccinated as 
select  deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by deaths.location order by deaths.location, deaths.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccinations$ vac
on deaths.location = vac.location
and deaths.date = vac.date
where deaths.continent is not null
