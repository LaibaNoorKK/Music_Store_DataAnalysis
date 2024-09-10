--Q1: Who is the senior most employee in the job title?

select * from employee 
order by levels desc 
limit 1

--Q2: Which countires have the most invoices?

select Count(*), billing_country from invoice
group by billing_country
order by count desc

--Q3: What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

--Q4: Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both city name and sum of all invoice totals.

select sum(total), billing_city from invoice
group by billing_city
order by sum desc

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.

select * from customer
select invoice.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as highest_invoice 
from invoice
JOIN customer on invoice.customer_id = customer.customer_id
group by invoice.customer_id , customer.first_name , customer.last_name
order by highest_invoice desc
limit 1

--Q6: Write query to return the email, first name , last name and Genre of all Rock music listeners. 
--Return your list ordered alphabetically by email starting with A

select distinct email , first_name , last_name 
from customer as cus
join invoice as inc on cus.customer_id = inc.customer_id
join invoice_Line as il on inc.invoice_id = il.invoice_id
where track_id in(
	select track_id from track as tr
	join genre as ge on tr.genre_id = ge.genre_id
	where ge.name like 'Rock'
)
order by email

--Q7: Lets invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

select artist.name , count(track.track_id) as Total_count from artist
join album on album.artist_id = artist.artist_id
join track on track.album_id = album.album_id
where genre_id in (
	select track.genre_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
group by artist.name
order by Total_count desc
limit 10

--Q8: Return all the track names that have a song length longer than average song length.
--Return the name and milliseconds for each track. Order by the song length with the longest songs listed first.

select name , milliseconds from track
where milliseconds > (
	select avg(milliseconds) as av from track
)
order by milliseconds desc


--Q9: Find how much amount paid by each customer on artists? 
--Write a query to return customer name, artist name , total spent.

WITH best_artist as(
	select artist.artist_id , artist.name as artist_name , sum(il.unit_price*il.quantity) 
	from invoice_line as il
	join track on track.track_id = il.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)

select cu.first_name as Customer_Name, ba.artist_name, sum(il.unit_price*il.quantity) as total_amount 
from customer as cu
join invoice as i on i.customer_id = cu.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track on track.track_id = il.track_id
join album on album.album_id = track.album_id
join best_artist ba on ba.artist_id = album.artist_id
group by Customer_Name , ba.artist_name
order by total_amount desc



--Q.10 We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres.

WITH Customter_with_country AS (
		SELECT first_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2
		ORDER BY 2 ASC,4 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

--Q.11: Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount. 

--What amount has been spent by each customer from each country
WITH RECURSIVE 
	countrywise_sales_wrt_customers AS(
		select cu.customer_id , cu.first_name , i.billing_country , sum(i.total) as total_spent from invoice i
		join customer cu on cu.customer_id = i.customer_id
		group by 1,2 ,3
		order by 3 ),
		
--Who is the highest paying customer from each country

	highest_sale_countrywise AS(
		select billing_country, MAX(total_spent) as top_spent from countrywise_sales_wrt_customers
		group by billing_country)

select c.billing_country, c.total_spent , c.first_name from countrywise_sales_wrt_customers c
join highest_sale_countrywise hc on hc.billing_country = c.billing_country
where hc.top_spent = c.total_spent
order by 1

















