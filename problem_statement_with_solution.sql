/* The database consists of 11 tables, that contain information of an online  
music store.The tables include employees' table, customers' table,and other 
tables containing information like invoice details, track details,artist 
detail, etc.All the tables are well connected with their primary and foreign 
keys.The problem statements with their solutions are given below: */

/* Q1: Who is the senior most employee of the music store? */

select employee_id,first_name,last_name,title,STR_TO_DATE(left(birthdate,10),'%d-%m-%Y')
from employee
order by 5 asc
limit 1;

/* Q2: Which country the employees belong to? */

select employee_id, country from employee;

/* Q3: Which countries have the most Invoices? */

select billing_country Country,count(*) Number_of_Invoices
from invoice
group by Country
order by Number_of_Invoices desc;

/* Q4: Which countries has most revenue, so to concentarte in which countries to advertise to improve sales.*/

select billing_country Country,sum(Total) Revenue
from invoice
group by Country
order by 2 Desc;

/*Insight: So most of the revenue comes from North America, Soth America and Europe*/

/* Q5: What are top 5 countries by number of customers?*/

select country Country,count(*) Number_of_Customers
from customer
group by Country
order by Number_of_Customers Desc
limit 5;

/* Q6: What are top 5 values of total invoice with customer details? */

select c.Customer_id, concat(c.first_name, " ", c.last_name) Name,
i.invoice_id Invoice_Id,i.total Total
from customer c join invoice i on c.customer_id = i.customer_id
order by 4 desc
limit 5; 

/* Q7: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city City, sum(total) Sum_of_Invoices
from invoice
group by City
order by Sum_of_Invoices desc
limit 1;

/* Q8: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1,2,3
ORDER BY total_spending DESC
LIMIT 1;

/* Q9: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.customer_id as ID,concat(first_name, " ", last_name) as Name,email as Email
from customer c 
     join 
     invoice i on c.customer_id = i.customer_id
     join
     invoice_line il on i.invoice_id = il.invoice_id
where track_id in      
(select track_id 
from track t join genre g on t.genre_id = g.genre_id
where g.name = 'Rock')
order by 3 asc;


/* Q10: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.name Name, count(*) as Number_of_Rock_Titles
from artist a join album al on a.artist_id = al.artist_id
              join track t on al.album_id = t.album_id
              join genre g on t.genre_id = g.genre_id
where g.name='Rock'
group by 1
order by 2 desc
limit 10;              

/* Q11: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT track.name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

/* Q12: Find how much amount spent by each customer on artists? Write a query
 to return customer name, artist name and total spent */

select Customer_Name,name as Artist_Name,sum(track_cost) as Total
from
(select * from
(select c.customer_id,concat(first_name," ",last_name) as Customer_Name,il.track_id,
	   unit_price*quantity as track_cost
from customer c
     join
     invoice i on c.customer_id = i.customer_id
     join
     invoice_line il on i.invoice_id = il.invoice_id) as tb1
     join
(select t.track_id as tr_id, ar.name
		from track t 
			 join
             album al on t.album_id = al.album_id
             join
             artist ar on al.artist_id = ar.artist_id) as tb2
on tb1.track_id = tb2.tr_id) as tb3          
group by 1,2;             

/* Q13: We want to find out the most popular music Genre for each country. We determine 
the most popular genre as the genre with the highest amount of purchases. What genre we 
should concentate on to improve sales? */


with cte1 as
(select i.billing_country as Country,
        sum(il.unit_price * il.quantity) as songs_cost,
        g.name as Genre
 from invoice i
      join
      invoice_line il on i.invoice_id = il.invoice_id
      join
      track t on il.track_id = t.track_id
      join
      genre g on t.genre_id = g.genre_id
      group by 1,3
      order by 1 asc,2 Desc),
cte2 as
(select Country,Genre,songs_cost,
        rank() over(partition by Country order by songs_cost desc) as rnk
 from cte1
 order by 1 asc,3 desc)
 select Country, Genre
 from cte2
 where rnk=1;
 
 /*Solution::It is evident that ROCK songs are the most popular genre. To increase the sale, more ROCK category songs should be promoted through
           advertisement. */
 
 
 
 


/* Q14: Write a query that determines the customer that has spent the most on music for
each country. Write a query that returns the country along with the top customer and how 
much they spent. */

with cte1 as
(select i.billing_country as Country,
		concat(first_name," ",last_name) as Customer_Name,
        sum(i.total) as Total_Purchase
        from customer c
             join
             invoice i on c.customer_id = i.customer_id
group by 1,2
order by Country asc, Total_Purchase desc)
select Country, Customer_Name,Total_Purchase
from
(select Country,
        Customer_Name,
        Total_Purchase,
	    rank() over(partition by Country order by Total_Purchase desc) as rnk
from cte1) as tb
where rnk=1
