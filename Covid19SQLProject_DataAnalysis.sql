Select * 
From PortfolioProjects..CovidDeaths$
Order By location,date 

/*Select * 
From PortfolioProjects..CovidVaccinations$
Order By location,date */

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths$
Order By location,date 

--Total Cases vs Total Deaths
--How likely are you to contract Covid by country?
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where location like '%United States%'
Order By location,date 

--Total Cases vs Population
--What percentage of the population has Covid?
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProjects..CovidDeaths$
Where location like '%United States%' 
Order By location,date 

--Countries with the Highest Infection Rate compared to the Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group By Location, population
Order By PercentOfPopulationInfected desc

--Countries with the Highest Death Count per Population
--Total_deaths column is a nvarchar and needs to be converted to integer; Also need to filter out NULL continents from location
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group By Location
Order By TotalDeathCount desc

--***Continents with the Highest Death Count per Population Broken Down by Continent
--[Note: North America (doesn't include Canada)*]
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group By continent
Order By TotalDeathCount desc

--Continents with the Highest Death Count per Population Broken Down by Continent
Select  SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where continent is not null
--Group By date
Order By Total_Cases, Total_Deaths


--Total Population vs Vaccinations
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(convert(int,V.new_vaccinations)) OVER (Partition by D.location Order By D.location, D.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ D
Inner Join PortfolioProjects..CovidVaccinations$ V
On D.location = V.location and D.date = V.date
Where D.continent is not null
Order By D.location, D.date

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(convert(int,V.new_vaccinations)) OVER (Partition by D.location Order By D.location, 
D.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ D
Inner Join PortfolioProjects..CovidVaccinations$ V
On D.location = V.location and D.date = V.date
Where D.continent is not null
--Order By D.location, D.date
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPopVaccinated
From PopvsVac
--explore more calculations

--Temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(convert(int,V.new_vaccinations)) OVER (Partition by D.location Order By D.location, 
D.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ D
Inner Join PortfolioProjects..CovidVaccinations$ V
On D.location = V.location and D.date = V.date
Where D.continent is not null
--Order By D.location, D.date

Select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPopVaccinated
From #PercentPopulationVaccinated


--create view for visualizations

Create view PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(convert(int,V.new_vaccinations)) OVER (Partition by D.location Order By D.location, 
D.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths$ D
Inner Join PortfolioProjects..CovidVaccinations$ V
On D.location = V.location and D.date = V.date
Where D.continent is not null
--Order By D.location, D.date

Select * 
From PercentPopulationVaccinated