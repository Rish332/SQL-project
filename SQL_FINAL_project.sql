create database ABC;
use abc;
select * from dim_brand_details;
select * from dim_drug_details;
select * from dim_form_details;
select * from dim_member_details;
select * from fact_fact_table;

ALTER TABLE `abc`.`dim_brand_details` 
CHANGE COLUMN `drug_brand_generic_code` `drug_brand_generic_code` INT NOT NULL ,
CHANGE COLUMN `drug_brand_generic_desc` `drug_brand_generic_desc` VARCHAR(100) NOT NULL ,
ADD PRIMARY KEY (`drug_brand_generic_code`);

ALTER TABLE `abc`.`dim_drug_details` 
CHANGE COLUMN `drug_ndc` `drug_ndc` INT(11) NOT NULL ,
CHANGE COLUMN `drug_name` `drug_name` VARCHAR(100) NOT NULL ,
CHANGE COLUMN `drug_form_code` `drug_form_code` CHAR(2) NOT NULL ,
CHANGE COLUMN `drug_brand_generic_code` `drug_brand_generic_code` INT(11) NOT NULL ,
ADD PRIMARY KEY (`drug_ndc`);

ALTER TABLE `abc`.`dim_drug_details` 
ADD INDEX `drug_form_code_idx` (`drug_form_code` ASC) VISIBLE,
ADD INDEX `drug_brand_generic_code_idx` (`drug_brand_generic_code` ASC) VISIBLE;

ALTER TABLE `abc`.`dim_drug_details` 
ADD CONSTRAINT `drug_form_code`
  FOREIGN KEY (`drug_form_code`)
  REFERENCES `abc`.`dim_form_details` (`drug_form_code`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
ADD CONSTRAINT `drug_brand_generic_code`
  FOREIGN KEY (`drug_brand_generic_code`)
  REFERENCES `abc`.`dim_brand_details` (`drug_brand_generic_code`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE `abc`.`dim_form_details` 
CHANGE COLUMN `drug_form_code` `drug_form_code` CHAR(2) NOT NULL ,
CHANGE COLUMN `drug_form_desc` `drug_form_desc` VARCHAR(100) NOT NULL ,
ADD PRIMARY KEY (`drug_form_code`);

ALTER TABLE `abc`.`dim_member_details` 
CHANGE COLUMN `member_id` `member_id` INT(11) NOT NULL ,
CHANGE COLUMN `member_first_name` `member_first_name` VARCHAR(100) NOT NULL ,
CHANGE COLUMN `member_last_name` `member_last_name` VARCHAR(100) NOT NULL ,
CHANGE COLUMN `member_birth_date` `member_birth_date` DATE NOT NULL ,
CHANGE COLUMN `member_age` `member_age` INT(11) NOT NULL ,
CHANGE COLUMN `member_gender` `member_gender` CHAR(2) NOT NULL ,
ADD PRIMARY KEY (`member_id`);

ALTER TABLE `abc`.`fact_fact_table` 
CHANGE COLUMN `fact_id` `fact_id` INT(11) NOT NULL ,
CHANGE COLUMN `member_id` `member_id` INT(11) NOT NULL ,
CHANGE COLUMN `fill_date` `fill_date` DATE NOT NULL ,
CHANGE COLUMN `copay` `copay` INT(11) NOT NULL ,
CHANGE COLUMN `insurancepaid` `insurancepaid` INT(11) NOT NULL ,
CHANGE COLUMN `drug_ndc` `drug_ndc` INT(11) NOT NULL ,
ADD PRIMARY KEY (`fact_id`),
ADD INDEX `member_id_idx` (`member_id` ASC) VISIBLE,
ADD INDEX `drug_ndc_idx` (`drug_ndc` ASC) VISIBLE;

ALTER TABLE `abc`.`fact_fact_table` 
ADD CONSTRAINT `member_id`
  FOREIGN KEY (`member_id`)
  REFERENCES `abc`.`dim_member_details` (`member_id`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE,
ADD CONSTRAINT `drug_ndc`
  FOREIGN KEY (`drug_ndc`)
  REFERENCES `abc`.`dim_drug_details` (`drug_ndc`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
  
  
  

SELECT 
    ddd.drug_name, COUNT(fft.fill_date) AS no_of_prescription
FROM
    fact_fact_table fft,
    dim_drug_details ddd
WHERE
    fft.drug_ndc = ddd.drug_ndc
GROUP BY drug_name;


SELECT 
    COUNT(fft.fill_date) AS no_of_prescription,
    COUNT(DISTINCT fft.member_id) AS distinct_members,
    SUM(fft.copay) AS sum_of_copay,
    SUM(fft.insurancepaid) AS sum_of_insuarance_paid,
    CASE
        WHEN dmd.member_age < 65 THEN 'Less than 65'
        WHEN dmd.member_age > 65 THEN 'greater than 65'
    END AS age_group
FROM
    dim_member_details dmd,
    fact_fact_table fft
WHERE
    fft.member_id = dmd.member_id
GROUP BY age_group;


CREATE TABLE fact_final AS SELECT * FROM
    fact_fact_table
ORDER BY fill_date DESC;

SELECT 
    ff.member_id,
    dmd.member_first_name,
    dmd.member_last_name,
    ddd.drug_name,
    fill_date,
    ff.insurancepaid
FROM
    fact_final ff,
    dim_drug_details ddd,
    dim_member_details dmd
WHERE
    ff.drug_ndc = ddd.drug_ndc
        AND ff.member_id = dmd.member_id
GROUP BY ff.member_id
ORDER BY fill_date DESC;



  