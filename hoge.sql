WITH 
Const as (
  SELECT '1981-03-01' as targetDate
)

,AsaNumber as (
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
  p.no, p.name, p.code, p.val, COALESCE(a.月数, 0) as 月数
FROM 
  (
    SELECT ROW_NUMBER() OVER() no, name, code, val
    FROM .\def\plans.csv
  ) as p 
  LEFT JOIN (
    SELECT
      name,
      val,
      COUNT(*) as 月数
    FROM (
      SELECT 
        MAX(no) as no,
        id,
        action,
        date,
        name,
        val
      FROM AsaNumber, Const
      -- WHERE date <= date('1981-03-01', '+1 months','start of month') AND action <> 'fin'
      WHERE date <= date(Const.targetDate, '+1 months','start of month') AND action <> 'fin'
      GROUP BY id
    )
    GROUP BY name, val
  ) as a
  ON p.name = a.name AND p.val = a.val
)


-- select * from AsaNumber
select * from AsaCode
