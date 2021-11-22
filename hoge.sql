WITH 
Const as (
  SELECT '1981-06-01' targetDate
)

,AsaNumber as (
  SELECT
    *
  FROM (
    SELECT 
      ROW_NUMBER() OVER() _no,
      id,"action" _act,
      CASE
        WHEN "action" == '!mod' THEN date2
        ELSE date1
      END _date,
      CASE
        WHEN value4 <> '' THEN value4
        WHEN value3 <> '' THEN value3
        WHEN value2 <> '' THEN value2
        WHEN value1 <> '' THEN value1
        ELSE NULL
      END _val,
      CASE
        WHEN value4 <> '' THEN 'value4'
        WHEN value3 <> '' THEN 'value3'
        WHEN value2 <> '' THEN 'value2'
        WHEN value1 <> '' THEN 'value1'
        ELSE NULL
      END _name
    FROM -
  )
  WHERE _val is not NULL AND _name is not NULL
)

,AsDefined as (
  SELECT 
    ROW_NUMBER() OVER() _no, 
    "name" _name, 
    code _code, 
    val _val
  FROM .\def\plans.csv
)

,AsaCode as (
SELECT
  _no, _name, _code, _val
  ,COALESCE(( 
    SELECT
      _count
    FROM (
      SELECT _name, _val, COUNT(*) _count
      FROM (
        SELECT MAX(_no), _name, _val
        FROM AsaNumber, Const
        WHERE _date < date(Const.targetDate,'-1 months','start of month') AND _act <> 'fin'
        GROUP BY id
      ) as a
      WHERE p._name = a._name AND p._val = a._val
      GROUP BY _name, _val
    )
  ), 0) 月数1
  ,COALESCE(( 
    SELECT
      _count
    FROM (
      SELECT _name, _val, COUNT(*) _count
      FROM (
        SELECT MAX(_no), _name, _val
        FROM AsaNumber, Const
        WHERE _date < date(Const.targetDate,'start of month') AND _act <> 'fin'
        GROUP BY id
      ) as a
      WHERE p._name = a._name AND p._val = a._val
      GROUP BY _name, _val
    )
  ), 0) 月数2
  ,COALESCE(( 
    SELECT
      _count
    FROM (
      SELECT _name, _val, COUNT(*) _count
      FROM (
        SELECT MAX(_no), _name, _val
        FROM AsaNumber, Const
        WHERE _date < date(Const.targetDate,'+1 months','start of month') AND _act <> 'fin'
        GROUP BY id
      ) as a
      WHERE p._name = a._name AND p._val = a._val
      GROUP BY _name, _val
    )
  ), 0) 月数3
FROM AsDefined as p
)

,AsAggregate as (
SELECT
  _name, _code, _val, 月数1, 月数2, 月数3, (月数1 + 月数2 + 月数3) 合計, ((月数1 + 月数2 + 月数3) * _val) allVal
FROM AsaCode
)

-- select * from Const
-- select * from AsaNumber
-- select * from AsDefined
-- select * from AsaCode
select * from AsAggregate
