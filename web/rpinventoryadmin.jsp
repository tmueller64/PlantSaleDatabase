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

<psstags:breadcrumb title="Remaining Inventory Report" page="${pageContext.request.requestURI}"/>


<psstags:report title="Remaining Inventory Report"
                columnNames="Number,Name,Remaining Inventory"
                columnTypes="text,text,number"
                doNotUseOrg="true"
                doNotCustomize="true">
   <jsp:attribute name="query">
        SELECT product.num, product.name, product.remaininginventory
        FROM product
        WHERE product.remaininginventory >= 0
        ORDER BY rightNum(product.num);
   </jsp:attribute>
</psstags:report>
</body>
</html>