CREATE TABLE
    online_courses (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL
    );

INSERT INTO
    online_courses (title, description)
VALUES
    (
        'Learning Java',
        'A complete course that will help you learn Java in simple steps'
    ),
    (
        'Advanced Java',
        'Master advanced topics in Java, with hands-on examples'
    ),
    (
        'Introduction to Machine Learning',
        'Build and train simple machine learning models'
    ),
    (
        'Learning Springboot',
        'Build web applications in Java using SpringBoot'
    ),
    (
        'Learning TensorFlow',
        'Build and train deep learning models using TensorFlow 2.0'
    ),
    (
        'Learning PyTorch',
        'Build and train deep learning models using PyTorch'
    ),
    (
        'Introduction to Self-supervised Machine Learning',
        'Learn more from your unlabelled data'
    ),
    (
        'Data Analytics and Visualization',
        'Visualize, understand, and explore data using Python'
    ),
    (
        'Learning SQL',
        'Learn SQL programming in 21 days'
    ),
    (
        'Learning C++',
        'Take your first steps in C++ programming'
    ),
    (
        'Learning Python',
        'Take your first steps in Python programming'
    ),
    (
        'Learning PostgreSQL',
        'SQL programming using the PostgreSQL object-relational database'
    ),
    (
        'Advanced PostgreSQL',
        'Master advanced features in PostgreSQL'
    );

SELECT
    id,
    title,
    description
FROM
    online_courses
WHERE
    title LIKE '%java%'
    OR description LIKE '%java%';

SELECT
    id,
    title,
    description
FROM
    online_courses
WHERE
    title ILIKE '%java%'
    OR description ILIKE '%java%';

-- tsvector
-- The to_tsvector function parses an input text and converts it to the search type that represents a searchable  document.
SELECT
    to_tsvector (
        'Visualize, understand, and explore data using Python'
    );

-- the result is a list of lexemes ready to be searched
-- stop words ("in", "a", "the", etc) were removed
-- the numbers are the position of the lexemes in the document
-- tsquery
-- The to_tsquery function parses an input text and converts it to the search type that represents a query. 
-- For instance, the user wants to search "java in a nutshell":
SELECT
    to_tsquery ('The & machine & learning');

-- the result is a list of tokens ready to be queried
-- stop words ("in", "a", "the", etc) were removed
SELECT
    websearch_to_tsquery ('The machine learning');

-- @@ operator

-- This will return "true"
SELECT 'machine & learning'::tsquery @@ 'Build and train simple machine learning models'::tsvector;
-- This will return "false"
SELECT 'deep & learning'::tsquery @@ 'Build and train simple machine learning models'::tsvector;
--This will return "true"
SELECT 'Build and train simple machine learning models'::tsvector @@ 'models'::tsquery;
-- This will return "false"
SELECT 'Build and train simple machine learning models'::tsvector @@ 'deep'::tsquery;