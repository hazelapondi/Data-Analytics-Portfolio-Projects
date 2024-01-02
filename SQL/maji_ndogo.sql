-- Determine number of sources for each location type
SELECT DISTINCT(location_type),
	COUNT(town_name)    
FROM 
	location
GROUP BY
	location_type;

-- Determine how many wells, taps and rivers there are
SELECT
	DISTINCT(type_of_water_source),
	COUNT(number_of_people_served) AS num_of_users
FROM
	water_source
GROUP BY 
	type_of_water_source;

-- Determine the number of people who share particular types of water sources on average
SELECT
	DISTINCT(type_of_water_source),
	ROUND(AVG(number_of_people_served)) AS avg_num_of_users
FROM
	water_source
GROUP BY 
	type_of_water_source;

-- Determine the number of people served by each water source
SELECT
	type_of_water_source,
	SUM(number_of_people_served) AS population_served    
FROM
	water_source
GROUP BY 
	type_of_water_source;

-- Determine which taps should be fixed first
SELECT
	source_id,
	type_of_water_source,
	number_of_people_served,
	RANK () OVER (
	ORDER BY number_of_people_served DESC) AS priority_rank
FROM
	water_source
GROUP BY
	source_id,
	type_of_water_source;

-- Determining the average queue times for each hour in each day
SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Sunday,
-- Monday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Monday,
-- Tuesday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Tuesday,
-- Wednesday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Wednesday,
-- Thursday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Thursday,
-- Friday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Friday,
-- Saturday
	ROUND(AVG(
	CASE
		WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
		ELSE NULL
	END
	),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
	hour_of_day
ORDER BY
	hour_of_day;


-- Create auditor_report table
DROP TABLE IF EXISTS auditor_report;
CREATE TABLE auditor_report (
	location_id VARCHAR(32),
	type_of_water_source VARCHAR(64),
	true_water_source_score int DEFAULT NULL,
	statements VARCHAR(255)
);

-- Create CTE 
WITH
	Incorrect_records AS(
    	SELECT
		auditor_report.location_id AS audit_location,
		visits.record_id,
		employee.employee_name,
		auditor_report.true_water_source_score AS auditor_score,
		water_quality.subjective_quality_score AS employee_score    
	FROM 
		auditor_report
	INNER JOIN
		visits
	ON
		auditor_report.location_id = visits.location_id
	INNER JOIN
		water_quality
	ON
		visits.record_id = water_quality.record_id
	INNER JOIN
		water_source
	ON
		visits.source_id = water_source.source_id
	INNER JOIN
		employee
	ON
		visits.assigned_employee_id = employee.assigned_employee_id
	WHERE
		visits.visit_count = 1
		AND auditor_report.true_water_source_score != water_quality.subjective_quality_score
	LIMIT 
		10000),
	error_count AS ( -- This CTE calculates the number of mistakes each employee made
	SELECT
		DISTINCT employee_name, -- List of unique employee names
		COUNT(employee_name) AS number_of_mistakes
	FROM
		Incorrect_records
	GROUP BY
		employee_name
	ORDER BY 
		number_of_mistakes DESC),
	suspect_list AS ( -- This CTE SELECTS the employees with above−average mistakes
		SELECT 
			employee_name,
			number_of_mistakes
		FROM 
			error_count
		WHERE
			number_of_mistakes > ( SELECT AVG(number_of_mistakes) FROM error_count )
		GROUP BY
			employee_name)
SELECT
	employee_name,
	number_of_mistakes
FROM
	suspect_list;


-- Replacing our CTE with a View
CREATE VIEW 
	Incorrect_records AS (
	SELECT
		auditor_report.location_id,
		visits.record_id,
		employee.employee_name,
		auditor_report.true_water_source_score AS auditor_score,
		wq.subjective_quality_score AS employee_score,
		auditor_report.statements AS statements
	FROM
		auditor_report
	JOIN
		visits
	ON auditor_report.location_id = visits.location_id
	JOIN
		water_quality AS wq
	ON visits.record_id = wq.record_id
	JOIN
		employee
	ON employee.assigned_employee_id = visits.assigned_employee_id
	WHERE
		visits.visit_count =1
		AND auditor_report.true_water_source_score != wq.subjective_quality_score);
SELECT 
  * 
FROM Incorrect_records;

-- This query filters all of the records where "corrupt" employees gathered data.
SELECT
	employee_name,
	location_id,
	statements
FROM
	Incorrect_records
WHERE
	employee_name in (SELECT employee_name FROM suspect_list)
    	AND statements LIKE "%cash%";


-- Create a view that assembles data from different tables into one to simplify analysis
CREATE VIEW combined_analysis_table AS
SELECT
	water_source.type_of_water_source AS source_type,
	location.province_name,
	location.town_name,
	location.location_type,
	water_source.number_of_people_served AS people_served,
	visits.time_in_queue,
	well_pollution.results
FROM 
	visits
LEFT JOIN -- joining well_pollution and visits
	well_pollution
ON	
	visits.source_id = well_pollution.source_id
INNER JOIN -- joining location to visits
	location
ON	
	visits.location_id = location.location_id
INNER JOIN -- joining water_source and visits
	water_source
ON	
	visits.source_id = water_source.source_id
--  Filtering to ensure we only get one record for each location
WHERE
	visits.visit_count = 1;


-- Creating a CTE that calculates the population of each province
WITH province_totals AS (
	SELECT
		province_name,
		SUM(people_served) AS total_ppl_serv
	FROM
		combined_analysis_table
	GROUP BY
		province_name
	)
SELECT
	ct.province_name,
	-- These case statements create columns for each type of source.
	-- The results are aggregated and percentages are calculated
	ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN
	province_totals pt 
ON 
	ct.province_name = pt.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name;

    
-- Aggregate the data per town
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
	-- This CTE calculates the population of each town
	-- Since there are two Harare towns, we have to group by province_name and town_name
	SELECT 
		province_name, 
		town_name, 
		SUM(people_served) AS total_ppl_serv
	FROM combined_analysis_table
	GROUP BY 
		province_name,
		town_name
	)
