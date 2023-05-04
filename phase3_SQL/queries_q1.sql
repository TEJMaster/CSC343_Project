DROP VIEW IF EXISTS UR_Change, Relation, incomelevel_Change, Top10_Economies, Top10_Change CASCADE;

-- Q1 part1 investigate the relationship between covid data and unemployment rate change

-- Find the unemployment rate change for every country from 2019 to 2020
CREATE VIEW UR_Change AS
SELECT countrycode, ur_2020 - ur_2019 AS ur_change 
FROM Unemployment
WHERE ur_2020 - ur_2019 IS NOT NULL;

-- Find the relation between every country's covid status and their change in unemployment rate
CREATE VIEW Relation AS
SELECT UR_Change.countrycode, COVID_Data.total_cases_per_million, COVID_Data.total_deaths_per_million, UR_Change.ur_change
FROM UR_Change, COVID_Data
WHERE UR_Change.countrycode = COVID_Data.countrycode 
AND COVID_Data.date_ = '2020-09-19';


-- Q1 part2 inestigate the impact of covid infection and the umemployment rate change for each income level group 

CREATE VIEW incomelevel_Change AS
SELECT Incomelevel.incomegroup, Avg(Unemployment.ur_2019) AS mean_2019, 
Avg(Unemployment.ur_2020) AS mean_2020,
Avg(Unemployment.ur_2020 - Unemployment.ur_2019) AS mean_change
FROM Unemployment INNER JOIN IncomeLevel ON Unemployment.countrycode = Incomelevel.countrycode
WHERE Unemployment.ur_2020 - Unemployment.ur_2019 IS NOT NULL AND Incomelevel.incomegroup IS NOT NULL
GROUP BY Incomelevel.incomegroup;


-- Q1 part 3 investigate the impact of covid infection and the umemployment rate change for the top 10 economies in the world

-- find covid data for the top 10 economies
CREATE VIEW Top10_Economies AS
SELECT countrycode, Total_cases_per_million
FROM covid_data 
WHERE countrycode IN ('USA', 'CHN', 'JPN', 'DEU', 'GBR', 'FRA', 'IND', 'ITA', 'BRA', 'CAN')
AND date_ = '2020-09-19'
ORDER BY Total_cases_per_million;

-- For the top 10 economies, find the relation betwen the covid infection rate and their change in unemployment rate. 
CREATE VIEW Top10_Change AS
SELECT Top10_Economies.countrycode, Top10_Economies.Total_cases_per_million, 
Unemployment.ur_2019, Unemployment.ur_2020, (Unemployment.ur_2020 -  Unemployment.ur_2019) AS ur_change
FROM Top10_Economies LEFT JOIN Unemployment 
ON Top10_Economies.countrycode = Unemployment.countrycode
ORDER BY ur_change;


-- Part 1 result

-- print the corelation coefficient for the total cases per million and the change in unemployment rate
SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef case vs change"

FROM(
SELECT
    sum("cases") AS amt_sum,
    sum("changes") AS act_sum,
    sum("cases" * "cases") AS amt_sum_sq,
    sum("changes" * "changes") AS act_sum_sq,
    sum("cases" * "changes") AS tot_sum,
    count(*) as _count

FROM(
SELECT
    Relation.Total_cases_per_million AS "cases",
    Relation.ur_change AS "changes"
FROM Relation
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;

-- print the corelation coefficient for the total deaths per million and the change in unemployment rate
SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef death vs change"

FROM(
SELECT
    sum("cases") AS amt_sum,
    sum("changes") AS act_sum,
    sum("cases" * "cases") AS amt_sum_sq,
    sum("changes" * "changes") AS act_sum_sq,
    sum("cases" * "changes") AS tot_sum,
    count(*) as _count

FROM(
SELECT
    Relation.Total_deaths_per_million AS "cases",
    Relation.ur_change AS "changes"
FROM Relation
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;

