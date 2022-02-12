Information about Plant Sale System

Database: 
To create the database, do:
run mysql as root
CREATE DATABASE plantsale;
GRANT ALL PRIVILEGES ON plantsale.* TO 'plantsale'@'localhost' IDENTIFIED BY 'plantsale' WITH GRANT OPTION;
then run mysql as:
mysql -u plantsale -p plantsale 
(password is "plantsale")


NetBeans Application Server:
Admin username: admin
Admin password: adminadmin
Admin console running on port 4848


Troubleshooting Tips:

1. If there are extra rows in a Supplier Order, make sure the extra rows all have 0 flats ordered, and then run this SQL DELETE:

delete spo.* from saleproductorder as spo left join saleproduct as sp on spo.saleproductID=sp.id where sp.saleID=365 and spo.flatsordered = 0;

with the right sale ID. 

2. If there are "missing" orders - orders that have been entered and do not show up in reports, it may be because a seller was not entered for
the order. Fix this by updating all such orders with a given seller using:

update custorder set sellerID=21850 where sellerID is NULL and saleID=383;


Plant Sale System Design

The UI for the Plant Sale System consists of a number of Pages of various types.  The types of Pages are:
DataTablePage - a Page that shows a table of data, e.g. the list of customers. Operations:
delete one or more items
create a new item. This operation transitions to the PropertiesPage for the new item.
select an item for editing.  This operation transitions to the PropertiesPage for the item.
PropertiesPage - a Page that shows the properties for a single item, e.g., the name, address, etc. for a single customer. Operations:
Edit the properties for the item and save the changes (Save button).
Select DataTablePages for tables that are associated with this item.

TasksPage - a Page that lists a set of tasks (a menu), e.g., a list of reports

Pages are associated with one another.  DataTablePages are associated with a Properties page 
(for editing the properties of a selected item, 


Inventory Feature 

An "inventory" value will be added to the Properties tab for a supplied product. 
The default value will be 0 meaning that there is no limit to the inventory. 
The value will be the number of units, not the number of flats. 

An "Inventory" tab will be added to the Product tab. This tab will display an 
"inventory for active sales" number. If any supplied product has an inventory 
value of 0, then the inventory for all active sales will be "no limit". Otherwise 
it will be the sum of the inventory values for the supplied products for that product number. 
The number will be in order units, not flats. 

If the inventory value is not "no limit", the tab will also display a "remaining inventory" 
number that is calculated based on the existing active orders. Every time an order is 
entered or edited or whenever a supplied product inventory number is changed, the 
remaining inventory number will go up or down as appropriate, and if any entry causes 
the number to go below 0, that entry will not be allowed. This means that if orders 
have already been entered, you will not be able to enter an inventory number that 
would result in not having enough to cover the orders. 

The product properties tab will allow entry of an alternative product. 

Since the inventory tab is on the products page, org admins will not be able to see 
it. The error message that is displayed when a order entry exceeds the inventory will 
provide the number units remaining.  So for example if the order requested 5 units of 
some product and only 3 are remaining, the error message will say that 5 were requested 
and only 3 are available and will also report what alternative product an be selected. 
If the available inventory for the alternative is also 0, then it's alternative will 
be suggested (if non-zero), and so on. 

The remaining inventory number for each product will be recalculated every time
an order or inventory is edited and will be stored in the database. This will 
prevent having to examine every order every time an order is entered. However, 
if there is some problem with the software or the database is updated manually, 
it is conceivable that the remaining inventory number could be out of sync with 
the actual orders and inventory values, so there will be a "recalculate inventory" 
button on the inventory tab that will cause the remaining inventory number to be 
recalculated based on all existing orders in active sales and the supplied inventory values. 

The remaining inventory for a product must be recalculated when:
- a sale becomes active/inactive (recalculate from scratch) - currently manual via Tasks page
- the recalculate remaining inventory button is pressed (recalculate from scratch)
- the inventory for a supplied product is changed - currently manual via Tasks page
- mass delete of users via the admin tasks page - currently manual via Tasks page
- an order is created or edited 
- orders are deleted from seller, sale, customer pages

Modification for changing product num to string:

alter table product modify column num varchar(10) not null default '0';
alter table saleproduct modify column num varchar(10) not null;
alter table productgroupmember modify column productNum varchar(10) not null;
DELIMITER $$
CREATE FUNCTION rightNum(num TINYTEXT) RETURNS TINYTEXT
  DETERMINISTIC
BEGIN
  return RIGHT(CONCAT(SPACE(10), num), 10);
END;
$$
DELIMITER ;