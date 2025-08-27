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

-- get the coordinates
SELECT
    ST_X (geom),
    ST_Y (geom)
FROM
    geometries
WHERE
    name = 'Point';

SELECT
    ST_asText (geom),
    ST_Length (geom)
FROM
    geometries
WHERE
    name = 'Simple line';

SELECT
    ST_asText (geom),
    ST_Length (geom)
FROM
    geometries
WHERE
    name = 'Linestring';

-- get the start and end point using the following query
SELECT
    ST_asText (geom),
    ST_Length (geom),
    ST_asText (ST_StartPoint (geom)),
    ST_asTEXT (ST_EndPoint (geom))
FROM
    geometries
WHERE
    name = 'Linestring';

-- 3 different polygons
SELECT
    name,
    ST_AsText (geom),
    ST_Area (geom),
    geom
FROM
    geometries
WHERE
    name LIKE 'Polygon%'
    or name LIKE 'Square'
    or name LIKE 'Rectangle';

DROP TABLE IF EXISTS UKPlaces;

CREATE TABLE
    UKPlaces (
        sensor_id VARCHAR(50) PRIMARY KEY NOT NULL,
        name TEXT,
        longitude VARCHAR(50),
        latitude VARCHAR(50),
        country TEXT,
        sensorLocation GEOMETRY
    );

INSERT INTO
    UKPlaces (
        sensor_id,
        name,
        longitude,
        latitude,
        country,
        sensorLocation
    )
VALUES
    (
        'S1',
        'York',
        -1.080278,
        53.958332,
        'UK',
        ST_GeomFromText ('POINT(-1.080278 53.958332)', 4326)
    ),
    (
        'S2',
        'Worcester',
        -2.220000,
        52.192001,
        'UK',
        ST_GeomFromText ('POINT(-2.220000 52.192001)', 4326)
    ),
    (
        'S3',
        'Winchester',
        -1.308000,
        51.063202,
        'UK',
        ST_GeomFromText ('POINT(-0.138702 51.063202)', 4326)
    ),
    (
        'S4',
        'Wells',
        -2.647000,
        51.209000,
        'UK',
        ST_GeomFromText ('POINT(-2.647000 51.209000)', 4326)
    ),
    (
        'S5',
        'Wakefield',
        -1.490000,
        53.680000,
        'UK',
        ST_GeomFromText ('POINT(-1.490000 53.680000)', 4326)
    ),
    (
        'S6',
        'Truro',
        -5.051000,
        50.259998,
        'UK',
        ST_GeomFromText ('POINT(-5.051000 50.259998)', 4326)
    ),
    (
        'S7',
        'Sunderland',
        -1.381130,
        54.906101,
        'UK',
        ST_GeomFromText ('POINT(-1.381130 54.906101)', 4326)
    );

SELECT
    *
FROM
    UKPlaces;

SELECT
    sensorLocation
FROM
    ukplaces
WHERE
    name = 'Wells'
    OR name = 'Truro';

-- distance between the two places using the following query (in degrees)
SELECT
    ST_Distance (
        geometry (a.sensorLocation),
        geometry (b.sensorLocation)
    )
FROM
    UKPlaces a,
    UKPlaces b
WHERE
    a.name = 'Wells'
    AND b.name = 'Truro';

-- calculate it using geography (in meters)
SELECT
    ST_Distance (
        geography (a.sensorLocation),
        geography (b.sensorLocation)
    )
FROM
    UKPlaces a,
    UKPlaces b
WHERE
    a.name = 'Wells'
    AND b.name = 'Truro';

SELECT name FROM UKPlaces
WHERE ST_DWithin(sensorLocation,ST_GeomFromText('POINT(-0.138702 51.501220)',4326)::geography, 250000);