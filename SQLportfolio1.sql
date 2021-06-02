SELECT *
FROM portfolioproject..coviddeaths
ORDER BY 3,4

--SELECT *
--FROM portfolioproject..covidvaccines
--ORDER BY 3,4

Select Location, date, total_cases, new_cases,total_deaths,population
FROM portfolioproject..coviddeaths
ORDER BY 1,2

-- total cases vs total deaths
Select Location, date, total_cases,total_deaths, (cast(NULLIF(total_deaths,0) as decimal(19,5))/cast(NULLIF(total_cases,0) as decimal(19,5)))*100 as deathratio
FROM portfolioproject..coviddeaths
WhERE location like '%states%'

-- what percentage of population got covid

 Select Location, date, total_cases,population, (cast(NULLIF(total_cases,0) as decimal(19,5))/cast(NULLIF(population,0) as decimal(19,5)))*100 as effectedpeople
FROM portfolioproject..coviddeaths
WhERE location like '%states%'

Select population, population/
from portfolioproject..coviddeaths
-- countries with highest infection rates compared to population

alter table portfolioproject..coviddeaths alter column population bigint
delete from portfolioproject..coviddeaths where population = 0

select population from portfolioproject..coviddeaths where population=0
select total_cases/population as ex from portfolioproject..coviddeaths
select (cast(total_cases as float)/(population))*100 as c from portfolioproject..coviddeaths

 Select location, population, MAX(cast(total_cases as bigint)) as HIghestinfectedcount, ((MAX((cast(total_cases as float))/(population))*100)) as effectedpeople
FROM portfolioproject..coviddeaths 
--where population!=0
Group by location,population
order by effectedpeople desc

SELECT *
FROM portfolioproject..coviddeaths
where continent is not null
ORDER BY 3,4

--showing country with highest deaths

 Select location, MAX(cast(total_deaths as int)) as totaldeaths
FROM portfolioproject..coviddeaths 
where continent!=''
Group by location
order by totaldeaths desc


-- deaths continent wise( correct query)

Select location, MAX(cast(total_deaths as int)) as totaldeaths
FROM portfolioproject..coviddeaths 
where continent=''
Group by location
order by totaldeaths desc

-- deaths continent wise( fro project purpose)
Select continent, MAX(cast(total_deaths as int)) as totaldeaths
FROM portfolioproject..coviddeaths 
where continent!=''
Group by continent
order by totaldeaths desc

-- global numbers using date
-- deaths according to dates

Select new_cases, new_deaths
from portfolioproject..coviddeaths

Select date, sum(cast(new_cases as float)) as Totalcases, sum(cast(new_deaths as float)) as totaldeaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as Deathpercentage
from portfolioproject..coviddeaths
where new_cases!=0 and new_cases!=''
group by date

Select sum(cast(new_cases as float)) as Totalcases, sum(cast(new_deaths as float)) as totaldeaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as Deathpercentage
from portfolioproject..coviddeaths
where new_cases!=0 and new_cases!=''

--joining two tables

select *
from portfolioproject..coviddeaths dev
join portfolioproject..covidvaccines vac
on dev.location=vac.location and dev.date=vac.date


-- vaccinations

select dev.continent,dev.location,dev.date,dev.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dev.location order by dev.location,dev.date) as rollingtotalvaccines
from portfolioproject..coviddeaths dev
join portfolioproject..covidvaccines vac
on dev.location=vac.location and dev.date=vac.date
where dev.continent!=''

--vaccinationsvspopulation

with popvsvac(continent,location,date,population,new_vaccinations,rollingtotalvaccines)
as
(select dev.continent,dev.location,dev.date,dev.population,vac.new_vaccinations, 
Sum(convert(float,vac.new_vaccinations)) over (partition by dev.location order by dev.location,dev.date) as rollingtotalvaccines
from portfolioproject..coviddeaths dev
join portfolioproject..covidvaccines vac
on dev.location=vac.location and dev.date=vac.date
where dev.continent!='')
select *,(rollingtotalvaccines/population)*100 as percentageofvaccinatedpeople
from popvsvac

-- alternative method #complicated
drop if table exists sample123
create table sample123(
continent nvarchar(50),
location nvarchar(50),
date nvarchar(50),
population numeric,
new_vaccinations nvarchar,
rollingtotalvaccines numeric)

insert into sample123
select dev.continent,dev.location,dev.date,dev.population,vac.new_vaccinations, 
Sum(convert(float,vac.new_vaccinations)) over (partition by dev.location order by dev.location,dev.date) as rollingtotalvaccines
from portfolioproject..coviddeaths dev
join portfolioproject..covidvaccines vac
on dev.location=vac.location and dev.date=vac.date
where dev.continent!=''

select *,(rollingtotalvaccines/population)*100 as percentageofvaccinatedpeople
from sample123

-- creating views

-- creating rolling vaccinated view

create view rollingvaccinated as
select dev.continent,dev.location,dev.date,dev.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dev.location order by dev.location,dev.date) as rollingtotalvaccines
from portfolioproject..coviddeaths dev
join portfolioproject..covidvaccines vac
on dev.location=vac.location and dev.date=vac.date
where dev.continent!=''



