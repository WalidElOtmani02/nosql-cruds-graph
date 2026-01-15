//////////////////////////////////////////////////////
// 0. CONSTRAINTS
//////////////////////////////////////////////////////

// Movie
CREATE CONSTRAINT movie_id IF NOT EXISTS
FOR (m:Movie)
REQUIRE m.id IS UNIQUE;

// Person
CREATE CONSTRAINT person_id IF NOT EXISTS
FOR (p:Person)
REQUIRE p.id IS UNIQUE;

// Genre
CREATE CONSTRAINT genre_id IF NOT EXISTS
FOR (g:Genre)
REQUIRE g.id IS UNIQUE;

// Keyword
CREATE CONSTRAINT keyword_id IF NOT EXISTS
FOR (k:Keyword)
REQUIRE k.id IS UNIQUE;

// Company
CREATE CONSTRAINT company_id IF NOT EXISTS
FOR (c:Company)
REQUIRE c.id IS UNIQUE;

// Country
CREATE CONSTRAINT country_code IF NOT EXISTS
FOR (c:Country)
REQUIRE c.code IS UNIQUE;

// Language
CREATE CONSTRAINT language_code IF NOT EXISTS
FOR (l:Language)
REQUIRE l.code IS UNIQUE;

// User
CREATE CONSTRAINT user_id IF NOT EXISTS
FOR (u:User)
REQUIRE u.id IS UNIQUE;

// MovieLensMovie
CREATE CONSTRAINT ml_movie_id IF NOT EXISTS
FOR (ml:MovieLensMovie)
REQUIRE ml.movieId IS UNIQUE;


//////////////////////////////////////////////////////
// 1. MOVIES (movie_metadata.csv)
//////////////////////////////////////////////////////

LOAD CSV WITH HEADERS FROM 'file:///movie_metadata.csv' AS row
WITH row, toInteger(row.movie_id) AS movieId
WHERE movieId IS NOT NULL
MERGE (m:Movie {id: movieId})
SET m.imdb_id           = row.imdb_id,
    m.title             = row.title,
    m.original_title    = row.original_title,
    m.original_language = row.original_language,
    m.adult             = CASE row.adult
                            WHEN 'True'  THEN true
                            WHEN 'False' THEN false
                            ELSE null END,
    m.budget            = CASE WHEN row.budget = '' THEN 0 ELSE toInteger(row.budget) END,
    m.homepage          = row.homepage,
    m.overview          = row.overview,
    m.popularity        = CASE WHEN row.popularity = '' THEN null ELSE toFloat(row.popularity) END,
    m.poster_path       = row.poster_path,
    m.release_date      = row.release_date,
    m.revenue           = CASE WHEN row.revenue = '' THEN 0 ELSE toInteger(row.revenue) END,
    m.runtime           = CASE WHEN row.runtime = '' THEN null ELSE toFloat(row.runtime) END,
    m.status            = row.status,
    m.tagline           = row.tagline,
    m.video             = CASE row.video
                            WHEN 'True'  THEN true
                            WHEN 'False' THEN false
                            ELSE null END,
    m.vote_average      = CASE WHEN row.vote_average = '' THEN null ELSE toFloat(row.vote_average) END,
    m.vote_count        = CASE WHEN row.vote_count = '' THEN 0 ELSE toInteger(row.vote_count) END;


//////////////////////////////////////////////////////
// 2. GENRES (genres.csv & movie_genres.csv)
//////////////////////////////////////////////////////

// Genre nodes
LOAD CSV WITH HEADERS FROM 'file:///genres.csv' AS row
WITH row, toInteger(row.genre_id) AS genreId
WHERE genreId IS NOT NULL
MERGE (g:Genre {id: genreId})
SET g.name = row.name;

// Movie–Genre relationships
LOAD CSV WITH HEADERS FROM 'file:///movie_genres.csv' AS row
WITH row,
     toInteger(row.movie_id) AS movieId,
     toInteger(row.genre_id)  AS genreId
WHERE movieId IS NOT NULL AND genreId IS NOT NULL
MATCH (m:Movie {id: movieId})
MATCH (g:Genre {id: genreId})
MERGE (m)-[:IN_GENRE]->(g);


//////////////////////////////////////////////////////
// 3. KEYWORDS (keyword.csv & movie_keywords.csv)
//////////////////////////////////////////////////////

// Keyword nodes
LOAD CSV WITH HEADERS FROM 'file:///keyword.csv' AS row
WITH row, toInteger(row.keyword_id) AS keywordId
WHERE keywordId IS NOT NULL
MERGE (k:Keyword {id: keywordId})
SET k.name = row.name;

// Movie–Keyword relationships
LOAD CSV WITH HEADERS FROM 'file:///movie_keywords.csv' AS row
WITH row,
     toInteger(row.movie_id)    AS movieId,
     toInteger(row.keyword_id)  AS keywordId
WHERE movieId IS NOT NULL AND keywordId IS NOT NULL
MATCH (m:Movie {id: movieId})
MATCH (k:Keyword {id: keywordId})
MERGE (m)-[:HAS_KEYWORD]->(k);


//////////////////////////////////////////////////////
// 4. CAST (cast.csv)
//////////////////////////////////////////////////////

LOAD CSV WITH HEADERS FROM 'file:///cast.csv' AS row
WITH row,
     toInteger(row.movie_id)  AS movieId,
     toInteger(row.person_id) AS personId,
     CASE WHEN row.gender = '' THEN null ELSE toInteger(row.gender) END AS gender
