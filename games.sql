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
		ROW_NUMBER() OVER(PARTITION BY genre, console ORDER BY critic_score DESC) AS 'Critic Score By Genre And Console' 
FROM games_db
WHERE critic_score IS NOT NULL

-- Highest sale (total_sales) of a game for each publisher
;WITH Highest_Sale_Per_Publisher AS (
	SELECT  title,
			console,
			total_sales,
			ROW_NUMBER() OVER(PARTITION BY publisher ORDER BY total_sales DESC) AS Total_Sales_Ranking
	FROM games_db
	WHERE total_sales IS NOT NULL
)
SELECT  title,
		console,
		total_sales
FROM Highest_Sale_Per_Publisher
WHERE Total_Sales_Ranking = 1 

-- Calculate the cumulative total of total_sales ordered by the Year Of Relase Date
SELECT  YEAR(release_date), 
		SUM(total_sales) AS Yearly_Sales,
		SUM(SUM(total_sales)) OVER(ORDER BY YEAR(release_date)) AS Cumulative_Total_Sales
FROM games_db
WHERE release_date IS NOT NULL AND id < 60000
GROUP BY YEAR(release_date)

-- Display all games where total_sales does not equal the sum of the regional sales (More Then 0.1 Diffrence)
;WITH Total_Sale_Calc AS (
	SELECT  title, 
			jp_sales,
			na_sales,
			pal_sales,
			other_sales,
			total_sales,
			jp_sales + na_sales + pal_sales + other_sales AS Total_Sales_Calculation
	FROM games_db
	
)

SELECT  title
FROM Total_Sale_Calc
WHERE ABS(total_sales - Total_Sales_Calculation) > 0.1

-- Display all developers who have developed at least one game with a critic_score above 9.0 and total_sales of at least 10 million.
;WITH Good_Critic_Score_And_Good_Sales AS (	
	SELECT 	title, 
			developer,
			critic_score,
			total_sales
	FROM games_db
	WHERE	critic_score > 9
			AND total_sales >= 10
)
SELECT DISTINCT developer
FROM Good_Critic_Score_And_Good_Sales

-- Which console yielded the highest overall sales(Top 10)
SELECT  console,
		ROUND(SUM(total_sales), 2)AS Total_Sales_Per_Console
FROM games_db
GROUP BY console
HAVING SUM(total_sales) IS NOT NULL
ORDER BY Total_Sales_Per_Console DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

--  Calculate the average critic_score for each console
SELECT  console,
		ROUND(AVG(critic_score), 2) AS Average_Score
FROM games_db
WHERE critic_score IS NOT NULL
GROUP BY console
ORDER BY Average_Score DESC

-- The Year And Month With the Max Amount Of Games
;WITH Total_Releases_Per_Date AS(
	SELECT  YEAR(release_date) AS Release_Year,
			MONTH(release_date) AS Release_Month,
			DAY(release_date) AS Release_Day,
			DATENAME(WEEKDAY, release_date) AS Release_Day_Name,
			COUNT(*) OVER(PARTITION BY YEAR(release_date), MONTH(release_date) ORDER BY YEAR(release_date), MONTH(release_date), DAY(release_date)) AS Cumulative_Games_Per_Month
	FROM games_db
	WHERE YEAR(release_date) IS NOT NULL
	GROUP BY YEAR(release_date),
			 MONTH(release_date),
			 DAY(release_date),
			 DATENAME(WEEKDAY, release_date)
	
)

SELECT  TOP 1 
		Release_Year,
	 	Release_Month,
		SUM(Cumulative_Games_Per_Month) AS Total_Releases
FROM Total_Releases_Per_Date
GROUP BY Release_Year,
		 Release_Month
ORDER BY Total_Releases DESC


-- Which three years with highest critic_score  
SELECT  DISTINCT TOP 5
		YEAR(release_date) AS Release_Year,
		ROUND(AVG(critic_score) OVER(PARTITION BY YEAR(release_date)), 2) AS Average_Critic_Score
FROM games_db
WHERE   critic_score IS NOT NULL	
		AND YEAR(release_date) IS NOT NULL
ORDER BY Average_Critic_Score DESC

-- Which three years had the highest number of games with a critic_score above 9.0
;WITH Total_Games_Above_9 AS(
	SELECT  YEAR(release_date) AS Release_Year,
			COUNT(*) AS Total_Games
	FROM games_db
	WHERE critic_score IS NOT NULL
		  AND critic_score > 9 		
	GROUP BY YEAR(release_date)	
	--ORDER BY Total_Games DESC
)
SELECT  TOP 3 Release_Year,
		SUM(Total_Games) AS Total_Games_By_Year
