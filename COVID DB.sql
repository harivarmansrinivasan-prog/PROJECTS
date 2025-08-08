
select * from coviddeaths
where continent is not null

select location,date,total_cases,new_cases,total_deaths,population from coviddeaths 
where continent is not null
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_rate from coviddeaths
where continent is not null 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_rate from coviddeaths
where  location like '%states%' and continent is not null

select location,date,population,total_cases,(total_cases/population)*100 as case_vs_pop from coviddeaths
where continent is not null
  
select location,population,max(total_cases) as highestinfected,max((total_cases/population))*100 as highest_affected_percent from coviddeaths
where continent is not null
group by location,population 
order by highest_affected_percent desc
SET SQL_SAFE_UPDATES = 0;

update coviddeaths
set continent=null
where continent=''
SET SQL_SAFE_UPDATES = 1;

select location,max(cast(total_deaths as signed) ) as totaldeaths from coviddeaths
where continent is not null
group by location 
order by totaldeaths desc

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_rate from coviddeaths
where  location like '%states%' and continent is not null

#GLOBAL NUMBERS IN DATE CERTAIN CASES
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as signed)) as total_deaths,(sum(cast(new_deaths as signed))/sum(new_cases))*100 as death_rate 
from coviddeaths
where  continent is not null
group by date

#TOTAL DEATH RATE
select sum(new_cases) as total_cases,sum(cast(new_deaths as signed)) as total_deaths,(sum(cast(new_deaths as signed))/sum(new_cases))*100 as death_rate 
from coviddeaths
where  continent is not null

#looking for people vs vacinations
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(cast(cv.new_vaccinations as signed)) over (partition by cd.location order by cd.location,cd.date) 
as rolling_people_vacinated
from covidvacinations as cv join coviddeaths as cd 
on cv.location=cd.location and
cv.date=cd.date
where  cd.continent is not null
order by 1,2,3

with popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vacinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(cast(cv.new_vaccinations as signed)) over (partition by cd.location order by cd.location,cd.date) 
as rolling_people_vacinated
from covidvacinations as cv join coviddeaths as cd 
on cv.location=cd.location and
cv.date=cd.date
where  cd.continent is not null)
#order by 1,2,3
select *,(rolling_people_vacinated/population)*100 as rvp_rate from popvsvac

#creating view table 
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS SIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_people_vacinated
FROM 
    covidvacinations AS cv 
JOIN 
    coviddeaths AS cd ON cv.location = cd.location AND cv.date = cd.date
WHERE 
    cd.continent IS NOT NULL;

SELECT 
    *,
    (rolling_people_vacinated / population) * 100 AS rvp_rate 
FROM 
    PercentPopulationVaccinated;



