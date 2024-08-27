# PostgreSQL
This page goes through the PostgreSQL exercies avaiable on https://pgexercises.com/

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
### Question
1. How can you retrieve all the information from the cd.facilities table?
```sql
select * from cd.facilities;     
```

2. You want to print out a list of all of the facilities and their cost to members. How would you retrieve a list of only facility names and costs?
```sql
select name, membercost from cd.facilities;
```

3. How can you produce a list of facilities that charge a fee to members?
```sql
select * from cd.facilities where membercost > 0;
```

4. How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
```sql
select facid, name, membercost, monthlymaintenance 
	from cd.facilities 
where
 membercost > 0 and 
	(membercost < monthlymaintenance/50.0);     
```
   
5. 
## Joins and subqueries
```sql
```
## Modifying data
```sql
```
## Aggregates
```sql
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