FROM Total_Games_Above_9 
GROUP BY Release_Year
ORDER BY Total_Games_By_Year DESC

-- Calculate the percentage of games for each genre out of the total number of games in the database.
SELECT  genre,
		COUNT(*) AS Amount_Of_Games,
		FORMAT(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(), 'P') AS 'Total_Percentage'
FROM games_db
GROUP BY genre

-- Display the top 3 highest-rated games (by critic_score) in each genre
;WITH Top_3_By_Score_And_Genre AS(
	SELECT  title,
			genre,
			critic_score,
			RANK() OVER(PARTITION BY genre ORDER BY critic_score DESC) AS Game_Rank
	FROM games_db
	WHERE critic_score IS NOT NULL
)
SELECT  title,
		genre,
		critic_score
FROM Top_3_By_Score_And_Genre
WHERE Game_Rank < 4


-- Classify each publisher based on the average critic_score of their games
;WITH Average_Score_By_Publisher AS (
	SELECT  publisher,
			ROUND(AVG(critic_score), 2)  AS Average_Critic_Score
	FROM games_db
	WHERE critic_score IS NOT NULL
	GROUP BY publisher
)
SELECT  *,
		CASE	
			WHEN Average_Critic_Score < 5 THEN 'Bad Publisher'
			WHEN Average_Critic_Score < 7 THEN 'Below Average'
			WHEN Average_Critic_Score < 8 THEN 'Average Publisher'
			WHEN Average_Critic_Score < 9 THEN 'Good Publisher'
			ELSE 'Excellent Publisher'
		END AS Publisher_Score
FROM Average_Score_By_Publisher
ORDER BY publisher

-- For each game, calculate the difference between its highest and lowest regional sales (among NA, Japan, Europe+Africa, Other)
;WITH Min_Max_Sales AS(
	SELECT  title,
			na_sales,
			jp_sales,
			pal_sales,
			other_sales,
			CASE 
				WHEN na_sales >= jp_sales AND na_sales >= pal_sales AND na_sales >= other_sales THEN na_sales
				WHEN jp_sales >= na_sales AND jp_sales >= pal_sales AND jp_sales >= other_sales THEN jp_sales
				WHEN pal_sales >= jp_sales AND pal_sales >= pal_sales AND na_sales >= other_sales THEN pal_sales
				ELSE other_sales
			END AS Max_Sales,
			CASE 
				WHEN na_sales <= jp_sales AND na_sales <= pal_sales AND na_sales <= other_sales THEN na_sales
				WHEN jp_sales <= na_sales AND jp_sales <= pal_sales AND jp_sales <= other_sales THEN jp_sales
				WHEN pal_sales <= na_sales AND pal_sales <= jp_sales AND pal_sales <= other_sales THEN pal_sales
				ELSE other_sales
			END AS Min_Sales
	FROM games_db
	WHERE na_sales IS NOT NULL  
		  AND jp_sales IS NOT NULL 
		  AND pal_sales IS NOT NULL
		  AND other_sales IS NOT NULL
)
SELECT  title,
		Max_Sales - Min_Sales AS Difference_Between_Max_Sales_Min_Sales
FROM Min_Max_Sales

-- Display the top 30 games with the largest difference between North America sales and Japan sales
SELECT  TOP 30 title,
		na_sales,
		jp_sales,
		na_sales - jp_sales AS Diff_Bertween_Sales_In_Japan_And_North_America
FROM games_db
WHERE na_sales IS NOT NULL AND jp_sales IS NOT NULL
ORDER BY Diff_Bertween_Sales_In_Japan_And_North_America DESC

-- Calculate the monthly percentage change in total sales over time between 1993 and 2019 
SELECT   YEAR(release_date) AS Release_Year,
		 MONTH(release_date) AS Release_Month,
		 ROUND(SUM(total_sales), 2) AS Total_Sales_Current_Month,
		 ROUND(ISNULL(LAG(SUM(total_sales)) OVER(ORDER BY YEAR(release_date), MONTH(release_date)), 0), 2) AS Last_Month_Total_Sales,
		 FORMAT(ROUND(SUM(total_sales), 2) - ROUND(ISNULL(LAG(SUM(total_sales)) OVER(ORDER BY YEAR(release_date), MONTH(release_date)), 0), 2), 'P') AS Difference_Betweeen_Current_Month_And_Last_Month
