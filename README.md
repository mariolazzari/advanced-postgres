# advanced PostgreSQL

## Installing and setup

```yaml
version: '3.9'
services:
  postgis17:
    image: postgis/postgis:17-3.5
    container_name: postgis17
    restart: always
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
      POSTGRES_DB: loonydb
    ports:
      - "5432:5432"
    volumes:
      - postgis17_data:/var/lib/postgresql/data

volumes:
  postgis17_data:
```

```sh
docker-compose up
```

## Geospatial data

### Spatial data analysis

Data analysis extended to geographical data (locations, paths...).
PostGIS (Geographical information system) support geographical objects and allows location queries in SQL.

#### Geometry types

- Atomic types
  - Pointt
  - LineString
  - LinearRing
  - Polygon

- Collection types
  - MultiPoint
  - MultiLineString
  - MultiPolygon
  - GeometryCollection
  - PolihedralSurface
  
### WKT and WKB

Two formats for rappresenting geometry values

- WKT: Well-Known Text
- WKB: Well-Known Binary

### Geometry and Geography data types

#### Geometry data type

- on plane
- shortest path between point is line 
- less accurate
- ideal for small areas

#### Geography data type

- on sphere
- shortest path between point is arc 
- more accurate
- ideal for larger areas (regions, continents)

### Spatial reference system

How geometry is referenced on Earth surface, also called SRS (spatial reference system).

- Geodetic SRS
- Projected SRS
- Local SRS

It is identified by an integer number, called SRID.

### Creating table with geometry types

```sql
CREATE TABLE geometries(name text, geom geometry);

SELECT srid, auth_name, auth_srid, srtext, proj4text
FROM public.spatial_ref_sys;

SELECT * FROM public.geometry_columns;

INSERT INTO geometries VALUES
  ('Point', 'POINT(0 0)'),
  ('Point', 'POINT(1 1)'),
  ('Point', 'POINT(1 2)'),
  ('Simple line', 'LINESTRING(1 2, 2 2)'),
  ('Linestring', 'LINESTRING(0 0, 1 1, 2 0, 1 0, 2 1, 3 0)'),
  ('Square', 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'),
  ('Rectangle', 'POLYGON((1 2, 3 2, 3 1, 1 1, 1 2))'),
  ('PolygonWithHole', 'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0),(1 1, 1 2, 2 2, 2 1, 1 1))'),
  ('Collection', 'GEOMETRYCOLLECTION(POINT(2 0),POLYGON((0 0, 1 0, 1 1, 0 1, 0 0)))');

-- ST_AsText get the WKT or the Well-known Text format of the geometry data
SELECT *, ST_AsText(geom) FROM geometries;
```

### Computing data

```sql
-- get the coordinates
SELECT ST_X(geom), ST_Y(geom)
FROM geometries
WHERE name = 'Point';

SELECT ST_asText(geom), ST_Length(geom)
FROM geometries
WHERE name = 'Simple line';

SELECT ST_asText(geom), ST_Length(geom)
FROM geometries
WHERE name = 'Linestring';

-- get the start and end point using the following query
SELECT ST_asText(geom), ST_Length(geom), 
   ST_asText(ST_StartPoint(geom)), 
   ST_asTEXT(ST_EndPoint(geom))
FROM geometries
WHERE name = 'Linestring';

-- 3 different polygons
SELECT name, ST_AsText(geom), ST_Area(geom), geom
FROM geometries
WHERE name LIKE 'Polygon%' or name LIKE 'Square' or name LIKE 'Rectangle';
```

### Real world data

```sql
DROP TABLE IF EXISTS UKPlaces;

CREATE TABLE UKPlaces (
  sensor_id VARCHAR(50) PRIMARY KEY NOT NULL,
  name TEXT,
  longitude VARCHAR(50),
  latitude VARCHAR(50),
  country TEXT,
  sensorLocation GEOMETRY
);

INSERT INTO UKPlaces (sensor_id, name, longitude, latitude, country, sensorLocation) VALUES 
('S1', 'York', -1.080278, 53.958332, 'UK', ST_GeomFromText('POINT(-1.080278 53.958332)',4326)),
('S2', 'Worcester', -2.220000, 52.192001, 'UK', ST_GeomFromText('POINT(-2.220000 52.192001)',4326)),
('S3', 'Winchester', -1.308000, 51.063202, 'UK', ST_GeomFromText('POINT(-0.138702 51.063202)',4326)),
('S4', 'Wells', -2.647000, 51.209000, 'UK', ST_GeomFromText('POINT(-2.647000 51.209000)',4326)),
('S5', 'Wakefield', -1.490000, 53.680000, 'UK', ST_GeomFromText('POINT(-1.490000 53.680000)',4326)),
('S6', 'Truro', -5.051000, 50.259998, 'UK', ST_GeomFromText('POINT(-5.051000 50.259998)',4326)),
('S7', 'Sunderland', -1.381130, 54.906101, 'UK', ST_GeomFromText('POINT(-1.381130 54.906101)',4326));

SELECT * FROM UKPlaces;
```

