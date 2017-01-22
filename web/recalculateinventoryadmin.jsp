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
    <sql:update var="recalculate1" dataSource="${pssdb}">
        UPDATE product SET remaininginventory = -1;
    </sql:update>
    <sql:update var="recalculate2" dataSource="${pssdb}">
        UPDATE product oldproduct
            INNER JOIN
              (SELECT product.id, inventory, ordered, remainingInventory(inventory, ordered) as rem from product
                INNER JOIN (SELECT productID, SUM(inventory) AS inventory FROM supplieritem GROUP BY productID) as supitem ON product.id = supitem.productID
                INNER JOIN (SELECT product.id AS id, SUM(custorderitem.quantity) AS ordered FROM custorderitem, product, saleproduct, sale, org 
                      WHERE custorderitem.saleProductID = saleproduct.id AND 
                            product.num = saleproduct.num AND 
                            saleproduct.saleID = sale.id AND 
                            sale.id = org.activesaleID GROUP BY product.id) as orditem ON product.id = orditem.id)
              AS newproduct ON oldproduct.id = newproduct.id
            SET oldproduct.remaininginventory = newproduct.rem;
    </sql:update>
    <c:set var="infomsg" value="Remaining inventory recalculated." scope="session"/>

    <c:redirect url="recalculateinventoryadmin.jsp"/>
</c:if>

<html>
    <head>
        <%@include file="/WEB-INF/jspf/head.jspf"%>
    </head>
    <body>
        <%@include file="/WEB-INF/jspf/banner.jspf"%>

        <psstags:breadcrumb title="Recalculate Inventory" page="${pageContext.request.requestURI}"/>

        <psstags:showinfomsg/>

        <form name="recalculateform" method="POST" action="recalculateinventoryadmin.jsp" onclick="hideinfomsg();">
            <table class="propsform" align=center width="100%">
                
                <tr><td colspan="2">
                    <p class="instructions">
                        This action will recalculate the remaining inventory for all products.
                    </p>
                </td></tr>
                
                <tr>
                    <td colspan=2>
                        <input type="submit" name="submit" value="Recalculate" style="position: relative; left: 30px;">
                    </td>
                </tr>
            </table>
        </form>

</body>
</html>
    
    
    
    
    
