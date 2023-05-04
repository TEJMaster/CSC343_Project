DROP VIEW IF EXISTS continent_rank, continent_high, continent_impact, continent_relation, sub_continent_rank, sub_continent_high, sub_continent_impact, sub_continent_relation CASCADE;

-- Q3 part 1 find the impact of covid from the highest covid case country on each continent

-- Find the unemployment rate change for every country from 2019 to 2020
CREATE VIEW UR_Change AS
SELECT countrycode, ur_2020 - ur_2019 AS ur_change 
FROM Unemployment
WHERE ur_2020 - ur_2019 IS NOT NULL;

-- rank the country's total covid cases based on continent
CREATE VIEW continent_rank AS
SELECT country.countrycode, country.name, country.regioncode, Region.region, COVID_Data.total_case,
COVID_Data.total_cases_per_million,
    RANK() OVER (PARTITION BY country.regioncode ORDER BY COVID_Data.total_case) AS low_rank,
    RANK() OVER (PARTITION BY country.regioncode ORDER BY COVID_Data.total_case DESC) AS high_rank
FROM country, COVID_Data, Region
WHERE country.countrycode = COVID_Data.countrycode 
AND country.regioncode = Region.regioncode
AND COVID_Data.date_ = '2020-09-19';

-- find the country with highest covid cases for each continent
CREATE VIEW continent_high AS
SELECT countrycode, name, regioncode, region, total_case, total_cases_per_million
FROM continent_rank
WHERE high_rank = 1
ORDER BY total_case;

-- find the average unemployment rate change for each continent
CREATE VIEW continent_impact AS
SELECT country.regioncode, avg(UR_Change.ur_change) as avg_change
FROM UR_Change, country
WHERE country.countrycode = UR_Change.countrycode
GROUP BY country.regioncode;

-- find the relation between that continent's average unemployment rate change and that continent
CREATE VIEW continent_relation AS
SELECT continent_impact.regioncode, continent_impact.avg_change,continent_high.total_cases_per_million
FROM continent_impact, continent_high
WHERE continent_impact.regioncode = continent_high.regioncode;

SELECT region.region, continent_relation.avg_change, continent_relation.total_cases_per_million as highest_cases_per_million
FROM continent_relation, region
WHERE continent_relation.regioncode = region.regioncode
ORDER BY continent_relation.avg_change;

SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef continent cases per million vs change"

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
    continent_relation.total_cases_per_million AS "cases",
    continent_relation.avg_change AS "changes"
FROM continent_relation
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;

-- Q3 part 2 find the impact of covid from the highest covid case country on each sub-continent

-- rank the country's total covid cases based on sub-continent
CREATE VIEW sub_continent_rank AS
SELECT country.countrycode, country.name, country.subregioncode, subregion.subregion, COVID_Data.total_case, COVID_Data.total_cases_per_million,
    RANK() OVER (PARTITION BY country.subregioncode ORDER BY COVID_Data.total_case) AS low_rank,
    RANK() OVER (PARTITION BY country.subregioncode ORDER BY COVID_Data.total_case DESC) AS high_rank
FROM country, COVID_Data, subregion
WHERE country.countrycode = COVID_Data.countrycode 
AND country.subregioncode = subregion.subregioncode
AND COVID_Data.date_ = '2020-09-19';

-- rank the country's total covid cases based on sub-continent
CREATE VIEW sub_continent_high AS
SELECT countrycode, name, subregioncode, subregion, total_case, total_cases_per_million
FROM sub_continent_rank
WHERE high_rank = 1
ORDER BY total_cases_per_million;

-- find the country with highest covid cases for each sub-continent
CREATE VIEW sub_continent_impact AS
SELECT country.subregioncode, avg(UR_Change.ur_change) as avg_change
FROM UR_Change, country
WHERE country.countrycode = UR_Change.countrycode
GROUP BY country.subregioncode;

-- find the relation between that continent's average unemployment rate change and that sub-continent
CREATE VIEW sub_continent_relation AS
SELECT sub_continent_impact.subregioncode, sub_continent_impact.avg_change, sub_continent_high.total_cases_per_million
FROM sub_continent_impact, sub_continent_high
WHERE sub_continent_impact.subregioncode = sub_continent_high.subregioncode;


SELECT subregion.subregion, sub_continent_relation.avg_change, sub_continent_relation.total_cases_per_million as highest_cases_per_million
FROM sub_continent_relation, subregion
WHERE sub_continent_relation.subregioncode = subregion.subregioncode
ORDER BY sub_continent_relation.avg_change;

SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef sub-continent cases per million vs change"


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
    sub_continent_relation.total_cases_per_million AS "cases",
    sub_continent_relation.avg_change AS "changes"
FROM sub_continent_relation
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;
