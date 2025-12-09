//CRUD
CREATE (:Sensor {id: 187, x: 10.0, y: 20.0});

MATCH (s:Sensor {id: 1})
RETURN s;

MATCH (s:Sensor {id: 1})
SET s.x = 22.5;

MATCH (m:Measurement {id: 187})
DETACH DELETE m;

// Beispiel Queries
MATCH (s:Sensor {id: 1})-[:Measures]->(m:Measurement)
RETURN m.timestamp, m.temperature
ORDER BY m.timestamp;

MATCH (s1:Sensor)-[r:Connected_to]-(s2:Sensor)
RETURN s1, r, s2;
