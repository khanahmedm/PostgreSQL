# PostgreSQL
This page goes through the PostgreSQL exercies avaiable on https://pgexercises.com/

You may download PostgreSQL database from [here](https://www.postgresql.org/download/)

1. [Create Tables](#create-tables)
2. [Populate Tables](#populate-tables)
3. [Simple SQL Queries](#simple-sql-queries)
4. [Joins and subquries](#joins-and-subqueries)
5. [Modifying Data](#modifying-data)
6. [Aggregates](#aggregates)
7. [Date](#date)
8. [String](#string)
9. [Recursive](#recursive)


## Create Tables
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

## Populate Tables
```sql
INSERT statements
```

## Simple SQL Queries
### Question
How can you retrieve all the information from the cd.facilities table?
```sql
select * from cd.facilities;     
```

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
