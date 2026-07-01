# Toronto-Airbnb-Market-Intelligence
A hands on data analysis project using real Airbnb listing data from Toronto. Analyze 15,000+ listings to answer four business questions, then deliver findings as a Power BI dashboard.

# The Brief

You're a data analyst at a property management startup expanding into Toronto's short-term rental market. Leadership needs a market intelligence report before committing resources.

Questions to answer:

- Supply concentration — Which neighbourhoods and room types dominate?
- Demand signals — Where is demand strongest? (review activity as a booking proxy)
- Competitive landscape — Professional operators vs casual hosts
- Regulatory compliance — How does licensing vary across the city?

# Dataset
Source: Airbnb — Toronto (https://insideairbnb.com/get-the-data/)

# Setup in Bigquery

# Start with fixing data quality and removing nulls
Removing all the null ids

CREATE OR REPLACE TABLE liquid-anchor-431301-p1.airbnb_toronto.Listings AS
SELECT *
FROM liquid-anchor-431301-p1.airbnb_toronto.Listings
WHERE SAFE_CAST(id AS INT64) IS NOT NULL
  AND neighbourhood IS NOT NULL;
 FROM `liquid-anchor-431301-p1.airbnb_toronto.Listings`

Understand the shape and quality of the data before answering the questions

--Row count and null overview
select 
COUNT(*) AS total_rows,
COUNT(DISTINCT neighbourhood) AS unique_neighbourhoods,
COUNT(DISTINCT host_id) AS unique_hosts,
COUNTIF(reviews_per_month IS NULL) AS null_review_per_month,
COUNTIF(last_review IS NULL) AS null_last_review,
COUNTIF(license IS NOT NULL AND license != '') AS licensed_count
from `airbnb_toronto.Listings`

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

# Answering the questions

1. Which neighboorhood has more supply?
-- Top 15 neighbourhoods by listing count

select
count(id) as listing_count,
neighbourhood
from
`airbnb_toronto.Listings`
group by neighbourhood
order by listing_count desc
limit 15


-- Top 15 neighbourhoods x room type
SELECT
  neighbourhood,
  room_type,
  COUNT(*) AS listing_count
FROM `airbnb_toronto.Listings`
WHERE neighbourhood IN (
  SELECT neighbourhood
  FROM `airbnb_toronto.Listings`
  GROUP BY neighbourhood
  ORDER BY COUNT(*) DESC
  LIMIT 15
)
GROUP BY neighbourhood, room_type
ORDER BY listing_count DESC;

-- Room type distribution
SELECT
  room_type,
  COUNT(*) AS listing_count
FROM `airbnb_toronto.Listings`
GROUP BY room_type
ORDER BY listing_count DESC;

2. Where is the demand strongest?

SELECT
  neighbourhood,
  COUNT(*) AS listing_count,
  ROUND(AVG(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0)), 2) AS avg_rpm,
  APPROX_QUANTILES(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0), 2)[OFFSET(1)] AS median_rpm,
  SUM(SAFE_CAST(number_of_reviews AS INT64)) AS total_reviews
FROM `airbnb_toronto.Listings`
WHERE SAFE_CAST(number_of_reviews AS INT64) > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 10
ORDER BY avg_rpm DESC
LIMIT 15;

3. Professional hosts VS Casual hosts

SELECT
  CASE
    WHEN calculated_host_listings_count > 1 THEN 'Professional'
    ELSE 'Casual'
  END AS host_type,
  COUNT(*) AS listing_count,
  ROUND(AVG(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0)), 2) AS avg_rpm,
  APPROX_QUANTILES(COALESCE(SAFE_CAST(reviews_per_month AS FLOAT64), 0), 2)[OFFSET(1)] AS median_rpm,
  SUM(SAFE_CAST(number_of_reviews AS INT64)) AS total_reviews,
  ROUND(AVG(availability_365)) AS avg_availability
FROM `airbnb_toronto.Listings`
WHERE SAFE_CAST(number_of_reviews AS INT64) > 0
GROUP BY host_type
HAVING COUNT(*) >= 10
ORDER BY avg_rpm DESC;

4. Compliance

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

Development of dashboard in Tableau

https://public.tableau.com/views/TorontoAirbnbMarketIntelligence/AirbnbMarketIntelligence?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link
 
