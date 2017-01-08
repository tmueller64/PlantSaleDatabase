<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<c:if test="${!empty param.next}">
    <c:if test="${empty param.primarysaleID} || param.primarysaleID == 0">
        <c:set var="errormsg" scope="session">You must select a primary sale."</c:set>
        <c:redirect url="supplierordernewadmin.jsp"/>
    </c:if>
  
    <sql:query var="s" dataSource="${pssdb}">
        SELECT address, city, state, postalcode FROM org,sale
        WHERE org.id = sale.orgID and sale.id = ?;
        <sql:param value="${param.primarysaleID}"/>
    </sql:query>
    <sql:update var="updateCount" dataSource="${pssdb}">
        INSERT INTO supplierorder (supplierID, deladdress, delcity, delstate,delpostalcode)
        VALUES (?, ?, ?, ?, ?);
        <sql:param value="${currentSupplierId}"/>
        <sql:param value="${s.rows[0].address}"/>
        <sql:param value="${s.rows[0].city}"/>
        <sql:param value="${s.rows[0].state}"/>
        <sql:param value="${s.rows[0].postalcode}"/>
    </sql:update>
    <sql:query var="r" sql="select max(id) from supplierorder;" dataSource="${pssdb}"/>
    <c:set var="soid" value="${r.rowsByIndex[0][0]}"/>
    <psstags:encrypt var="rowide" value="${soid}"/>
    <c:url var="editurl" value="supplierordereditadmin.jsp">
        <c:param name="id" value="${rowide}"/>
    </c:url>
    <sql:update var="updateCount" dataSource="${pssdb}">
        UPDATE saleproductorder,saleproduct SET saleproductorder.supplierorderID = ?
            WHERE saleproductorder.saleproductID = saleproduct.id and
                  saleproduct.saleID = ?;
      <sql:param value="${soid}"/>
      <sql:param value="${param.primarysaleID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session">Order created.  Add additional sales or edit details if desired.</c:set>
    <c:redirect url="${editurl}"/>
</c:if>
   
<html>
    <head>
        <%@include file="/WEB-INF/jspf/head.jspf"%>
    </head>
    <body>
        <%@include file="/WEB-INF/jspf/banner.jspf"%>

        <psstags:breadcrumb title="New Supplier Order" page="supplierordereditadmin.jsp" var="currentSupplierOrderId"/>
        <div class="orderform">
            <c:if test="${!empty errormsg}">
                <div class=errorMessage><span>${errormsg}</span></div>
                <c:set var="errormsg" scope="session" value=""/>
            </c:if>

            <form method="POST" action="supplierordernewadmin.jsp">
                <table class="propsform" align=center>
                    <%-- drop down for sales --%>
                    <psstags:inputfield label="Primary Sale for this Order">
                        <sql:query var="sq" dataSource="${pssdb}">
                            SELECT DISTINCT org.name as oname, sale.name as sname, sale.id as sid
                                FROM org,sale,saleproduct,saleproductorder
                                WHERE org.id = sale.orgID and sale.id = saleproduct.saleID and 
                                      saleproductorder.saleproductID = saleproduct.id and
                                      year(sale.saleend) = year(curdate()) and
                                      saleproductorder.supplierID = ?;
                            <sql:param value="${currentSupplierId}"/>
                        </sql:query>
                        <select name="primarysaleID">
                            <option value="0">Select a primary sale</option>
                            <c:forEach var="s" items="${sq.rowsByIndex}">
                                <option value="${s[2]}">${s[0]} - ${s[1]}</option>
                            </c:forEach>
                        </select>
                    </psstags:inputfield>
            
                    <tr>
                        <td colspan=2>
                            <center>
                                <input type="submit" name="next" value="Next">
                            </center>
                        </td>
                    </tr>
                </table>
            </form> 
        </div>
    </body>
</html>