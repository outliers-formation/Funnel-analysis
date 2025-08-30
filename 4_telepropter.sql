/*
CREATE TABLE `teleprompter_hashed` ( 
  `event` TEXT NULL,
  `event_time` BIGINT NULL,
  `distinct_id` TEXT NULL,
  `os_version` TEXT NULL,
  `country_code` TEXT NULL
);

CREATE TABLE `teleprompter`.`events_description` (
	`event_name` VARCHAR(250) NOT NULL,
	`event_english` VARCHAR(250) NOT NULL,
	`event_hungarian` VARCHAR(250) NOT NULL
)
*/


SELECT  COUNT(*) FROM teleprompter.teleprompter_hashed_fixed;
SELECT  * FROM teleprompter.teleprompter_hashed_fixed LIMIT 100;


SELECT  COUNT(*) FROM teleprompter.teleprompter_hashed;

DESC teleprompter.teleprompter_hashed;


select DISTINCT teleprompter_hashed.distinct_id
from teleprompter_hashed;

select DISTINCT teleprompter_hashed.os_version
from teleprompter_hashed;


select DISTINCT teleprompter_hashed.country_code
from teleprompter_hashed;

select DISTINCT teleprompter_hashed.event
from teleprompter_hashed;





/*DROP temporary TABLE if exists all_user;
CREATE TEMPORARY TABLE all_user
(select DISTINCT teleprompter_hashed.distinct_id
from teleprompter_hashed);*/

/*DROP temporary TABLE if exists trial_user;
CREATE TEMPORARY TABLE trial_user
(select DISTINCT teleprompter_hashed_fixed.distinct_id, 1 AS trial
from teleprompter_hashed_fixed
where teleprompter_hashed_fixed.event like 'trial_started_event');
SELECT * FROM trial_user;

DROP temporary TABLE if exists trial_cancelled_user;
CREATE TEMPORARY TABLE trial_cancelled_user
(select DISTINCT teleprompter_hashed_fixed.distinct_id, 1 AS cancelled
from teleprompter_hashed_fixed
where teleprompter_hashed_fixed.event like 'trial_cancelled_event');

DROP temporary TABLE if exists trial_converted_user;
CREATE TEMPORARY TABLE trial_converted_user
(select DISTINCT teleprompter_hashed_fixed.distinct_id, 1 AS converted
from teleprompter_hashed_fixed
where teleprompter_hashed.event like 'trial_converted_event');*/

/*DROP TABLE if exists user_status;
CREATE TABLE user_status
(SELECT all_user.distinct_id, trial_user.trial, 
trial_cancelled_user.cancelled, trial_converted_user.converted  FROM all_user
LEFT JOIN trial_user ON trial_user.distinct_id = all_user.distinct_id
LEFT JOIN trial_cancelled_user ON trial_cancelled_user.distinct_id = all_user.distinct_id
LEFT JOIN trial_converted_user ON trial_converted_user.distinct_id = all_user.distinct_id)
;

SELECT * FROM user_status;*/


/*DROP TABLE if  EXISTS teleprompter_hashed2 ;
CREATE TABLE teleprompter_hashed2 
(SELECT * FROM teleprompter.teleprompter_hashed
LEFT JOIN teleprompter.events_description ON 
teleprompter.events_description.event_name = teleprompter.teleprompter_hashed.event
);*/

-- SELECT * FROM teleprompter_hashed2 LIMIT 100;


