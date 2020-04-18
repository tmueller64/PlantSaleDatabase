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

<psstags:breadcrumb title="Top Sellers by Seller Group Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Top Sellers by Seller Group Report"
                columnNames="Seller Group,Seller Name,Sales,Donations,Total Proceeds"
                columnTypes="text,text,money,money,money">
   <jsp:attribute name="query">             
    SELECT sgname, CONCAT(lastname, ', ', firstname) as sname, sum(amount), sum(donation),
           sum(pamount) + sum(donation) as proceeds
    FROM (SELECT seller.lastname AS lastname, seller.firstname AS firstname, 
                 sum(custorderitem.quantity * saleproduct.unitprice) AS amount, 
                 sum(custorderitem.quantity) AS units,
                 sum(custorderitem.quantity * saleproduct.unitprice * saleproduct.profit) as pamount,
                 donation AS donation, seller.id AS sid, sellergroup.name AS sgname
            FROM custorder
            LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN seller ON custorder.sellerID = seller.id
            INNER JOIN sale ON custorder.saleID = sale.id
            INNER JOIN sellergroup ON seller.sellergroupID = sellergroup.id
            WHERE seller.orgID = ${currentOrgId} and ${customcriteria}
            GROUP BY custorder.id) AS subtotal
    GROUP BY sid
    ORDER BY sgname, proceeds DESC, lastname, firstname;
   </jsp:attribute>
</psstags:report>
</body>
</html>