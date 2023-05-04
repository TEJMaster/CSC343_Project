DROP VIEW IF EXISTS countryHDI, countrybeds, countrylife, HDI_Relation, differentHDI, TOP25_HDI, BOT25_HDI CASCADE;

-- Q2 part 1 determine the relationship between country's HDI and the change in unemployment rate

CREATE VIEW countryHDI AS
SELECT HealthCareLevel.countrycode, HealthCareLevel.hdi, ur_change
FROM HealthCareLevel, UR_Change
WHERE HealthCareLevel.hdi IS NOT NULL
AND HealthCareLevel.countrycode = UR_Change.countrycode;

SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef hdi vs change"

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
    countryHDI.hdi AS "cases",
    countryHDI.ur_change AS "changes"
FROM countryHDI
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;




-- Q2 part 2 determine the relationship between country's hospital beds per thousand population and the change in unemployment rate
CREATE VIEW countrybeds AS
SELECT HealthCareLevel.countrycode, HealthCareLevel.bedsperthousand, ur_change
FROM HealthCareLevel, UR_Change
WHERE HealthCareLevel.bedsperthousand IS NOT NULL
AND HealthCareLevel.countrycode = UR_Change.countrycode;

SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef beds vs change"

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
    countrybeds.bedsperthousand AS "cases",
    countrybeds.ur_change AS "changes"
FROM countrybeds
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;



-- Q2 part 3 determine the relationship between country's life expectancy and the change in unemployment rate
CREATE VIEW countrylife AS
SELECT HealthCareLevel.countrycode, HealthCareLevel.lifeexpectancy, ur_change
FROM HealthCareLevel, UR_Change
WHERE HealthCareLevel.lifeexpectancy IS NOT NULL
AND HealthCareLevel.countrycode = UR_Change.countrycode;

SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef life expectancy vs change"

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
    countrylife.lifeexpectancy AS "cases",
    countrylife.ur_change AS "changes"
FROM countrylife
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;


-- Q2 part 4 determine the relationship between covid cases per millin and country's HDI

CREATE VIEW HDI_Relation AS
SELECT countryHDI.countrycode, COVID_Data.total_cases_per_million, COVID_Data.total_deaths_per_million, countryHDI.hdi
FROM countryHDI, COVID_Data
WHERE countryHDI.countrycode = COVID_Data.countrycode 
AND COVID_Data.date_ = '2020-09-19';

SELECT
    ((tot_sum - (amt_sum * act_sum / _count)) / sqrt((amt_sum_sq - pow(amt_sum, 2.0) / _count) * (act_sum_sq - pow(act_sum, 2.0) / _count))) AS "Corr Coef covid cases vs hdi"

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
    HDI_Relation.total_cases_per_million AS "cases",
    HDI_Relation.hdi AS "changes"
FROM HDI_Relation
) as a

) as b

GROUP BY tot_sum, amt_sum, act_sum, _count, amt_sum_sq, act_sum_sq;


--Q2 part 5 find the mean change in unemployment rate and covid cases per million for the top and bottom 25% countries

-- rank the country based on their hdi
CREATE VIEW differentHDI AS
SELECT countryHDI.countrycode, HDI_relation.total_cases_per_million, HDI_relation.total_deaths_per_million, 
countryHDI.hdi, countryHDI.ur_change, 
RANK() OVER (order by countryHDI.hdi asc) rank
FROM countryHDI, HDI_relation
WHERE countryHDI.countrycode = HDI_relation.countrycode;


CREATE VIEW TOP25_HDI AS
SELECT avg(total_cases_per_million) as per_milliion_cases_avg , avg(ur_change) as ur_change_avg
FROM differentHDI
WHERE rank > 171 * 0.75;

CREATE VIEW BOT25_HDI AS
SELECT avg(total_cases_per_million) as per_milliion_cases_avg , avg(ur_change) as ur_change_avg
FROM differentHDI
WHERE rank < 171 * 0.25;