FROM games_db
WHERE   MONTH(release_date) IS NOT NULL
		AND YEAR(release_date) IS NOT NULL
		AND YEAR(release_date) > 1993
		AND YEAR(release_date) < 2020
GROUP BY YEAR(release_date),
		 MONTH(release_date)
HAVING  SUM(total_sales) IS NOT NULL

-- Which developers have released only one game, and that game sold over 10 million units
SELECT  developer,
		MAX(total_sales) AS Total_Sales_Per_Devloper
FROM games_db 
WHERE developer IS NOT NULL 
	  --AND id < 64000
GROUP BY developer
HAVING  COUNT(developer) = 1
		AND MAX(total_sales) > 0.8
ORDER BY Total_Sales_Per_Devloper

 
-- For each genre, calculate the average critic score difference between Sony and Microsoft consoles
;WITH Sony_VS_Microsoft AS(
	SELECT  genre,
			console,
			critic_score,
			CASE
				WHEN console LIKE 'X%' THEN 'Microsoft Consoles'
				WHEN console LIKE 'PS%' THEN 'Sony Consoles'
				ELSE 'Other Consoles'
			END AS Console_Type
	FROM games_db
	WHERE critic_score IS NOT NULL
)

SELECT  genre,
		--Console_Type,
		--AVG(critic_score) AS Average_Critic_Score
		AVG(CASE WHEN Console_Type = 'Sony Consoles' THEN critic_score END) Average_Critic_Score_Sony,
		AVG(CASE WHEN Console_Type = 'Microsoft Consoles' THEN critic_score END) Average_Critic_Score_Microsoft
FROM Sony_VS_Microsoft
WHERE Console_Type IN ('Microsoft Consoles' , 'Sony Consoles')
GROUP BY --Console_Type,
		 genre	
ORDER BY genre

-- For each genre, calculate the average total sales difference between Sony and Microsoft consoles
;WITH Console_Type_Mic_Sony AS (
	SELECT  console,
			genre,
			total_sales,
			CASE 
				WHEN console LIKE 'X%' THEN 'Microsoft Console'
				WHEN console LIKE 'PS%' THEN 'Sony Console'
				ELSE 'Other Console'
			END AS Console_Type
	FROM games_db
	WHERE total_sales IS NOT NULL
)
SELECT  genre,
		ROUND(SUM(CASE WHEN Console_Type = 'Microsoft Console' THEN total_sales END), 2) AS Total_Sales_Microsoft,
		ROUND(SUM(CASE WHEN Console_Type = 'Sony Console' THEN total_sales END), 2) AS Total_Sales_Sony,
		ABS(ROUND(SUM(CASE WHEN Console_Type = 'Microsoft Console' THEN total_sales END), 2) -
		ROUND(SUM(CASE WHEN Console_Type = 'Sony Console' THEN total_sales END), 2)) AS Sales_Difference
FROM Console_Type_Mic_Sony
GROUP BY genre
HAVING SUM(CASE WHEN Console_Type = 'Microsoft Console' THEN total_sales END) IS NOT NULL		
	   AND SUM(CASE WHEN Console_Type = 'Sony Console' THEN total_sales END) IS NOT NULL

-- What is the cumulative average critic score across all games ordered by release date
SELECT  title,
		console,
		critic_score,
		release_date,
		ROUND(AVG(critic_score) OVER(ORDER BY release_date), 2) AS Cumulative_critic_score
FROM games_db
WHERE  critic_score IS NOT NULL
	   AND release_date IS NOT NULL

-- Identify months where the number of game releases exceeded 150% of the monthly average
;WITH Total_Games_Per_Month AS(
	SELECT YEAR(release_date) AS Release_Year,
		   MONTH(release_date) AS Release_Month, 
		   COUNT(*) AS Number_Of_Games,
		   AVG(COUNT(*)) OVER() AS Average_Per_Month
	FROM games_db
	WHERE release_date IS NOT NULL
	GROUP BY YEAR(release_date),
			 MONTH(release_date)
	
)
SELECT  Release_Year,
		Release_Month,
		Number_Of_Games
FROM Total_Games_Per_Month
WHERE Number_Of_Games  > Average_Per_Month * 1.5
ORDER BY Release_Year,
		 Release_Month