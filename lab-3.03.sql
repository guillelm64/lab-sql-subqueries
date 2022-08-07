 USE sakila;
 -- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
 SELECT title, count(inventory_id) FROM inventory as i
 JOIN film AS f
 ON i.film_id = f.film_id
 WHERE title = 'HUNCHBACK IMPOSSIBLE'
 GROUP BY title;
 
-- 2. List all films whose length is longer than the average of all the films.
SELECT title, length FROM film
WHERE length > ( SELECT AVG(length) FROM film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

    SELECT first_name, last_name FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor
					WHERE film_id = (SELECT film_id from film 
										WHERE title = 'ALONE TRIP'
								)
			);
            
/* 4. Sales have been lagging among young families, and you wish to target all 
family movies for a promotion. Identify all movies categorized as family films.
*/

SELECT f.title, f.film_id, c.name FROM category AS c
JOIN film_category AS fc
ON c.category_id = fc.category_id
JOIN film AS f
ON f.film_id = fc.film_id
WHERE name = 'FAMILY'
GROUP BY f.title
ORDER BY f.film_id ASC;

/*
 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join,
 you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information
 */
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (	
    SELECT address_id FROM address
      WHERE city_id IN (
        SELECT city_id FROM city
			WHERE country_id = (SELECT country_id FROM country 
						WHERE country = 'CANADA'
			)
        )
	);
    
SELECT first_name, last_name, email FROM customer AS c
JOIN address as a
ON c.address_id = a.address_id
JOIN city AS ct
ON ct.city_id = a.city_id
JOIN country as cy 
ON cy.country_id = ct.country_id
WHERE country = 'CANADA';

/* 6. Which are films starred by the most prolific actor? 
Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred. 
*/

SELECT title FROM film 
	WHERE film_id IN (
	SELECT film_id FROM film_actor
	 WHERE actor_id IN ( 
		SELECT actor_id,  count(actor_id) AS appearances FROM film_actor
		 GROUP BY actor_id
		 ORDER BY appearances DESC
		 LIMIT 1
		 )
	)
    ;
   -- el limit me da error, pero no encuentro otra forma de hacerlo
 /*
 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer 
 ie the customer that has made the largest sum of payments
 */
		
    
SELECT title, first_name, sum(amount) FROM film
 WHERE film_id IN (  
    SELECT film_id FROM inventory 
     WHERE inventory_id IN (
        SELECT inventory_id FROM rental 
         WHERE customer_id IN (  SELECT distinct customer_id, sum(amount) AS amount FROM payment
							GROUP BY customer_id
							ORDER BY amount DESC
                            LIMIT 1
				) 
			)
		);

/*Limit me sigue dando error, abajo lo saco con joins en dos pasos*/
        
SELECT f.title, c.first_name, c.last_name, sum(p.amount)  AS amount, c.customer_id FROM film AS f
JOIN inventory AS i
ON f.film_id = i.film_id
JOIN rental AS r
ON r.inventory_id = i.inventory_id
JOIN customer AS c
ON c.customer_id = r.customer_id
JOIN payment AS p
ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY amount DESC
LIMIT 1;

SELECT f.title AS films_rented_by_most_profitable_customer FROM film AS f
JOIN inventory AS i
ON f.film_id = i.film_id
JOIN rental AS r
ON i.inventory_id = r.inventory_id
WHERE customer_id = 526
GROUP BY title;



 -- 8. Customers who spent more than the average payments.

SELECT first_name, last_name FROM customer
WHERE customer_id IN ( SELECT customer_id FROM payment
						GROUP BY customer_id 
                        HAVING avg(amount) > (SELECT AVG(amount) FROM payment)
                        );
						 

 