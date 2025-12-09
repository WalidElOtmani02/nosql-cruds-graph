// Create a user and a movie node using merge
// Merge is used so that if the node already exists, it gets reused, if it doesnt exist, the node will be created.
MERGE (u:User {id: 999999})
SET u.name = "Test User";

MERGE (ml:MovieLensMovie {movieId: 110});

// Simple read command
MATCH (u:User {id: 999999})
RETURN u;

// Updating the rating on a movie of a user
MATCH (u:User {id: 999999})-[r:RATED]->(ml:MovieLensMovie {movieId: 110})
SET r.rating = 5.0;

// Deleting user 
MATCH (u:User {id: 999999})
DETACH DELETE u;