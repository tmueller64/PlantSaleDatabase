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

<psstags:breadcrumb title="Total Sales Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Total Sales Report"
                columnNames="Total Sales,Total Units,Total Donations"
                columnTypes="money,number,money"> 
   <jsp:attribute name="query">
    SELECT sum(subtotal.amount), sum(subtotal.units), sum(subtotal.donation)
    FROM (SELECT sum(custorderitem.quantity * saleproduct.unitprice) AS amount, 
                 sum(custorderitem.quantity) AS units,
                 donation AS donation, seller.id
            FROM custorder
            LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN seller ON custorder.sellerID = seller.id
            INNER JOIN sale ON custorder.saleID = sale.id
            WHERE seller.orgID = ${currentOrgId} and ${customcriteria}
            GROUP BY custorder.id) AS subtotal;
   </jsp:attribute>
</psstags:report>
</body>
</html>