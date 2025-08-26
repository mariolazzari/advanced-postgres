CREATE TABLE
    geometries (name text, geom geometry);

SELECT
    srid,
    auth_name,
    auth_srid,
    srtext,
    proj4text
FROM
    public.spatial_ref_sys;

SELECT
    *
FROM
    public.geometry_columns;

INSERT INTO
    geometries
VALUES
    ('Point', 'POINT(0 0)'),
    ('Point', 'POINT(1 1)'),
    ('Point', 'POINT(1 2)'),
    ('Simple line', 'LINESTRING(1 2, 2 2)'),
    (
        'Linestring',
        'LINESTRING(0 0, 1 1, 2 0, 1 0, 2 1, 3 0)'
    ),
    ('Square', 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'),
    ('Rectangle', 'POLYGON((1 2, 3 2, 3 1, 1 1, 1 2))'),
    (
        'PolygonWithHole',
        'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0),(1 1, 1 2, 2 2, 2 1, 1 1))'
    ),
    (
        'Collection',
        'GEOMETRYCOLLECTION(POINT(2 0),POLYGON((0 0, 1 0, 1 1, 0 1, 0 0)))'
    );

-- ST_AsText get the WKT or the Well-known Text format of the geometry data
SELECT
    *,
    ST_AsText (geom)
FROM
    geometries;