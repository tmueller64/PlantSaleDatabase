# schema update for adding the inventory tracking feature
ALTER TABLE product ADD COLUMN remaininginventory INTEGER default '-1' AFTER unitprice;
ALTER TABLE product ADD COLUMN alternate INTEGER default '0' AFTER remaininginventory;
ALTER TABLE supplieritem ADD COLUMN inventory INTEGER default '0' AFTER costperflat;
DELIMITER $$
CREATE FUNCTION remainingInventory(inventory INTEGER, ordered INTEGER) RETURNS INTEGER
  DETERMINISTIC
BEGIN
  DECLARE rv INTEGER;
  IF (inventory = 0) THEN
    SET rv = -1;
  ELSEIF (ordered > inventory) THEN
    SET rv = 0;
  ELSE 
    SET rv = inventory - ordered;
  END IF;
  RETURN (rv);
END;
$$
DELIMITER ;
