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

        <c:if test="${! empty param.id}">
            <psstags:decrypt var="pid" value="${param.id}"/>
            <c:set scope="session" var="currentSupplierOrderId" value="${pid}"/>
        </c:if>

        <sql:query var="sq" dataSource="${pssdb}">
            SELECT name,address,city,state,postalcode,contactname,faxnumber
                FROM supplier,supplierorder
                WHERE supplierorder.id = ? and supplier.id = supplierorder.supplierID;
            <sql:param value="${currentSupplierOrderId}"/>
        </sql:query>
        <c:set var="s" value="${sq.rows[0]}"/>
        
        <sql:query var="stq" dataSource="${pssdb}">
            SELECT deladdress,delcity,delstate,delpostalcode,expecteddeliverydate FROM supplierorder
                WHERE id = ?;
           <sql:param value="${currentSupplierOrderId}"/>
        </sql:query>
        <c:set var="st" value="${stq.rows[0]}"/>
        <div class="report">
                <table>
                    <caption>Delivery Inventory Worksheet</caption>
                    <tr valign="top">
                        <td>
                            <b>Supplier:</b><br>
                            ${s.name}<br>
                            ${s.address}<br>
                            ${s.city}, ${s.state}  ${s.postalcode}<br>
                        </td>
                        <td>
                            <b>Delivery Location:</b><br>
                            ${st.deladdress}<br>
                            ${st.delcity}, ${st.delstate}  ${st.delpostalcode}<br>
                        </td>
                    </tr>
                    <tr style="height: 16pt">
                        <td style="white-space: nowrap">Expected Delivery Date: ${st.expecteddeliverydate}</td>
                        <td align="right" style="white-space: nowrap">Actual Delivery Date:____________________________________</td>
                    </tr>
                </table>
                <table>
                <sql:transaction dataSource="${pssdb}">
                    <sql:update var="v">
                        SET SESSION SQL_BIG_SELECTS=1;
                    </sql:update>
                    <sql:query var="sales">
                        SELECT DISTINCT sale.id as id, sale.name as sname, org.name as oname
                        FROM sale,org,saleproductorder,saleproduct
                        WHERE saleproductorder.supplierorderID = ? and 
                        saleproductorder.saleproductID = saleproduct.id and
                        saleproduct.saleID = sale.id and
                        sale.orgID = org.id;
                        <sql:param value="${currentSupplierOrderId}"/>
                    </sql:query>
                    <c:set var="sheader" value=""/>
                    <c:set var="sfields" value=""/>
                    <c:set var="sjoins" value=""/>
                    <c:set var="sdrops" value="notable"/>
                    <c:set var="sfilter" value="0"/>
                    <c:forEach var="s" items="${sales.rowsByIndex}">
                        <c:set var="s_id" value="${s[0]}"/>
                        <c:set var="sheader">${sheader}<th class="pssTblColHdr">${s[2]}<br>${s[1]}</th></c:set>
                        <c:set var="sfields">${sfields}, s${s_id}flatsordered</c:set>
                        <c:set var="sfilter">${sfilter} or s${s_id}flatsordered > 0</c:set>
                        <c:set var="sjoins">${sjoins} LEFT JOIN (SELECT saleproduct.num AS s${s_id}num, flatsordered AS s${s_id}flatsordered
                            FROM saleproductorder, saleproduct
                            WHERE saleproduct.saleID = "${s_id}" AND
                            saleproductorder.saleproductID = saleproduct.id AND
                            saleproductorder.supplierID = ${currentSupplierId} AND 
                            saleproductorder.supplierorderID = ${currentSupplierOrderId}) AS supp_${s_id} ON s${s_id}num = product.num</c:set>
                    </c:forEach>
                    <sql:query var="product">
                        SELECT product.name as name, product.num as num 
                        ${sfields}
                        FROM product
                        ${sjoins}
                        WHERE ${sfilter}
                        ORDER BY product.num;    
                    </sql:query>
                </sql:transaction>
                <thead>
                    <tr>
                        <th class="pssTblColHdr" rowspan="2">Product</th>
                        <th class="pssTblColHdr" colspan="${sales.rowCount}">Enter Actual Flats Received For</th>
                    </tr>
                    <tr>
                        ${sheader}
                    </tr>
                </thead>
            
<c:forEach var="p" items="${product.rows}">
    <tbody><tr style="height: 16pt">
            <td style="white-space: nowrap; width: 200px">${p.num}. ${p.name}</td>
            <c:forEach var="s" items="${sales.rows}">
                <c:set var="flatsordered">s${s.id}flatsordered</c:set>
                <td style="white-space: nowrap; width: 50px">
                    (${p[flatsordered]}<c:if test="${empty p[flatsordered]}">0</c:if>)__________ 
                </td>
            </c:forEach>
    </tr> </tbody> 
</c:forEach>
</table>
<br>
<b>Note:</b> The expected number of flats is shown in parenthesis before the blank.

        <div>
Received By: _____________________________________________________________________________
</div>
        </div>
    </body>
</html>