### Compute distances

```sql
 SELECT sensorLocation FROM ukplaces 
 WHERE name='Wells' OR name='Truro';

-- distance between the two places using the following query (in degrees)
SELECT ST_Distance(geometry(a.sensorLocation), geometry(b.sensorLocation))
FROM UKPlaces a, UKPlaces b
WHERE a.name='Wells' AND b.name='Truro';

-- calculate it using geography (in meters)
SELECT ST_Distance(geography(a.sensorLocation), geography(b.sensorLocation))
FROM UKPlaces a, UKPlaces b
WHERE a.name='Wells' AND b.name='Truro';
```

### Lines on map

```sql
SELECT name FROM UKPlaces 
WHERE ST_DWithin(sensorLocation, 
                 ST_GeomFromText('POINT(-0.138702 51.501220)',4326)::geography, 
                 250000);
```

### Import shape files

```sh
shp2pgsql -I -s 4269 ./cb_2017_us_state_20m.shp public.us_state_20 | psql -d loonydb -p 5432
```

## Performing full text search

### Full text search

Identifies documents that satisfy natural langiage query and sorts them by relevance.

### Basic search with LIKE

```sql
CREATE TABLE online_courses
(
  id SERIAL PRIMARY KEY, 
  title TEXT NOT NULL, 
  description TEXT NOT NULL
);


INSERT INTO online_courses (title, description) VALUES
  ('Learning Java', 'A complete course that will help you learn Java in simple steps'),
  ('Advanced Java', 'Master advanced topics in Java, with hands-on examples'),
  ('Introduction to Machine Learning', 'Build and train simple machine learning models'),
  ('Learning Springboot', 'Build web applications in Java using SpringBoot'),
  ('Learning TensorFlow', 'Build and train deep learning models using TensorFlow 2.0'),
  ('Learning PyTorch', 'Build and train deep learning models using PyTorch'),
  ('Introduction to Self-supervised Machine Learning', 'Learn more from your unlabelled data'),
  ('Data Analytics and Visualization', 'Visualize, understand, and explore data using Python'),
  ('Learning SQL', 'Learn SQL programming in 21 days'),
  ('Learning C++', 'Take your first steps in C++ programming'),
  ('Learning Python', 'Take your first steps in Python programming'),
  ('Learning PostgreSQL', 'SQL programming using the PostgreSQL object-relational database'),
  ('Advanced PostgreSQL', 'Master advanced features in PostgreSQL');

SELECT 
    id,
    title,
    description
FROM 
    online_courses
WHERE  
    title LIKE '%java%' OR description LIKE '%java%';

SELECT 
    id,
    title,
    description
FROM 
    online_courses
WHERE  
    title ILIKE '%java%' OR description ILIKE '%java%';
```

### Tsvector and Tsquery

```sql
-- tsvector
-- The to_tsvector function parses an input text and converts it to the search type that represents a searchable  document.

SELECT to_tsvector('Visualize, understand, and explore data using Python');

-- the result is a list of lexemes ready to be searched
-- stop words ("in", "a", "the", etc) were removed
-- the numbers are the position of the lexemes in the document

-- tsquery
-- The to_tsquery function parses an input text and converts it to the search type that represents a query. 
-- For instance, the user wants to search "java in a nutshell":

SELECT to_tsquery('The & machine & learning');

-- the result is a list of tokens ready to be queried
-- stop words ("in", "a", "the", etc) were removed

SELECT websearch_to_tsquery('The machine learning');
```

### Using @@ operator

- allows to match a query against a document and returns true or false.
- You can have tsquery @@ tsvector or tsvector @@ tsquery

```sql
-- This will return "true"
SELECT 'machine & learning'::tsquery @@ 'Build and train simple machine learning models'::tsvector;
-- This will return "false"
SELECT 'deep & learning'::tsquery @@ 'Build and train simple machine learning models'::tsvector;
--This will return "true"
SELECT 'Build and train simple machine learning models'::tsvector @@ 'models'::tsquery;
-- This will return "false"
SELECT 'Build and train simple machine learning models'::tsvector @@ 'deep'::tsquery;
```

### Logical operations

```sql
SELECT *
FROM online_courses
WHERE to_tsquery('learn') @@ to_tsvector(title);

-- Search using or
SELECT * 
FROM online_courses
WHERE to_tsquery('machine | deep') @@ to_tsvector(title || description);

-- Search using not
SELECT * 
FROM 
    online_courses, 
    to_tsvector(title || description) document
WHERE to_tsquery('programming & !days') @@ document;
```

