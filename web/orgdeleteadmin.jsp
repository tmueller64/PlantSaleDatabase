<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">


<c:if test="${! empty param.submit}">
    <%-- validate the update --%>
    <c:if test="${userrole != 'admin'}">
        <c:redirect url="accessviolation.html"/>
    </c:if>
    <c:if test="${param.orgID == 0}">
        <c:set var="infomsg" scope="session" value="Select an organization to be deleted."/>
        <c:redirect url="orgdeleteadmin.jsp"/>
    </c:if>
    <c:if test="${param.confirm != 'yes'}">
        <c:set var="infomsg" scope="session" value="Enter 'yes' to confirm that the organization should be deleted."/>
        <c:redirect url="orgdeleteadmin.jsp"/>
    </c:if>
        
    <c:set var="infomsg" value="<ul>" scope="session"/>

    <%-- delete user entries --%>
    <sql:update var="delUser" dataSource="${pssdb}">
        DELETE FROM user WHERE orgID = ?;
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delUser} user records.</li>"/>

    <%-- delete seller group entries --%>
    <sql:update var="delSG" dataSource="${pssdb}">
        DELETE FROM sellergroup WHERE orgID = ?;
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delSG} seller group records.</li>"/>

    <%-- delete seller entries --%>
    <sql:update var="delS" dataSource="${pssdb}">
        DELETE FROM seller WHERE orgID = ?;
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delS} seller records.</li>"/>

    <%-- delete custorderitem entries --%>
    <sql:update var="delCOI" dataSource="${pssdb}">
        DELETE FROM custorderitem WHERE orderID IN 
            (SELECT id FROM custorder WHERE customerID IN
                (SELECT id FROM customer WHERE orgID = ?));
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delCOI} customer order item records.</li>"/>

    <%-- delete custorder entries --%>
    <sql:update var="delCO" dataSource="${pssdb}">
        DELETE FROM custorder WHERE customerID IN 
            (SELECT id FROM customer WHERE orgID = ?);
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delCO} customer order records.</li>"/>

    <%-- delete customer entries --%>
    <sql:update var="delCust" dataSource="${pssdb}">
        DELETE FROM customer WHERE orgID = ?; 
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delCust} customer records.</li>"/>

    <%-- delete saleproductorder entries --%>
    <sql:update var="delSPO" dataSource="${pssdb}">
        DELETE FROM saleproductorder WHERE saleproductID IN 
            (SELECT id FROM saleproduct WHERE saleID IN
                (SELECT id FROM sale WHERE orgID = ?));
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delSPO} sale product order records.</li>"/>

    <%-- delete saleproduct entries --%>
    <sql:update var="delSP" dataSource="${pssdb}">
        DELETE FROM saleproduct WHERE saleID IN 
            (SELECT id FROM sale WHERE orgID = ?);
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delSP} sale product records.</li>"/>
 
    <%-- delete transfer entries --%>
    <sql:update var="delT1" dataSource="${pssdb}">
        DELETE FROM transfer WHERE fromsaleID IN 
            (SELECT id FROM sale WHERE orgID = ?);
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delT1} sale transfer out records.</li>"/>
    
    <sql:update var="delT2" dataSource="${pssdb}">
        DELETE FROM transfer WHERE tosaleID IN 
            (SELECT id FROM sale WHERE orgID = ?);
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delT2} sale transfer in records.</li>"/>

    <%-- delete sale entries --%>
    <sql:update var="delSales" dataSource="${pssdb}">
        DELETE FROM sale WHERE orgID = ? ;
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delSales} sale records.</li>"/>      

    <%-- delete org entrie --%>
    <sql:update var="delOrg" dataSource="${pssdb}">
        DELETE FROM org WHERE id = ? ;
        <sql:param value="${param.orgID}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="${infomsg}<li>Deleted ${delOrg} organization record.</li>"/>      

    <c:set var="infomsg" scope="session" value="${infomsg}</ul>"/>
    
    <c:redirect url="orgdeleteadmin.jsp"/>
</c:if>

<html>
    <head>
        <%@include file="/WEB-INF/jspf/head.jspf"%>
    </head>
    <body>
        <%@include file="/WEB-INF/jspf/banner.jspf"%>

        <psstags:breadcrumb title="Organization Delete" page="${pageContext.request.requestURI}"/>

        <psstags:showinfomsg/>

        <p>
            <font color="red">WARNING</font>: This page allows you to delete an entire organization from the database
            with a single operation.  Make sure that the organization that you have selected is what you really intend.
        </p>
        <form name="deleteform" method="POST" action="orgdeleteadmin.jsp" onclick="hideinfomsg();">
            <table class="delform" align=center width="100%">
                
                <tr><td colspan="2">
                    <p class="instructions">
                        This action will delete an organization including all users, customers, sellers, 
                        seller groups, sales, customer orders, and supplier orders for the sales. To 
                        make sure an organization is not accidentally deleted, enter "yes" to confirm this operation.
                    </p>
                </td></tr>
                <psstags:inputfield label="Organization to Delete">
                    <sql:query var="oq" dataSource="${pssdb}">
                        SELECT id as id, name as name FROM org;
                    </sql:query>
                    <select name="orgID">
                        <option value="0">Select an organization</option>
                        <c:forEach var="o" items="${oq.rowsByIndex}">
                            <option value="${o[0]}">${o[0]} - ${o[1]}</option>
                        </c:forEach>
                    </select>
                </psstags:inputfield>
                <psstags:inputfield label="Confirm by entering 'yes'">
                    <input type="text" name="confirm" value="" size="5"/>
                </psstags:inputfield>
                <tr>
                    <td colspan=2>
                        <input type="submit" name="submit" value="Submit" style="position: relative; left: 30px;">
                        <input type="reset" value="Reset" style="position: relative; left: 50px;">
                    </td>
                </tr>
            </table>
        </form>
</body>
</html>