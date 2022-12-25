--selecting all the data from the CovidDeaths table
Select *
From PortfolioProjects.dbo.CovidDeaths
where continent is not null
order by 3,4

-------------------------------------------------------------------------------------------------------

--selecting all the data from the CovidVaccinations table
--Select *
--From PortfolioProjects..CovidVaccinations
--order by 3,4

-------------------------------------------------------------------------------------------------------

--selecting the required data 
Select location,date,continent,population,total_cases,new_cases,total_deaths,new_deaths 
From PortfolioProjects.dbo.CovidDeaths
order by location,date

-------------------------------------------------------------------------------------------------------

--Q1 total deaths vs total cases, probability of death if you get Covid in respected countries during the time of its spreading for ex. countries ending with 'dia'
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProjects.dbo.CovidDeaths
Where location like '%india%'
order by location,date

-------------------------------------------------------------------------------------------------------

--Q2 total cases vs population, estimation of what percent of population is infected by covid-19
Select location,date,population,total_cases,(total_cases/population)*100 as Percent_Population_Infected
From PortfolioProjects.dbo.CovidDeaths
Where location like '%india%'
order by location,date

-------------------------------------------------------------------------------------------------------

--Q3 Countries with highest infection rate as compared to population
Select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as Percent_Population_Infected
From PortfolioProjects.dbo.CovidDeaths
group by location,population
order by Percent_Population_Infected desc

-------------------------------------------------------------------------------------------------------

--Q4 Countries with highest death count 
Select location,population,max(total_deaths) as HighestDeathCount
From PortfolioProjects.dbo.CovidDeaths
group by location,population
order by HighestDeathCount desc  

--now this query does not gives correct results because the datatype of total_deaths is varchar, therefore we need to cast it to int while running so that
--max function works properly on it.Also data has some values in terms of continent in the location column and therefore they should be ignored

Select location,population,max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProjects.dbo.CovidDeaths
where continent is not null
group by location,population
order by HighestDeathCount desc

-------------------------------------------------------------------------------------------------------

--Q5 Breaking the data on the basis of continent 
--showing continents with the highest death counts per population
Select location,max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProjects.dbo.CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc
--here the data is presented on the basis of death count of each continent but grouped by location
--breaking it on the basis of continent 
Select continent,max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProjects.dbo.CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

-------------------------------------------------------------------------------------------------------

--Q6 Breaking the data in terms of global numbers, calculating the death percentage on each date
Select date,sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentageGlobally
From PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by date

--if we just want to see the total deaths vs total cases in entire world
Select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentageGlobally
From PortfolioProjects..CovidDeaths
where continent is not null

-------------------------------------------------------------------------------------------------------

--perform join on both tables
Select *
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date

-------------------------------------------------------------------------------------------------------

--Q7 Checking the total number of people vaccinated per population
Select d.continent,d.location,d.date,d.population,v.new_vaccinations
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by d.location

-------------------------------------------------------------------------------------------------------

--Q8 calculate the rolling sum of people getting vaccinated by using partition by on location
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
Sum(cast(v.new_vaccinations as bigint)) Over (Partition by d.location order by d.location,d.date) as RollingSumofVaccinations    --another way of converting one datatype to another
--,(RollingSumofVaccinations/population)*100     --to calculate percent of people vaccinated
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by d.location
--this gives an error that Invalid column name 'RollingSumofVaccinations', because it is an alias and cannot be used. Hence we need to create a temporary table here
--or create a CTE 

-------------------------------------------------------------------------------------------------------

--Q9 first creating CTE
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

-------------------------------------------------------------------------------------------------------

--Q10 same above execution but by creating a temp table

Drop table if exists PerPopulationVaccinated
Create table PerPopulationVaccinated
(
continent nvarchar(255),location nvarchar(255),date datetime,
population numeric, new_vaccinations numeric, RollingSumofVaccinations numeric
)

Insert into PerPopulationVaccinated
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
Sum(cast(v.new_vaccinations as bigint)) Over (Partition by d.location order by d.location,d.date) as RollingSumofVaccinations    --another way of converting one datatype to another
--,(RollingSumofVaccinations/population)*100
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
--where d.continent is not null

select *, (RollingSumofVaccinations/population)*100 as PercentPopulationVaccinated
from PerPopulationVaccinated

-------------------------------------------------------------------------------------------------------

--Q11 creating view of the data required for visualizations for later use
Create view PercentPopulationVaccinated as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
Sum(cast(v.new_vaccinations as bigint)) Over (Partition by d.location order by d.location,d.date) as RollingSumofVaccinations    --another way of converting one datatype to another
--,(RollingSumofVaccinations/population)*100
From PortfolioProjects..CovidDeaths d
Join PortfolioProjects..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--once view is created it is like a permanent table, hence queries can be performed on these views

-------------------------------------------------------------------------------------------------------
