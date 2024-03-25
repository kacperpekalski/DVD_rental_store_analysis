-- Task 1 Part 1
 

-- 1. All animation movies released between 2017 and 2019 with rate more than 1, alphabetical


SELECT f.title
FROM film f 
INNER JOIN film_category fc 
ON f.film_id = fc.film_id 
INNER JOIN category c 
ON fc.category_id = c.category_id 
WHERE UPPER(c.name) = UPPER('Animation') 
	AND f.release_year BETWEEN 2017 AND 2019
	AND f.rental_rate > 1
ORDER BY f.title ASC;

-- 2. The revenue earned by each rental store after March 2017 (columns: address and address2 – as one column, revenue)

SELECT CONCAT(a.address , ' ', a.address2) AS address, SUM(p.amount) AS revenue
FROM rental r 
INNER JOIN payment p 
ON r.rental_id = p.rental_id 
INNER JOIN inventory i 
ON r.inventory_id = i.inventory_id 
INNER JOIN store s 
ON i.store_id = s.store_id 
INNER JOIN address a 
ON s.address_id = a.address_id
WHERE p.payment_date >= '2017-04-01'
GROUP BY s.store_id, CONCAT(a.address , ' ', a.address2);


-- 3. Top-5 actors by number of movies (released after 2015) they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)

SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS number_of_movies
FROM film_actor fa 
INNER JOIN film f 
ON fa.film_id = f.film_id 
INNER JOIN actor a 
ON fa.actor_id = a.actor_id 
WHERE f.release_year > 2015
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY COUNT(fa.film_id) DESC, a.first_name ASC, a.last_name ASC
LIMIT 5;


/* 4. 
 	Number of Drama, Travel, Documentary per year (columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), 
	sorted by release year in descending order. Dealing with NULL values is encouraged)
*/

SELECT f.release_year,
    COUNT(CASE WHEN UPPER(c.name) = UPPER('Drama') THEN 1 END) AS number_of_drama_movies,
    COUNT(CASE WHEN UPPER(c.name) = UPPER('Travel') THEN 1 END) AS number_of_travel_movies,
    COUNT(CASE WHEN UPPER(c.name) = UPPER('Documentary') THEN 1 END) AS number_of_documentary_movies
FROM film f 
INNER JOIN film_category fc 
ON f.film_id = fc.film_id 
INNER JOIN category c 
ON fc.category_id = c.category_id 
GROUP BY f.release_year
ORDER BY f.release_year DESC;


-- Task 1 Part 2

/*  1. 
	Who were the top revenue-generating staff members in 2017? They should be rewarded with a bonus for their performance. 
	Please indicate which store the employee worked in. If he changed stores during 2017, indicate the last one
*/

SELECT s.staff_id, s.first_name, s.last_name, s.store_id, SUM(p.amount) AS revenue_generating
FROM rental r 
INNER JOIN payment p 
ON r.rental_id  = p.rental_id 
INNER JOIN 
	(SELECT s2.staff_id, MAX(s2.last_update) AS last_update
	FROM staff s2
	GROUP BY s2.staff_id) AS latest_staff
ON r.staff_id = latest_staff.staff_id
INNER JOIN staff s 
ON r.staff_id = s.staff_id AND s.last_update = latest_staff.last_update
WHERE date_part('YEAR', p.payment_date) = 2017
GROUP BY s.staff_id, s.first_name, s.last_name, s.store_id
ORDER BY revenue_generating DESC
LIMIT 5;


/* 2.
	Which 5 movies were rented more than others, and what's the expected age of the audience for these movies? 
	To determine expected age please use 'Motion Picture Association film rating system'
*/

SELECT f.title, COUNT(r.rental_id) AS rental_count,
	CASE 
		WHEN f.rating = 'G' THEN 'Children'
	    WHEN f.rating = 'PG' THEN 'Children (with parental guidance)'
	    WHEN f.rating = 'PG-13' THEN 'Teenagers'
	    WHEN f.rating = 'R' THEN 'Adults (under 17 requires accompanying parent or adult guardian)'
	    WHEN f.rating = 'NC-17' THEN 'Adults only (no one 17 and under admitted)'
	    ELSE 'Unknown'
	END AS expected_age_range
FROM rental r 
INNER JOIN inventory i 
ON r.inventory_id  = i.inventory_id 
INNER JOIN film f 
ON i.film_id = f.film_id 
GROUP BY f.film_id, f.title
ORDER BY rental_count DESC, f.title ASC
LIMIT 5;


-- Task 1 Part 3


/*
	Which actors/actresses didn't act for a longer period of time than the others? 
	
	The task can be interpreted in various ways, and here are a few options:
		V1: gap between the latest release_year and current year per each actor;
		V2: gaps between sequential films per each actor;
		V3: gap between the release of their first and last film
*/

-- V1

SELECT a.actor_id, a.first_name, a.last_name, EXTRACT(YEAR FROM CURRENT_DATE) - MAX(f.release_year) AS gap_years
FROM film_actor fa 
INNER JOIN film f 
ON fa.film_id = f.film_id 
INNER JOIN actor a 
ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY gap_years DESC, a.first_name ASC, a.last_name ASC
LIMIT 5;


-- V2
   
SELECT actor_id, first_name, last_name, MAX(current_release_year - previous_release_year) AS gap_years
FROM
(
	SELECT 
	    fa.actor_id,
	    a.first_name,
	    a.last_name,
	    f.film_id,
	    f.release_year AS current_release_year,
	    MAX(f2.release_year) AS previous_release_year
	FROM 
	    film_actor fa
	INNER JOIN 
	    film f ON fa.film_id = f.film_id
	INNER JOIN actor a ON fa.actor_id = a.actor_id
	JOIN 
	    film_actor fa2 ON fa.actor_id = fa2.actor_id
	INNER JOIN 
	    film f2 ON fa2.film_id = f2.film_id AND f.release_year > f2.release_year
	GROUP BY 
	    fa.actor_id, a.first_name, a.last_name, f.film_id, f.release_year
	ORDER BY current_release_year DESC, f.film_id DESC
) AS subquery
GROUP BY actor_id, first_name, last_name
ORDER BY gap_years DESC, first_name, last_name
LIMIT 5;


 -- V3
   
 SELECT fa.actor_id, a.first_name, last_name, MAX(f.release_year) - MIN(f2.release_year) AS gap_years
 FROM film_actor fa
 INNER JOIN actor a 
 ON fa.actor_id = a.actor_id 
 INNER JOIN film f 
 ON fa.film_id = f.film_id 
 JOIN film_actor fa2 
 ON fa.actor_id = fa2.actor_id
 INNER JOIN film f2 
 ON fa2.film_id = f2.film_id
 GROUP BY fa.actor_id, a.first_name , a.last_name
 ORDER BY gap_years DESC, a.first_name ASC, a.last_name ASC
 LIMIT 5;
 