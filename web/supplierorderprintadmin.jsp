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
        <psstags:accesscheck/>

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
        
        <sql:query var="btq" dataSource="${pssdb}">
            SELECT name,address,city,state,postalcode,contactname FROM org
                WHERE id = 1;
        </sql:query>
        <c:set var="bt" value="${btq.rows[0]}"/>
        
        <sql:query var="stq" dataSource="${pssdb}">
            SELECT deladdress,delcity,delstate,delpostalcode,expecteddeliverydate FROM supplierorder
                WHERE id = ?;
           <sql:param value="${currentSupplierOrderId}"/>
        </sql:query>
        <c:set var="st" value="${stq.rows[0]}"/>
        <div class="report">
        <table>
        <tr valign="top">
        <td colspan="2">
        <b>Supplier:</b><br>
        ${s.name}<br>
        Attn: ${s.contactname}<br>
        ${s.address}<br>
        ${s.city}, ${s.state}  ${s.postalcode}<br>
        Fax: ${s.faxnumber}<br>
        </td>
        </tr>
        <tr><td colspan="2">Expected Delivery Date: ${st.expecteddeliverydate}</td></tr>
        <tr valign="top">
        <td>
        <b>Bill To:</b><br>
        ${bt.name}<br>
        Attn: ${bt.contactname}<br>
        ${bt.address}<br>
        ${bt.city}, ${bt.state}  ${bt.postalcode}<br>
        </td>
        <td>
        <b>Ship To:</b><br>
        ${st.deladdress}<br>
        ${st.delcity}, ${st.delstate}  ${st.delpostalcode}<br>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <psstags:report title="Order Details"
            columnNames="Item Number,Product Name,Quantity (flats)"
            columnTypes="number,text,number"
            doNotCustomize="true"
            doNotUseOrg="true">
            <jsp:attribute name="query">
            SELECT num, name, sum(flatsordered) as fordered
                FROM saleproduct,saleproductorder
                WHERE saleproductorder.supplierorderID = "${currentSupplierOrderId}" and
                      saleproductorder.saleproductID = saleproduct.id and
                      saleproductorder.supplierID = "${currentSupplierId}"
                GROUP BY num, name
                HAVING fordered > 0
                ORDER by num;
            </jsp:attribute>
        </psstags:report>
        </td>
        </tr>
        </table>
        </div>
    </body>
</html>