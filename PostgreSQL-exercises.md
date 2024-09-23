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

## Dates
```sql
```
## String
```sql
```
## Recursive
```sql
```
