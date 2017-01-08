<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
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

<psstags:breadcrumb title="Order Listing Report" page="${pageContext.request.requestURI}"/>


<psstags:report title="Order Listing Report"
                columnNames="Seller,Order Date,Customer,Phone,Amount"
                columnTypes="text,text,text,text,money">
   <jsp:attribute name="query">
   SELECT concat(seller.lastname,', ',seller.firstname), 
          orderdate,
          concat(customer.lastname,', ',customer.firstname),
          customer.phonenumber,
          sum(custorderitem.quantity * saleproduct.unitprice)
     FROM custorder
       LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
       LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
       INNER JOIN customer ON custorder.customerID = customer.id
       INNER JOIN seller ON custorder.sellerID = seller.id
       WHERE seller.orgID = ${currentOrgId} and ${customcriteria}
       GROUP BY customer.lastname, customer.firstname, custorder.orderdate, custorder.id 
       ORDER BY seller.lastname, seller.firstname, customer.lastname, customer.firstname, custorder.orderdate;
   </jsp:attribute>
</psstags:report>
</body>
</html>