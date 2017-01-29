<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
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

<psstags:breadcrumb title="Gross Profit Report" page="${pageContext.request.requestURI}"/>
<sql:transaction dataSource="${pssdb}">
    <sql:query var="r">
        SELECT org.name as oname, sale.name as sname, 
        SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice * (1 - saleproduct.profit)) as due,
        SUM(cogs) as cogs,
        SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice * (1 - saleproduct.profit) - cogs) as gprofit
        FROM saleproduct
        INNER JOIN sale ON sale.id = saleproduct.saleID
        INNER JOIN org ON org.activesaleID = sale.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(custorderitem.quantity) AS unitordered FROM saleproduct,custorderitem
                          WHERE saleproduct.id = custorderitem.saleproductID
                          GROUP BY saleproduct.id) AS custorder ON custorder.id = saleproduct.id
        LEFT JOIN (SELECT saleproduct.id AS id, SUM(flatsdelivered * unitsperflat) AS unitsdelivered, SUM(flatsdelivered * costperflat) AS cogs
                          FROM saleproductorder,saleproduct,supplieritem,product
                          WHERE saleproductorder.saleproductID = saleproduct.id and
                                saleproduct.num = product.num and
                                supplieritem.productID = product.id and
                                supplieritem.supplierID = saleproductorder.supplierID
                          GROUP BY saleproduct.id) AS del ON del.id = saleproduct.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS trincount FROM saleproduct, transfer
                          WHERE transfer.saleproductID = saleproduct.id
                          GROUP BY saleproduct.id) AS trin ON trin.id = saleproduct.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS troutcount FROM saleproduct, transfer
                          WHERE transfer.saleproductID = saleproduct.id
                          GROUP BY saleproduct.id) AS trout ON trout.id = saleproduct.id
        GROUP BY saleproduct.saleID
        ORDER BY oname, sname;
    </sql:query>

<c:set var="title" value="Gross Profit for Active Sales Report"/>
<c:set var="columnNames" value="Organization,Sale,Total Due,COGS,Gross Profit"/>
<c:set var="columnTypes" value="text,text,money,money,money"/>
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
   <sql:query var="r">
        SELECT SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice * (1 - saleproduct.profit)) as due,
               SUM(cogs) as cogs,
               SUM((ifnull(unitsdelivered,0) + ifnull(trincount,0) - ifnull(troutcount,0)) * saleproduct.unitprice * (1 - saleproduct.profit) - cogs) as gprofit
        FROM saleproduct
        INNER JOIN sale ON sale.id = saleproduct.saleID
        INNER JOIN org ON org.activesaleID = sale.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(custorderitem.quantity) AS unitordered FROM saleproduct,custorderitem
                          WHERE saleproduct.id = custorderitem.saleproductID
                          GROUP BY saleproduct.id) AS custorder ON custorder.id = saleproduct.id
        LEFT JOIN (SELECT saleproduct.id AS id, SUM(flatsdelivered * unitsperflat) AS unitsdelivered, SUM(flatsdelivered * costperflat) AS cogs
                          FROM saleproductorder,saleproduct,supplieritem,product
                          WHERE saleproductorder.saleproductID = saleproduct.id and
                                saleproduct.num = product.num and
                                supplieritem.productID = product.id and
                                supplieritem.supplierID = saleproductorder.supplierID
                          GROUP BY saleproduct.id) AS del ON del.id = saleproduct.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS trincount FROM saleproduct, transfer
                          WHERE transfer.saleproductID = saleproduct.id
                          GROUP BY saleproduct.id) AS trin ON trin.id = saleproduct.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS troutcount FROM saleproduct, transfer
                          WHERE transfer.saleproductID = saleproduct.id
                          GROUP BY saleproduct.id) AS trout ON trout.id = saleproduct.id;
    </sql:query>

<c:set var="t" value="${r.rows[0]}"/>
    <tr>    
        <th style="text-align: left; border: 0; background: white" colspan="2">Totals</th>
        <td style="text-align: right; "><fmt:formatNumber value="${t.due}" type="currency"/></td>
        <td style="text-align: right; "><fmt:formatNumber value="${t.cogs}" type="currency"/></td>
        <td style="text-align: right; "><fmt:formatNumber value="${t.gprofit}" type="currency"/></td>
        
    </tr>
</table>
</div>
</sql:transaction>

</body>
</html>