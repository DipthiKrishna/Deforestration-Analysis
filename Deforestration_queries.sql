/*SQL Queries Used*/
/* the total forest area of the world in 1990*/
WITH t1 AS
(SELECT year,forest_area_sqkm /2.59 As forest_area_sqmiles
FROM forest_area)
SELECT SUM(forest_area_sqmiles)
FROM t1
WHERE year=1990;

/*the total forest area (in sq km) of the world in 2016*/
WITH t1 AS
(SELECT year,forest_area_sqkm /2.59 As forest_area_sqmiles
FROM forest_area)
SELECT SUM(forest_area_sqmiles)
FROM t1
WHERE year=2016;

/*the change (in sq km) in the forest area of the world from 1990 to 2016*/
WITH t1 AS
(SELECT year,forest_area_sqkm /2.59 As forest_area_sqmiles
FROM forest_area)
SELECT ((SELECT SUM(forest_area_sqmiles)
FROM t1
WHERE year=2016)-(SELECT SUM(forest_area_sqmiles) FROM t1
WHERE year=1990)) AS forest_area_difference
FROM t1;

/*compare the amount of forest area lost between 1990 and 2016, to which
country's –total area in 2016 is it closest to*/
WITH t1 AS
(SELECT country_name,total_area_sq_mi
FROM land_area
WHERE year=2016)
SELECT DISTINCT(country_name),total_area_sq_mi
FROM land_area
WHERE total_area_sq_mi< 845960.65
ORDER BY 2 DESC;

/*In 2016, the percentage of the total land area of the world designated as forest*/
SELECT ROUND(((sum(f.forest_area_sqkm
/2.59)/sum(l.total_area_sq_mi))*100) ::numeric,2) As forest_percent
FROM forest_area f
JOIN land_area l
USING(country_code)
WHERE f.year=2016;

/*In 1990, the percentage of the total land area of the world designated as forest*/
SELECT ROUND(((sum(f.forest_area_sqkm
/2.59)/sum(l.total_area_sq_mi))*100) ::numeric,2) As forest_percent
FROM forest_area f
JOIN land_area l
USING(country_code)
WHERE f.year=1990;

/*Regional Outlook*/
WITH t1 AS
(SELECT country_code,forest_area_sqkm/2.59 AS Forest_area_Sqmi
FROM forest_area
WHERE year=1990),
t2 AS
(SELECT country_code,forest_area_sqkm/2.59 AS Forest_area_Sqmi
FROM forest_area
WHERE year=2016),
t3 AS
(SELECT r.region,SUM(t1.Forest_area_Sqmi) AS
total_forest_area_1990, SUM(t2.Forest_area_Sqmi) AS total_forest_area_2016
FROM regions r
JOIN t1
ON r.country_code=t1.country_code
JOIN t2
ON r.country_code=t2.country_code
GROUP BY 1
ORDER BY 2 DESC)
SELECT t3.region,ROUND(((t3.total_forest_area_1990/(SELECT
SUM(forest_area_sqkm)/2.59 FROM forest_area WHERE
year=1990))*100)::numeric,2) AS
forest_percent_1990,ROUND(((t3.total_forest_area_2016/(SELECT
SUM(forest_area_sqkm)/2.59 FROM forest_area WHERE
year=2016))*100)::numeric,2) AS forest_percent_2016
FROM t3;

/*Country level percentage difference 1990-2016*/
WITH t1 AS
(SELECT country_code,forest_area_sqkm/2.59 AS Forest_area_Sqmi
FROM forest_area
WHERE year=1990),
t2 AS
(SELECT country_code,forest_area_sqkm/2.59 AS Forest_area_Sqmi
FROM forest_area
WHERE year=2016),
t3 AS
(SELECT r.region,t1.country_code AS country_code,
SUM(t1.Forest_area_Sqmi) AS total_forest_area_1990,
SUM(t2.Forest_area_Sqmi) AS total_forest_area_2016
FROM regions r
JOIN t1
ON r.country_code=t1.country_code
JOIN t2
ON r.country_code=t2.country_code
GROUP BY 1,2
ORDER BY 3 DESC),
t4 AS
(SELECT t3.region,r.country_name,
(t3.total_forest_area_1990*100/(SELECT SUM(total_area_sq_mi) FROM
land_area WHERE year=1990)) AS forest_percent_1990,
(t3.total_forest_area_2016*100/(SELECT SUM(total_area_sq_mi) FROM
land_area WHERE year=2016)) AS forest_percent_2016
FROM t3
JOIN regions r
ON r.country_code=t3.country_code
ORDER BY 3 DESC)
SELECT t4.country_name,
ROUND((t4.forest_percent_2016-t4.forest_percent_1990)::numeric,2) AS
Forest_growth_percent_1990_to_2016
FROM t4
WHERE t4.forest_percent_2016 IS NOT NULL AND t4.forest_percent_1990 IS
NOT NULL
ORDER BY 2 DESC;

