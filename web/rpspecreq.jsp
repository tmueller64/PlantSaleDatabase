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

<psstags:breadcrumb title="Special Request Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Special Request Report"
                addRowCount="true"
                columnNames="Order Date,Customer Name,Phone,Seller,Special Request"
                columnTypes="text,text,text,text,text">
   <jsp:attribute name="query">
        SELECT DISTINCT orderdate, CONCAT(customer.lastname, ', ', customer.firstname) as cname, phonenumber,concat(seller.lastname,', ',seller.firstname), specialrequest
            FROM customer, custorder, seller  
            WHERE customer.orgID = ${currentOrgId} and 
                  custorder.customerID = customer.id and
                  custorder.sellerID = seller.id and
                  specialrequest != "" and
                  ${customcriteria}
            ORDER BY cname;
   </jsp:attribute>
</psstags:report>
</body>
</html>