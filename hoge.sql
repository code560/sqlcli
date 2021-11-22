WITH 
AsaNumber as (
  SELECT
    *
  FROM (
    SELECT 
      ROW_NUMBER() OVER() no,
      id,action,
      CASE
        WHEN action == '!mod' THEN date2
        ELSE date1
      END as date,
      CASE
        WHEN value4 <> '' THEN value4
        WHEN value3 <> '' THEN value3
        WHEN value2 <> '' THEN value2
        WHEN value1 <> '' THEN value1
        ELSE NULL
      END as val,
      CASE
        WHEN value4 <> '' THEN 'value4'
        WHEN value3 <> '' THEN 'value3'
        WHEN value2 <> '' THEN 'value2'
        WHEN value1 <> '' THEN 'value1'
        ELSE NULL
      END as name
    FROM -
  )
  WHERE val is not NULL AND name is not NULL
)

,AsaCode as (
SELECT
  code,
  val,
  COUNT(codeId) as 数
FROM (
  SELECT
    p.no, p.name, p.code, p.val, 
    a.id, a.action, a.date,
    p.code||'-'||p.val as codeId
  FROM (
    SELECT ROW_NUMBER() OVER() no, name, code, val
    FROM .\def\plans.csv
  ) as p
  LEFT JOIN (
    SELECT 
      MAX(no) as no,
      id,
      action,
      date,
      name,
      val
    FROM AsaNumber
    WHERE date <= date('1981-07-01', '','start of month') AND action <> 'fin'
    GROUP BY id
  ) as a ON p.name = a.name AND p.val = a.val
)
GROUP BY code
)

-- select * from AsaNumber
select * from AsaCode
