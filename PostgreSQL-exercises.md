# PostgreSQL
This page goes through the PostgreSQL exercises avaiable on https://pgexercises.com/

You may download PostgreSQL database from [here](https://www.postgresql.org/download/)

1. [Create Database & Schema](#create-database-and-schema)
2. [Create Tables](#create-tables)
3. [Populate Tables](#populate-tables)
4. [Simple SQL Queries](#simple-sql-queries)
5. [Joins and subquries](#joins-and-subqueries)
6. [Modifying Data](#modifying-data)
7. [Aggregates](#aggregates)
8. [Date](#date)
9. [String](#string)
10. [Recursive](#recursive)

## Create Database and Schema
```sql
--
-- PostgreSQL database dump
--
CREATE DATABASE exercises;
\c exercises
CREATE SCHEMA cd;



-- Dumped from database version 9.2.0
-- Dumped by pg_dump version 9.2.0
-- Started on 2013-05-19 16:05:10 BST

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 7 (class 2615 OID 32769)
-- Name: cd; Type: SCHEMA; Schema: -; Owner: -
--

SET search_path = cd, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;
```
[go to the top](#postgresql)

## Create Tables
### Member Table DDL
``` sql
 CREATE TABLE cd.members
    (
       memid integer NOT NULL, 
       surname character varying(200) NOT NULL, 
       firstname character varying(200) NOT NULL, 
       address character varying(300) NOT NULL, 
       zipcode integer NOT NULL, 
       telephone character varying(20) NOT NULL, 
       recommendedby integer,
       joindate timestamp NOT NULL,
       CONSTRAINT members_pk PRIMARY KEY (memid),
       CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
            REFERENCES cd.members(memid) ON DELETE SET NULL
    );
```

### Facilities Table DDL
```sql
CREATE TABLE cd.facilities
    (
       facid integer NOT NULL, 
       name character varying(100) NOT NULL, 
       membercost numeric NOT NULL, 
       guestcost numeric NOT NULL, 
       initialoutlay numeric NOT NULL, 
       monthlymaintenance numeric NOT NULL, 
       CONSTRAINT facilities_pk PRIMARY KEY (facid)
    );
```

### Bookings Table DDL
```sql
CREATE TABLE cd.bookings
    (
       bookid integer NOT NULL, 
       facid integer NOT NULL, 
       memid integer NOT NULL, 
       starttime timestamp NOT NULL,
       slots integer NOT NULL,
       CONSTRAINT bookings_pk PRIMARY KEY (bookid),
       CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
       CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
    );
```

[go to the top](#postgresql)

## Populate Tables
1. Copy insert statements for Members table from [here](insert-into-members.sql)
2. Copy insert statements for facilities table from [here](insert-into-facilities.sql)
3. Copy insert statements for Bookings table from [here](insert-into-bookings.sql) 

[go to the top](#postgresql)

## Simple SQL Queries
### Questions
1. #### Retrieve everything from a table
How can you retrieve all the information from the cd.facilities table?
```sql
select * from cd.facilities;     
```

2. #### Retrieve specific columns from a table
You want to print out a list of all of the facilities and their cost to members. How would you retrieve a list of only facility names and costs?
```sql
select name, membercost from cd.facilities;
```

3. #### Control which rows are retrieved
How can you produce a list of facilities that charge a fee to members?
```sql
select * from cd.facilities where membercost > 0;
```

4. #### Control which rows are retrieved - part 2
How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
```sql
select facid, name, membercost, monthlymaintenance 
	from cd.facilities 
where
 membercost > 0 and 
	(membercost < monthlymaintenance/50.0);     
```
   
5. #### Basic string searches
How can you produce a list of all facilities with the word 'Tennis' in their name?
```sql
select *
	from cd.facilities 
	where 
		name like '%Tennis%';
```

6. #### Matching against multiple possible values
How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
```sql
select *
	from cd.facilities 
	where 
		facid in (1,5);
```

7. #### Classify results into buckets
How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their monthly maintenance cost is more than $100? Return the name and monthly maintenance of the facilities in question.
```sql
select name, 
	case when (monthlymaintenance > 100) then
		'expensive'
	else
		'cheap'
	end as cost
	from cd.facilities;  
```

8. #### Working with dates
How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.
```sql
select memid, surname, firstname, joindate 
	from cd.members
	where joindate >= '2012-09-01';   
```

9. #### Removing duplicates, and ordering results
How can you produce an ordered list of the first 10 surnames in the members table? The list must not contain duplicates.
```sql
select distinct surname 
	from cd.members
order by surname
limit 10;  
```

10. #### Combining results from multiple queries
You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!
```sql
select surname 
	from cd.members
union
select name
	from cd.facilities;   
```
11. #### Simple aggregation
You'd like to get the signup date of your last member. How can you retrieve this information?
```sql
select max(joindate) as latest
	from cd.members;      
```

12. #### More aggregation
You'd like to get the first and last name of the last member(s) who signed up - not just the date. How can you do that?
```sql
select firstname, surname, joindate
	from cd.members
	where joindate = 
		(select max(joindate) 
			from cd.members);   
```


## Joins and subqueries
13. #### Retrieve the start times of members' bookings
How can you produce a list of the start times for bookings by members named 'David Farrell'?
```sql
select bks.starttime 
	from 
		cd.bookings bks
		inner join cd.members mems
			on mems.memid = bks.memid
	where 
		mems.firstname='David' 
		and mems.surname='Farrell';    
```

Alternate syntax for join:
```sql
select bks.starttime
        from
                cd.bookings bks,
                cd.members mems
        where
                mems.firstname='David'
                and mems.surname='Farrell'
                and mems.memid = bks.memid;
```

14. #### Work out the start times of bookings for tennis courts
How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
```sql
select bks.starttime as start, facs.name as name
	from 
		cd.facilities facs
		inner join cd.bookings bks
			on facs.facid = bks.facid
	where 
		facs.name in ('Tennis Court 2','Tennis Court 1') and
		bks.starttime >= '2012-09-21' and
		bks.starttime < '2012-09-22'
order by bks.starttime;    
```
15. #### Produce a list of all members who have recommended another member
How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
```sql
select distinct recs.firstname as firstname, recs.surname as surname
	from 
		cd.members mems
		inner join cd.members recs
			on recs.memid = mems.recommendedby
order by surname, firstname;   
```

16. #### Produce a list of all members, along with their recommender
How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
```sql
select mems.firstname as memfname, mems.surname as memsname, recs.firstname as recfname, recs.surname as recsname
	from 
		cd.members mems
		left outer join cd.members recs
			on recs.memid = mems.recommendedby
order by memsname, memfname;      
```

17. #### Produce a list of all members who have used a tennis court
How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name followed by the facility name.
```sql
select distinct mems.firstname || ' ' || mems.surname as member, facs.name as facility
	from 
		cd.members mems
		inner join cd.bookings bks
			on mems.memid = bks.memid
		inner join cd.facilities facs
			on bks.facid = facs.facid
	where
		facs.name in ('Tennis Court 2','Tennis Court 1')
order by member, facility   
```

18.  #### Produce a list of costly bookings
How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.
```sql
select mems.firstname || ' ' || mems.surname as member, 
	facs.name as facility, 
	case 
		when mems.memid = 0 then
			bks.slots*facs.guestcost
		else
			bks.slots*facs.membercost
	end as cost
        from
                cd.members mems                
                inner join cd.bookings bks
                        on mems.memid = bks.memid
                inner join cd.facilities facs
                        on bks.facid = facs.facid
        where
		bks.starttime >= '2012-09-14' and 
		bks.starttime < '2012-09-15' and (
			(mems.memid = 0 and bks.slots*facs.guestcost > 30) or
			(mems.memid != 0 and bks.slots*facs.membercost > 30)
		)
order by cost desc;       
```

19.  #### Produce a list of all members, along with their recommender, using no joins.
How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
```sql
select distinct mems.firstname || ' ' ||  mems.surname as member,
	(select recs.firstname || ' ' || recs.surname as recommender 
		from cd.members recs 
		where recs.memid = mems.recommendedby
	)
	from 
		cd.members mems
order by member;   
```

20.  #### Produce a list of costly bookings, using a subquery
The Produce a list of costly bookings exercise contained some messy logic: we had to calculate the booking cost in both the WHERE clause and the CASE statement. Try to simplify this calculation using subqueries. For reference, the question was:
*How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost.*
```sql
select member, facility, cost from (
	select 
		mems.firstname || ' ' || mems.surname as member,
		facs.name as facility,
		case
			when mems.memid = 0 then
				bks.slots*facs.guestcost
			else
				bks.slots*facs.membercost
		end as cost
		from
			cd.members mems
			inner join cd.bookings bks
				on mems.memid = bks.memid
			inner join cd.facilities facs
				on bks.facid = facs.facid
		where
			bks.starttime >= '2012-09-14' and
			bks.starttime < '2012-09-15'
	) as bookings
	where cost > 30
order by cost desc;      
```

## Modifying data

21. #### Insert some data into a table
The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

```sql
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values (9, 'Spa', 20, 30, 100000, 800);   
```

22. #### Insert multiple rows of data into a table
In the previous exercise, you learned how to add a facility. Now you're going to add multiple facilities in one command. Use the following values:

facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
```sql
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values
        (9, 'Spa', 20, 30, 100000, 800),
        (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);   
```

23. #### Insert calculated data into a table
Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:

Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
```sql
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;    
```

24. #### Update some existing data
We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
```sql
update cd.facilities
    set initialoutlay = 10000
    where facid = 1;
```

25. #### Update multiple rows and columns at the same time
We want to increase the price of the tennis courts for both members and guests. Update the costs to be 6 for members, and 30 for guests.
```sql
update cd.facilities
    set
        membercost = 6,
        guestcost = 30
    where facid in (0,1);    
```

26. #### Update a row based on the contents of another row
We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
```sql
update cd.facilities facs
    set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    where facs.facid = 1;     
```
Postgres provides a nonstandard extension to SQL called UPDATE...FROM that addresses this: it allows you to supply a FROM clause to generate values for use in the SET clause. Example below:
```sql
update cd.facilities facs
    set
        membercost = facs2.membercost * 1.1,
        guestcost = facs2.guestcost * 1.1
    from (select * from cd.facilities where facid = 0) facs2
    where facs.facid = 1;
```

27. #### Delete all bookings
As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
```sql
delete from cd.bookings;
```
An alternative to unqualified DELETEs is the following:
```sql
truncate cd.bookings;
```

28. #### Delete a member from the cd.members table
We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
```sql
delete from cd.members where memid = 37;  
```

29. #### Delete based on a subquery
In our previous exercises, we deleted a specific member who had never made a booking. How can we make that more general, to delete all members who have never made a booking?
```sql
delete from cd.members where memid not in (select memid from cd.bookings);   
```
An alternative is to use a correlated subquery. Where our previous example runs a large subquery once, the correlated approach instead specifies a smaller subqueryto run against every row.
```sql
delete from cd.members mems where not exists (select 1 from cd.bookings where memid = mems.memid);
```

## Aggregates

30. #### Count the number of facilities
For our first foray into aggregates, we're going to stick to something simple. We want to know how many facilities exist - simply produce a total count. 
```sql
select count(*) from cd.facilities;  
```

31. #### Count the number of expensive facilities
Produce a count of the number of facilities that have a cost to guests of 10 or more.
```sql
select count(*) from cd.facilities where guestcost >= 10;  
```

32. #### Count the number of recommendations each member makes.
Produce a count of the number of recommendations each member has made. Order by member ID.
```sql
select recommendedby, count(*) 
	from cd.members
	where recommendedby is not null
	group by recommendedby
order by recommendedby; 
```

33. #### List the total slots booked per facility
Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
```sql
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by facid;       
```

34. #### List the total slots booked per facility in a given month
Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
```sql
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	where
		starttime >= '2012-09-01'
		and starttime < '2012-10-01'
	group by facid
order by sum(slots);    
```

35. #### List the total slots booked per facility per month
Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.
```sql
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where extract(year from starttime) = 2012
	group by facid, month
order by facid, month;  
```

36. #### Find the count of members who have made at least one booking
Find the total number of members (including guests) who have made at least one booking.
```sql
select count(distinct memid) from cd.bookings  
```

37.  #### List facilities with more than 1000 slots booked
Produce a list of facilities with more than 1000 slots booked. Produce an output table consisting of facility id and slots, sorted by facility id.
```sql
select facid, sum(slots) as "Total Slots"
        from cd.bookings
        group by facid
        having sum(slots) > 1000
        order by facid   
```

38.  #### Find the total revenue of each facility
Produce a list of facilities along with their total revenue. The output table should consist of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
```sql
select facs.name, sum(slots * case
			when memid = 0 then facs.guestcost
			else facs.membercost
		end) as revenue
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.name
order by revenue;   
```

39.  #### Find facilities with a total revenue less than 1000
Produce a list of facilities with a total revenue less than 1000. Produce an output table consisting of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
```sql
select name, revenue from (
	select facs.name, sum(case 
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) as revenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as agg where revenue < 1000
order by revenue;
```

40. #### Output the facility id that has the highest number of slots booked
Output the facility id that has the highest number of slots booked. For bonus points, try a version without a LIMIT clause. This version will probably look messy!
```sql
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by sum(slots) desc
LIMIT 1;       
```

```sql
select facid, max(totalslots) from (
	select facid, sum(slots) as totalslots    
		from cd.bookings    
		group by facid
	) as sub group by facid
```

```sql
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);
```

41. #### List the total slots booked per facility per month, part 2
Produce a list of the total number of slots booked per facility per month in the year of 2012. In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities. The output table should consist of facility id, month and slots, sorted by the id and month. When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
```sql
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;  
```

```sql
select facid, extract(month from starttime) as month, sum(slots) as slots
    from cd.bookings
    where
        starttime >= '2012-01-01'
        and starttime < '2013-01-01'
    group by facid, month
union all
select facid, null, sum(slots) as slots
    from cd.bookings
    where
        starttime >= '2012-01-01'
        and starttime < '2013-01-01'
    group by facid
union all
select null, null, sum(slots) as slots
    from cd.bookings
    where
        starttime >= '2012-01-01'
        and starttime < '2013-01-01'
order by facid, month;
```

```sql
with bookings as (
	select facid, extract(month from starttime) as month, slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
)
select facid, month, sum(slots) from bookings group by facid, month
union all
select facid, null, sum(slots) from bookings group by facid
union all
select null, null, sum(slots) from bookings
order by facid, month;
```

42. #### List the total hours booked per named facility
Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour. The output table should consist of the facility id, name, and hours booked, sorted by facility id. Try formatting the hours to two decimal places.
```sql
select facs.facid, facs.name,
	trim(to_char(sum(bks.slots)/2.0, '9999999999999999D99')) as "Total Hours"

	from cd.bookings bks
	inner join cd.facilities facs
		on facs.facid = bks.facid
	group by facs.facid, facs.name
order by facs.facid;      
```

43. #### List each member's first booking after September 1st 2012
Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
```sql
select mems.surname, mems.firstname, mems.memid, min(bks.starttime) as starttime
	from cd.bookings bks
	inner join cd.members mems on
		mems.memid = bks.memid
	where starttime >= '2012-09-01'
	group by mems.surname, mems.firstname, mems.memid
order by mems.memid;  
```

44. #### Produce a list of member names, with each row containing the total member count
Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
```sql
select count(*) over(), firstname, surname
	from cd.members
order by joindate  
```

```sql
select (select count(*) from cd.members) as count, firstname, surname
	from cd.members
order by joindate
```

```sql
select count(*) over(partition by date_trunc('month',joindate)),
	firstname, surname
	from cd.members
order by joindate
```

45. #### Produce a numbered list of members
Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
```sql
select row_number() over(order by joindate), firstname, surname
	from cd.members
order by joindate      
```

46. #### Output the facility id that has the highest number of slots booked, again
Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
```sql
select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1       
```

```sql
select facid, total from (
	select facid, total, rank() over (order by total desc) rank from (
		select facid, sum(slots) total
			from cd.bookings
			group by facid
		) as sumslots
	) as ranked
where rank = 1
```

47. #### Rank members by (rounded) hours used
Produce a list of members (including guests), along with the number of hours they've booked in facilities, rounded to the nearest ten hours. Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank. Sort by rank, surname, and first name.
```sql
select firstname, surname,
	((sum(bks.slots)+10)/20)*10 as hours,
	rank() over (order by ((sum(bks.slots)+10)/20)*10 desc) as rank

	from cd.bookings bks
	inner join cd.members mems
		on bks.memid = mems.memid
	group by mems.memid
order by rank, surname, firstname;   
```

```sql
select firstname, surname, hours, rank() over (order by hours desc) from
	(select firstname, surname,
		((sum(bks.slots)+10)/20)*10 as hours

		from cd.bookings bks
		inner join cd.members mems
			on bks.memid = mems.memid
		group by mems.memid
	) as subq
order by rank, surname, firstname;
```

48. #### Find the top three revenue generating facilities
Produce a list of the top three revenue generating facilities (including ties). Output facility name and rank, sorted by rank and facility name.
```sql
select name, rank from (
	select facs.name as name, rank() over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as rank
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
	where rank <= 3
order by rank;     
```

49. #### Classify facilities by value
``` sql
select name, case when class=1 then 'high'
		when class=2 then 'average'
		else 'low'
		end revenue
	from (
		select facs.name as name, ntile(3) over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as class
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
order by class, name;   
```

50. #### Calculate the payback time for each facility
Based on the 3 complete months of data so far, calculate the amount of time each facility will take to repay its cost of ownership. Remember to take into account ongoing monthly maintenance. Output facility name and payback time in months, order by facility name. Don't worry about differences in month lengths, we're only looking for a rough value here!
```sql
select 	facs.name as name,
	facs.initialoutlay/((sum(case
			when memid = 0 then slots * facs.guestcost
			else slots * membercost
		end)/3) - facs.monthlymaintenance) as months
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.facid
order by name;     
```

```sql
select 	name, 
	initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime 
	from 
		(select facs.name as name, 
			facs.initialoutlay as initialoutlay,
			facs.monthlymaintenance as monthlymaintenance,
			sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end)/3 as monthlyrevenue
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.facid
	) as subq
order by name;
```

```sql
with monthdata as (
	select 	mincompletemonth,
		maxcompletemonth,
		(extract(year from maxcompletemonth)*12) +
			extract(month from maxcompletemonth) -
			(extract(year from mincompletemonth)*12) -
			extract(month from mincompletemonth) as nummonths 
	from (
		select 	date_trunc('month', 
				(select max(starttime) from cd.bookings)) as maxcompletemonth,
			date_trunc('month', 
				(select min(starttime) from cd.bookings)) as mincompletemonth
	) as subq
)
select 	name, 
	initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime 
	
	from
		(select facs.name as name,
			facs.initialoutlay as initialoutlay,
			facs.monthlymaintenance as monthlymaintenance,
			sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end)/(select nummonths from monthdata) as monthlyrevenue
			
			from cd.bookings bks
			inner join cd.facilities facs
				on bks.facid = facs.facid
			where bks.starttime < (select maxcompletemonth from monthdata)
			group by facs.facid
		) as subq
order by name;
```

51. #### Calculate a rolling average of total revenue
For each day in August 2012, calculate a rolling average of total revenue over the previous 15 days. Output should contain date and revenue columns, sorted by the date. Remember to account for the possibility of a day having zero revenue. This one's a bit tough, so don't be afraid to check out the hint!
```sql
select 	dategen.date,
	(
		-- correlated subquery that, for each day fed into it,
		-- finds the average revenue for the last 15 days
		select sum(case
			when memid = 0 then slots * facs.guestcost
			else slots * membercost
		end) as rev

		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		where bks.starttime > dategen.date - interval '14 days'
			and bks.starttime < dategen.date + interval '1 day'
	)/15 as revenue
	from
	(
		-- generates a list of days in august
		select 	cast(generate_series(timestamp '2012-08-01',
			'2012-08-31','1 day') as date) as date
	)  as dategen
order by dategen.date;
```

```sql
select date, avgrev from (
	-- AVG over this row and the 14 rows before it.
	select 	dategen.date as date,
		avg(revdata.rev) over(order by dategen.date rows 14 preceding) as avgrev
	from
		-- generate a list of days.  This ensures that a row gets generated
		-- even if the day has 0 revenue.  Note that we generate days before
		-- the start of october - this is because our window function needs
		-- to know the revenue for those days for its calculations.
		(select
			cast(generate_series(timestamp '2012-07-10', '2012-08-31','1 day') as date) as date
		)  as dategen
		left outer join
			-- left join to a table of per-day revenue
			(select cast(bks.starttime as date) as date,
				sum(case
					when memid = 0 then slots * facs.guestcost
					else slots * membercost
				end) as rev

				from cd.bookings bks
				inner join cd.facilities facs
					on bks.facid = facs.facid
				group by cast(bks.starttime as date)
			) as revdata
			on dategen.date = revdata.date
	) as subq
	where date >= '2012-08-01'
order by date;
```

```sql
create or replace view cd.dailyrevenue as
	select 	cast(bks.starttime as date) as date,
		sum(case
			when memid = 0 then slots * facs.guestcost
			else slots * membercost
		end) as rev

		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by cast(bks.starttime as date);

select date, avgrev from (
	select  dategen.date as date,
		avg(revdata.rev) over(order by dategen.date rows 14 preceding) as avgrev
	from		
		(select
			cast(generate_series(timestamp '2012-07-10', '2012-08-31','1 day') as date) as date
		)  as dategen
		left outer join
			cd.dailyrevenue as revdata on dategen.date = revdata.date
		) as subq
	where date >= '2012-08-01'
order by date;
```
    
## Dates
```sql
```
## String
```sql
```
## Recursive
```sql
```
