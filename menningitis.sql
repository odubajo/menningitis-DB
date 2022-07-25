
-- DATA CLEANING

select * from project.dbo.meningitis_dataset$

-- Standardize Date Format

SELECT report_date, CONVERT(date,report_date)
FROM project.dbo.meningitis_dataset$

ALTER TABLE project.dbo.meningitis_dataset$
Add Reportdate Date;

UPDATE project.dbo.meningitis_dataset$
SET Reportdate = CONVERT(date,report_date)

ALTER TABLE project.dbo.meningitis_dataset$
Add DOB Date;

UPDATE project.dbo.meningitis_dataset$
SET DOB = CONVERT(Date,date_of_birth)


-- Converting some column values all to lower case

ALTER TABLE project.dbo.meningitis_dataset$
Add Healthstatus NVARCHAR(255);

UPDATE project.dbo.meningitis_dataset$
SET Healthstatus = LOWER(health_status)

ALTER TABLE project.dbo.meningitis_dataset$
Add reportoutcome NVARCHAR(255);

UPDATE project.dbo.meningitis_dataset$
SET reportoutcome= LOWER(report_outcome)

-- Drop Irrelevant Columns

ALTER TABLE project.dbo.meningitis_dataset$
DROP COLUMN report_date,date_OF_birth,gender_male,gender_female,rural_settlement,urban_settlement ,cholera,
diarrhoea, measles,viral_haemmorrhaphic_fever,meningitis,ebola,marburg_virus,yellow_fever,rubella_mars,malaria,
alive,dead,unconfirmed,confirmed,report_outcome,health_status;


----- DATA EXPLORATION


-- Show all data

SELECT * from project.dbo.meningitis_dataset$
order by id

--To view gender count and thier average age in the dataset

SELECT COUNT(gender) as gender_count,AVG(age) as average_age
FROM project.dbo.meningitis_dataset$
GROUP BY gender

-- to view the number of cases per state
SELECT state, COUNT(state) as total_infected
FROM project.dbo.meningitis_dataset$
GROUP BY state
ORDER BY 2

-- to view the number of confirmed and unconfirmed cases per state
SELECT state, reportoutcome, COUNT(reportoutcome) as case_confirmation
FROM project.dbo.meningitis_dataset$
GROUP BY state, reportoutcome
ORDER BY 1

-- to view the count of the outcome of disease per state
SELECT state,Healthstatus, COUNT(Healthstatus) as disease_outcome
FROM project.dbo.meningitis_dataset$
GROUP BY state, Healthstatus
ORDER BY 1

-- to view the counts of children and adults
SELECT state,COUNT(adult_group) AS adults, COUNT(child_group) as children
FROM project.dbo.meningitis_dataset$
GROUP BY state
ORDER BY 1

-- to view the cases before and after the 2015 election
SELECT surname,firstname,disease,report_year,
CASE
   WHEN report_year < 2015 THEN 'before_election'
   ELSE 'after_election'
END AS elction_period
FROM project.dbo.meningitis_dataset$

-- Using CTE to check infant cases 

WITH CTE_Disease as
(SELECT surname,firstname,disease,state,age,
COUNT(state) OVER(PARTITION BY state) as total_state_infetion
FROM project.dbo.meningitis_dataset$
WHERE age_str like '%months%')
SELECT surname, disease , age, state,total_state_infetion
FROM CTE_Disease

-- Creating a stored procedure to check diease count

CREATE PROCEDURE Temp_disease1
@disease nvarchar(100)
AS
Create table #temp_disease1 (
disease varchar(100),
people_infected int ,
)


Insert into #temp_disease1
SELECT disease, Count(disease)
FROM project.dbo.meningitis_dataset$
WHERE disease= @disease
GROUP BY disease

SELECT* 
From #temp_disease1
GO;

EXEC Temp_disease1 @disease = 'Ebola'