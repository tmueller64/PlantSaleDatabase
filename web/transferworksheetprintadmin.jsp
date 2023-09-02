<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%> 
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
        <%@include file="/WEB-INF/jspf/bannerprint.jspf"%>

        <sql:query var="sq" dataSource="${pssdb}">
            SELECT org.name as oname, sale.name as sname FROM org,sale
                WHERE sale.id = ? and sale.orgID = org.id;
            <sql:param value="${currentSaleId}"/>
        </sql:query>
        <c:set var="s" value="${sq.rowsByIndex[0]}"/>
        
        <div class="report">
            <table>
                <caption>Transfer Worksheet for ${s[0]} - ${s[1]}</caption>
        
                <sql:query var="transfers" dataSource="${pssdb}">
                    SELECT saleproduct.num as num, saleproduct.name as pname, 
                           transfer.expectedquantity as amt, org.name as oname,
                           sale.name as sname
                        FROM sale,org,transfer,saleproduct
                        WHERE transfer.fromsaleID = ? and transfer.tosaleID = sale.id and
                              transfer.saleproductID = saleproduct.id and sale.orgID = org.id;
                    <sql:param value="${currentSaleId}"/>
                </sql:query>
                <c:if test="${transfers.rowCount > 0}">
                    <tr>
                        <th colspan="0" style="text-align: left" class="pssTblColHdr">Transfers From This Sale</th>
                    </tr>
                    <tr>
                        <th class="pssTblColHdr">Product</th>
                        <th class="pssTblColHdr">Expected Transfer (units)</th>
                        <th class="pssTblColHdr">To Sale</th>
                        <th class="pssTblColHdr">Actual Transfer (units)</th>
                    </tr>
                    <c:forEach var="p" items="${transfers.rows}">
                        <tr>
                            <td style="white-space: nowrap">${p.num}. ${p.pname}</td>
                            <td style="text-align: right; white-space: nowrap">${p.amt}</td>
                            <td style="white-space: nowrap">${p.oname} - ${p.sname}</td>
                            <td style="white-space: nowrap; width: 150px"></td>
                        </tr>
                    </c:forEach>
                </c:if>
        
                <sql:query var="transfers" dataSource="${pssdb}">
                    SELECT saleproduct.num as num, saleproduct.name as pname, 
                           transfer.expectedquantity as amt, org.name as oname,
                           sale.name as sname
                        FROM sale,org,transfer,saleproduct
                        WHERE transfer.tosaleID = ? and transfer.fromsaleID = sale.id and
                              transfer.saleproductID = saleproduct.id and sale.orgID = org.id;
                    <sql:param value="${currentSaleId}"/>
                </sql:query>
                <c:if test="${transfers.rowCount > 0}">

                    <tr>
                        <th colspan="0" style="text-align: left" class="pssTblColHdr">Transfers To This Sale</th>
                    </tr>
                    <tr>
                        <th class="pssTblColHdr">Product</th>
                        <th class="pssTblColHdr">Expected Transfer (units)</th>
                        <th class="pssTblColHdr">From Sale</th>
                        <th class="pssTblColHdr">Actual Transfer (units)</th>
                    </tr>
                    <c:forEach var="p" items="${transfers.rowsByIndex}">
                        <tr>
                            <td style="white-space: nowrap">${p[0]}. ${p[1]}</td>
                            <td style="text-align: right; white-space: nowrap">${p[2]}</td>
                            <td style="white-space: nowrap">${p[3]} - ${p[4]}</td>
                            <td style="white-space: nowrap; width: 150px"></td>
                        </tr>
                    </c:forEach>
                </c:if>
            </table>
            <div style="position: relative; top: 40px">
Received By: _____________________________________________________________________________
</div>
        </div>
    </body>
</html>