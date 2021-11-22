WITH 
Const as (
  SELECT '1981-03-01' as targetDate
)

,AsaNumber as (
  SELECT
    *
  FROM (
    SELECT 
      ROW_NUMBER() OVER() _no,
      id,"action" as _act,
      CASE
        WHEN "action" == '!mod' THEN date2
        ELSE date1
      END as _date,
      CASE
        WHEN value4 <> '' THEN value4
        WHEN value3 <> '' THEN value3
        WHEN value2 <> '' THEN value2
        WHEN value1 <> '' THEN value1
        ELSE NULL
      END as _val,
      CASE
        WHEN value4 <> '' THEN 'value4'
        WHEN value3 <> '' THEN 'value3'
        WHEN value2 <> '' THEN 'value2'
        WHEN value1 <> '' THEN 'value1'
        ELSE NULL
      END as _name
    FROM -
  )
  WHERE _val is not NULL AND _name is not NULL
)

,AsDefined as (
  SELECT 
    ROW_NUMBER() OVER() _no, 
    "name" as _name, 
    code as _code, 
    val as _val,
    "name"||'-'||val as _planId
  FROM .\def\plans.csv
)

,AsaCode as (
SELECT
  p._no, p._name, p._code, p._val, COALESCE(a.月数, 0) as 月数
  -- p._planId, COALESCE(a.月数, 0) as 月数
FROM AsDefined as p 
  LEFT JOIN (
    SELECT
      _name,
      _val,
      COUNT(*) as 月数
    FROM (
      SELECT 
        MAX(_no) as no,
        id,
        _act,
        _date,
        _name,
        _val
      FROM AsaNumber, Const
      WHERE _date <= date(Const.targetDate, '+1 months','start of month') AND _act <> 'fin'
      GROUP BY id
    )
    GROUP BY _name, _val
  ) as a
  ON p._name = a._name AND p._val = a._val
)


-- select * from Const
-- select * from AsaNumber
-- select * from AsDefined
select * from AsaCode
