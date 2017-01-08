<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.Date" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <%@include file="/WEB-INF/jspf/head.jspf"%>
    </head>
    <body>
        <psstags:accesscheck/>

        <sql:query var="oq" dataSource="${pssdb}">
            SELECT org.name as oname,address,city,state,postalcode,contactname,activesaleID,sale.name as sname
            FROM org,sale
            WHERE org.id = ? and org.activesaleID = sale.id;
            <sql:param value="${currentOrgId}"/>
        </sql:query>
        <c:set var="o" value="${oq.rows[0]}"/>
        <c:set var="activeSaleId" scope="request" value="${o.activesaleID}"/>
<div class="report">
<table width="100%">
<tr>
<th colspan="2" style="text-align: left; border-right: 0px">${o.sname}</th>
<th style="text-align: right; border-left: 0px">Date:</th>
<td><fmt:formatDate value="<%= new Date(System.currentTimeMillis()) %>" type="date"/></td>
<tr><th style="text-align: right; border: 0; background: white; vertical-align: top; width: 50px">To:</th>
<td style="border: 0" colspan="3">
${o.oname}<br>
Attn: ${o.contactname}<br>
${o.address}<br>
${o.city}, ${o.state}  ${o.postalcode}<br>
</td>
</tr>
</table>
<br>
<sql:transaction dataSource="${pssdb}">
    <sql:query var="r">
     SELECT concat(cast(saleproduct.num as char), '. ', saleproduct.name) as pname, 
            custorder.unitspreordered as preordered,
            ifnull(unitsordered,0) - custorder.unitspreordered as extras,
            ifnull(unitsordered,0) as totaldel
            FROM saleproduct
            INNER JOIN sale ON sale.id = saleproduct.saleID
            LEFT JOIN (SELECT saleproduct.id AS id, sum(custorderitem.quantity) AS unitspreordered 
                              FROM saleproduct, custorderitem
                              WHERE saleproduct.saleID = ${activeSaleId} and saleproduct.id = custorderitem.saleproductID
                              GROUP BY saleproduct.id) AS custorder ON custorder.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, SUM(flatsordered * unitsperflat) AS unitsordered 
                              FROM saleproductorder,saleproduct,supplieritem,product
                              WHERE saleproductorder.saleproductID = saleproduct.id and
                                    saleproduct.num = product.num and
                                    supplieritem.productID = product.id and
                                    supplieritem.supplierID = saleproductorder.supplierID and
                                    saleproduct.saleID = ${activeSaleId}
                              GROUP BY saleproduct.id) AS ord ON ord.id = saleproduct.id
            WHERE saleproduct.saleID = ${activeSaleId}
            ORDER BY saleproduct.num;
    </sql:query>
    
<c:set var="title" value="Plant Sale Inventory Information"/>
<c:set var="columnNames" value="Product,Pre-Sold,Extras,Total"/>
<c:set var="columnTypes" value="text,number,number,number"/>
<c:set var="colTypes" value="${fn:split(columnTypes, ',')}"/>

<table title="${title}" summary="${title}">
    <caption>${title}</caption>
    <thead>
    <tr>
        <c:forEach var="chdr" items="${columnNames}" varStatus="status">
            <th>${chdr}</th>
        </c:forEach>
    </tr>
    </thead>
<c:forEach var="row" items="${r.rowsByIndex}">
    <tbody><tr>
            <c:forEach var="col" items="${row}" varStatus="coln">
                <c:choose>
                    <c:when test="${colTypes[coln.index] == 'number'}">
                        <td class="number" width="20">${col}</td>
                    </c:when>
                    
                    <c:otherwise>
                        <td class="text" width="200">${col}</td>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
    </tr></tbody>
</c:forEach>
</table>
</div>
</sql:transaction>

    </body>
</html>
