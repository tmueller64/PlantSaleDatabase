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
                columnNames="Total Sales,Total Units"
                columnTypes="money,number"
                doNotUseOrg="true">
   <jsp:attribute name="query">
        SELECT sum(custorderitem.quantity * saleproduct.unitprice), 
               sum(custorderitem.quantity)
        FROM custorderitem, saleproduct, custorder, seller
        WHERE custorder.id = custorderitem.orderID and 
              custorder.sellerID = seller.id and
              custorderitem.saleproductID = saleproduct.id and
              ${customcriteria};
   </jsp:attribute>
</psstags:report>
</body>
</html>