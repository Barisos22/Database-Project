-- ---------------------------- --
--            VIEWS             -- 
-- ---------------------------- --
CREATE VIEW high_healthcare_expense_countries (c_id, date, percent_gdp) AS
SELECT * 
FROM healthcare_spending
WHERE percent_gdp >= 5 ;

CREATE VIEW high_pollution_deaths (c_id, date, death_percentage) AS
SELECT c_id, date, death_percentage
FROM air_pol_deaths_reported
WHERE death_percentage > 20 ;

CREATE VIEW high_lung_cancer AS
SELECT c_id, date, (lungc_amount / (lungc_amount + liporalc_amount + liverc_amount)) * total_percent AS lungc_percent
FROM cancer_death_reported
WHERE (lungc_amount / (lungc_amount + liporalc_amount + liverc_amount)) * total_percent > 0.2 ;

CREATE VIEW high_depression_percent (c_id, date, percent_depression) AS
SELECT c_id, date, percent_depression
FROM mental_disorder
WHERE percent_depression > 5 ;

CREATE VIEW high_urban_rate_countries AS 
SELECT c_id, date, amount_urban / (amount_urban + amount_rural) AS percent_urban
FROM housed_population
WHERE amount_urban / (amount_urban + amount_rural) > 0.7;

-- ---------------------------- --
--     JOINS/SET OPERATIONS     -- 
-- ---------------------------- --

SELECT c_id FROM high_urban_rate_countries
INTERSECT 
SELECT c_id FROM high_depression_percent;

SELECT DISTINCT high_urban_rate_countries.c_id FROM high_urban_rate_countries 
INNER JOIN high_depression_percent  
ON high_urban_rate_countries.c_id = high_depression_percent.c_id;

-- -------------------- --

SELECT c_id FROM high_urban_rate_countries
EXCEPT
SELECT c_id FROM high_depression_percent;

SELECT distinct high_urban_rate_countries.c_id FROM 
high_urban_rate_countries LEFT OUTER JOIN high_depression_percent 
ON high_urban_rate_countries.c_id = high_depression_percent.c_id
WHERE high_depression_percent.c_id IS NULL;

-- ---------------------------- --
--         IN & EXISTS          -- 
-- ---------------------------- --

SELECT C.c_id, C.date, C.lungc_amount FROM cancer_death_reported C WHERE C.c_id IN
(SELECT A.c_id FROM air_pol_deaths_reported A WHERE A.death_percentage > 23);

SELECT C.c_id, C.date, C.lungc_amount FROM cancer_death_reported C WHERE exists
(SELECT A.c_id FROM air_pol_deaths_reported A WHERE A.death_percentage > 23 AND C.c_id=A.c_id);

-- ---------------------------- --
--     AGGREGATE OPERATORS      -- 
-- ---------------------------- --

SELECT H.c_id, AVG(H.percent_gdp)
FROM healthcare_spending H
WHERE H.date >= 2010
GROUP BY H.c_id
HAVING 0.1 < (SELECT MIN(C.total_percent)
FROM cancer_death_reported C
WHERE H.c_id=C.c_id);

#maximum death percentages of countries after 2000 grouped by their country names that also has higher urban rate than rural, Calculate average of MAX column

SELECT A.c_id, MAX(A.death_percentage)
FROM air_pol_deaths_reported A
WHERE A.date >= 2000
GROUP BY A.c_id
HAVING 0.5 < (SELECT AVG(H.amount_urban/(H.amount_urban + H.amount_rural)) #urban > rural
FROM housed_population H
WHERE A.c_id=H.c_id);

#the opposite of earlier, calculate average of MAX column
SELECT A.c_id, MAX(A.death_percentage)
FROM air_pol_deaths_reported A
WHERE A.date >= 2000
GROUP BY A.c_id
HAVING 0.5 >= (SELECT AVG(H.amount_urban/(H.amount_urban + H.amount_rural)) #urban < rural
FROM housed_population H
WHERE A.c_id=H.c_id);


SELECT C.c_id, COUNT(*)
FROM cancer_death_reported C
WHERE C.total_percent > 0.1
GROUP BY C.c_id
HAVING 4 < (SELECT AVG(M.percent_anxiety)
FROM mental_disorder M
WHERE M.c_id = C.c_id);

#Change having > 10 to 8,6,4,2 and see how as dates progress, the average death percentage from air polution in a year decreases (in whole world)
#It also shows the Cancer deat amounts in years, total ammounts rise as years progress
SELECT C.date, SUM(C.lungc_amount)
FROM cancer_death_reported C
WHERE C.date >= 2000
GROUP BY C.date
HAVING 1 < (SELECT AVG(A.death_percentage) 
FROM air_pol_deaths_reported A
WHERE A.date=C.date);

-- ---------------------------- --
--     CONSTRAINT & TRIGGER     -- 
-- ---------------------------- --

ALTER TABLE Healthcare_Spending
ADD CONSTRAINT ck_percent_gdp CHECK (percent_gdp >= 0 AND percent_gdp <= 100);

DELIMITER //
CREATE TRIGGER insert_into_healthcare BEFORE INSERT ON healthcare_spending
FOR EACH ROW
BEGIN
	IF NEW.percent_gdp < 0 THEN
		SET NEW.percent_gdp = 0;
	ELSEIF NEW.percent_gdp > 100 THEN
		SET NEW.percent_gdp = 100;
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER update_healthcare BEFORE UPDATE ON healthcare_spending
FOR EACH ROW
BEGIN
	IF NEW.percent_gdp < 0 THEN
		SET NEW.percent_gdp = 0;
	ELSEIF NEW.percent_gdp > 100 THEN
		SET NEW.percent_gdp = 100;
	END IF;
END//
DELIMITER ;

INSERT INTO healthcare_spending VALUES ("USA",1337,101);

SELECT * FROM healthcare_spending WHERE date = 1337 OR date = 1338;

INSERT INTO healthcare_spending VALUES ("USA",1338,-3);

SET SQL_SAFE_UPDATES = 0;
DELETE FROM healthcare_spending WHERE date = 1337 OR date = 1338;
SET SQL_SAFE_UPDATES = 1;

-- ---------------------------- --
--          PROCEDURE           -- 
-- ---------------------------- --

DELIMITER //
CREATE PROCEDURE ReturnAveragePopulation (IN country CHAR(3))
BEGIN
	SELECT AVG(amount_urban + amount_rural) AS AveragePopulation FROM housed_population WHERE c_id = country;
END//
DELIMITER ;

CALL ReturnAveragePopulation("USA");

CALL ReturnAveragePopulation("AFG");
