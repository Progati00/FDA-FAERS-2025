# Create a new database called faers
create database faers;

# Switch to the faers database
use faers;

# View all rows from faers_2025_q2, outc25, demo
select * from faers_2025_q2;
select * from outc25;
select * from demo;

# Check first 10 rows from faers_2025_q2 ordered by primaryid
SELECT * FROM faers_2025_q2 ORDER BY primaryid LIMIT 10;

# Count records grouped by indi_pt in faers_2025_q2
SELECT indi_pt, COUNT(*) AS record_count FROM faers_2025_q2 GROUP BY indi_pt ORDER BY record_count DESC;

# Check first 10 rows from outc25 ordered by primaryid
SELECT * FROM outc25 ORDER BY primaryid LIMIT 10;

# Count records grouped by outc_cod in outc25
select outc_cod, count(*) as record_count from outc25 group by outc_cod order by record_count desc;

# Check first 10 rows from reac25 ordered by primaryid
SELECT * FROM reac25 ORDER BY primaryid LIMIT 10;

# Count records grouped by pt in reac25
select pt, count(*) as record_count from reac25 group by pt order by record_count desc;

# Check first 10 rows from rpspr ordered by primaryid
SELECT * FROM rpspr ORDER BY primaryid LIMIT 10;

# Count records grouped by rpsr_cod in rpspr
select rpsr_cod, count(*) as record_count from rpspr group by rpsr_cod order by record_count desc;

# View all rows from drug25 table
select * from drug25;

# Remove unnecessary columns from drug25
ALTER TABLE drug25 DROP COLUMN lot_num, DROP COLUMN exp_dt, DROP COLUMN nda_num, DROP COLUMN dose_amt,DROP COLUMN dose_unit, DROP COLUMN 
dose_form, DROP COLUMN dose_freq;

# Disable safe updates so we can update without using a key column
SET SQL_SAFE_UPDATES = 0;

# Replace NULL or blank dose_vbm with 'Unknown
UPDATE drug25 SET dose_vbm = 'Unknown' WHERE dose_vbm IS NULL OR TRIM(dose_vbm) = '';

# Remove unnecessary columns from drug25 table
ALTER TABLE drug25 DROP COLUMN dechal, DROP COLUMN rechal;

ALTER TABLE drug25 DROP COLUMN dose_vbm, DROP COLUMN cum_dose_chr, drop column cum_dose_unit;

# Replace NULL or blank route with 'Unknown'
UPDATE drug25 SET route = 'Unknown' WHERE route IS NULL OR TRIM(route) = '';

# View all rows from demo
select * from demo;

# Remove unnecessary columns from table demo 
alter table demo drop column i_f_code, drop column event_dt, drop column mfr_dt, drop column init_fda_dt, drop column fda_dt,
drop column rept_cod, drop column auth_num, drop column mfr_num, drop column mfr_sndr, drop column lit_ref, drop column age_cod,
drop column age_grp, drop column e_sub, drop column wt_cod, drop column rept_dt, drop column to_mfr, drop column occp_cod;

# Replace NULL or blank wt with 0 (since it's numeric)
UPDATE demo SET wt = 0 WHERE wt IS NULL OR TRIM(wt) = '';

# Disable safe updates
SET SQL_SAFE_UPDATES = 0;

# Remove rows from faers_2025_q2 where any important column is NULL
DELETE FROM faers_2025_q2 WHERE primaryid IS NULL OR caseid IS NULL OR indi_drug_seq IS NULL OR indi_pt IS NULL;

# Create a deduplicated version of faers_2025_q2
CREATE TABLE faers_2025_q2_clean AS SELECT DISTINCT * FROM faers_2025_q2; 

# Drop the old faers_2025_q2 table
DROP TABLE faers_2025_q2;

# Rename the cleaned table back to faers_2025_q2
RENAME TABLE faers_2025_q2_clean TO faers_2025_q2;

# Remove rows from outc25 with NULL values in key columns
DELETE FROM outc25 WHERE primaryid IS NULL OR caseid IS NULL OR outc_cod IS NULL;

# Remove rows from reac25 with NULL values in key columns
DELETE FROM reac25 WHERE primaryid IS NULL OR caseid IS NULL OR pt IS NULL;

# Remove rows from rpspr with NULL values in key columns
DELETE FROM rpspr WHERE primaryid IS NULL OR caseid IS NULL OR rpsr_cod IS NULL;


# INNER JOIN (only rows where primaryid AND caseid match in both tables)
SELECT f.primaryid, f.caseid, f.indi_drug_seq, f.indi_pt, o.outc_cod FROM faers_2025_q2 f INNER JOIN outc25 o
ON f.primaryid = o.primaryid AND f.caseid = o.caseid;

# LEFT JOIN (all rows from faers_2025_q2, matched with outc25 when possible)
SELECT f.primaryid, f.caseid, f.indi_drug_seq, f.indi_pt, o.outc_cod FROM faers_2025_q2 f LEFT JOIN outc25 o
ON f.primaryid = o.primaryid AND f.caseid = o.caseid;

# Joining just on primaryid
SELECT f.primaryid, f.caseid, f.indi_drug_seq, f.indi_pt, o.outc_cod FROM faers_2025_q2 f LEFT JOIN outc25 o
ON f.primaryid = o.primaryid;

# Join demo with all other tables
SELECT 
    d.primaryid, d.caseid, d.age, d.sex, d.wt, d.reporter_country, d.occr_country,
    dr.drug_seq, dr.role_cod, dr.drugname, dr.prod_ai, dr.val_vbm, dr.route,
    f.indi_drug_seq, f.indi_pt,
    o.outc_cod,
    r.pt
FROM demo d LEFT JOIN drug25 dr ON d.primaryid = dr.primaryid AND d.caseid = dr.caseid
LEFT JOIN faers_2025_q2 f ON d.primaryid = f.primaryid AND d.caseid = f.caseid
LEFT JOIN outc25 o ON d.primaryid = o.primaryid AND d.caseid = o.caseid
LEFT JOIN reac25 r ON d.primaryid = r.primaryid AND d.caseid = r.caseid
LEFT JOIN rpspr rp ON d.primaryid = rp.primaryid AND d.caseid = rp.caseid;


# Create a new table combined_faers with results of all LEFT JOINs
CREATE TABLE combined_faers AS SELECT 
    d.primaryid, d.caseid, d.age, d.sex, d.wt, d.reporter_country, d.occr_country,
    dr.drug_seq, dr.role_cod, dr.drugname, dr.prod_ai, dr.val_vbm, dr.route,
    f.indi_drug_seq, f.indi_pt,
    o.outc_cod,
    r.pt
FROM demo d LEFT JOIN drug25 dr ON d.primaryid = dr.primaryid AND d.caseid = dr.caseid
LEFT JOIN faers_2025_q2 f ON d.primaryid = f.primaryid AND d.caseid = f.caseid
LEFT JOIN outc25 o ON d.primaryid = o.primaryid AND d.caseid = o.caseid
LEFT JOIN reac25 r ON d.primaryid = r.primaryid AND d.caseid = r.caseid
LEFT JOIN rpspr rp ON d.primaryid = rp.primaryid AND d.caseid = rp.caseid;





