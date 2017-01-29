drop table if exists product;
CREATE TABLE product (
id INTEGER auto_increment ,
name VARCHAR(30) NOT NULL default 'New Product Name',
num INTEGER default '0',
unitprice NUMERIC(8,2) NOT NULL default '0',
remaininginventory INTEGER default '-1',
alternate INTEGER default '0',
PRIMARY KEY (id), UNIQUE KEY (num)
);

drop function if exists remainingInventory;
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

drop table if exists supplier;
CREATE TABLE supplier (
id INTEGER auto_increment ,
name VARCHAR(30) NOT NULL default 'New Supplier Name',
address varchar(255),
city varchar(50),
state varchar(20),
postalcode varchar(20),
phonenumber varchar(30),
faxnumber varchar(30),
contactname varchar(30), 
PRIMARY KEY (id)
);

drop table if exists supplieritem;
CREATE TABLE supplieritem (
id INTEGER auto_increment ,
supplierID INTEGER default '0',
productID INTEGER default '0',
unitsperflat INTEGER default '0',
costperflat NUMERIC(8,2) NOT NULL default '0',
inventory INTEGER default '0',
PRIMARY KEY (id)
);

drop table if exists supplierorder;
CREATE TABLE supplierorder (
id INTEGER auto_increment,
supplierID INTEGER default '0',
supplierdeliveryID INTEGER default '0',
expecteddeliverydate DATE NOT NULL default '1900-01-01',
actualdeliverydate DATE,
deladdress varchar(100),
delcity varchar(30),
delstate varchar(10),
delpostalcode varchar(10),
PRIMARY KEY (id)
);

drop table if exists org;
CREATE TABLE org (
id INTEGER auto_increment ,
name VARCHAR (50)  NOT NULL default 'New Organization Name',
address varchar(100),
city varchar(30),
state varchar(10),
postalcode varchar(10),
phonenumber varchar(15),
contactname varchar(50),
activesaleID INTEGER default '0', 
PRIMARY KEY (id)
);

drop table if exists user;
CREATE TABLE user (
id INTEGER auto_increment ,
orgID INTEGER default '0',
username VARCHAR (32)  NOT NULL default '',
password VARCHAR (32)  NOT NULL default '',
role VARCHAR(10) NOT NULL default '',
PRIMARY KEY (id), UNIQUE KEY (username)
);

drop table if exists sellergroup;
CREATE TABLE sellergroup (
id INTEGER auto_increment ,
orgID INTEGER default '0',
name VARCHAR (32)  NOT NULL default '',
insellergroupID INTEGER default '0',
active VARCHAR (3) NOT NULL default 'yes',
PRIMARY KEY (id)
);

drop table if exists seller;
CREATE TABLE seller (
id INTEGER auto_increment ,
orgID INTEGER default '0',
firstname VARCHAR (30)  NOT NULL default '',
lastname VARCHAR (50)  NOT NULL default '',
familyname VARCHAR (50)  NOT NULL default '',
sellergroupID INTEGER default '0',
PRIMARY KEY (id),
KEY lastname (lastname), KEY (sellergroupID)
);

drop table if exists customer;
CREATE TABLE customer (
id INTEGER auto_increment ,
orgID INTEGER default '0',
firstname varchar(30), 
lastname varchar(50),
address varchar(255),
city varchar(50),
state varchar(20),
postalcode varchar(20),
phonenumber varchar(30),
phonenumber2 varchar(30),
email varchar(50),
PRIMARY KEY (id)
);

drop table if exists sale;
CREATE TABLE sale (
id INTEGER auto_increment ,
name varchar(30),
theme varchar(50),
coordname varchar(30),
orgID INTEGER default '0',
salestart DATE NOT NULL default '2000-01-01',
saleend DATE NOT NULL default '2000-01-01',
profit FLOAT default '0.40',
PRIMARY KEY (id)
);

drop table if exists saleproduct;
CREATE TABLE saleproduct (
id INTEGER auto_increment ,
saleID INTEGER default '0',
name VARCHAR(30),
num INTEGER default '0',
unitprice NUMERIC(8,2) NOT NULL default '0',
profit FLOAT default '0.0',
PRIMARY KEY (id)
);

