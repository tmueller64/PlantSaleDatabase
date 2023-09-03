<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.SortedMap"%>
<%@page import = "java.io.*,java.util.*" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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

<c:if test="${empty currentSaleId}">
  <sql:query var="r" dataSource="${pssdb}">
      SELECT activesaleID from org where org.id = ?;
    <sql:param value="${currentOrgId}"/>
  </sql:query>
  <c:set var="currentSaleId" value="${r.rows[0].activesaleID}"/>
</c:if>

<sql:query var="saleq" dataSource="${pssdb}">
    SELECT sale.name as name, salestart, saleend, org.phonenumber as phonenumber
        from sale, org where sale.id = ? and sale.orgID = org.id;
  <sql:param value="${currentSaleId}"/>
</sql:query>
<c:set var="sale" value="${saleq.rows[0]}"/>

<psstags:breadcrumb title="Import On-line Orders for ${sale.name}" page="importordersadmin.jsp"/>

<c:if test="${!empty errormsg}">
     <div class=errorMessage><span>${errormsg}</span></div>
     <c:set var="errormsg" scope="session" value=""/>
</c:if>
<psstags:showinfomsg/>

<div class="orderform">
    <p>Click on the "Choose File" button to upload the on-line orders CSV file. Then click Submit.
    <sql:query var="sellerq" dataSource="${pssdb}">
       SELECT id FROM seller WHERE orgId = ? AND firstname = 'Unmatched' AND lastname = 'Seller';
       <sql:param value="${currentOrgId}"/>
    </sql:query>
    <c:if test="${sellerq.rowCount == 0}">
        <p>To expedite on-line order entry, create a seller named "Unmatched Seller" which can be used as a temporary
            seller for on-line orders that cannot be matched with an existing seller.</p>
    </c:if>
    
    <form action="importordersuploadadmin.jsp" method = "post" enctype = "multipart/form-data">
        <p><input type="file" accept=".csv,text/csv" id="importFile" name="filename" size="50"></p>
        <p><input type="submit" name="submit" value="Submit"></p>
    </form>
</div>
</body>
</html>