SELECT
	ct.province_name,
	ct.town_name,
	ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt 
ON 
	ct.province_name = tt.province_name 
	AND ct.town_name = tt.town_name
GROUP BY -- We group by province first then by town
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;

-- Querying town_aggregated_water_access
SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *	100,0) AS Pct_broken_taps
FROM
	town_aggregated_water_access;

/*
Create a table Project_progress including the following columns:
Project_id −− Unique key for sources in case we visit the same source more than once in the future.
source_id −− Each of the sources we want to improve should exist and should refer to the source table. This ensures data integrity.
Address -- Street address
Improvement -- What the engineers should do at that place
Source_status −− We want to limit the type of information engineers can give us, so we limit Source_status.
	− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
	− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
Date_of_completion -- Engineers will add this the day the source has been upgraded.
Comments -- Engineers can leave comments. We use a TEXT type that has no limit on char length
*/

CREATE TABLE Project_progress (
	Project_id SERIAL PRIMARY KEY,
	source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
	Address VARCHAR(50), 
	Town VARCHAR(30),
	Province VARCHAR(30),
	Source_type VARCHAR(50),
	Improvement VARCHAR(50), 
	Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
	Date_of_completion DATE, 
	Comments TEXT 
);

/*
Join the location, visits, and well_pollution tables to the water_source table. Since well_pollution only has data for wells,
we have to join those records to the water_source table with a LEFT JOIN, and we use visits to link the various id's together.
*/
SELECT
	location.address,
	location.town_name,
	location.province_name,
	water_source.source_id,
	water_source.type_of_water_source,
	well_pollution.results,
	CASE 
		WHEN water_source.type_of_water_source = 'well' THEN
			IF(well_pollution.results = 'Contaminated: Biological', 'Install UV filter', 'Null') 
			ELSE 
			IF(well_pollution.results = 'Contaminated: Chemical', 'Install RO filter', 'Null')
	END AS improvement_plan,    
	CASE
		WHEN water_source.type_of_water_source IN ('river') THEN
		'Drill well'
	END AS improvement_plan,
	CASE
		WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30  
		THEN CONCAT("Install ", FLOOR(visits.time_in_queue/30), " taps nearby")
		ELSE NULL
	END AS improvement_plan,
	CASE
		WHEN water_source.type_of_water_source IN ('tap_in_home_broken') THEN 'Diagnose local infrastructure'
	END AS improvement_plan
FROM
	water_source
LEFT JOIN
	well_pollution 
ON 
	water_source.source_id = well_pollution.source_id
INNER JOIN
	visits 
ON 
	water_source.source_id = visits.source_id
INNER JOIN
	location 
ON 
	location.location_id = visits.location_id
WHERE
	visits.visit_count = 1 -- This must always be true
	AND ( -- AND one of the following (OR) options must be true as well.
	well_pollution.results != 'Clean'
	OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
	OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
	);
