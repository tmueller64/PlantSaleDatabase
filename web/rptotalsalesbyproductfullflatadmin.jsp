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

<psstags:breadcrumb title="Total Sales by Product (Full Flats) Report" page="${pageContext.request.requestURI}"/>

<psstags:report title="Total Sales by Product (Full Flats) Report"
                columnNames="Number,Name,Units/Flat,Total Flats"
                columnTypes="text,text,number,number"
                doNotUseOrg="true">
   <jsp:attribute name="query">
        SELECT num, name, unitsperflat, sum(flats) AS sumflats
            FROM (SELECT custorder.saleID, saleproduct.num AS num, saleproduct.name AS name, 
                    unitsperflat, CEILING(SUM(custorderitem.quantity) / unitsperflat) AS flats
                 FROM org, custorderitem, saleproduct, custorder, seller, product
                 LEFT JOIN (SELECT productID, MIN(unitsperflat) AS unitsperflat FROM supplier, supplieritem
                        WHERE supplier.id = supplieritem.supplierID
			GROUP BY productID) AS suppitem ON suppitem.productID = product.id
                 WHERE org.id = seller.orgID AND
                       custorder.id = custorderitem.orderID AND
                       custorder.sellerID = seller.id AND
                       custorderitem.saleproductID = saleproduct.id AND
                       saleproduct.num = product.num AND ${customcriteria}
                 GROUP BY saleproduct.num, custorder.saleID
                 ORDER by saleproduct.num) as prodflats
	    GROUP BY num
            ORDER BY num;
   </jsp:attribute>
</psstags:report>
</body>
</html>