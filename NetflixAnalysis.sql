--Q.1 Count the number of Movies Vs Tv Shows.
select 
	type,
	count(*) as total_content
from 
	netflix_tb
group by type;

--Q.2 Find the most common rating for movies and Tv Shows.
WITH CTE as (
			SELECT 
				type,
				rating,
				COUNT(*),
				ROW_NUMBER() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as rnk
			FROM 
				netflix_tb
			GROUP By 1,2
			)
SELECT 
	type,
	rating,
	count
FROM 
	CTE
WHERE rnk=1;

--Q.3 List all movies released in a specific year(e.g.2020)
select 
	*
from 
	netflix_tb
where
	type='Movie' 
	and
	release_year=2020;
	
--Q.4 Find the top 5 countries with the most content on Netflix
SELECT 
	country,
	count
FROM
	(SELECT 
		UNNEST (STRING_TO_ARRAY(country,',')) as country,
		count(*),
		ROW_NUMBER() OVER( ORDER BY COUNT(*)DESC) as rnk
	FROM 
		netflix_tb
	GROUP BY 1)
WHERE rnk<=5;

--Q.5 Identify the longest movies.
WITH CTE as (
		SELECT 
			type,
			title,
			max(CAST(REPLACE(duration,'min','') as INTEGER)) as max_duration,
			RANK()OVER(ORDER BY max(CAST(REPLACE(duration,'min','') as INTEGER)) DESC) as rk
		FROM netflix_tb
		WHERE type='Movie'
		and duration is not null
		GROUP BY 1,2
		)
SELECT 
	*
FROM CTE
WHERE rk=1;

--Q.6 Find content added in the last 5 year.
SELECT 
	*
FROM netflix_tb
WHERE TO_DATE(date_added,'Month,dd,yyyy')>=CURRENT_DATE - INTERVAL '5 YEARS';

--Q.7 Find all the movies/tv Shows by director 'Rajiv chilaka'.
SELECT
	*
FROM
	netflix_tb
WHERE LOWER(director) LIKE '%rajiv chilaka%';

--Q.8 List All Tv Shows with more than 5 Seansons.
Select 
	*
from 
	netflix_tb
where 
	duration ilike '%season%'
	and
	type='TV Show'
	and 
	substring(duration,1,1):: numeric>5;

--Q.9 Count the number of content items in each genre.
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(*)as total_content
FROM 
	netflix_tb
GROUP BY
	UNNEST(STRING_TO_ARRAY(listed_in,','));
	
--Q.10 Find each year and average numbers of contents realease in India on netflix.
--Return top 5 year with highest avg content release?
SELECT
	EXTRACT(YEAR FROM(TO_DATE(date_added,'Month DD,yyyy')))as Year, 
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_tb WHERE country='India'),2)as avg_Content
FROM
	netflix_tb,
	UNNEST(STRING_TO_ARRAY(country,',')) as Country_Name
WHERE TRIM(Country_Name)='India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Q.11 List all the movies that are documentries.
SELECT
	* 
FROM
	netflix_tb
WHERE type='Movie'
	and listed_in like '%Documentaries%';
--Q.12 Find all content without a director.
SELECT
	*
FROM
	netflix_tb
WHERE 
	director is null;
--Q.13 Find how many movies actor 'Salman Khan' appeared in last 10 Year?
SELECT
	*
FROM
	netflix_tb
WHERE 
	casts ilike'%Salman Khan%'
	and TO_DATE(date_added,'Month DD,YYYY')>=Current_Date -Interval '10 Year';
--Q.14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
With CTE as
	(
	SELECT
		UNNEST(STRING_TO_ARRAY(casts,',')) as New_Casts,
		COUNT(show_id),
		ROW_NUMBER()OVER(ORDER BY COUNT(*)DESC) as row
	FROM
		netflix_tb
	WHERE 
		country ILIKE '%India'
		AND type='Movie'
	GROUP BY 1
	)
SELECT
	new_casts,
	count
FROM
	CTE
WHERE row<=10;
--Q.15 Categories the content based on the presence of the keywords 'kill' and 'violence' in the 
--description field.Lable content containing these keyword as 'Bad' and all other content as 'Good'
--Count how many items fall into each category.
WITH CTE as
(
	SELECT
		*,
		CASE
			WHEN description ILIKE '%kill%' OR
				 description ILIKE '%violence%'
			THEN
				'Bad'
			ELSE 'Good'
		END AS Lable
	
	FROM
		netflix_tb
		)
SELECT
	lable,
	COUNT(*) as Total_Count
FROM
	CTE
GROUP BY 1;