-- rendeljünk hozzá olvasható dátumot
DROP TABLE if  EXISTS teleprompter_hashed3 ;
CREATE TABLE teleprompter_hashed3 
(SELECT teleprompter.teleprompter_hashed_fixed.*,
-- (SELECT teleprompter.teleprompter_hashed2.*,
FROM_UNIXTIME(teleprompter.teleprompter_hashed_fixed.event_time) AS event_time2  
FROM teleprompter.teleprompter_hashed_fixed
);

-- SELECT * FROM teleprompter_hashed3 LIMIT 10;



/* import kodolas */
-- rakjuk hozzá a kódokat
DROP TABLE if EXISTS teleprompter_coding1;
SELECT * FROM coding;
CREATE TABLE teleprompter_coding1
(SELECT teleprompter_hashed3.*, coding.kod FROM teleprompter_hashed3
LEFT JOIN coding ON coding.event_name = teleprompter_hashed3.`event`
);


-- SELECT COUNT(*) FROM teleprompter_coding1 ;
SELECT kod, COUNT(*) FROM teleprompter_coding1 
GROUP BY kod ;
-- az események kb 1/3-a olyan esemény, ami nem felhasználói interakció

/*SELECT * FROM teleprompter_coding1 LIMIT 100;
SELECT COUNT(*) FROM teleprompter_coding1 ;

SELECT kod, COUNT(*) FROM teleprompter_coding1
GROUP BY kod;

SELECT COUNT(*) FROM teleprompter_coding1 
WHERE kod IS NULL 
;*/


/*azt a rahedli hiányt még tisztázni kell a kiróval */

/*SELECT EVENT, COUNT(*) FROM teleprompter_coding1 
WHERE kod IS NULL 
GROUP BY event;*/


DROP TABLE if EXISTS teleprompter_coding1a;
CREATE TABLE teleprompter_coding1a
(
SELECT * FROM teleprompter_coding1
WHERE kod >0);



SELECT COUNT(*) FROM teleprompter_coding1a;
-- 18424070 esemány van ami kapott kódot

-- itt tartok
DROP TABLE if EXISTS kuka1;
CREATE TABLE kuka1
(SELECT distinct_id, COUNT(*) AS kuka1 
FROM teleprompter_coding1a
WHERE EVENT = 'trial_started_event'
GROUP BY distinct_id
HAVING  COUNT(*)>1);



DROP TABLE if EXISTS kuka2;
CREATE TABLE kuka2
(SELECT distinct_id, COUNT(*) AS kuka2
FROM teleprompter_coding1a
WHERE EVENT = 'trial_converted_event'
GROUP BY distinct_id
HAVING  COUNT(*)>1);



DROP TABLE if EXISTS kuka3;
CREATE TABLE kuka3
(SELECT distinct_id, COUNT(*) AS kuka3
FROM teleprompter_coding1a
WHERE EVENT = 'trial_cancelled_event'
GROUP BY distinct_id
HAVING  COUNT(*)>1);

SELECT * FROM kuka3;

-- SELECT COUNT(distinct distinct_id) FROM teleprompter_coding1a;

DROP TABLE if exists teleprompter_coding1b;
CREATE TABLE teleprompter_coding1b
(SELECT teleprompter_coding1a.* FROM teleprompter_coding1a
LEFT JOIN kuka1 ON kuka1.distinct_id = teleprompter_coding1a.distinct_id
LEFT JOIN kuka2 ON kuka2.distinct_id = teleprompter_coding1a.distinct_id
LEFT JOIN kuka3 ON kuka3.distinct_id = teleprompter_coding1a.distinct_id
WHERE kuka1.kuka1 IS  NULL and kuka2.kuka2 IS  NULL and kuka3.kuka3 IS NULL);
-- kidobjuk azokat, ahol nincs se trial, se cancelled, se subscription

-- SELECT COUNT(*) FROM teleprompter_coding1a;
-- SELECT COUNT(*) FROM teleprompter_coding1b;



DROP TABLE if EXISTS elofizetok;
CREATE TABLE elofizetok
(SELECT distinct distinct_id, 1 as elofizeto FROM teleprompter_coding1b
WHERE EVENT = "trial_converted_event"
);

DROP TABLE if EXISTS canceled_user;
CREATE TABLE canceled_user
(SELECT distinct distinct_id, 1 AS canceled FROM teleprompter_coding1b
WHERE EVENT = "trial_cancelled_event"
);

DROP TABLE if EXISTS start_trial_user;
CREATE TABLE start_trial_user
(SELECT distinct distinct_id, 1 AS trial FROM teleprompter_coding1b
WHERE EVENT = "trial_started_event"
);

drop temporary TABLE if EXISTS teleprompter_coding1c_tmp;
CREATE temporary TABLE teleprompter_coding1c_tmp
(SELECT teleprompter_coding1b.* , elofizetok.elofizeto, canceled_user.canceled, start_trial_user.trial
FROM teleprompter_coding1b
LEFT JOIN start_trial_user ON start_trial_user.distinct_id = teleprompter_coding1b.distinct_id
LEFT JOIN canceled_user ON canceled_user.distinct_id = teleprompter_coding1b.distinct_id
LEFT JOIN elofizetok ON elofizetok.distinct_id = teleprompter_coding1b.distinct_id
WHERE start_trial_user.trial IS NOT NULL 
-- AND  (elofizetok.elofizeto IS NULL and canceled_user.canceled IS NULL)
);
SELECT COUNT(*) FROM teleprompter_coding1c_tmp;
-- 2 959 369 esemény van olyan usereknél akiknél ismert hogy eljutottak a trialig. 
-- muszaj a többit kikukázni, mert a többieknél nem ismert hogy hogyan jutottak el a cancelledig ill. előfizetésig.




drop TABLE if EXISTS teleprompter_coding1c;
CREATE TABLE teleprompter_coding1c
(SELECT teleprompter_coding1b.* , elofizetok.elofizeto, canceled_user.canceled, start_trial_user.trial
FROM teleprompter_coding1b
LEFT JOIN start_trial_user ON start_trial_user.distinct_id = teleprompter_coding1b.distinct_id
LEFT JOIN canceled_user ON canceled_user.distinct_id = teleprompter_coding1b.distinct_id
LEFT JOIN elofizetok ON elofizetok.distinct_id = teleprompter_coding1b.distinct_id
WHERE start_trial_user.trial IS NOT NULL AND 
(elofizetok.elofizeto IS NOT NULL OR canceled_user.canceled IS NOT NULL)
);

SELECT COUNT(*) FROM teleprompter_coding1c;
-- 2 745 310 esemény van olyan usereknél, akik trial és cancelled/subscription


-- 17260 userünk van
SELECT COUNT(distinct distinct_id) FROM teleprompter_coding1c
;

drop TABLE if EXISTS teleprompter_coding1d;
CREATE TABLE teleprompter_coding1d
(SELECT * FROM teleprompter_coding1c
WHERE canceled IS NULL OR elofizeto IS NULL);


SELECT COUNT(*) FROM teleprompter_coding1d;

-- 16841
SELECT COUNT(distinct distinct_id) FROM teleprompter_coding1d;
-- 16 841 userünk maradt. kidobtuk azokat is, akik egyszerre cancelled és subscription is.
-- 2 575 934 eseményünk maradt


drop TABLE if EXISTS teleprompter_coding1e;
CREATE TABLE teleprompter_coding1e
(SELECT c1.* FROM teleprompter_coding1d c1
LEFT JOIN teleprompter_coding1d c2 ON c2.distinct_id = c1.distinct_id
WHERE (c2.event = "trial_cancelled_event" OR c2.event = "trial_converted_event")
AND c1.event_time <=c2.event_time);

SELECT COUNT(*) FROM teleprompter_coding1e;
SELECT COUNT(distinct distinct_id) FROM teleprompter_coding1e;
-- 2 092 489 eseményünk maradt, úgy, hogy kidobtunk minden eseményt, ami az előfizetés vagy a felmondás utáni
-- 16 841 a userszám nem változott



drop TABLE if EXISTS teleprompter_coding1f;
CREATE TABLE teleprompter_coding1f
(SELECT c1.* FROM teleprompter_coding1e c1
LEFT JOIN teleprompter_coding1e c2 ON c2.distinct_id = c1.distinct_id
WHERE c2.event = "trial_started_event" AND c1.event_time >= c2.event_time);

SELECT * FROM teleprompter_coding1f;
SELECT COUNT(*) FROM teleprompter_coding1f;
SELECT COUNT(distinct distinct_id) FROM teleprompter_coding1f;
-- 1 478 996 eseményünk marad, úgy hogy kidobtunk minden eseményt ami a trial előtt volt
-- 16 841 a userszám nem változott


-- mennyi időt töltött aktívan
drop temporary TABLE if EXISTS tmp_time;
CREATE temporary TABLE tmp_time
(SELECT c1.distinct_id, MAX(c1.event_time)- MIN(c1.event_time) AS total_time,
MAX(c1.event_time) AS maxi_,
MIN(c1.event_time) AS mini_,
COUNT(*) AS darab
FROM teleprompter_coding1f c1
GROUP BY c1.distinct_id
);

/*SELECT * FROM tmp_time 
WHERE distinct_id = '$device:user_13024108956385';

SELECT * FROM teleprompter_coding1f 
WHERE distinct_id = '$device:user_13024108956385';
*/
-- SELECT * FROM teleprompter_coding1f LIMIT 1000;

DROP TABLE if EXISTS mini;
CREATE TABLE mini
(SELECT distinct_id, kod, elofizeto, canceled, trial FROM teleprompter_coding1f
);


SELECT * FROM mini;

-- mennyi eseménye volt egy-egy kategóriából
DROP TABLE if EXISTS mini2;
CREATE TABLE mini2
(SELECT distinct_id,elofizeto, canceled, trial, kod,
COUNT(*)  OVER (PARTITION BY distinct_id, kod) AS kod_db
  FROM mini);
  

SELECT * FROM mini2 LIMIT 100;

/*DROP TABLE If EXISTS mini_tmp;
CREATE TABLE mini_tmp
(SELECT distinct_id, elofizeto, canceled, trial, kod, kod_db,
           ROW_NUMBER() OVER (PARTITION BY distinct_id, kod ORDER BY distinct_id) AS row_num
    FROM mini2
 )   ;
 
SELECT * FROM mini_tmp ORDER BY distinct_id, kod, row_num;
DROP TABLE If EXISTS mini3;
CREATE TABLE mini3
(SELECT * FROM mini_tmp 
WHERE row_num = 1
);*/

-- SELECT * FROM mini3 ORDER BY distinct_id, kod, row_num;

DROP TABLE If EXISTS mini4;
CREATE TABLE mini4
(SELECT mini2.*,tmp_time.total_time, tmp_time.maxi_, tmp_time.mini_, tmp_time.darab 
FROM mini2
LEFT JOIN tmp_time ON tmp_time.distinct_id = mini2.distinct_id
);


-- SELECT * FROM mini4 ORDER BY distinct_id, kod, row_num;

SELECT * FROM teleprompter_coding1 
WHERE distinct_id = '$device:user_00324547235046';


/*WITH CTE AS (
    SELECT distinct_id, 
           ROW_NUMBER() OVER (PARTITION BY distinct_id ORDER BY distinct_id) AS row_num
    FROM mini2
)
DELETE FROM mini2
WHERE distinct_id IN (
    SELECT distinct_id 
    FROM CTE
    WHERE row_num > 1
);*/


SELECT * FROM mini4;


SELECT * FROM coding WHERE event_name IN
(
'errorCatched',
'freeTrial_start',
'LiveStreamTutorialViewController',
'ManageAccountViewModel.reconnectAccountAction()',
'PlayerViewController.stopSpeechRecognition()',
'purchasestart',
'trial_cancelled_event',
'trigger_fire'

);