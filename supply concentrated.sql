--Where is the supply concentrated?
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
