CREATE OR REPLACE TABLE liquid-anchor-431301-p1.airbnb_toronto.Listings AS
SELECT *
FROM liquid-anchor-431301-p1.airbnb_toronto.Listings
WHERE SAFE_CAST(id AS INT64) IS NOT NULL
  AND neighbourhood IS NOT NULL;
 FROM `liquid-anchor-431301-p1.airbnb_toronto.Listings`