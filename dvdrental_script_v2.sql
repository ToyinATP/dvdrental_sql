SELECT * 
FROM FILM;

SELECT *
FROM rental
order by rental.inventory_id;

SELECT	COUNT(rental.customer_id)
FROM	rental
WHERE	rental.customer_id = 459;


SELECT *
FROM customer;


-- This script shows the top 3 films by rental_rate--
SELECT film_id,
       title,
       rental_rate,
       RANK() OVER (PARTITION BY title ORDER BY rental_rate DESC) AS rank
FROM film
ORDER BY rental_rate DESC
LIMIT 3;



-- RANKING OF THE TOP 5 CUSTOMERS BY TOTAL RENT AMOUNT--
SELECT p.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_fullname,
       SUM(p.amount) AS total_amount,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) AS rank
FROM payment AS p
LEFT JOIN customer AS c 
	ON p.customer_id = c.customer_id
GROUP BY p.customer_id, customer_fullname
LIMIT 5;



-- RANK OF ACTORS BASED ON APPEARANCES--
SELECT 	f.actor_id,
		CONCAT(a.first_name, ' ', a.last_name) AS actor_fullname,
		COUNT(f.film_id) AS total_appearances,
		RANK () OVER(ORDER BY COUNT(f.film_id) DESC) AS rank
FROM film_actor AS f
LEFT JOIN actor AS a
	ON	f.actor_id = a.actor_id
GROUP BY f.actor_id,actor_fullname
ORDER BY total_appearances DESC;




-- DENSE RANK OF FILM_CATEGORIES--
SELECT 	f.category_id,
		cat.name,
		COUNT (f.film_id) AS genre_inventory,
		DENSE_RANK () OVER(ORDER BY COUNT(f.film_id) DESC) AS rank
FROM	film_category AS f
LEFT JOIN	category as cat
	ON	f.category_id = cat.category_id
GROUP BY	f.category_id,cat.name
ORDER BY	genre_inventory DESC;



--DENSE RANK OF CUSTOMERS BASED ON THEIR NUMBER OF FILMS RENTED--
WITH table1 AS (SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_fullname,
       COUNT(r.rental_id) AS total_movies,
       DENSE_RANK() OVER(ORDER BY COUNT(r.rental_id) DESC) AS rank
FROM	customer AS c
LEFT JOIN rental AS r 
	ON 	c.customer_id = r.customer_id
GROUP BY c.customer_id,customer_fullname)
SELECT *
FROM	table1
WHERE rank <=5;


-- Rank films based on their release years within each category using DENSE_RANK().
SELECT 	fcat.category_id,
		f.title,
		cat.name,
		f.release_year,
		RANK () OVER (PARTITION BY cat.name ORDER BY f.release_year DESC)
FROM	film as f
LEFT JOIN	film_category AS  fcat
	ON	f.film_id = fcat.film_id
LEFT JOIN	category AS cat
	ON	fcat.category_id = cat.category_id
GROUP BY f.title,fcat.category_id,cat.name,f.release_year;



--7 Assign a unique number to each rental of each customer, from oldest rentage to newest. Show this information for our customers called “Aaron Selby” and “Mary Smith”.
WITH table1 AS 
				(SELECT r.rental_id,
    					CONCAT(c.first_name, ' ', c.last_name) AS customer_fullname,
    					ROW_NUMBER() OVER (PARTITION BY ((c.first_name, ' ', c.last_name)) ORDER BY r.rental_date ASC) AS unique_number
				FROM	rental AS r
				LEFT JOIN customer AS c
				ON	r.customer_id = c.customer_id)
SELECT * 
FROM table1 
WHERE	customer_fullname IN ('Aaron Selby','Mary Smith')
ORDER BY	customer_fullname, unique_number;




--8 Retrieve the top 5 most rented films and include a column indicating the rental_id in which they were rented.
WITH table1 AS (
				SELECT	r.rental_id,
						f.film_id,
						f.title,
				COUNT (r.rental_date) AS total_rent,
				DENSE_RANK () OVER (ORDER BY (COUNT (r.rental_date)) DESC) AS film_rank
				FROM	rental AS r
				LEFT JOIN	inventory AS i
					ON	r.inventory_id = i.inventory_id
				LEFT JOIN	film AS f
					ON	i.film_id = f.film_id
				GROUP BY	r.rental_id,f.film_id,f.title)
SELECT *
FROM table1
WHERE film_rank <= 5;


SELECT i.inventory_id,
       f.film_id,
       f.title,
       COUNT(r.rental_date) AS total_rent,
       DENSE_RANK() OVER (ORDER BY COUNT(r.rental_date) DESC) AS film_rank
FROM rental AS r
LEFT JOIN inventory AS i 
	ON r.inventory_id = i.inventory_id
LEFT JOIN film AS f 
	ON i.film_id = f.film_id
GROUP BY i.inventory_id, f.film_id, f.title;


--9 Find the three most active customers by the number of rentals, assigning a sequential number to each using ROW_NUMBER().
WITH table1 AS (SELECT	c.customer_id,
		CONCAT(c.first_name, ' ',c.last_name) AS full_name,
		COUNT (r.customer_id) AS rent_number,
		DENSE_RANK () OVER (ORDER BY COUNT(r.customer_id) DESC) AS rank,
		ROW_NUMBER () OVER (ORDER BY COUNT(r.customer_id) DESC) AS sequence_number
FROM	customer AS c
LEFT JOIN	rental AS r
	ON	c.customer_id = r.customer_id
GROUP BY	c.customer_id )
SELECT *
FROM table1
WHERE rank <= 3;


--11 Calculate the average rental rate for each film, considering a window that includes the two preceding and two following films based on their rental rate.
SELECT AVG(rental_rate) OVER (ORDER BY film_id DESC
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) AS avg_rental_rate
FROM	FILM;


