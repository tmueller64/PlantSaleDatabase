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
                columnNames="Total Sales,Total Units,Orders,On-line Orders"
                columnTypes="money,number,number,number"
                doNotUseOrg="true">
   <jsp:attribute name="query">
        SELECT sum(custorderitem.quantity * saleproduct.unitprice), 
               sum(custorderitem.quantity),
               count(distinct custorder.id),
               count(distinct case when custorder.specialrequest like '%TID%' then custorder.specialrequest else NULL end)
        FROM custorderitem, saleproduct, custorder
        WHERE custorder.id = custorderitem.orderID and 
              custorderitem.saleproductID = saleproduct.id and
              ${customcriteria};
   </jsp:attribute>
</psstags:report>
</body>
</html>