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
    <c:set var="dtfrom" value="${param.dtfrom}" scope="session"/>
    <c:set var="dtto" value="${param.dtto}" scope="session"/>
    <c:set var="onlineOnly" value="${param.onlineOnly}" scope="session"/>
  </c:when>
  <c:otherwise>
    <sql:query var="dt" dataSource="${pssdb}">
        SELECT salestart, saleend FROM sale WHERE sale.id = ?;
      <sql:param value="${currentSaleId}"/>
    </sql:query>
    <c:set var="dtfrom" value="${dt.rows[0].salestart}" scope="session"/>
    <c:set var="dtto" value="${dt.rows[0].saleend}" scope="session"/> 
    <c:set var="onlineOnly" value="${param.onlineOnly}" scope="session"/>
    <c:set var="pnumfrom" value="1" scope="session"/>
    <c:set var="pnumto" value="100000" scope="session"/>
  </c:otherwise>
</c:choose>

        
        
<div style="margin-top: 5px">
<script type="text/javascript" src="CalendarPopup.js"></script>
<script language="JavaScript">document.write(getCalendarStyles());</script>

<form name="reportform" method="POST" action="">
<span>
<span class="textfieldlabel2">Date - From:</span>
<input type="text" name="dtfrom" id="dtfrom" size="10" value="${dtfrom}"
       onFocus="calfrom.select(document.reportform.dtfrom,'dtfromanchor','yyyy-MM-dd'); return false;">
<span id="dtfromanchor">&nbsp;</span>
<div id="dtfromcal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
<script>
     var calfrom = new CalendarPopup("dtfromcal");
</script>

<span class="textfieldlabel2">To:</span>
<input type="text" name="dtto" size="10" value="${dtto}"
       onFocus="calto.select(document.reportform.dtto,'dttoanchor','yyyy-MM-dd'); return false;">
<span id="dttoanchor">&nbsp;</span>
<div id="dttocal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
<script>
     var calto = new CalendarPopup("dttocal");
</script>

<input name="onlineOnly" type="checkbox" value="checked" ${param.onlineOnly}>Only On-line Orders</input>

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