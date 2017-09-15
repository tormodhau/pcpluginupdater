-- TEN-591
-- Set mobile-flag=0 for records which should not be selectable on mobile-flag
UPDATE prosjekt.key SET mobile=0 WHERE id > 35 AND id < 56;
UPDATE prosjekt.key SET mobile=0 WHERE id > 55 AND id < 67 AND id != 56 AND id != 57 and id != 59;