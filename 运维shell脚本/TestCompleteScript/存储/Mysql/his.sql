-- ----------------------------
-- Procedure structure for doctor_patient_sync
-- ----------------------------
DROP PROCEDURE IF EXISTS `doctor_patient_sync`;
DELIMITER ;;
CREATE DEFINER=`enginer`@`localhost` PROCEDURE `doctor_patient_sync`()
BEGIN
truncate table his.doctor_patient_relation;
INSERT INTO `his`.`doctor_patient_relation`
(`doctor_id`,`patient_id`)
 SELECT t.doctor_id, t.patient_id FROM his.patient t;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for currval
-- ----------------------------
DROP FUNCTION IF EXISTS `currval`;
DELIMITER ;;
CREATE DEFINER=`enginer`@`%` FUNCTION `currval`(seq_name VARCHAR(50)) RETURNS int(11)
    DETERMINISTIC
BEGIN
         DECLARE value INTEGER;
         SET value = 0;
         SELECT current_value INTO value
                   FROM sequence
                   WHERE name = seq_name;
         RETURN value;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for nextval
-- ----------------------------
DROP FUNCTION IF EXISTS `nextval`;
DELIMITER ;;
CREATE DEFINER=`enginer`@`%` FUNCTION `nextval`(seq_name VARCHAR(50)) RETURNS int(11)
    DETERMINISTIC
BEGIN
         UPDATE sequence
                   SET current_value = current_value + increment
                   WHERE name = seq_name;
         RETURN currval(seq_name);
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for setval
-- ----------------------------
DROP FUNCTION IF EXISTS `setval`;
DELIMITER ;;
CREATE DEFINER=`enginer`@`%` FUNCTION `setval`(seq_name VARCHAR(50), value INTEGER) RETURNS int(11)
    DETERMINISTIC
BEGIN
         UPDATE sequence
                   SET current_value = value
                   WHERE name = seq_name;
         RETURN currval(seq_name);
END
;;
DELIMITER ;