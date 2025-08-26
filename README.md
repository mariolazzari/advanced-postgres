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