### Using different languages

```sql
SET default_text_search_config = 'pg_catalog.spanish';

SELECT to_tsvector('english', 'The cake is good');
SELECT to_tsvector('spanish', 'The cake is good');
SELECT to_tsvector('simple', 'The cake is good');

SELECT to_tsvector('english', 'el pastel es bueno');
SELECT to_tsvector('spanish', 'el pastel es bueno');
SELECT to_tsvector('simple', 'el pastel es bueno');

SET default_text_search_config = 'pg_catalog.spanish';

SELECT to_tsvector(
  'Bienvenido al tutorial de PostgreSQL.' ||
  'PostgreSQL se utiliza para almacenar datos.' ||
  'tener una buena experiencia!'
) @@ to_tsquery('buena');
-- We see this is also true as buena is present

-- Now let's look at another word
SELECT to_tsvector(
  'Bienvenido al tutorial de PostgreSQL.' ||
  'PostgreSQL se utiliza para almacenar datos.' ||
  'tener una buena experiencia!'
) @@ to_tsquery('buen');

-- We see this also is true as buen and buena mean the same 

-- Let's search a word that's not present
SELECT to_tsvector(
  'Bienvenido al tutorial de PostgreSQL.' ||
  'PostgreSQL se utiliza para almacenar datos.' ||
  'tener una buena experiencia!'
) @@ to_tsquery('mala');

-- We see this shows false
```

### Search parameters

```sql
-- So let's create a table for storing all of this 
-- (notice the tsvector data type for the document_tokens column)
CREATE TABLE documents  
(
    document_id SERIAL,
    document_text TEXT,
    document_tokens TSVECTOR,

    CONSTRAINT documents_pkey PRIMARY KEY (document_id)
)

-- Now let's insert the documents into it
INSERT INTO documents (document_text) VALUES  
('The greatest glory in living lies not in never falling, but in rising every time we fall. -Nelson Mandela'),
('The way to get started is to quit talking and begin doing. -Walt Disney'),
('When you reach the end of your rope, tie a knot in it and hang on. -Franklin D. Roosevelt'),
('Never let the fear of striking out keep you from playing the game. -Babe Ruth'),
('You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose. -Dr. Seuss'),
('Life is a long lesson in humility. -James M. Barrie');

-- The output will be
INSERT 0 6

-- Finally, a little UPDATE command will conveniently populate the tokens column
UPDATE documents d1  
SET document_tokens = to_tsvector(d1.document_text)  
FROM documents d2; 

SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ websearch_to_tsquery('begin doing'); 

SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('hang & on'); 

-- There should be one document in the result

SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('long <-> lesson'); 

-- One document with the term "long lesson"

SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('direction <2> choose'); 

-- One document with "direction you choose"

SELECT document_id, document_text, document_tokens FROM documents
WHERE document_tokens @@ to_tsquery('fear <3> out'); 

-- One document with "fear of striking out"
```

### Ranking results

```sql
SELECT document_text, ts_rank(to_tsvector(document_text), to_tsquery('life|fear')) AS rank
FROM documents
ORDER BY rank DESC
LIMIT 10;

SELECT document_text, ts_rank(to_tsvector(document_text), to_tsquery('never')) AS rank
FROM documents
ORDER BY rank DESC
LIMIT 10;
```

### Dictionaries

```sql
CREATE TEXT SEARCH DICTIONARY public.simple_dict (
    TEMPLATE = pg_catalog.simple,
    STOPWORDS = english
);

SELECT ts_lexize('public.simple_dict', 'Shoes');
```

## Triggers

### Introduction

- Automatic execution of a function when a certain operation is performed
- Can be attached to tables and views
- Before, After, Instead of

### Execution order

- Before statement
- Before row
- Insert / update / delete -> Instad of
- After row
- After statement

### Row level after insert

```sql
CREATE TABLE employees(
   id INT GENERATED ALWAYS AS IDENTITY,
   first_name TEXT NOT NULL,
   last_name TEXT NOT NULL,
   department TEXT NOT NULL,  
   salary INT NOT NULL,
   PRIMARY KEY(id)
);

INSERT INTO employees (first_name, last_name, department, salary)
VALUES 
('Alice', 'Smith', 'Engineering', 125000),
('Bob', 'Baker', 'Sales', 85000);

-- entry table where we audit new employees
CREATE TABLE new_employee_logs (
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  joining_date date NOT NULL
);

-- Create a function
CREATE OR REPLACE FUNCTION new_employee_joining_func() RETURNS TRIGGER AS $new_employee_trigger$
   BEGIN
      INSERT INTO new_employee_logs(first_name, last_name, joining_date)
      VALUES (new.first_name, new.last_name, current_timestamp);
      RETURN NEW;
   END;
$new_employee_trigger$ LANGUAGE plpgsql;

-- create a trigger for this function (note that this is an AFTER INSERT and a row-level trigger)
CREATE TRIGGER new_employee_trigger 
AFTER INSERT ON employees
FOR EACH ROW 
  EXECUTE PROCEDURE new_employee_joining_func();

-- insert some values within employees table and notice how trigger works
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('John', 'Watson', 'Sales', 65000);

SELECT * FROM employees;

-- new entry is added
SELECT * from new_employee_logs;
```

