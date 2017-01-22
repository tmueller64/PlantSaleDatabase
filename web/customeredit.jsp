<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<%@include file="/WEB-INF/jspf/head.jspf"%>
</head>
<body>
<%@include file="/WEB-INF/jspf/banner.jspf"%>
<c:if test="${! empty param.id}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentCustomerId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select firstname, lastname from customer where id = ?;
    <sql:param value="${currentCustomerId}"/>
</sql:query>
<psstags:breadcrumb title="Customer - ${r.rows[0].firstname} ${r.rows[0].lastname}" 
                    page="customeredit.jsp"
                    var="currentCustomerId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="customeredit.jsp">
<psstags:tab name="Properties">
  <psstags:propsform table="customer" itemid="${currentCustomerId}">
     <psstags:textfield label="First Name" field="firstname" size="30"/>
     <psstags:textfield label="Last Name" field="lastname" size="50"/>
     <psstags:textfield label="Address" field="address" size="100"/>
     <psstags:textfield label="City" field="city" size="50"/>
     <psstags:textfield label="State" field="state" size="10"/>  
     <psstags:textfield label="Zip" field="postalcode" size="10"/>
     <psstags:textfield label="Phone" field="phonenumber" size="15"/>
     <psstags:textfield label="Alt. Phone" field="phonenumber2" size="15"/>
     <psstags:textfield label="Email" field="email" size="50"/>
   </psstags:propsform>
</psstags:tab>

<psstags:tab name="Orders">
These are the orders that have been entered for this customer.
 <psstags:datatable title="Customer Orders"
    table="custorder"
    order="LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN seller ON custorder.sellerID = seller.id
            WHERE custorder.customerID = ${currentCustomerId}
            GROUP BY seller.lastname, seller.firstname, custorder.orderdate, custorder.id 
            ORDER BY custorder.orderdate, seller.lastname, seller.firstname"
    initialValues="(customerID) VALUES (${currentCustomerId})"
    columnNames="Order Date,Seller,Amount"
    columns="orderdate,concat(seller.lastname,', ',seller.firstname),sum(custorderitem.quantity * saleproduct.unitprice)"
    itemeditpage="editorder.jsp"
    itemnewpage="enterorder.jsp"
    extradeletesql="UPDATE product INNER JOIN
                     (SELECT product.id, quantity FROM product, custorderitem, saleproduct
                        WHERE orderId = ? AND saleproductID = saleproduct.id AND 
                              product.num = saleproduct.num AND
                              product.remaininginventory >= 0)
                      AS orditem ON product.id = orditem.id
                    SET remaininginventory = remaininginventory + orditem.quantity;
                 DELETE FROM custorderitem WHERE orderID = ?"/>
</psstags:tab>

</psstags:tabset>
</body>
</html>