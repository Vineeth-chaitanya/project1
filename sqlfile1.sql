create table covid_deaths(
iso_code varchar(50),
continent varchar(50),
location varchar(50),
date varchar(50),
total_cases varchar(50),
new_cases varchar(50),
new_cases_smoothed varchar(50),
total_deaths varchar(50),
new_deaths varchar(50),
new_deaths_smoothed varchar(50),
total_cases_per_million varchar(50),
new_cases_per_million varchar(50),
new_cases_smoothed_per_million varchar(50),
total_deaths_per_million varchar(50),
new_deaths_per_million varchar(50),
new_deaths_smoothed_per_million varchar(50),
reproduction_rate varchar(50),
icu_patients varchar(50),
icu_patients_per_million varchar(50),
hosp_patients varchar(50),
hosp_patients_per_million varchar(50),
weekly_icu_admissions varchar(50),
weekly_icu_admissions_per_million varchar(50),
weekly_hosp_admissions varchar(50),
weekly_hosp_admissions_per_million varchar(50),
new_tests varchar(50),
total_tests varchar(50),
total_tests_per_thousand varchar(50),
new_tests_per_thousand varchar(50),
new_tests_smoothed varchar(50),
new_tests_smoothed_per_thousand varchar(50),
positive_rate varchar(50),
tests_per_case varchar(50),
tests_units varchar(20),
total_vaccinations varchar(50),
people_vaccinated varchar(50),
people_fully_vaccinated varchar(50),
new_vaccinations varchar(50),
new_vaccinations_smoothed varchar(50),
total_vaccinations_per_hundred varchar(50),
people_vaccinated_per_hundred varchar(50),
people_fully_vaccinated_per_hundred varchar(50),
new_vaccinations_smoothed_per_million varchar(50),
stringency_index varchar(50),
population varchar(50),
population_density varchar(50),
median_age varchar(50),
aged_65_older varchar(50),
aged_70_older varchar(50),
gdp_per_capita varchar(50),
extreme_poverty varchar(50),
cardiovasc_death_rate varchar(50),
diabetes_pervalence varchar(50),
female_smokers varchar(50),
male_smokers varchar(50),
handwashing_facilities varchar(50),
hospital_beds_per_thousand varchar(50),
life_expectacy varchar(50),
human_development_index varchar(50)
)

create table covid_vaccinations(
iso_code varchar(30),
continent varchar(30),
location varchar(30),
date varchar(30),
new_tests varchar(30),
total_tests varchar(30),
total_tests_per_thousand varchar(30),
new_tests_per_thousand varchar(30),
new_tests_smoothed varchar(30),
new_tests_smoothed_per_thousand varchar(30),
positive_rate varchar(30),
tests_per_case varchar(30),
tests_units varchar(30),
total__vaccinations varchar(30),
people_vaccinated varchar(30),
people_fully_vaccinated varchar(30),
new_vaccinations varchar(30),
new_vaccinations_smoothed varchar(30),
total_vaccinations_per_hundred varchar(30),
people_vaccinated_per_hundred varchar(30),
people_fully_vaccinated_per_hundred varchar(30),
new_vaccinations_smoothed_per_million varchar(30),
stringency_index varchar(30),
population_density varchar(30),
median_age varchar(30),
aged_65_older varchar(30),
aged_70_older varchar(30),
gdp_per_capita varchar(30),
extreme_poverty varchar(30),
cardiovasc_death_rate varchar(30),
diabetes_prevalence varchar(30),
female_smokers varchar(30),
male_smokers varchar(30),
handwashing_facilities varchar(30),
hospital_beds_per_thousand varchar(30),
life_expectancy varchar(30),
human_development_index varchar(30))

select count(1) from covid_deaths
select count(1) from covid_vaccinations

select * from covid_deaths
where location is not null
order by 3,4

select * from covid_vaccinations
where location is not null
order by 3,4

--Total cases Vs Total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from covid_deaths
where location like 'india'

--Total cases Vs Population
select location,date,total_cases,population,(total_cases/population)*100 as infected_rate
from covid_deaths
where location like 'india'
order by infected_rate desc

-- highest infected_rate countries
select location,population,max(total_cases),max((total_cases/population))*100 as infected_rate
from covid_deaths
group by location,population
order by infected_rate desc

-- highest death count per population
select location,population,max(cast(total_deaths as signed)) as totaldeathcount
from covid_deaths
where continent is not null and location is not null
group by location,population
order by totaldeathcount desc

-- by continent
select continent,max(cast(total_deaths as signed)) as totaldeathcount
from covid_deaths
where continent is not null
group by continent

-- global numbers
select sum(new_cases) as totalcases, sum(cast(new_deaths as signed)) as totaldeaths, (sum(cast(new_deaths as signed))/sum(new_cases))*100 as deathper
from covid_deaths
group by date

-- vaccinations table

select * from covid_vaccinations


select d.continent,d.location,d.date,d.population,v.new_vaccinations
from covid_deaths d
join covid_vaccinations v
	ON d.location=v.location and d.date=v.date
    where d.continent is not null
    order by 2,3
    
    -- Total population VS vaccinations
select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(cast(v.new_vaccinations as signed)) over (partition by d.location order by d.location,d.date) as total_vaccinationsRolling
from covid_deaths d
join covid_vaccinations v
	ON d.location=v.location and d.date=v.date
    where d.continent is not null
    order by 2,3

-- using CTE to get total_vaccinationsRolling/population percentage
with vacvspop(continent,location,date,population,new_vaccinations,total_vaccinationsrolling)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(cast(v.new_vaccinations as signed)) over (partition by d.location order by d.location,d.date) as total_vaccinationsRolling
from covid_deaths d
join covid_vaccinations v
	ON d.location=v.location and d.date=v.date
    where d.continent is not null
    order by 2,3
)

select *,(total_vaccinationsrolling/population)*100 as vaccpercentage
from vacvspop

-- By creating a temporary table
drop table if exists perpopulationvaccinated
create table perpopulationvaccinated
(
continent varchar(50),
location varchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinationsrolling numeric
)

insert into perpopulationvaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(cast(v.new_vaccinations as signed)) over (partition by d.location order by d.location,d.date) as total_vaccinationsRolling
from covid_deaths d
join covid_vaccinations v
	ON d.location=v.location and d.date=v.date
    -- where d.continent is not null
    -- order by 2,3
select *,(total_vaccinationsrolling/population)*100 as vaccpercentage
from perpopulationvaccinated

-- for tableau visualization
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as deathPercentage
from covid_deaths

-- Table 2
Select continent, SUM(cast(new_deaths as signed)) as TotalDeathCount
From covid_deaths
-- Where location like '%states%'
Where continent is not null 
and location not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc

-- Table 3
Select location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
-- Where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc

-- Table 4
use covid
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Where location is not null
Group by Location, Population, date
order by PercentPopulationInfected desc
