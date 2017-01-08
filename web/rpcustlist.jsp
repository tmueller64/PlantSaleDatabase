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

<psstags:breadcrumb title="Customer Listing" page="${pageContext.request.requestURI}"/>

<psstags:report title="Customer Listing"
                addRowCount="true"
                columnNames="Name,Address,City,Zip,Phone"
                columnTypes="text,text,text,text,text">
   <jsp:attribute name="query">
        SELECT DISTINCT CONCAT(customer.firstname, ' ', customer.lastname), address, city, postalcode, phonenumber 
            FROM customer, custorder, seller  
            WHERE customer.orgID = ${currentOrgId} and 
                  custorder.customerID = customer.id and
                  custorder.sellerID = seller.id and
                  ${customcriteria}
            ORDER BY customer.lastname, customer.firstname;
   </jsp:attribute>
</psstags:report>
</body>
</html>