readme
---

# sample-m.csv

action  
- new
- !new
- mod
- !mod
- fin


# sql history
```
# 連番をつける
SELECT ROW_NUMBER() OVER() as no,id,action,date1 FROM - ORDER BY date1 DESC
```
---
```
# 複数列で排他的に値があればどれかを取得
SELECT id,action,MAX(date1),
  CASE WHEN value4 != '' THEN value4
       WHEN value3 != '' THEN value3
       WHEN value2 != '' THEN value2
       ELSE value1
    END as value
  FROM - 
  GROUP BY id
```
```
id,action,MAX(date1),value
001,mod,1981-04-15,50
002,fin,1981-06-15,1
003,!new,1981-06-11,30
004,new,1981-06-21,1
```
---
```
# actionの値に応じて数値を選択
SELECT id,action,MAX(date1),value1,value2,value3,value4,
  CASE WHEN action == '!new' THEN 0
       WHEN action == 'fin' THEN 0
       ELSE (
         CASE WHEN value4 != '' THEN value4
              WHEN value3 != '' THEN value3
              WHEN value2 != '' THEN value2
              ELSE value1
         END)
    END as val
  FROM - 
  GROUP BY id
```
```
id,action,MAX(date1),value1,value2,value3,value4,val
001,mod,1981-04-15,50,,,,50
002,fin,1981-06-15,1,,,,0
003,!new,1981-06-11,30,,,,0
004,new,1981-06-21,,,,1,1
```
---
```
# 指定日までのレコードで絞り込み
SELECT no,id,action,MAX(date1),value1,value2,value3,value4
  FROM numTable
  WHERE date1 < '1981-07-01'
  GROUP BY id
```
```
id,action,MAX(date1),value1,value2,value3,value4
001,mod,1981-04-15,50,,,
002,fin,1981-06-15,1,,,
003,!new,1981-06-11,30,,,
004,new,1981-06-21,,,,1
```
---
```
# 指定日とvalue1のあるレコードで絞り込み
WITH AsaNumber as (
  SELECT ROW_NUMBER() OVER() as no,*
  FROM -
)

SELECT MAX(no),id,action,date1,date2,value1,value2,value3,value4
  FROM AsaNumber
  WHERE date1 < '1981-07-01' AND value1 != ''
  GROUP BY id
```
```
MAX(no),id,action,date1,date2,value1,value2,value3,value4
3,001,mod,1981-04-15,1981-04-13,50,,,
8,002,fin,1981-06-15,1981-06-14,1,,,
7,003,!new,1981-06-11,1981-01-11,30,,,
11,006,new,1981-06-30,1981-06-30,10,,,20
```
---
```
# 数値の並び替えはText -> Intしたものでソートする
# と、桁考慮した並びになる。
SELECT 
  DISTINCT val
FROM AsaNumber
ORDER BY cast(val as int)
```
```
val
1
5
20
30
50
100
```
---
```
# 定義済みのコードを紐付ける
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
)

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
```
```
no,contractId,action,date1,date2,value1,value2,value3,value4,itemId
8,002,fin,1981-06-15,1981-06-14,1,,,,101
11,006,new,1981-06-30,1981-06-30,10,,,20,103
7,003,!new,1981-06-11,1981-01-11,30,,,,104
3,001,mod,1981-04-15,1981-04-13,50,,,,105
```
---
```
# コードごとに集計
# WITH句はカンマで複数連続で書く
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
```
```
itemId,COUNT(itemId)
101,1
103,1
104,1
105,1
```
---
```
# 定数を使う
WITH 
Const as (
  SELECT '1981-06-01' targetDate
)

SELECT MAX(_no), _name, _val
FROM AsaNumber, Const
WHERE _date < date(Const.targetDate,'-1 months','start of month') AND _act <> 'fin'
```
---
```
# ３ヶ月集計
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
```
```
_name,_code,_val,月数1,月数2,月数3
value1,101,1,1,1,1
value1,101,5,0,0,0
value1,101,10,0,0,0
value1,101,20,0,0,0
value1,101,30,0,0,1
value1,101,40,0,0,0
value1,101,50,1,1,1
```
---
```
# ３ヶ月集計の合計とVAL掛け値
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
```
```
_name,_code,_val,月数1,月数2,月数3,合計,allVal
value1,101,1,1,1,1,3,3
value1,101,5,0,0,0,0,0
value1,101,10,0,0,0,0,0
value1,101,20,0,0,0,0,0
value1,101,30,0,0,1,1,30
value1,101,40,0,0,0,0,0
value1,101,50,1,1,1,3,150
value1,101,100,0,0,0,0,0
value1,101,200,0,0,0,0,0
value1,101,500,0,0,0,0,0
value1,101,1000,0,0,0,0,0
value2,201,1,0,0,0,0,0
value2,201,2,0,0,0,0,0
value2,201,5,0,0,0,0,0
value2,201,10,0,0,0,0,0
value2,201,100,0,0,0,0,0
value3,301,1,0,0,0,0,0
value3,301,2,0,0,0,0,0
value3,301,5,0,0,0,0,0
value3,301,10,0,0,0,0,0
value3,301,20,0,0,0,0,0
value3,301,100,0,0,1,1,100
value4,401,1,0,0,1,1,1
value4,401,2,0,0,0,0,0
value4,401,5,0,0,0,0,0
value4,401,10,0,0,0,0,0
value4,401,20,0,0,1,1,20
value4,401,100,0,0,0,0,0
```



