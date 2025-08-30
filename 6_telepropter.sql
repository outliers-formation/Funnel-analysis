SELECT * FROM teleprompter_coding1f LIMIT 100 ;


DROP  TABLE if exists days;
CREATE  TABLE days
(
SELECT
  teleprompter_coding1f.distinct_id,
wEEKofyear(event_time2) AS WEEK,
weekday(event_time2) AS WEEKDAY,
to_days(event_time2) - TO_DAYS("2025-01-01") AS dayofyear

FROM teleprompter_coding1f);

SELECT * FROM days LIMIT 10000 ;

SELECT * FROM days WHERE distinct_id = '$device:user_00537276903347' ;
