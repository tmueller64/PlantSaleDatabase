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

UPDATE product oldproduct
  INNER JOIN
    (SELECT product.id, inventory, ordered, remainingInventory(inventory, ordered) as rem from product
      INNER JOIN (SELECT productID, SUM(inventory) AS inventory FROM supplieritem GROUP BY productID) as supitem ON product.id = supitem.productID
      INNER JOIN (SELECT product.id AS id, SUM(custorderitem.quantity) AS ordered FROM custorderitem, product, saleproduct, sale, org 
            WHERE custorderitem.saleProductID = saleproduct.id AND 
                  product.num = saleproduct.num AND 
                  saleproduct.saleID = sale.id AND 
                  sale.id = org.activesaleID GROUP BY product.id) as orditem ON product.id = orditem.id)
    AS newproduct ON oldproduct.id = newproduct.id
  SET oldproduct.remaininginventory = newproduct.rem;
  

