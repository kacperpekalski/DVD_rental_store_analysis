/*
 * Choose your top-3 favorite movies and add them to the 'film' table. Fill in rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3 weeks respectively.
 */

INSERT INTO film (title, description, language_id, rental_duration, release_year, rental_rate, length, replacement_cost, rating, fulltext)
SELECT 
    'CARS',
    'An animated adventure about cars discovering the value of friendship and competition during a thrilling racing journey full of twists and turns',
    1,
    1,
    2006,
    4.99,
    120,
    14.99,
    'G',
    to_tsvector('english', 'An animated adventure about cars discovering the value of friendship and competition during a thrilling racing journey full of twists and turns')
WHERE NOT EXISTS (SELECT 1 FROM film WHERE UPPER(title) = 'CARS' AND release_year = 2006 AND length = 120)
RETURNING film_id;

INSERT INTO film (title, description, language_id, rental_duration, release_year, rental_rate, length, replacement_cost, rating, fulltext)
SELECT 
    'CARS 2',
    'An animated adventure about cars discovering the value of friendship and competition during a thrilling racing journey full of twists and turns',
    1, 
    2, 
    2011, 
    9.99, 
    110, 
    12.99, 
    'G',
    to_tsvector('english', 'An animated adventure about cars discovering the value of friendship and competition during a thrilling racing journey full of twists and turns')
WHERE NOT EXISTS (SELECT 1 FROM film WHERE UPPER(title) = 'CARS 2' AND release_year = 2011 AND length = 110)
RETURNING film_id;

INSERT INTO film (title, description, language_id, rental_duration, release_year, rental_rate, length, replacement_cost, rating, fulltext)
SELECT 
    'CARS 3',
    'An animated adventure about cars discovering the value of friendship and competition during a thrilling racing journey full of twists and turns',
    1, 
    3, 
    2010, 
    19.99, 
    105, 
    11.99, 
    'G',
    to_tsvector('english', 'An animated adventure about cars discovering the value of friendship and competition during a thrilling racing journey full of twists and turns')
WHERE NOT EXISTS (SELECT 1 FROM film WHERE UPPER(title) = 'CARS 3' AND release_year = 2010 AND length = 105)
RETURNING film_id;


/*
 * Add the actors who play leading roles in your favorite movies to the 'actor' and 'film_actor' tables (6 or more actors in total).
 */

WITH new_actors AS (
    SELECT first_name, last_name
    FROM (VALUES 
        ('Owen', 'Wilson'),
        ('Bonnie', 'Hunt'),
        ('Paul', 'Newman'),
        ('Tony', 'Shalhoub'),
        ('John', 'Turturro'),
        ('Emily', 'Mortimer')
    ) AS actors (first_name, last_name)
)
INSERT INTO actor (first_name, last_name)
SELECT 
    na.first_name, 
    na.last_name
FROM 
    new_actors na
LEFT JOIN 
    actor a ON UPPER(a.first_name) = UPPER(na.first_name) AND UPPER(a.last_name) = UPPER(na.last_name)
WHERE 
    a.actor_id IS NULL;
	
INSERT INTO film_actor (film_id, actor_id)
SELECT f.film_id, a.actor_id
FROM (
	SELECT 'CARS 3' AS title, 2010 AS release_year, 105 AS length, 'Owen' AS first_name, 'Wilson' AS last_name
	UNION ALL
	SELECT 'CARS' AS title, 2006 AS release_year, 120 AS length, 'Owen' AS first_name, 'Wilson' AS last_name
	UNION ALL
    SELECT 'CARS 2' AS title, 2011 AS release_year, 110 AS length, 'Owen' AS first_name, 'Wilson' AS last_name
    UNION ALL
    SELECT 'CARS' AS title, 2006 AS release_year, 120 AS length, 'Bonnie' AS first_name, 'Hunt' AS last_name
    UNION ALL
    SELECT 'CARS' AS title, 2006 AS release_year, 120 AS length, 'Paul' AS first_name, 'Newman' AS last_name
    UNION ALL
    SELECT 'CARS' AS title, 2006 AS release_year, 120 AS length, 'Tony' AS first_name, 'Shalhoub' AS last_name
    UNION ALL
    SELECT 'CARS' AS title, 2006 AS release_year, 120 AS length, 'John' AS first_name, 'Turturro' AS last_name
    UNION ALL
    SELECT 'CARS 2' AS title, 2011 AS release_year, 110 AS length, 'Emily' AS first_name, 'Mortimer' AS last_name
) AS data
JOIN film f ON UPPER(data.title) = UPPER(f.title) AND data.release_year = f.release_year AND data.length = f.length
JOIN actor a ON UPPER(data.first_name) = UPPER(a.first_name) AND UPPER(data.last_name) = UPPER(a.last_name)
WHERE NOT EXISTS (
    SELECT 1 
    FROM film_actor fa2 
    WHERE fa2.film_id = f.film_id AND fa2.actor_id = a.actor_id
);

