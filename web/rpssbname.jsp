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

<psstags:breadcrumb title="Seller Sales by Name Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Seller Sales by Name Report"
                columnNames="Seller Name,Sales,Orders,Donations"
                columnTypes="text,money,number,money">
   <jsp:attribute name="query">             
    SELECT CONCAT(lastname, ', ', firstname) as sname, 
                 SUM(amount) as samount, 
		 COUNT(DISTINCT custorder.id) as sorders, 
                 SUM(donation)
        FROM custorder
        LEFT JOIN (SELECT custorder.id AS id, SUM(custorderitem.quantity * saleproduct.unitprice) AS amount,
	                  SUM(custorderitem.quantity) AS units
	             FROM custorder, custorderitem, saleproduct
	             WHERE custorderitem.orderID = custorder.id AND custorderitem.saleproductID = saleproduct.id
	             GROUP by custorder.id) AS ordertotal ON custorder.id = ordertotal.id
        INNER JOIN seller ON custorder.sellerID = seller.id
        WHERE seller.orgID = ${currentOrgId} and ${customcriteria}
        GROUP BY seller.id
        ORDER BY sname;
   </jsp:attribute>
</psstags:report>
</body>
</html>