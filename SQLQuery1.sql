select Location, date, total_cases,new_cases,total_deaths,population
from PortafolioProyect ..CovidDeaths$
order by 1,2

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortafolioProyect ..CovidDeaths$
where location like '%states%'
order by 1,2

select Location, date, Population,total_cases,(total_cases/Population)*100 as PercentagePopulationInfected 
from PortafolioProyect ..CovidDeaths$
where location like '%states%'
order by 1,2


select Location,Population,max(total_cases) as HighestInfectionCount,max((total_cases/Population))*100 as PercentagePopulationInfected 
from PortafolioProyect ..CovidDeaths$
group by location,population
order by PercentagePopulationInfected desc

select Location,max(cast(total_deaths as int)) as TotalDeathCount 
from PortafolioProyect ..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum (cast(new_deaths as int))/ sum(new_cases) *100 as DeathPercentage
from PortafolioProyect ..CovidDeaths$
--where location like '%states%'
where continent is not null
Group By date
order by 1,2

select * from PortafolioProyect ..CovidVaccination$ 


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations))over(partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated from PortafolioProyect ..CovidDeaths$  dea join PortafolioProyect .. CovidVaccination$ vac
on dea.location = vac .location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (Continent, location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations))over(partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated from PortafolioProyect ..CovidDeaths$  dea join PortafolioProyect .. CovidVaccination$ vac
on dea.location = vac .location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population) *100 from PopvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations))over(partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated from PortafolioProyect ..CovidDeaths$  dea join PortafolioProyect .. CovidVaccination$ vac
on dea.location = vac .location and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
-- Crear la vista PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortafolioProyect..[CovidDeaths$] dea
JOIN PortafolioProyect..[CovidVaccination$] vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