/* 
 * Add your favorite movies to any store's inventory.
 */

INSERT INTO inventory (film_id, store_id)
SELECT f.film_id, s.store_id
FROM film f
CROSS JOIN store s
WHERE f.title IN ('CARS', 'CARS 2', 'CARS 3') 
	AND s.store_id = 1
	
/* 
 * Alter any existing customer in the database with at least 43 rental and 43 payment records. 
 * Change their personal data to yours (first name, last name, address, etc.). 
 * You can use any existing address from the "address" table. 
 * Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.
 */
	
SELECT r.customer_id, COUNT(r.rental_id), COUNT(p.payment_id) 
FROM rental r
JOIN payment p
ON r.rental_id = p.rental_id 
GROUP BY r.customer_id
HAVING COUNT(r.rental_id) > 43 AND count(p.payment_id) > 43
ORDER BY COUNT(r.rental_id) DESC
LIMIT 1;

-- OUTPUT customer_id = 148

UPDATE customer 
SET first_name = 'KACPER', last_name = 'PĘKALSKI', address_id = 151, email = 'kac.pekalski1@gmail.com'
WHERE customer_id = 148


/*
 * Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
 */

DELETE FROM payment 
WHERE customer_id =     
	(SELECT customer_id 
    	FROM customer 
    	WHERE first_name = 'KACPER' 
    		AND last_name = 'PĘKALSKI' 
    		AND address_id = 151 
    		AND email = 'kac.pekalski1@gmail.com'
    	LIMIT 1);

DELETE FROM rental 
WHERE customer_id =     
	(SELECT customer_id 
    	FROM customer 
    	WHERE first_name = 'KACPER' 
    		AND last_name = 'PĘKALSKI' 
    		AND address_id = 151 
    		AND email = 'kac.pekalski1@gmail.com'
    	LIMIT 1);
    	
    
/*
 * Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)
	(Note: to insert the payment_date into the table payment, you can create a new partition 
	(see the scripts to install the training database ) or add records for thefirst half of 2017)
 */
    
    
CREATE TABLE payment_p2024_03
PARTITION OF payment
FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT
    '2024-03-02',
    (SELECT i.inventory_id 
     FROM inventory i
     JOIN film f ON i.film_id = f.film_id
     WHERE i.store_id = 1 
       AND f.title = 'CARS' 
       AND f.release_year = 2006 
       AND f.length = 120
     LIMIT 1),
    (SELECT c.customer_id 
     FROM customer c 
     WHERE c.first_name = 'KACPER' 
       AND c.last_name = 'PĘKALSKI' 
       AND c.address_id = 151 
       AND c.email = 'kac.pekalski1@gmail.com'
     LIMIT 1),
    '2024-03-09',
    (SELECT s.staff_id 
     FROM staff s 
     WHERE s.store_id = 1 
       AND s.active IS TRUE 
     LIMIT 1);

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT     
    148,
    1,
    (SELECT r.rental_id 
     FROM rental r
     WHERE r.customer_id = 148 
       AND r.rental_date = '2024-03-02' 
       AND r.return_date = '2024-03-09' 
       AND r.inventory_id = 4582 
       AND r.staff_id = 1 
     LIMIT 1),
    (SELECT 
        ROUND(((DATE_PART('day', '2024-03-09'::timestamp - '2024-03-02'::timestamp) + 1) * (f.rental_rate / (f.rental_duration*7)))::numeric, 2) AS amount
     FROM inventory i
     JOIN film f ON i.film_id = f.film_id 
     WHERE i.inventory_id = 4582 
     LIMIT 1),
     '2024-03-09'