### Row level after update

```sql
CREATE TABLE employee_salary_logs (
   id INT GENERATED ALWAYS AS IDENTITY,
   first_name TEXT NOT NULL,
   last_name TEXT NOT NULL,
   old_salary INT NOT NULL,
   incremented_salary INT NOT NULL,
   incremented_on DATE NOT NULL
);

-- If the salary is incremented, then let's aduit the last name and the time we incremented the salary and what the old salary and new salary is
CREATE OR REPLACE FUNCTION EMPLOYEE_SALARY_UPDATE_FUNC () RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
BEGIN
  IF NEW.salary <> OLD.salary THEN
     INSERT INTO employee_salary_logs(first_name, last_name, old_salary, incremented_salary, incremented_on)
     VALUES(OLD.first_name, OLD.last_name, OLD.salary, NEW.salary, now());
  END IF;

  RETURN NEW;
END;
$$

CREATE TRIGGER EMPLOYEE_SALARY_UPDATE_TRIGGER
AFTER
UPDATE ON EMPLOYEES FOR EACH ROW
EXECUTE PROCEDURE EMPLOYEE_SALARY_UPDATE_FUNC ();

UPDATE employees
SET salary = 75000
WHERE last_name = 'Watson'; 

SELECT * FROM employee_salary_logs;

UPDATE EMPLOYEES
SET SALARY = 1.1 * SALARY

SELECT * FROM employee_salary_logs;
```

### Statement trigger

```sql
-- table which tracks operations performed on other tables
CREATE TABLE table_changed_logs (
  change_type TEXT NOT NULL,  
  changed_table_name TEXT NOT NULL, 
  changed_on date NOT NULL
);

-- Function to track what changes were made to a table (INSERT, UPDATE, DELETE)
CREATE OR REPLACE FUNCTION table_changed_logs_func() RETURNS TRIGGER AS $table_changed_trigger$
   BEGIN
      INSERT INTO table_changed_logs(change_type, changed_table_name, changed_on)
      VALUES (TG_OP, TG_TABLE_NAME, current_timestamp);
      RETURN NEW;
   END;
$table_changed_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER employees_inserted_trigger
AFTER INSERT ON employees
EXECUTE PROCEDURE table_changed_logs_func();

CREATE TRIGGER employees_inserted_trigger
AFTER UPDATE ON employees
EXECUTE PROCEDURE table_changed_logs_func();

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Julia', 'Dennis', 'Engineering', 80000);

UPDATE employees
SET salary = 1.05 * salary
WHERE salary < 85000

SELECT * FROM table_changed_logs;
SELECT * FROM employee_salary_logs;

-- We can see the trigger using the following query (should be 4 triggers)
SELECT tgname FROM pg_trigger;
-- Drop triggers
DROP TRIGGER employees_inserted_trigger ON employees;
```

## Transactions

### Isolation levels

- Atomicity
- Multi steps grouped into one single operation
- Execution is entire or not at all

Isolation level: visibility to user and system

- Read committed: pick up committed operations only
- Read uncommitted: uncommitted operation are taken
- Repeatable read: committed rows available only after transaction ends
- Serializable: concurrent changes on same block non allowed

### Create and commit

```sql
CREATE TABLE BANK_ACCOUNTS (
ID INT GENERATED BY DEFAULT AS IDENTITY,
NAME TEXT NOT NULL,
BALANCE INT NOT NULL,
PRIMARY KEY (ID)
);

INSERT INTO bank_accounts(name, balance)
VALUES('Jack', 1000);

-- Rollback
BEGIN;

UPDATE bank_accounts
SET balance = balance - 1500
WHERE name = 'Jack';

SELECT * FROM bank_accounts;

UPDATE bank_accounts
SET balance = balance + 1500
WHERE name = 'Dora';

SELECT * FROM bank_accounts;

ROLLBACK;

SELECT * FROM bank_accounts;

-- Commit
INSERT INTO bank_accounts(name, balance) 
VALUES('Charlie', 10000);

INSERT INTO bank_accounts(name, balance)
VALUES('Dora', 25000);

BEGIN;

UPDATE bank_accounts
SET balance = balance - 100
WHERE name = 'Charlie';

UPDATE bank_accounts
SET balance = balance + 100
WHERE name = 'Dora';

COMMIT;

SELECT * FROM bank_accounts;

```