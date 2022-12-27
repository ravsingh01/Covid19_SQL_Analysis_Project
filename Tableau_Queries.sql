/*
Queries used for Tableau Project
*/

--Q1 to display the death percentage against the total number of cases
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null 

--Q2 to display the death count till date by location(continent)
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc

--Q3 to display percent of population infected against different countries
Select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as Percent_Population_Infected
From PortfolioProjects.dbo.CovidDeaths
group by location,population
order by Percent_Population_Infected desc

--Q4 to display percent of population infected against different countries, grouping on additional column of date
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

--Q5 total number of vaccinations made till date in each coutry
Select d.continent, d.location, d.date, d.population
, MAX(v.total_vaccinations) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
group by d.continent, d.location, d.date, d.population
order by location


--Q5 to display the death percentage countrywise
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null 
order by location

--Q6  Rolling sum of vaccinations and percent of population vaccinated
With rollingvacc (continent,location,date,population,new_vaccinations,RollingSumofVaccinations)
as 
(
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
Sum(cast(v.new_vaccinations as bigint)) Over (Partition by d.location order by d.location,d.date) as RollingSumofVaccinations    --another way of converting one datatype to another
--,(RollingSumofVaccinations/population)*100
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by d.location
)
--this gives error because, The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, 
--unless TOP, OFFSET or FOR XML is also specified.
--now we can run using the below code by working on the CTE created, however in order to run you have to execute the code with CTE
select *, (RollingSumofVaccinations/population)*100 as PercentPopulationVaccinated
from rollingvacc


--Link for the Tableau Dashboard created on the basis of above queries
https://public.tableau.com/app/profile/ravi.singh1520/viz/COVID-19Dashboard_16721100909070/Dashboard1?publish=yes