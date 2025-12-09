MATCH (p:Platform)-[:publishes]->(t:Text)
RETURN p.name AS Platform,
  t.Sentiment AS Sentiment,
  COUNT(*) AS Count
ORDER BY Count DESC;


MATCH (p:Platform)-[:publishes]->(t:Text)<-[:writes]-(u:User)
RETURN p, t, u;