WHERE movieId IS NOT NULL AND personId IS NOT NULL
MERGE (m:Movie  {id: movieId})
MERGE (p:Person {id: personId})
SET p.name   = row.name,
    p.gender = gender
MERGE (p)-[r:ACTED_IN {credit_id: row.credit_id}]->(m)
SET r.character  = row.character,
    r.cast_id    = CASE WHEN row.cast_id = '' THEN null ELSE toInteger(row.cast_id) END,
    r.cast_order = CASE WHEN row.cast_order = '' THEN null ELSE toInteger(row.cast_order) END;


//////////////////////////////////////////////////////
// 5. CREW (crew.csv)
//////////////////////////////////////////////////////

LOAD CSV WITH HEADERS FROM 'file:///crew.csv' AS row
WITH row,
     toInteger(row.movie_id)  AS movieId,
     toInteger(row.person_id) AS personId,
     CASE WHEN row.gender = '' THEN null ELSE toInteger(row.gender) END AS gender
WHERE movieId IS NOT NULL AND personId IS NOT NULL
MERGE (m:Movie  {id: movieId})
MERGE (p:Person {id: personId})
SET p.name   = row.name,
    p.gender = gender
MERGE (p)-[r:WORKED_ON {credit_id: row.credit_id}]->(m)
SET r.department = row.department,
    r.job        = row.job;


//////////////////////////////////////////////////////
// 6. PRODUCTION COMPANIES
//    (production_companies.csv & movie_production_companies.csv)
//////////////////////////////////////////////////////

// Company nodes
LOAD CSV WITH HEADERS FROM 'file:///production_companies.csv' AS row
WITH row, toInteger(row.company_id) AS companyId
WHERE companyId IS NOT NULL
MERGE (c:Company {id: companyId})
SET c.name = row.name;

// Movie–Company relationships
LOAD CSV WITH HEADERS FROM 'file:///movie_production_companies.csv' AS row
WITH row,
     toInteger(row.movie_id)   AS movieId,
     toInteger(row.company_id) AS companyId
WHERE movieId IS NOT NULL AND companyId IS NOT NULL
MATCH (m:Movie {id: movieId})
MATCH (c:Company {id: companyId})
MERGE (m)-[:PRODUCED_BY]->(c);


//////////////////////////////////////////////////////
// 7. PRODUCTION COUNTRIES
//    (production_countries.csv & movie_production_countries.csv)
//////////////////////////////////////////////////////

// Country nodes
LOAD CSV WITH HEADERS FROM 'file:///production_countries.csv' AS row
WITH row
WHERE row.country_code IS NOT NULL AND row.country_code <> ''
MERGE (c:Country {code: row.country_code})
SET c.name = row.name;

// Movie–Country relationships
LOAD CSV WITH HEADERS FROM 'file:///movie_production_countries.csv' AS row
WITH row,
     toInteger(row.movie_id) AS movieId,
     row.country_code        AS countryCode
WHERE movieId IS NOT NULL AND countryCode IS NOT NULL AND countryCode <> ''
MATCH (m:Movie {id: movieId})
MATCH (c:Country {code: countryCode})
MERGE (m)-[:PRODUCED_IN]->(c);


//////////////////////////////////////////////////////
// 8. SPOKEN LANGUAGES
//    (spoken_languages.csv & movie_spoken_languages.csv)
//////////////////////////////////////////////////////

// Language nodes
LOAD CSV WITH HEADERS FROM 'file:///spoken_languages.csv' AS row
WITH row
WHERE row.language_code IS NOT NULL AND row.language_code <> ''
MERGE (l:Language {code: row.language_code})
SET l.name = row.name;

// Movie–Language relationships
LOAD CSV WITH HEADERS FROM 'file:///movie_spoken_languages.csv' AS row
WITH row,
     toInteger(row.movie_id) AS movieId,
     row.language_code       AS languageCode
WHERE movieId IS NOT NULL AND languageCode IS NOT NULL AND languageCode <> ''
MATCH (m:Movie {id: movieId})
MATCH (l:Language {code: languageCode})
MERGE (m)-[:HAS_LANGUAGE]->(l);


//////////////////////////////////////////////////////
// 9. LINK MOVIELENSMOVIE TO MOVIE
//    (links_normalized.csv)
//////////////////////////////////////////////////////

LOAD CSV WITH HEADERS FROM 'file:///links_normalized.csv' AS row
WITH
  toInteger(row.movieId) AS movieId,
  toInteger(row.tmdbId)  AS tmdbId
WHERE movieId IS NOT NULL AND tmdbId IS NOT NULL
MATCH (m:Movie {id: tmdbId})
MERGE (ml:MovieLensMovie {movieId: movieId})
MERGE (ml)-[:SAME_MOVIE_AS]->(m);


//////////////////////////////////////////////////////
// 10. RATINGS (ratings.csv) – BATCHED IMPORT
//////////////////////////////////////////////////////

LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row
CALL {
  WITH row
  WITH
    toInteger(row.userId)    AS userId,
    toInteger(row.movieId)   AS movieId,
    toFloat(row.rating)      AS rating,
    toInteger(row.timestamp) AS ts
  WHERE userId IS NOT NULL AND movieId IS NOT NULL

  MERGE (u:User {id: userId})
  MERGE (ml:MovieLensMovie {movieId: movieId})
  MERGE (u)-[r:RATED]->(ml)
  SET r.rating    = rating,
      r.timestamp = ts
} IN TRANSACTIONS OF 10000 ROWS;
