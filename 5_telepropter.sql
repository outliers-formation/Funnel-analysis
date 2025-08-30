select DISTINCT teleprompter_hashed_fixed.distinct_id, 1 AS trial
from teleprompter_hashed_fixed
where teleprompter_hashed_fixed.event like 'app_close';

DROP  TABLE if exists time_tmp1;
CREATE  TABLE time_tmp1
(select teleprompter_hashed_fixed.*, 
CASE 
when teleprompter_hashed_fixed.event = 'app_close' then 1
ELSE 2
END AS sort
from teleprompter_hashed_fixed
ORDER BY distinct_id, event_time, sort
);

DROP  TABLE if exists time_tmp2;
CREATE  TABLE time_tmp2
(
SELECT
  time_tmp1.*,
  LEAD(event_time) OVER (ORDER BY distinct_id, event_time, sort) AS event_time_next,
  LEAD(distinct_id) OVER (ORDER BY distinct_id, event_time, sort) AS distinct_id_next,
  LEAD(event) OVER (ORDER BY distinct_id, event_time, sort) AS event_next
FROM time_tmp1);

DROP  TABLE if exists time_tmp3;
CREATE  TABLE time_tmp3
(
SELECT
  time_tmp2.*,
case 
	when distinct_id = distinct_id_next and EVENT <> 'app_close' AND event_next <> 'app_open' then event_time_next - event_time
	ELSE 0
END time
FROM time_tmp2);

DROP  TABLE if exists time_tmp4;
CREATE  TABLE time_tmp4
(
SELECT
  time_tmp3.*,
	FROM_UNIXTIME(time_tmp3.event_time) AS event_time1  ,
	FROM_UNIXTIME(time_tmp3.event_time_next) AS event_time2 
FROM time_tmp3);


DROP  TABLE if exists time_tmp5;
CREATE  TABLE time_tmp5
(
SELECT
  time_tmp4.*,
case 
	when time_tmp4.time<=600 then time
	ELSE 0
END TIME2,
WEEKofyear(event_time1) AS WEEK,
weekday(event_time1) AS WEEKDAY,
to_days(event_time1) AS TO_DAYS,
to_days(event_time1) - TO_DAYS("2025-01-01") AS dayofyear

FROM time_tmp4);

SELECT * FROM time_tmp5 LIMIT 1000;

SELECT COUNT(*), week FROM time_tmp5 
GROUP BY week
LIMIT 1000;
SELECT COUNT(*), weekday FROM time_tmp5 
GROUP BY weekday

LIMIT 1000;


DROP  TABLE if exists time_data;
CREATE  TABLE time_data
(
SELECT
	time_tmp5.distinct_id, SUM(time_tmp5.time2) AS all_TIME
FROM time_tmp5
GROUP BY distinct_id
);


SELECT * FROM time_data LIMIT 1000;


SELECT * FROM time_tmp5 LIMIT 1000;

DROP  TABLE if exists time_data2;
CREATE  TABLE time_data2
(
SELECT
	time_tmp5.distinct_id, avg(time_tmp5.time2) AS avg_TIME2
FROM time_tmp5
GROUP BY distinct_id
);

SELECT * FROM time_data2 LIMIT 1000;















































SELECT COUNT(*), country_code
FROM teleprompter_hashed_fixed
GROUP BY country_code;



DROP  TABLE if exists tmp_country;
CREATE  TABLE tmp_country
(
SELECT
  distinct_id,
  country_code,
  COUNT(*) AS occurrence_count,
  RANK() OVER (
    PARTITION BY distinct_id
    ORDER BY COUNT(*) DESC
  ) AS rank_within_id
FROM teleprompter_hashed_fixed
WHERE country_code NOT IN ("unknown")
GROUP BY distinct_id, country_code
ORDER BY distinct_id, rank_within_id);

-- SELECT * FROM tmp_country WHERE distinct_id = "$device:user_12977629472233";
-- SELECT * FROM teleprompter_hashed_fixed WHERE distinct_id = "$device:user_83238418308962";


DROP  TABLE if exists user_country;
CREATE  TABLE user_country
(
SELECT
  distinct_id,
  country_code
FROM tmp_country
WHERE rank_within_id =1
);

SELECT * FROM user_country;














SELECT COUNT(*), os_version
FROM teleprompter_hashed_fixed
GROUP BY os_version;




DROP  TABLE if exists tmp_osver;
CREATE  TABLE tmp_osver
(
SELECT
  distinct_id,
  os_version,
  COUNT(*) AS occurrence_count,
  RANK() OVER (
    PARTITION BY distinct_id
    ORDER BY COUNT(*) DESC
  ) AS rank_within_id
FROM teleprompter_hashed_fixed
WHERE os_version is NOT null
GROUP BY distinct_id, os_version
ORDER BY distinct_id, rank_within_id);

SELECT * FROM tmp_osver WHERE distinct_id = "$device:user_83238418308962";



DROP  TABLE if exists user_osver;
CREATE  TABLE user_osver
(
SELECT
  distinct_id,
  os_version
FROM tmp_osver
WHERE rank_within_id =1
);

SELECT * FROM user_osver ;






