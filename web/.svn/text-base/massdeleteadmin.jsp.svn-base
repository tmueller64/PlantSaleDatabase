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
    <c:set var="infomsg" value="" scope="session"/>
    <c:if test="${! empty param.salesolderthandate}">
        <%-- validate date value - throws exception if invalid --%>
        <fmt:parseDate value="${param.salesolderthandate}" type="date" pattern="yyyy-MM-dd" var="sd"/>
        <c:set var="saledate" value="${param.salesolderthandate}"/>

        <%-- delete saleproductorder entries --%>
        <sql:update var="del1Count" dataSource="${pssdb}">
            DELETE FROM saleproductorder WHERE saleproductID IN 
                (SELECT id FROM saleproduct WHERE saleID IN
                    (SELECT id FROM sale WHERE saleend < ?)
                );
            <sql:param value="${saledate}"/>
        </sql:update>

        <%-- delete saleproduct entries --%>
        <sql:update var="del2Count" dataSource="${pssdb}">
            DELETE FROM saleproduct WHERE saleID IN 
                (SELECT id FROM sale WHERE saleend < ?);
            <sql:param value="${saledate}"/>
        </sql:update>
        <c:set var="delSaleProduct" value="${del1Count + del2Count}"/>

        <%-- delete custorderitem entries --%>
        <sql:update var="del3Count" dataSource="${pssdb}">
            DELETE FROM custorderitem WHERE saleproductID IN 
                (SELECT id FROM saleproduct WHERE saleID IN
                    (SELECT id FROM sale WHERE saleend < ?)
                );
            <sql:param value="${saledate}"/>
        </sql:update>

        <%-- delete custorder entries --%>
        <sql:update var="del4Count" dataSource="${pssdb}">
            DELETE FROM custorder WHERE saleID IN 
                (SELECT id FROM sale WHERE saleend < ?);
            <sql:param value="${saledate}"/>
        </sql:update>
        <c:set var="delCustOrder" value="${del3Count + del4Count}"/>

        <%-- delete transfer entries --%>
        <sql:update var="del5Count" dataSource="${pssdb}">
            DELETE FROM transfer WHERE fromsaleID IN 
                (SELECT id FROM sale WHERE saleend < ?);
            <sql:param value="${saledate}"/>
        </sql:update>
        <sql:update var="del6Count" dataSource="${pssdb}">
            DELETE FROM transfer WHERE tosaleID IN 
                (SELECT id FROM sale WHERE saleend < ?);
            <sql:param value="${saledate}"/>
        </sql:update>
        <c:set var="delTransfer" value="${del5Count + del6Count}"/>

        <%-- delete sale entries --%>
        <sql:update var="delSales" dataSource="${pssdb}">
            DELETE FROM sale WHERE saleend < ? ;
            <sql:param value="${saledate}"/>
        </sql:update>

        <c:set var="infomsg" scope="session" value="${infomsg}Deleted ${delSaleProduct} sale product records, ${delCustOrder} customer order records, and ${delTransfer} transfers in ${delSales} sales. "/>      
    </c:if>
    <c:if test="${! empty param.delcustwithnoorder}">
        <sql:update var="delCust" dataSource="${pssdb}">
            DELETE FROM customer WHERE id NOT IN (SELECT customerID FROM custorder WHERE customerID > 0); 
        </sql:update>
        <c:set var="infomsg" scope="session" value="${infomsg}Deleted ${delCust} customer records. "/>
    </c:if>     
            
    <%-- delete sellers with no orders in inactive seller groups --%>
    <c:if test="${! empty param.delsellerinactivewithnoorder}">
        <sql:transaction dataSource="${pssdb}">
          <sql:update var="r">
              CREATE TABLE seller_copy LIKE seller;
          </sql:update>      
          <sql:update var="keepSeller">
            INSERT INTO seller_copy 
                SELECT * FROM seller WHERE id IN (SELECT sellerID FROM custorder WHERE sellerID > 0) OR 
                    id IN (SELECT seller.id FROM seller, sellergroup WHERE seller.sellergroupID = sellergroup.id 
                            AND sellergroup.active = 'yes');    
          </sql:update>
          <sql:query var="oldSeller">
              SELECT id FROM seller;
          </sql:query>
          <sql:update var="r">
              DROP TABLE seller;
          </sql:update>                  
          <sql:update var="r">
              RENAME TABLE seller_copy TO seller;
          </sql:update>
        </sql:transaction>
        <c:set var="delSeller" value="${oldSeller.rowCount - keepSeller}"/>
        <c:set var="infomsg" scope="session" value="${infomsg}Deleted ${delSeller} seller records. "/>
    </c:if>   
    
    <%-- delete empty seller groups --%>
    <c:if test="${! empty param.delemptysellergroup}">
        <sql:transaction dataSource="${pssdb}">
          <sql:update var="r">
              CREATE TABLE sellergroup_copy LIKE sellergroup;
          </sql:update>      
          <sql:update var="keepSellerGroup">
            INSERT INTO sellergroup_copy 
                SELECT * FROM sellergroup WHERE id IN (SELECT sellergroupID FROM seller) OR 
                    id IN (SELECT insellergroupID FROM sellergroup);    
          </sql:update>
          <sql:query var="oldSellerGroup">
              SELECT id FROM sellergroup;
          </sql:query>
          <sql:update var="r">
              DROP TABLE sellergroup;
          </sql:update>                  
          <sql:update var="r">
              RENAME TABLE sellergroup_copy TO sellergroup;
          </sql:update>
        </sql:transaction>
        <c:set var="delSellerGroup" value="${oldSellerGroup.rowCount - keepSellerGroup}"/>
        <c:set var="infomsg" scope="session" value="${infomsg}Deleted ${delSellerGroup} seller group records. "/>
    </c:if>            

    <c:if test="${empty infomsg}">
        <c:set var="infomsg" scope="session" value="No delete options selected."/>        
    </c:if>
    <c:redirect url="massdeleteadmin.jsp"/>
</c:if>

<html>
    <head>
        <%@include file="/WEB-INF/jspf/head.jspf"%>
    </head>
    <body>
        <%@include file="/WEB-INF/jspf/banner.jspf"%>

        <psstags:breadcrumb title="Delete Old Data" page="${pageContext.request.requestURI}"/>

        <psstags:showinfomsg/>

        <p>
            <font color="red">WARNING</font>: This page allows you to delete many records from the database
            with a single operation.  Make sure that the date that you have entered is what you really intend.
        </p>
        <form name="deleteform" method="POST" action="massdeleteadmin.jsp" onclick="hideinfomsg();">
            <table class="propsform" align=center width="100%">
                
                <psstags:textfield label="Delete all sales older than (yyyy-mm-dd)" size="10" field="salesolderthandate"/>
                <tr><td colspan="2">
                    <p class="instructions">
                        This action will delete sales, customer orders, and supplier orders for the sales that have an 
                        end date prior to the given date. It does not delete any customers or sellers.
                    </p>
                </td></tr>
                <tr>
                    <td colspan="2"><input type="checkbox" name="delcustwithnoorder"/>
                    If checked, all customers that have no orders will be deleted.</td>
                </tr>
                <tr>
                    <td colspan="2"><input type="checkbox" name="delsellerinactivewithnoorder"/>
                    If checked, all sellers with no orders in groups that are not active for order entry will be deleted.</td>
                </tr>
                <tr>
                    <td colspan="2"><input type="checkbox" name="delemptysellergroup"/>
                    If checked, all empty seller groups will be deleted.</td>
                </tr>
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
    
    
    
    
    
