WITH AsaNumber as (
  SELECT 
    ROW_NUMBER() OVER() as no,
    *,
    CASE WHEN value4 != '' THEN value4
      WHEN value3 != '' THEN value3
      WHEN value2 != '' THEN value2
      ELSE value1
    END as val
  FROM -
),

AsaCode as (
  SELECT 
    MAX(a.no) as no,
    a.id as contractId,
    a.action as action,
    a.date1 as date1,
    a.date2 as date2,
    a.value1 as value1,
    a.value2 as value2,
    a.value3 as value3,
    a.value4 as value4,
    p.id as itemId
  FROM AsaNumber as a
    LEFT JOIN .\def\plans.csv as p ON a.val = p.plan
  WHERE date1 < '1981-07-01' AND value1 != ''
  GROUP BY contractId
  ORDER BY itemId
)

SELECT
  itemId,
  COUNT(itemId)
FROM AsaCode
GROUP BY itemId
