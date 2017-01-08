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

<psstags:breadcrumb title="Sales by Seller Group Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Sales by Seller Group Report"
                columnNames="Seller Group,Total Sales,Group Size,Avg. Sales per Seller,Total Units,Total Donations"
                columnTypes="text,money,number,money,number,money">
   <jsp:attribute name="query">
    SELECT sellergroup.name as sgname, sum(amount) as s1, COUNT(DISTINCT seller.id), sum(amount)/COUNT(DISTINCT seller.id) as avg, sum(units) as s2, sum(donation) as s3
    FROM seller
    LEFT JOIN (SELECT seller.lastname AS lastname, seller.firstname AS firstname,
                 sum(custorderitem.quantity * saleproduct.unitprice) AS amount,
                 sum(custorderitem.quantity) AS units,
                 donation AS donation, seller.id AS sid
            FROM custorder
            LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN seller ON custorder.sellerID = seller.id
            INNER JOIN sale ON custorder.saleID = sale.id
            WHERE seller.orgID = ${currentOrgId} and ${customcriteria}
            GROUP BY custorder.id) AS subtotal ON subtotal.sid = seller.id
    LEFT JOIN sellergroup ON sellergroup.id = seller.sellergroupID
    WHERE seller.orgID = ${currentOrgId} ${customsgroup}
    GROUP BY sellergroup.id
    HAVING s1 > 0 or s2 > 0 or s3 > 0
    ORDER BY avg DESC;
   </jsp:attribute>
</psstags:report>
</body>
</html>