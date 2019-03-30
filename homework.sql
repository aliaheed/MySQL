-- 1a. Display the first and last names of all actors from the table actor. --
select first_name, last_name 
from sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name,' ',last_name)) as actor_name 
from sakila.actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id , first_name , last_name 
from sakila.actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select * 
from sakila.actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * 
from sakila.actor
where last_name like '%LI%'
order by last_name , first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id , country 
from sakila.country
where country in ('Afghanistan','Bangladesh','China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). --
ALTER TABLE sakila.actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column. --
ALTER TABLE sakila.actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.--
select last_name , count(*) num_of_actors
from sakila.actor
group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors--
select last_name , count(*) num_of_actors
from sakila.actor
group by last_name
having count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record. --
update sakila.actor
set first_name = 'HARPO'
where first_name = 'Groucho' and last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. --
update sakila.actor
set first_name = 'GROUCHO'
where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select a.first_name , a.last_name , b.address
from sakila.staff A
	left join sakila.address B
	on a.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select a.first_name , a.last_name , sum(b.amount) total_amount
from sakila.staff a
	left join sakila.payment b
    on a.staff_id = b.staff_id
where year(b.payment_date) = 2005 and month(b.payment_date) = 8
group by 1,2;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select a.title , count(b.actor_id) 
from sakila.film A
	inner join sakila.film_actor B
    on a.film_id = b.film_id
group by a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select a.title ,  count(b.inventory_id) num_of_copies
from sakila.film A
	inner join sakila.inventory B
    on a.film_id = b.film_id
where a.title = 'Hunchback Impossible'
group by 1;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select a.first_name , a.last_name , sum(b.amount) total_paid
from sakila.customer A
	inner join sakila.payment B
    on a.customer_id = b.customer_id
group by 1,2
order by 2;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select a.title 
from (select * from sakila.film where title like 'q%' or title like 'k%') A
	inner join (select * from sakila.language where name = 'English') B
    on a.language_id = b.language_id
order by 1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select c.first_name , c.last_name
from (select * from sakila.film where title = 'Alone Trip') A
	inner join sakila.film_actor B
    on a.film_id = b.film_id
    
    inner join sakila.actor C
    on b.actor_id = c.actor_id
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select a.first_name , a.last_name , a.email , d.country
from sakila.customer A
	
    inner join sakila.address B
    on a.address_id = b.address_id
    
    inner join sakila.city C
    on b.city_id = c.city_id
	
    inner join (select * from sakila.country
				where country='Canada') D
    on c.country_id = d.country_id
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select a.title , c.name category
from sakila.film A
	inner join sakila.film_category B
    on a.film_id = b.film_id
    
    inner join (select * 
				from sakila.category
                where name = 'Family') C
    on b.category_id = c.category_id
;

-- 7e. Display the most frequently rented movies in descending order.
select a.title , count(c.rental_id) num_of_times_rented
from sakila.film A
	inner join sakila.inventory B
    on a.film_id = b.film_id
    
    inner join sakila.rental C
    on b.inventory_id = c.inventory_id

group by 1
order by 2 desc; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select a.store_id , sum(c.amount) Revenue_in_dollars
from sakila.store A
	inner join sakila.staff B
    on a.store_id = b.store_id

	inner join sakila.payment C
    on b.staff_id = c.staff_id

group by 1
;

-- 7g. Write a query to display for each store its store ID, city, and country.
select a.store_id , c.city , d.country
from sakila.store A
	inner join sakila.address B
    on a.address_id = b.address_id
    
    inner join sakila.city C
    on b.city_id = c.city_id
    
    inner join sakila.country D
    on c.country_id = d.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- category, film_category, inventory, payment, and rental

select a.name , sum(e.amount) gross_revenue
from sakila.category A
	inner join sakila.film_category B
    on a.category_id = b.category_id
    
    inner join sakila.inventory C
    on b.film_id = c.film_id
    
    inner join sakila.rental D
    on c.inventory_id = d.inventory_id
    
    inner join sakila.payment E
    on d.rental_id = e.rental_id
group by 1
order by 2 desc limit 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
-- by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view gross_revenue_top_5 as
select a.name , sum(e.amount) gross_revenue
from sakila.category A
	inner join sakila.film_category B
    on a.category_id = b.category_id
    
    inner join sakila.inventory C
    on b.film_id = c.film_id
    
    inner join sakila.rental D
    on c.inventory_id = d.inventory_id
    
    inner join sakila.payment E
    on d.rental_id = e.rental_id
group by 1
order by 2 desc limit 5
;

-- 8b. How would you display the view that you created in 8a?
select * from sakila.gross_revenue_top_5;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view sakila.gross_revenue_top_5;

