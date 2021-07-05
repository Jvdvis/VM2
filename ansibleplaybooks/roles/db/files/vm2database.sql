use vm2database;
CREATE TABLE IF NOT EXISTS `vm2database` (
   vm_id INT NOT NULL AUTO_INCREMENT,
   vm_name VARCHAR(100) NOT NULL,
   vm_ip VARCHAR(40) NOT NULL,
   reg_date VARCHAR(20) NOT NULL,
   PRIMARY KEY ( vm_id )
);