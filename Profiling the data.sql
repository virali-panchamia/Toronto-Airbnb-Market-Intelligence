-- -- Row count and null overview
-- select 
-- COUNT(*) AS total_rows,
--   COUNT(DISTINCT neighbourhood) AS unique_neighbourhoods,
--   COUNT(DISTINCT host_id) AS unique_hosts,
--   COUNTIF(reviews_per_month IS NULL) AS null_review_per_month,
--   COUNTIF(last_review IS NULL) AS null_last_review,
--   COUNTIF(license IS NOT NULL AND license != '') AS licensed_count
-- from `airbnb_toronto.Listings`


-- Room type distribution
SELECT
  room_type,
  COUNT(*) AS listing_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM `airbnb_toronto.Listings`
GROUP BY room_type
ORDER BY listing_count DESC


-- minimum nights distribution
select
 MIN(minimum_nights) AS min_val,
  MAX(minimum_nights) AS max_val,
  APPROX_QUANTILES(minimum_nights, 2)[OFFSET(1)] AS median_val,
  ROUND(AVG(minimum_nights), 1) AS avg_val
from `airbnb_toronto.Listings`


-- Multi listing hosts

SELECT
  COUNTIF(calculated_host_listings_count > 1) AS multi_listing_entries,
  COUNT(*) AS total,
  ROUND(COUNTIF(calculated_host_listings_count > 1) * 100.0 / COUNT(*), 1) AS pct
FROM `airbnb_toronto.Listings`