# schema update for adding the inventory tracking feature
ALTER TABLE saleproduct ADD COLUMN profit FLOAT default '0.0' AFTER unitprice;
