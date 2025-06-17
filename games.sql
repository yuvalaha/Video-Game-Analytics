USE Games

-- All Data
SELECT *
FROM games_db


-- Total Games In the Database
SELECT COUNT(*) AS Total_Games
FROM games_db


-- Games By Console
SELECT  console,
		COUNT(*) AS Number_Of_Games
FROM games_db
GROUP BY console
ORDER BY Number_Of_Games DESC


-- Number of Games, Average Score and Sales According to Release Year
SELECT  YEAR(release_date) AS Release_Year,
		COUNT(*) AS Number_Of_Games,
		FORMAT(AVG(total_sales) * 1000000 , 'C') AS Average_Sales
FROM games_db
WHERE YEAR(release_date) IS NOT NULL
GROUP BY YEAR(release_date)
ORDER BY Release_Year

-- Top 10 Total Sales
SELECT TOP 10 * 
FROM games_db
ORDER BY total_sales DESC

--Number Of Games for Every Developer
SELECT  developer, 
		COUNT(id) AS 'Number Of Games Per Developer'
FROM games_db
GROUP BY developer

--Average critic score
SELECT AVG(critic_score) AS 'Average Critic Score'
FROM games_db
WHERE critic_score IS NOT NULL

ALTER TABLE games_db
ALTER COLUMN na_sales FLOAT
ALTER TABLE games_db
ALTER COLUMN jp_sales FLOAT
ALTER TABLE games_db
ALTER COLUMN pal_sales FLOAT
ALTER TABLE games_db
ALTER COLUMN other_sales FLOAT

-- Sales Per Genre
SELECT  genre,
		FORMAT(SUM(jp_sales), '##.##') AS 'Sales In Japan',
		FORMAT(SUM(pal_sales), '##.##') AS 'Sales In Europe And Africa',
		FORMAT(SUM(na_sales), '##.##') AS 'Sales In North America',
		FORMAT(SUM(other_sales), '##.##') AS 'Sales In Rest Of The World'
FROM games_db
GROUP BY genre
ORDER BY genre

-- Total Sales Percentage in Japan
SELECT FORMAT(SUM(jp_sales) * 1.0 / SUM(total_sales), 'P') AS 'Japan Total Sales Percentage'
FROM games_db

-- Classify each game based on its total sales into success categories
SELECT  title,
		console,
		CASE
			WHEN total_sales IS NULL THEN 'No Information'
			WHEN total_sales < 2 THEN 'Flop'
			WHEN total_sales < 7 THEN 'Moderate'
			WHEN total_sales < 9 THEN 'Hit'
			ELSE 'Massive Hit'
		END AS 'Success Category'
FROM games_db

-- Critic Score in Every Genre, Console 
SELECT  title,
		console, 
		publisher,
		genre,
		critic_score,
		ROW_NUMBER() OVER(PARTITION BY genre, console ORDER BY critic_score) AS 'Critic Score By Genre' 
FROM games_db
WHERE critic_score IS NOT NULL