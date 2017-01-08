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

<c:if test="${! empty param.id}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentProductId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select name from product where id = ?;
    <sql:param value="${currentProductId}"/>
</sql:query>

<psstags:breadcrumb title="Product - ${r.rows[0].name}" page="producteditadmin.jsp" var="currentProductId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="producteditadmin.jsp">
                          
 <psstags:tab name="Properties">
   <psstags:propsform table="product" itemid="${currentProductId}">
     <psstags:textfield label="Name" field="name" size="50"/>
     <psstags:textfield label="Number" field="num" size="5"/>
     <psstags:textfield label="Unit Price" field="unitprice" size="6"/>
   </psstags:propsform>
 </psstags:tab>
   
 </psstags:tabset>

</body>