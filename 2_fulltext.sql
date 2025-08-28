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

-- logical operators
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

-- Using different languages
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

-- Search parameters

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

-- Ranking results
SELECT document_text, ts_rank(to_tsvector(document_text), to_tsquery('life|fear')) AS rank
FROM documents
ORDER BY rank DESC
LIMIT 10;

SELECT document_text, ts_rank(to_tsvector(document_text), to_tsquery('never')) AS rank
FROM documents
ORDER BY rank DESC
LIMIT 10;

-- Dictionaries
CREATE TEXT SEARCH DICTIONARY public.simple_dict (
    TEMPLATE = pg_catalog.simple,
    STOPWORDS = english
);

SELECT ts_lexize('public.simple_dict', 'Shoes');
