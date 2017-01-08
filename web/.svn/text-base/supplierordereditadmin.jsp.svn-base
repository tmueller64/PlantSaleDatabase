<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
   
<c:if test="${! empty param.save}">
    <%-- validate the update --%>
    <c:if test="${userrole != 'admin'}">
        <c:redirect url="accessviolation.html"/>
    </c:if>

    <%-- construct SQL statement for update --%>
    <c:set var="updstmt" value=""/>
    <sql:update var="updateCount" dataSource="${pssdb}">
        UPDATE supplierorder SET expecteddeliverydate = ?, deladdress = ?, delcity = ?, delstate = ?, delpostalcode = ?
        WHERE id=?;
        <sql:param value="${param.expecteddeliverydate}"/>
        <sql:param value="${param.deladdress}"/>
        <sql:param value="${param.delcity}"/>
        <sql:param value="${param.delstate}"/>
        <sql:param value="${param.delpostalcode}"/>
        <sql:param value="${currentSupplierOrderId}"/>
    </sql:update>
    <%-- first erase all entries for this supplier order --%>
    <sql:update var="updateCount" dataSource="${pssdb}">
        UPDATE saleproductorder SET supplierorderID = 0 WHERE supplierorderID = ?;
      <sql:param value="${currentSupplierOrderId}"/>
    </sql:update>
    <%-- next set the entries for the selected sales --%>
    <c:forEach var="saleId" items="${paramValues.saleIDs}">
      <sql:update var="updateCount" dataSource="${pssdb}">
          UPDATE saleproductorder,saleproduct SET saleproductorder.supplierorderID = ?
            WHERE saleproductorder.supplierID = ? and
                  saleproductorder.saleproductID = saleproduct.id and
                  saleproduct.saleID = ?;
        <sql:param value="${currentSupplierOrderId}"/>
        <sql:param value="${currentSupplierId}"/>
        <sql:param value="${saleId}"/>
      </sql:update>
    </c:forEach>
    <c:set var="infomsg" scope="session" value="Save completed."/>
    <c:redirect url="supplierordereditadmin.jsp"/>
</c:if>

<html>
    <head>
        <%@include file="/WEB-INF/jspf/head.jspf"%>
    </head>
    <body>
        <%@include file="/WEB-INF/jspf/banner.jspf"%>

        <c:if test="${! empty param.id}">
            <psstags:decrypt var="pid" value="${param.id}"/>
            <c:set scope="session" var="currentSupplierOrderId" value="${pid}"/>
        </c:if>

        <sql:query var="r" dataSource="${pssdb}">
            SELECT * FROM supplierorder WHERE id = ?;
            <sql:param value="${currentSupplierOrderId}"/>
        </sql:query>

        <psstags:breadcrumb title="Supplier Order - ${r.rows[0].expecteddeliverydate} ${r.rows[0].delcity}" page="supplierordereditadmin.jsp" var="currentSupplierOrderId"/>

        <psstags:showinfomsg/>

        <c:set var="row" value="${r.rows[0]}" scope="request"/>
        <form name="orderform" method="POST" action="supplierordereditadmin.jsp" onclick="hideinfomsg();">
            <table class="propsform" align=center>
                <tr><td colspan="2" style="text-align: left" class="textfieldlabel2">Delivery Information</td></tr>
                <psstags:textfield label="Expected Date" size="10" field="expecteddeliverydate"/>
                <psstags:textfield label="Address" size="50" field="deladdress"/>
                <psstags:textfield label="City" size="30" field="delcity"/>
                <psstags:textfield label="State" size="5" field="delstate"/>
                <psstags:textfield label="Zip" size="10" field="delpostalcode"/>
                <psstags:inputfield label="Sales for this Order">
                    <sql:query var="sq" dataSource="${pssdb}">
                        SELECT DISTINCT org.name as oname,
                                        sale.name as sname,
                                        sale.id as sid,
                                        saleproductorder.supplierOrderID as soid
                            FROM org,sale,saleproduct,saleproductorder
                            WHERE org.id = sale.orgID and sale.id = saleproduct.saleID and
                                  year(sale.saleend) = year(curdate()) and
                                  saleproductorder.saleproductID = saleproduct.id and 
                                  (saleproductorder.supplierorderID = 0 or saleproductorder.supplierOrderID = ?) and
                                  saleproductorder.supplierID = ?;
                        <sql:param value="${currentSupplierOrderId}"/>
                        <sql:param value="${currentSupplierId}"/>
                    </sql:query>
                    
                    <select name="saleIDs" multiple size="5">
                        <c:forEach var="s" items="${sq.rowsByIndex}">
                            <option value="${s[2]}" <c:if test="${s[3] != 0}">selected="true"</c:if>>${s[0]} - ${s[1]}</option>
                        </c:forEach>
                    </select>
                </psstags:inputfield>
                <tr><td colspan="2">
                    <p class="instructions">
                        Select multiple sales by pressing "Ctrl" while selecting with the left mouse button.
                    </p>
                </td></tr>
                <tr>
                    <td colspan=2>
                        <input type="submit" name="save" value="Save" style="position: relative; left: 30px;">
                        <input type="reset" value="Reset" style="position: relative; left: 50px;">
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>