/*Top 5 Amount Decrease in Forest Area by Country, 1990 & 2016:*/
WITH t1 AS
(SELECT f.country_name AS country, r.region AS
region,SUM(forest_area_sqkm) AS total_forest_area_1990
FROM forest_area f
JOIN regions r
USING(country_code)
WHERE year=1990
GROUP BY 1,2),
t2 AS
(SELECT f.country_name AS country,r.region as
region,SUM(forest_area_sqkm) AS total_forest_area_2016
FROM forest_area f
JOIN regions r
USING(country_code)
WHERE year=2016
GROUP BY 1,2)
SELECT
t1.country,t1.region,ROUND((t2.total_forest_area_2016-t1.total_forest_area_199
0)::numeric,2) AS forest_area_change
FROM t1
JOIN t2
USING(country)
WHERE t2.total_forest_area_2016 IS NOT NULL AND t1.total_forest_area_1990
IS NOT NULL AND country <> 'World'
ORDER BY 3
LIMIT 5;

/*Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016:*/
WITH t1 AS
(SELECT country_code,forest_area_sqkm/2.59 AS Forest_area_Sqmi
FROM forest_area
WHERE year=1990),
t2 AS
(SELECT country_code,forest_area_sqkm/2.59 AS Forest_area_Sqmi
FROM forest_area
WHERE year=2016),
t3 AS
(SELECT r.country_name AS country_name, r.region AS region,
SUM(t1.Forest_area_Sqmi) AS total_forest_area_1990,
SUM(t2.Forest_area_Sqmi) AS total_forest_area_2016
FROM regions r
JOIN t1
ON r.country_code=t1.country_code
JOIN t2
ON r.country_code=t2.country_code
GROUP BY 1,2
ORDER BY 3 DESC)
SELECT t3.country_name,t3.region,
ROUND((((t3.total_forest_area_2016-t3.total_forest_area_1990)*2.59)*100/(t3.to
tal_forest_area_1990*2.59))::numeric,2)
AS Percent_Forest_area_growth_SqKm
FROM t3
ORDER BY 3 ;

/*Count of Countries Grouped by Forestation Percent Quartiles, 2016*/
WITH t1 AS
(SELECT country_code,f.country_name,
(SUM(f.forest_area_sqkm)*100)/SUM(l.total_area_sq_mi *2.59) AS
forest_percentile
FROM forest_area f
JOIN land_area l
USING(country_code)
WHERE f.year=2016
GROUP BY 1,2
ORDER BY 3 DESC)
SELECT
CASE
WHEN forest_percentile <= 25 AND forest_percentile IS NOT NULL THEN
'Q1' WHEN forest_percentile<= 50 AND forest_percentile IS NOT NULL THEN
'Q2'
WHEN forest_percentile<= 75 AND forest_percentile IS NOT NULL THEN
'Q3' WHEN forest_percentile<= 100 AND forest_percentile IS NOT NULL THEN
'Q4' ELSE 'Null valued'
END AS quartile,
COUNT(*) AS number_of_countries
FROM t1
GROUP BY 1;

/*Top Quartile Countries, 2016:*/
SELECT f.country_name, r.region,
ROUND(((SUM(f.forest_area_sqkm)*100)/SUM(l.total_area_sq_mi
*2.59))::numeric,2) AS forest_percentile
FROM forest_area f
JOIN land_area l
USING(country_code)
JOIN regions r
USING(country_code)
WHERE f.year=2016 AND l.total_area_sq_mi IS NOT NULL AND
f.forest_area_sqkm IS NOT NULL
GROUP BY 1,2
HAVING (SUM(f.forest_area_sqkm)*100)/SUM(l.total_area_sq_mi *2.59)>75
ORDER BY 3 DESC;