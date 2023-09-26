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

<psstags:breadcrumb title="Total Sales by Organization Report" page="${pageContext.request.requestURI}"/>


<psstags:report title="Total Sales by Organization Report"
                columnNames="Organization,Total Sales,Total Units, Orders, On-line Orders"
                columnTypes="text,money,number,number,number"
                customizeProductRange="true"
                doNotUseOrg="true">
   <jsp:attribute name="query">
        SELECT org.name, sum(custorderitem.quantity * saleproduct.unitprice), 
               sum(custorderitem.quantity), 
               count(distinct custorder.id),
               count(distinct case when custorder.specialrequest like '%TID%' then custorder.specialrequest else NULL end)
        FROM org, custorderitem, saleproduct, custorder, seller
        WHERE org.id = seller.orgID and
              custorder.id = custorderitem.orderID and 
              custorder.sellerID = seller.id and
              custorderitem.saleproductID = saleproduct.id and
              ${customcriteria}
        GROUP BY org.id
        ORDER by org.name;
   </jsp:attribute>
</psstags:report>
</body>
</html>