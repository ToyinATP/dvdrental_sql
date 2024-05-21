SElECT *
FROM customer;

SELECT * 
FROM rental;

SELECT *
FROM payment;

SELECT *
FROM film;

SELECT *
FROM inventory;

SELECT *
FROM category;

SELECT * 
FROM film_category;

SELECT *
FROM store;

-- to identify the top 10 customers that rented the most movies--

SELECT 	rp.customer_id,
		rc.first_name,
		rc.last_name,
	   	COUNT(DISTINCT rr.rental_id) AS rent_number,
		SUM(rp.amount) AS total_spent
FROM payment AS rp
LEFT JOIN	customer AS rc
	ON	rp.customer_id = rc.customer_id
LEFT JOIN	rental AS rr
	ON	rc.customer_id = rr.customer_id
GROUP BY 	rp.customer_id, rc.first_name, rc.last_name
ORDER BY 	total_spent DESC LIMIT 10;


---To know the to top 5 most rented movies--

SELECT 	f.film_id,
		f.title,
		COUNT (DISTINCT rr.rental_id) AS rents
FROM film AS f
LEFT JOIN	inventory AS i
	ON	f.film_id = i.film_id
INNER JOIN	rental AS rr
	ON	rr.inventory_id = i.inventory_id
GROUP BY 	f.film_id, f.title
ORDER BY 	rents DESC LIMIT 5;

-- to determine the average number of rentals per customer--

SELECT 	rc.customer_id,
		rc.first_name,
		rc.last_name,
		COUNT(DISTINCT rr.rental_id) AS total_rental,
		AVG(COUNT (DISTINCT rr.rental_id)) OVER () AS Average_rent
FROM	customer AS rc
LEFT JOIN	rental AS rr
	ON	rc.customer_id = rr.customer_id
GROUP BY	rc.customer_id, rc.first_name, rc.last_name 
ORDER BY 	total_rental DESC;

--Analyse the most popular movie genre among customers--
SELECT	cat.name,
		cat.category_id,
		COUNT(DISTINCT rr.rental_id) AS total_rent
FROM	category AS cat
LEFT JOIN film_category AS fcat
	ON	cat.category_id = fcat.category_id
LEFT JOIN	film AS f
	ON	fcat.film_id = f.film_id
LEFT JOIN	inventory AS i
	ON	f.film_id = i.film_id
LEFT JOIN	rental AS rr
	ON	i.inventory_id = rr.inventory_id
LEFT JOIN	customer AS cust
	ON	rr.customer_id = cust.customer_id
GROUP BY cat.category_id,cat.name
ORDER BY	total_rent DESC LIMIT 1;

/* Identify the days and times when the stores experiences 
the highest and lowest rental activity*/

SELECT *
FROM staff;
SELECT 	rental.staff_id,
		rental.rental_date,
		COUNT(rental.rental_id) AS rent_count
FROM	rental
WHERE	rental.staff_id IN (1,2)
GROUP BY	rental.staff_id, rental.rental_date
ORDER BY	rental.rental_date DESC LIMIT 4;


/* Identify customers with a history of frequently returning
movies late*/

SELECT	customer_id,
		rental_date,
		return_date,
		DATE_PART('day',AGE(rental.return_date, rental.rental_date)) AS rental_period
FROM	rental
ORDER BY	rental_period DESC;

/* determine the number of customers who have been with the store 
for more than a year and analyse their rental behaviour*/


SELECT
    ct.customer_id,
    ct.first_name,
    ct.last_name,
	COUNT(DISTINCT rr.rental_id) AS rental_frequency,
    DATE_PART('year', AGE(ct.last_update, ct.create_date)) AS loyalty_years
FROM customer AS ct
LEFT JOIN	rental AS rr
	ON	ct.customer_id = rr.customer_id
WHERE activebool = true 
GROUP BY ct.customer_id, ct.first_name, ct.last_name
ORDER BY rental_frequency DESC;