<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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

<psstags:breadcrumb title="Customer Orders Report" page="${pageContext.request.requestURI}"/>

<c:choose>
  <c:when test="${!empty param.customize}">
    <c:set var="pnumfrom" value="${param.pnumfrom}" scope="session"/>
    <c:set var="pnumto" value="${param.pnumto}" scope="session"/>
  </c:when>
  <c:otherwise>
    <c:set var="pnumfrom" value="1" scope="session"/>
    <c:set var="pnumto" value="100000" scope="session"/>
  </c:otherwise>
</c:choose>

<div style="margin-top: 5px">
<form name="reportform" method="POST" action="">
<span>
<span class="textfieldlabel2">Product Range - From:</span>
<input type="text" name="pnumfrom" id="pnumfrom" size="6" value="${pnumfrom}">

<span class="textfieldlabel2">To:</span>
<input type="text" name="pnumto" size="6" value="${pnumto}">

<input type="submit" name="customize" value="Customize" onclick="runWaitScreen()">
</span>
</form>
</div>

<iframe src="rpcustorderspdf.jsp" width="100%" height="700">
   <p class="instructions">This browser does not support the iframe tag!</p>
</iframe>

</body>
</html>