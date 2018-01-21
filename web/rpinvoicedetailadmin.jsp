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
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<psstags:breadcrumb title="Active Sale Invoice Detail Report" page="${pageContext.request.requestURI}"/>

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
<tr><th style="text-align: right; border: 0; background: white; vertical-align: top">To:</th>
<td style="border: 0">
${o.oname}<br>
Attn: ${o.contactname}<br>
${o.address}<br>
${o.city}, ${o.state}  ${o.postalcode}<br>
</td>
        <sql:query var="btq" dataSource="${pssdb}">
            SELECT name,address,city,state,postalcode,contactname FROM org
                WHERE id = 1;
        </sql:query>
        <c:set var="bt" value="${btq.rows[0]}"/>

<th style="text-align: right; border: 0; background: white; vertical-align: top">Remit To:</th>
<td style="border: 0">
${bt.name}<br>
Attn: ${bt.contactname}<br>
${bt.address}<br>
${bt.city}, ${bt.state}  ${bt.postalcode}<br>
</td>
</tr>
</table>
<br>
<sql:transaction dataSource="${pssdb}">
    <sql:update var="v">
        SET SESSION SQL_BIG_SELECTS=1;
    </sql:update>
    <sql:query var="r">
         SELECT CONCAT(cast(saleproduct.num as char), '. ', saleproduct.name) as pname, 
            saleproduct.unitprice as price,
            custorder.unitsordered as preordered,
            @totaldel:=ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0) as totaldel,
            @totaldel * saleproduct.unitprice,
            cogs,
            @due:=@totaldel * saleproduct.unitprice * (1 - saleproduct.profit) as due,
            @due - cogs
         FROM saleproduct
            INNER JOIN sale ON sale.id = saleproduct.saleID
            LEFT JOIN (SELECT saleproduct.id AS id, sum(custorderitem.quantity) AS unitsordered FROM saleproduct, custorderitem
                              WHERE saleproduct.saleID = ${activeSaleId} and saleproduct.id = custorderitem.saleproductID
                              GROUP BY saleproduct.id) AS custorder ON custorder.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, SUM(flatsdelivered * unitsperflat) AS unitsdelivered, SUM(flatsdelivered * costperflat) AS cogs
                              FROM saleproductorder,saleproduct,supplieritem,product
                              WHERE saleproductorder.saleproductID = saleproduct.id and
                                    saleproduct.num = product.num and
                                    supplieritem.productID = product.id and
                                    supplieritem.supplierID = saleproductorder.supplierID and
                                    saleproduct.saleID = ${activeSaleId}
                              GROUP BY saleproduct.id) AS del ON del.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS trincount FROM saleproduct,transfer
                              WHERE tosaleID = ${activeSaleId} AND transfer.saleproductID = saleproduct.id
                              GROUP BY num) AS trin ON trin.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS troutcount FROM saleproduct,transfer
                              WHERE fromsaleID = ${activeSaleId} AND transfer.saleproductID = saleproduct.id
                              GROUP BY num) AS trout ON trout.id = saleproduct.id
            WHERE saleproduct.saleID = ${activeSaleId}
            ORDER BY rightNum(saleproduct.num);
    </sql:query>
    
<c:set var="title" value="Invoice Detail Report"/>
<c:set var="columnNames" value="Product,Unit Price,Pre-Sold,Units Received,Retail Value,COGS,Amount Due,Gross Profit"/>
<c:set var="columnTypes" value="text,money,number,number,money,money,money,money"/>
<c:set var="colTypes" value="${fn:split(columnTypes, ',')}"/>

<div class="report">
<table title="${title}" summary="${title}">
<caption>${title}</caption>

<tr>
<c:forEach var="chdr" items="${columnNames}" varStatus="status">
   <th>${chdr}</th>
</c:forEach>
</tr>

<c:forEach var="row" items="${r.rowsByIndex}">
<tr>     
    <c:forEach var="col" items="${row}" varStatus="coln">
      <c:choose>
        <c:when test="${colTypes[coln.index] == 'number'}">
          <td class="number">${col}</td>
        </c:when>
        <c:when test="${colTypes[coln.index] == 'money'}">
          <td class="number"><fmt:formatNumber value="${col}" type="currency"/></td>
        </c:when>
        <c:otherwise>
          <td class="text">${col}</td>
        </c:otherwise>
      </c:choose>
    </c:forEach>
</tr>
</c:forEach>

</table>
</div>
    <br>
    <sql:query var="r">
         SELECT SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice) as retail,
            SUM(cogs) as cogs,
            SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice * (1 - saleproduct.profit)) as due,
            SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice * (1 - saleproduct.profit) - cogs) as gprofit
         FROM saleproduct
            INNER JOIN sale ON sale.id = saleproduct.saleID
            LEFT JOIN (SELECT saleproduct.id AS id, sum(custorderitem.quantity) AS unitsordered FROM saleproduct, custorderitem
                              WHERE saleproduct.saleID = ${activeSaleId} and saleproduct.id = custorderitem.saleproductID
                              GROUP BY saleproduct.id) AS custorder ON custorder.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, SUM(flatsdelivered * unitsperflat) AS unitsdelivered, SUM(flatsdelivered * costperflat) AS cogs
                              FROM saleproductorder,saleproduct,supplieritem,product
                              WHERE saleproductorder.saleproductID = saleproduct.id and
                                    saleproduct.num = product.num and
                                    supplieritem.productID = product.id and
                                    supplieritem.supplierID = saleproductorder.supplierID and
                                    saleproduct.saleID = ${activeSaleId}
                              GROUP BY saleproduct.id) AS del ON del.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS trincount FROM saleproduct,transfer
                              WHERE tosaleID = ${activeSaleId} AND transfer.saleproductID = saleproduct.id
                              GROUP BY num) AS trin ON trin.id = saleproduct.id
            LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS troutcount FROM saleproduct,transfer
                              WHERE fromsaleID = ${activeSaleId} AND transfer.saleproductID = saleproduct.id
                              GROUP BY num) AS trout ON trout.id = saleproduct.id
            WHERE saleproduct.saleID = ${activeSaleId}
            GROUP BY saleproduct.saleID
    </sql:query>
</sql:transaction>
<c:set var="t" value="${r.rows[0]}"/>
<table width="100%">
<tr><th style="text-align: left; border: 0; background: white">Total Retail:</th><td style="text-align: right; "><fmt:formatNumber value="${t.retail}" type="currency"/></td></tr>
<tr><th style="text-align: left; border: 0; background: white">Total Due:</th><td style="text-align: right; "><fmt:formatNumber value="${t.due}" type="currency"/></td></tr>
<tr><th style="text-align: left; border: 0; background: white">Total COGS:</th><td style="text-align: right; "><fmt:formatNumber value="${t.cogs}" type="currency"/></td></tr>
<tr><th style="text-align: left; border: 0; background: white">Total Gross Profit:</th><td style="text-align: right; "><fmt:formatNumber value="${t.gprofit}" type="currency"/></td></tr>
</table>

</div>
</body>
</html>