drop table if exists saleproductorder;
CREATE TABLE saleproductorder (
id INTEGER auto_increment ,
saleproductID INTEGER default '0',
supplierID INTEGER default '0',
supplierorderID INTEGER default '0',
flatsordered INTEGER default '0',
flatsdelivered INTEGER default '0',
PRIMARY KEY (id)
);

drop table if exists transfer;
CREATE TABLE transfer (
id INTEGER auto_increment ,
fromsaleID INTEGER default '0',
tosaleID INTEGER default '0', 
saleproductID INTEGER default '0', 
expectedquantity INTEGER default '0', 
actualquantity INTEGER default '0',
PRIMARY KEY (id)
);

drop table if exists custorder;
CREATE TABLE custorder (
id INTEGER auto_increment ,
customerID INTEGER default '0',
sellerID INTEGER default '0',
saleID INTEGER default '0',
orderdate DATE NOT NULL default '1900-01-01',
specialrequest VARCHAR (255)  NOT NULL default '',
donation NUMERIC(8,2) NOT NULL default '0',
doublechecked BOOLEAN default false,
PRIMARY KEY (id), KEY (sellerID)
);

drop table if exists custorderitem;
CREATE TABLE custorderitem (
id INTEGER auto_increment ,
orderID INTEGER default '0',
saleproductID INTEGER default '0',
quantity INTEGER NOT NULL default '0',
PRIMARY KEY (id), KEY (orderID), KEY (saleproductID)
);

insert into org values (1, "Janet's Jungle", "950 N. Nye Avenue", "Fremont", "NE", "68025", "402-980-3807", "Janet Saeger", 0);
insert into user values (1, 1, "admin", "jj", "admin");
insert into product values (1, "Mums", 1, 2.50); 
insert into product values (2, "Lillies", 2, 3.00);
insert into product values (3, "Tree", 3, 10.00);
insert into supplier values (1, "DeJong", "123 Some Street", "Somecity", "IA", "5xxxx", "xxx-xxx-xxxx", "xxx-xxx-afax", "Some Iowa Guy");
insert into supplier values (2, "Michigan Westshores", "123 Some Street", "Somecity", "MI", "3xxxx", "xxx-xxx-xxxx", "xxx-xxx-afax", "Some Michigan Guy");
insert into supplieritem values (1, 1, 1, 6, "6.25", 0);
insert into org values (2, "Trinity Lutheran School", "1546 N. Luther Road", "Fremont", "NE", "68025", "402-721-5959", "Jim Knoepfel", 1);
insert into org values (3, "WOLSA", "156th and Fort", "Omaha", "NE", "6xxxx", "402-xxx-xxxx", "David Mueller", 0);
insert into user values (2, 1, "a", "jj", "admin");
insert into user values (3, 2, "trinity", "matthew", "dataentry");
insert into user values (4, 2, "trinityadmin", "matthew", "orgadmin");
insert into user values (5, 3, "wolsa", "mark", "dataentry");
insert into sellergroup values (1, 2, "5th Grade", 0, "yes");
insert into seller values (1, 2, "Becky", "Mueller", "Tom & Barb Mueller", 1);
insert into customer values (1, 2, "Glenn", "Mueller", "1924 Phelps Avenue", "Fremont", "NE", "68025", "4027271796", "", "mary_mueller@yahoo.com");
insert into sale values (1, '2005 Sale', 'Grow, Grow, Grow', 'Jen & Jen', 2, '2005-3-15', '2005-4-30', 0.40);
insert into sale values (2, '2006 Sale', 'Kingdom Growth', 'Steve', 2, '2006-3-15', '2006-4-30', 0.40);
insert into saleproduct values (1, 1, "Mums", 1, 2.00);
insert into saleproduct values (2, 1, "Lillies", 2, 3.00);
insert into saleproduct values (4, 1, "Tree", 3, 10.00);
insert into saleproduct values (3, 2, "Better Mums", 1, 2.50);
insert into custorder values (1, 1, 1, 1, '2005-4-1', "no special request", 3.00, false);
insert into custorderitem values (1, 1, 1, 3);
insert into saleproductorder values(1, 1, 1, 0, 2, 0);
insert into saleproductorder values(2, 1, 2, 0, 1, 0);




