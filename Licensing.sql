-- Overall licensing rate
SELECT
  CASE WHEN license IS NULL THEN 'No' ELSE 'Yes' END AS licensed_flag,
  COUNT(*) AS number_of_listings,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM airbnb_toronto.Listings), 1) AS pct_of_total
FROM `airbnb_toronto.Listings`
GROUP BY licensed_flag
ORDER BY number_of_listings DESC;

-- Licensing by neighbourhood
SELECT
  neighbourhood,
  COUNT(CASE WHEN license IS NULL THEN id ELSE NULL END) AS unlicensed,
  COUNT(CASE WHEN license IS NOT NULL THEN id ELSE NULL END) AS licensed,
  ROUND(COUNT(CASE WHEN license IS NOT NULL THEN id ELSE NULL END) * 1.0 / COUNT(*), 2) AS licensed_pct
FROM `airbnb_toronto.Listings`
GROUP BY neighbourhood
ORDER BY licensed DESC