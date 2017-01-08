Information about Plant Sale System

Database: 
To create the database, do:
run mysql as root
CREATE DATABASE plantsale;
GRANT ALL PRIVILEGES ON plantsale.* TO 'plantsale'@'%' IDENTIFIED BY 'plantsale' WITH GRANT OPTION;
then run mysql as:
mysql -u plantsale -p plantsale 
(password is "plantsale")

Deployment Details for petalsofmercy.com/PlantSale:
- the com/lowagie/text/pdf/fonts directory from the itext JAR file must be extracted into WEB-INF/classes to avoid a write permission violation


NetBeans Application Server:
Admin username: admin
Admin password: adminadmin
Admin console running on port 4848

TODO List
- need to prevent supplied product from being added twice to a supplier.
- provide table searching
- add ability to send email from the program

Troubleshooting Tips:

1. If there are extra rows in a Supplier Order, make sure the extra rows all have 0 flats ordered, and then run this SQL DELETE:

delete spo.* from saleproductorder as spo left join saleproduct as sp on spo.saleproductID=sp.id where sp.saleID=365 and spo.flatsordered = 0;

with the right sale ID. 

2. If there are "missing" orders - orders that have been entered and do not show up in reports, it may be because a seller was not entered for
the order. Fix this by updating all such orders with a given seller using:

update custorder set sellerID=21850 where sellerID is NULL and saleID=383;
