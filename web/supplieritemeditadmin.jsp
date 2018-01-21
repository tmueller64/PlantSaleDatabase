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
        <c:set scope="session" var="currentSupplierItemId" value="${pid}"/>
    </c:if>

    <sql:query var="r" dataSource="${pssdb}">
        SELECT product.name FROM product,supplieritem WHERE product.id = supplieritem.productID and supplieritem.id = ?;
        <sql:param value="${currentSupplierItemId}"/>
    </sql:query>

    <psstags:breadcrumb title="Supplied Product - ${r.rows[0].name}" page="supplieritemeditadmin.jsp" var="currentSupplierItemId"/>

    <psstags:tabset defaultTab="Properties"
                    height="700px"
                    width="100%"
                    path="supplieritemeditadmin.jsp">
                          
   <psstags:tab name="Properties">
       <psstags:propsform table="supplieritem" itemid="${currentSupplierItemId}">
           <%-- drop down for product --%>
           <psstags:inputfield label="Product">
               <sql:query var="pq" dataSource="${pssdb}">
               SELECT id, num, name FROM product ORDER BY rightNum(num);
               </sql:query>
               <select name="productID">
                   <c:forEach var="p" items="${pq.rows}">
                       <option value="${p.id}" <c:if test="${row['productID'] == p.id}">selected="true"</c:if>>${p.num}. ${p.name}</option>
                   </c:forEach>
               </select>
           </psstags:inputfield>
           <psstags:textfield label="Units per Flat" field="unitsperflat" size="5"/>
           <psstags:textfield label="Cost per Flat" field="costperflat" size="6"/>
           <psstags:textfield label="Inventory" field="inventory" size="6" note="Enter 0 for no limit; value is in units, not flats."/>
       </psstags:propsform>
   </psstags:tab>
       
    </psstags:tabset>

</body>
</html>