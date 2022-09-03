/*
Covid 19 Data Exploration Feburary 4, 2020- August 30 2022
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Project_1..[Covid Deaths]
Where continent is not null 
order by 3,4


--Gathering Data --

Select Location, date, total_cases, new_cases, total_deaths, population
From Project_1..[Covid Deaths]
Where continent is not null 
order by 1,2


--TABLE SHOWING THE LIKELIHOOD OF INFECTION OF EACH POPULATION IN JAMAICA--
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Percentage_Of_Deaths
From Project_1..[Covid Deaths]
Where location like '%Jamaica%'
and continent is not null 
order by 1,2

--TABLE SHOWING THE LIKELIHOOD OF INFECTION OF EACH POPULATION--
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Percentage_Of_Deaths
From Project_1..[Covid Deaths]
Where continent is not null 
order by 1,2


--TABLE SHOWING THE INFECTED PERCENTAGE OF THE POPULATION--
Select Location, date, Population, total_cases,  (total_cases/population)*100 as Percent_of_Population_Infected
From Project_1..[Covid Deaths]
order by 1,2


--TABLE ORDERED BY THE MAXIMUM INFECTION COUNT--

Select Location, Population, MAX(total_cases) as Maximum_Infection_Count,  MAX((total_cases/population))*100 as Percent_of_Population_Infected
From Project_1..[Covid Deaths]
Group by Location, Population
order by Percent_of_Population_Infected desc


--TABLE ORDERED BY THE MAXIMUM INFECTION COUNT IN JAMAICA--

Select Location, Population, MAX(total_cases) as Maximum_Infection_Count,  MAX((total_cases/population))*100 as Percent_of_Population_Infected
From Project_1..[Covid Deaths]
Where location like '%Jamaica%'
Group by Location, Population
order by Percent_of_Population_Infected desc

--TABLE ORDERED BY THE MAXIMUM DEATH RATE OF EACH COUNTRY--

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Rate
From  Project_1..[Covid Deaths]
Where continent is not null 
Group by Location
order by Total_Death_Rate desc

--TABLE ORDERED BY THE MAXIMUM DEATH RATE OF EACH COUNTRY IN JAMAICA--

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Rate
From  Project_1..[Covid Deaths]
Where location like '%Jamaica%'
Group by Location
order by Total_Death_Rate desc



           --CONTINENTAL VIEW--
-- TABLE SHOWING THE MAXIMUM DEATH RATE PER CONTINENT--

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Rate
From Project_1..[Covid Deaths]
Where continent is not null 
Group by continent
order by Total_Death_Rate desc


-- TABLE SHOWING TOTAL GLOBAL COVID DEATHS--

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CONVERT(int,new_deaths))/SUM(new_cases)*100 as DeathPercentage
From Project_1..[Covid Deaths]
Where continent is not null 
--Group By date
order by 1,2


--JOINT TABLE SHOWING THE VACCINATIONS OF POPULATIONS AND PERCENTAGE--

Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Vaccination_Count
--(Total_People_Vaccinated/deaths.population)*100 as Percentage_Vaccinated
From Project_1..[Covid Deaths] deaths
Join Project_1..[Covid Vaccinations] vax
	On deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null 
order by 2,3

--Showing Partition Calculations using a 1) CTE and 2) Temp Table

--USING A CTE--

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Vaccination_Count)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.Date) as Vaccination_Count
--, (Vaccination_Count/population)*100
From Project_1..[Covid Deaths] deaths
Join Project_1..[Covid Vaccinations] vax
	On deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null 
--order by 2,3
)
Select *, (Vaccination_Count/Population)*100
From PopvsVac

--Using a Temp Table--

DROP Table if exists #Percentage_of_Vaccinated_Population
Create Table #Percentage_of_Vaccinated_Population
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccination_Count numeric,
)

Insert into #Percentage_of_Vaccinated_Population
Select deaths.Continent, deaths.Location, deaths.Date, deaths.Population, vax.New_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Vaccination_Count
--, (Vaccination_Count/population)*100
From Project_1..[Covid Deaths] deaths
Join Project_1..[Covid Vaccinations] vax
	On deaths.location = vax.location
	and deaths.date = vax.date

Select *, (Vaccination_Count/Population)*100
From #Percentage_of_Vaccinated_Population



--Visulation Views  (For Later Use)
Create View Percentage_Vaccinated_Population_ as
Select deaths.Continent, deaths.Location, deaths.Date, deaths.Population, vax.New_vaccinations
, SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Vaccination_Count
--, (Vaccination_Count/population)*100
From Project_1..[Covid Deaths] deaths
Join Project_1..[Covid Vaccinations] vax
	On deaths.location = vax.location
	and deaths.date = vax.date
Where deaths.continent is not null

