Select *
From `Project Potfolio`.`coviddeaths`
where continent is not null
order by 3,4;

-- Select * 
-- From `Project Potfolio`.`covidvacinations`
-- order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths
From `Project Potfolio`.`coviddeaths`
order by 1,2;

-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `Project Potfolio`.`coviddeaths`
Where location like '%kingdom%'
order by 1,2;

-- Showing countries with highest death count per population
Select Location, max(total_deaths) as TotalDeathCount
From `Project Potfolio`.`coviddeaths`
-- Where location like '%kingdom%'
where continent is not null
Group by Location
order by TotalDeathCount desc;

-- break things down by continent
Select continent, max(total_deaths) as TotalDeathCount
From `Project Potfolio`.`coviddeaths`
-- Where location like '%kingdom%'
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Showing continents with the highest death count per population
Select continent, max(total_deaths) as TotalDeathCount
From `Project Potfolio`.`coviddeaths`
-- Where location like '%kingdom%'
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From `Project Potfolio`.`coviddeaths`
-- Where location like '%kingdom%'
where continent is not null
group by date
order by 2,3;

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From `Project Potfolio`.`coviddeaths`
-- Where location like '%kingdom%'
where continent is not null
-- group by date
order by 2,3;

Select *
From `Project Potfolio`.`coviddeaths` dea
Join `Project Potfolio`.`covidvacinations` vac
On dea.location = vac.location
and dea.date = vac.date;

-- Looking at Total vacciation vs population
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From `Project Potfolio`.`coviddeaths` dea
Join `Project Potfolio`.`covidvacinations` vac
On dea.location = vac.location
and dea.date = vac.date
-- where vac.new_vaccinations # 0
Order by 2,3;

-- USE CTE (Common Table Expression: it's a temporary result set that can use instead of creat a table and drop table) 

With PopvsVac (continent, location, date, population, new_vaccinatons, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From `Project Potfolio`.`coviddeaths` dea
Join `Project Potfolio`.`covidvacinations` vac
On dea.location = vac.location
and dea.date = vac.date
-- where vac.new_vaccinations # 0
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac;

-- TEMP TABLE
Drop Table if exists PercentPopVaccinated;
Create table `Project Potfolio`.`PercentPopVaccinated`
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
);

Insert into `Project Potfolio`.`PercentPopVaccinated`
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From `Project Potfolio`.`coviddeaths` dea
Join `Project Potfolio`.`covidvacinations` vac
On dea.location = vac.location
and dea.date = vac.date;
-- where vac.new_vaccinations # 0
-- Order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From `Project Potfolio`.`PercentPopVaccinated`;

-- Creating View to store data for later visualisations
Create view `Project Potfolio`.PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From `Project Potfolio`.`coviddeaths` dea
Join `Project Potfolio`.`covidvacinations` vac
On dea.location = vac.location
and dea.date = vac.date
-- where vac.new_vaccinations # 0
-- Order by 2,3

