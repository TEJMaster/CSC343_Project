DROP SCHEMA IF EXISTS CovidImpact CASCADE;
CREATE SCHEMA CovidImpact;
SET SEARCH_PATH TO CovidImpact;

-- Schema Begins.

-- A tuple in this  relation  represents the region unit.
-- regionCode is the unique code representing the region
-- Region is the  textual representation corresponding to the continent.
CREATE TABLE Region (
	regionCode TEXT NOT NULL,
	Region TEXT NOT NULL,
	PRIMARY KEY (regionCode)
);

-- A tuple in this  relation  represents the region unit.
-- regionCode is the unique code representing the subregion
-- subRegion is the  textual representation corresponding to the sub-continent.
CREATE TABLE SubRegion (
	subRegionCode TEXT NOT NULL,
	subRegion TEXT NOT NULL,
	PRIMARY KEY (subRegionCode)
);

-- A tuple in this relation represents a Country's geographical information .
-- Name is there formal country name.
-- countryCode is a 3-letter code representing their country.
-- regionCode is the code represent their continent.
-- subRegionCode is the code represent their sub-continent.
CREATE TABLE Country (
	Name TEXT NOT NULL,
	countryCode TEXT NOT NULL,
	regionCode TEXT NOT NULL,
	subRegionCode TEXT NOT NULL,
	PRIMARY KEY (countryCode),
	FOREIGN KEY (regionCode) REFERENCES Region(regionCode),
	FOREIGN KEY (subRegionCode) REFERENCES SubRegion(subRegionCode)
);


-- A tuple in this relation represents the unemployment rate per country in different year.
-- countryCode is their national code to represent their country.
-- 2019UR is the unemployed rate for the country in 2019.
-- 2020UR is the unemployed rate for the country in 2020.
CREATE TABLE Unemployment (
	countryCode TEXT NOT NULL,
	UR_2019 FLOAT,
        UR_2020 FLOAT,
	PRIMARY KEY (countryCode),
	FOREIGN KEY (countryCode) REFERENCES Country(countryCode)
);

-- A tuple in this relation represents the Income Level for each country in the global status.
-- countryCode is their national code to represent their country.
-- incomeGroup is the income status for countries
-- which separate as high income, upper middle income and lower middle income.
CREATE TABLE IncomeLevel (
	countryCode TEXT NOT NULL,
	incomeGroup TEXT,
	PRIMARY KEY (countryCode),
	FOREIGN KEY (countryCode) REFERENCES Country(countryCode)
);

-- A tuple in this relation represents the health care Level for each country in the global status.
-- countryCode is their national code to represent their country.
-- bedsPerThousand is the medical beds per one thousand population
-- lifeExpectancy is the average life expectancy of the country
-- HDI is the human developed index of the country.
CREATE TABLE HealthCareLevel (
  countryCode TEXT NOT NULL,
  bedsPerThousand FLOAT,
  lifeExpectancy FLOAT,
  HDI FLOAT,
  PRIMARY KEY (countryCode),
  FOREIGN KEY (countryCode) REFERENCES Country(countryCode)
);

-- A tuple in this relation represents the covid data for each country in the global status.
-- countryCode is their national code to represent their country.
-- date_ is the date for the data.
-- total_cases_per_million is the total covid cases per million on that date.
-- total_deaths_per_million total covid death per million on that date.
-- total_case is the total covid case of the country on that date.
-- total_death is the total covid death of the country on that date.
CREATE TABLE COVID_Data (
	countryCode TEXT NOT NULL,
	date_ DATE NOT NULL,
	total_cases_per_million FLOAT,
  total_deaths_per_million FLOAT,
  total_case INT,
  total_death INT,
	PRIMARY KEY (countryCode, date_),
	FOREIGN KEY (countryCode) REFERENCES Country(countryCode)
);

-- Schema Ends


CREATE TABLE import_country_data(
  name TEXT NOT NULL,
  alpha_3 TEXT NOT NULL,
  region TEXT NOT NULL,
  sub_region TEXT NOT NULL,
  region_code TEXT NOT NULL,
  sub_region_code TEXT NOT NULL
);
\COPY import_country_data(name, alpha_3, region, sub_region, region_code, sub_region_code) from 'continents.csv' DELIMITER ',' CSV HEADER

CREATE TABLE import_covid_data (
  iso_code TEXT NOT NULL,
  continent TEXT,
  location TEXT,
  date_ DATE,
  total_cases INT,
  total_deaths INT,
  total_cases_per_million FLOAT,
  total_deaths_per_million FLOAT,
  hospital_beds_per_thousand FLOAT,
  life_expectancy FLOAT,
  human_development_index FLOAT
);
\COPY import_covid_data(iso_code, continent, location, date_, total_cases, total_deaths, total_cases_per_million, total_deaths_per_million, hospital_beds_per_thousand, life_expectancy, human_development_index) from 'covid_data.csv' DELIMITER ',' CSV HEADER

CREATE TABLE import_income_level_data (
  Country_Code TEXT NOT NULL,
  Region TEXT,
  IncomeGroup TEXT
);
\COPY import_income_level_data(Country_Code, Region, IncomeGroup) from 'income_level.csv' DELIMITER ',' CSV HEADER

CREATE TABLE import_unemploytment_rate (
    CountryCode TEXT,
    nineteen FLOAT,
 	twenty FLOAT
);
\COPY import_unemploytment_rate(CountryCode, nineteen, twenty) from 'unemployment_rate.csv' DELIMITER ',' CSV HEADER

-- IMPORT DATA END


-- Data Cleaning
INSERT INTO Region(region, regionCode)
SELECT DISTINCT region, region_code
FROM import_country_data;

INSERT INTO subRegion(subregion, subregionCode)
SELECT DISTINCT sub_region, sub_region_code
FROM import_country_data;

INSERT INTO Country(Name, countryCode, regionCode, subRegionCode)
SELECT name, alpha_3, region_code, sub_region_code
FROM import_country_data;

INSERT INTO Unemployment(countryCode, UR_2019, UR_2020)
SELECT CountryCode, nineteen, twenty
FROM import_unemploytment_rate
WHERE CountryCode IN (SELECT countryCode FROM Country);

INSERT INTO IncomeLevel(countryCode, incomeGroup)
SELECT Country_Code, IncomeGroup
FROM import_income_level_data
WHERE Country_Code IN (SELECT countryCode FROM Country);

INSERT INTO HealthCareLevel(countryCode, bedsPerThousand, lifeExpectancy, HDI)
SELECT DISTINCT(iso_code), hospital_beds_per_thousand, life_expectancy, human_development_index
FROM import_covid_data
WHERE iso_code IN (SELECT countryCode FROM Country);

INSERT INTO COVID_Data (countryCode, date_, total_cases_per_million, total_deaths_per_million, total_case, total_death)
SELECT iso_code, date_, total_cases_per_million, total_deaths_per_million, total_cases, total_deaths
FROM import_covid_data
WHERE iso_code IN (SELECT countryCode FROM Country);
