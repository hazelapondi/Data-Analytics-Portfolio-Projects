-- select the number of records in the table
SELECT COUNT(*)
FROM players;

SELECT 
  COUNT(playerid) AS n_players,
  COUNT(firstname) AS n_first_names,
  COUNT(lastname) AS n_last_names,
  COUNT(age) AS n_ages,
  COUNT(birthdate) AS n_birth_dates,
  COUNT(height) AS n_heights,
  COUNT(weight) AS n_weights,
  COUNT(nationality) AS n_nationalities,
  COUNT(club) AS n_clubs,
  COUNT(value_eur) AS n_value_in_euros,
  COUNT(wage_eur) AS n_wages_in_euros,
  COUNT(team_position) AS n_teams_positions
FROM players;

-- select the first 5 rows of the entire table
SELECT * 
FROM players
LIMIT 5;

-- The full name height and weight of each player limiting to the first 5
SELECT 
	firstname, 
  lastname, 
  height, 
  weight
FROM players
LIMIT 5;

-- concatenate firstname and lastname as full name
SELECT 
	CONCAT(firstname,' ',lastname) AS full_name
FROM players
LIMIT 5;

-- Eldest and youngest player birth date
SELECT 
	playerid, 
  CONCAT(firstname,' ', lastname) AS full_name, 
  CAST(birthdate AS date) AS birth_date
FROM players
GROUP BY playerid, full_name, birth_date
ORDER BY birth_date;

-- average weight and height of players
SELECT
	ROUND(AVG(height),2) AS avg_height,
  ROUND(AVG(weight),2) AS avg_weight
FROM players;

-- position with the highest number of players
SELECT
	team_position,
  COUNT(playerid) AS n_players_position
FROM players
GROUP BY team_position
ORDER BY n_players_position DESC;

-- number of players from each nationality
SELECT
	nationality,
  COUNT(playerid) AS n_players_nationality
FROM players
GROUP BY nationality
ORDER BY n_players_nationality DESC;


-- club with the most number of players
SELECT
	club,
  COUNT(playerid) AS n_players_in_club
FROM players
GROUP BY club
ORDER BY n_players_in_club DESC;


-- average value in euros and wages for the top clubs
SELECT
	club,
  AVG(value_eur) AS avg_value,
  AVG(wage_eur) AS avg_wage,
  COUNT(playerid) AS n_players_in_club
FROM players
GROUP BY club
ORDER BY n_players_in_club DESC;


-- players with the highest wages 
SELECT
	CONCAT(firstname, ' ', lastname) AS full_name,
  value_eur,
  wage_eur
FROM players
GROUP BY full_name, value_eur, wage_eur
ORDER BY wage_eur DESC;

-- players with the highest market value 
SELECT
	CONCAT(firstname, ' ', lastname) AS full_name,
  value_eur,
  wage_eur
FROM players
GROUP BY full_name, value_eur, wage_eur
ORDER BY value_eur DESC;


-- aggregating players in different age groups
SELECT
	CASE WHEN age=20 THEN '20 years'
  WHEN age BETWEEN 20 AND 25 THEN '20-25 years'
  WHEN age BETWEEN 26 AND 30 THEN '26-30 years'
  ELSE 'over 30 years' END AS age_group,
  COUNT(playerid) AS n_players
FROM players
GROUP BY age_group;


-- average wage-value ratio
SELECT 
	ROUND(AVG(wage_eur / value_eur),2) AS avg_ratio
FROM players
WHERE value_eur IS NOT NULL 
AND wage_eur IS NOT NULL;

   
