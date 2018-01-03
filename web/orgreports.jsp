<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
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

<c:if test="${! empty param.id and userrole == 'admin'}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentOrgId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select name from org where id = ?;
    <sql:param value="${currentOrgId}"/>
</sql:query>

<psstags:breadcrumb title="Organization - ${r.rows[0].name}" page="orgreports.jsp"/>

<psstags:tabset     defaultTab="Reports"
                        height="700px"
                         width="100%"
                          path="orgreports.jsp">

<psstags:tab name="Reports">
<p class="instructions">Select one of the following reports:</p>

<h2>Prize Administration Reports</h2>
<ul class="tasklist">
<li><a href="rpssbgroup.jsp" onclick="runWaitScreen()">Top Sellers sorted by Seller Group</a></li>
<li><a href="rpsgroupsum.jsp" onclick="runWaitScreen()">Seller Group Summary</a></li>
<li><a href="rptotalsales.jsp" onclick="runWaitScreen()">Total Sales</a></li>
</ul>
</psstags:tab>
</psstags:tabset>

</body>
</html>