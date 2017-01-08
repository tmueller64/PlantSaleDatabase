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

<psstags:breadcrumb title="Top Sellers Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Top Sellers Report"
                columnNames="Seller Name,Sales,Donations,Total Proceeds"
                columnTypes="text,money,money,money">
   <jsp:attribute name="query">
    SELECT CONCAT(lastname, ', ', firstname) as sname, sum(amount), sum(donation),
           sum(amount) * profit + sum(donation) as proceeds
    FROM (SELECT seller.lastname AS lastname, seller.firstname AS firstname, 
                 sum(custorderitem.quantity * saleproduct.unitprice) AS amount, 
                 sum(custorderitem.quantity) AS units,
                 donation AS donation, seller.id AS sid, sale.profit AS profit
            FROM custorder
            LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN seller ON custorder.sellerID = seller.id
            INNER JOIN sale ON custorder.saleID = sale.id
            WHERE seller.orgID = ${currentOrgId} and ${customcriteria}
            GROUP BY custorder.id) AS subtotal
    GROUP BY sid
    ORDER BY proceeds DESC, lastname, firstname;
   </jsp:attribute>
</psstags:report>
</body>
</html>