WHERE NOT EXISTS (
    SELECT 1 
    FROM payment pp 
    WHERE pp.rental_id = (
        SELECT r.rental_id 
        FROM rental r
        WHERE r.customer_id = 148 
           AND r.rental_date = '2024-03-02' 
           AND r.return_date = '2024-03-09' 
           AND r.inventory_id = 4582 
           AND r.staff_id = 1 
        LIMIT 1
    )
);

     
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT
    '2024-03-09',
    (SELECT i.inventory_id 
     FROM inventory i
     JOIN film f ON i.film_id = f.film_id
     WHERE i.store_id = 1 
       AND f.title = 'CARS 2' 
       AND f.release_year = 2011 
       AND f.length = 110
     LIMIT 1),
    (SELECT c.customer_id 
     FROM customer c 
     WHERE c.first_name = 'KACPER' 
       AND c.last_name = 'PĘKALSKI' 
       AND c.address_id = 151 
       AND c.email = 'kac.pekalski1@gmail.com'
     LIMIT 1),
    '2024-03-15',
    (SELECT s.staff_id 
     FROM staff s 
     WHERE s.store_id = 1 
       AND s.active IS TRUE 
     LIMIT 1);

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT     
    148,
    1,
    (SELECT r.rental_id 
     FROM rental r
     WHERE r.customer_id = 148 
       AND r.rental_date = '2024-03-09' 
       AND r.return_date = '2024-03-15' 
       AND r.inventory_id = 
       		(SELECT i.inventory_id 
			     FROM inventory i
			     JOIN film f ON i.film_id = f.film_id
			     WHERE i.store_id = 1 
			       AND f.title = 'CARS 2' 
			       AND f.release_year = 2011 
			       AND f.length = 110
			     LIMIT 1) 
       AND r.staff_id = 1 
     LIMIT 1),
    (SELECT 
        ROUND(((DATE_PART('day', '2024-03-15'::timestamp - '2024-03-09'::timestamp) + 1) * (f.rental_rate / (f.rental_duration*7)))::numeric, 2) AS amount
     FROM inventory i
     JOIN film f ON i.film_id = f.film_id 
     WHERE i.inventory_id =     
     	(SELECT i.inventory_id 
		     FROM inventory i
		     JOIN film f ON i.film_id = f.film_id
		     WHERE i.store_id = 1 
		       AND f.title = 'CARS 2' 
		       AND f.release_year = 2011 
		       AND f.length = 110
		     LIMIT 1) 
     LIMIT 1),
     '2024-03-15'
WHERE NOT EXISTS (
	SELECT 1 
	FROM payment pp 
	WHERE pp.rental_id = (
		SELECT r.rental_id 
	    FROM rental r
	    WHERE r.customer_id = 148 
	       AND r.rental_date = '2024-03-09' 
	       AND r.return_date = '2024-03-15' 
	       AND r.inventory_id =      	
	       		(SELECT i.inventory_id 
				     FROM inventory i
				     JOIN film f ON i.film_id = f.film_id
				     WHERE i.store_id = 1 
				       AND f.title = 'CARS 2' 
				       AND f.release_year = 2011 
				       AND f.length = 110
				     LIMIT 1)
	       AND r.staff_id = 1 
	    LIMIT 1));
     
	   
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT
    '2024-03-15',
    (SELECT i.inventory_id 
     FROM inventory i
     JOIN film f ON i.film_id = f.film_id
     WHERE i.store_id = 1 
       AND f.title = 'CARS 3' 
       AND f.release_year = 2010 
       AND f.length = 105
     LIMIT 1),
    (SELECT c.customer_id 
     FROM customer c 
     WHERE c.first_name = 'KACPER' 
       AND c.last_name = 'PĘKALSKI' 
       AND c.address_id = 151 
       AND c.email = 'kac.pekalski1@gmail.com'
     LIMIT 1),
    '2024-03-19',
    (SELECT s.staff_id 
     FROM staff s 
     WHERE s.store_id = 1 
       AND s.active IS TRUE 
     LIMIT 1);

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT     
    148,
    1,
    (SELECT r.rental_id 
     FROM rental r
     WHERE r.customer_id = 148 
       AND r.rental_date = '2024-03-15' 
       AND r.return_date = '2024-03-19' 
       AND r.inventory_id = 
       		(SELECT i.inventory_id 
			     FROM inventory i
			     JOIN film f ON i.film_id = f.film_id
			     WHERE i.store_id = 1 
			       AND f.title = 'CARS 3' 
			       AND f.release_year = 2010 
			       AND f.length = 105
			     LIMIT 1) 
       AND r.staff_id = 1 
     LIMIT 1),
    (SELECT 
        ROUND(((DATE_PART('day', '2024-03-19'::timestamp - '2024-03-15'::timestamp) + 1) * (f.rental_rate / (f.rental_duration*7)))::numeric, 2) AS amount
     FROM inventory i
     JOIN film f ON i.film_id = f.film_id 
     WHERE i.inventory_id =     
     	(SELECT i.inventory_id 
		     FROM inventory i
		     JOIN film f ON i.film_id = f.film_id
		     WHERE i.store_id = 1 
		       AND f.title = 'CARS 3' 
		       AND f.release_year = 2010 
		       AND f.length = 105
		     LIMIT 1) 
     LIMIT 1),
     '2024-03-19'
WHERE NOT EXISTS (
	SELECT 1 
	FROM payment pp 
	WHERE pp.rental_id = (
		SELECT r.rental_id 
	    FROM rental r
	    WHERE r.customer_id = 148 
	       AND r.rental_date = '2024-03-15' 
	       AND r.return_date = '2024-03-19' 
	       AND r.inventory_id =      	
	       		(SELECT i.inventory_id 
				     FROM inventory i
				     JOIN film f ON i.film_id = f.film_id
				     WHERE i.store_id = 1 
				       AND f.title = 'CARS 3' 
				       AND f.release_year = 2010 
				       AND f.length = 105
				     LIMIT 1)
	       AND r.staff_id = 1 
	    LIMIT 1));

	