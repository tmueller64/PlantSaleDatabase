# schema update for adding the inventory tracking feature
ALTER TABLE saleproduct ADD COLUMN profit FLOAT default '0.0' AFTER unitprice;

# schema update for adding default profit for a product
ALTER TABLE product ADD COLUMN prodprofit VARCHAR(6) default '' AFTER alternate;