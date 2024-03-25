/*
	Top-3 most selling movie categories of all time and total dvd rental income for each category. Only consider dvd rental customers from the USA.
*/


SELECT ct.name, SUM(p.amount)
FROM rental r
INNER JOIN payment p 
ON r.rental_id = p.rental_id
INNER JOIN customer c
ON r.customer_id = c.customer_id
INNER JOIN address a 
ON c.address_id = a.address_id 
INNER JOIN city ci
ON a.city_id = ci.city_id 
INNER JOIN country co
ON ci.country_id = co.country_id 
INNER JOIN inventory i 
ON r.inventory_id = i.inventory_id 
INNER JOIN film f 
ON i.film_id = f.film_id 
INNER JOIN film_category fc 
ON f.film_id = fc.film_id 
INNER JOIN category ct
ON fc.category_id = ct.category_id 
WHERE UPPER(co.country) = UPPER('United States')
GROUP BY ct.name 
ORDER BY SUM(p.amount) DESC
LIMIT 3;

/*
	For each client, display a list of horrors that he had ever rented (in one column, separated by commas), and the amount of money that he paid for it
*/


SELECT c.customer_id, c.first_name, c.last_name, STRING_AGG(DISTINCT f.title, ', '), SUM(pa.amount) 
FROM rental r
INNER JOIN payment pa
ON r.rental_id = pa.rental_id 
INNER JOIN customer c 
ON r.customer_id = c.customer_id 
INNER JOIN inventory i 
ON r.inventory_id = i.inventory_id 
INNER JOIN film f 
ON i.film_id = f.film_id 
INNER JOIN film_category fc 
ON f.film_id = fc.film_id 
INNER JOIN category ct
ON fc.category_id = ct.category_id
WHERE UPPER(ct.name) = 'HORROR'
GROUP BY c.customer_id, c.first_name, c.last_name 