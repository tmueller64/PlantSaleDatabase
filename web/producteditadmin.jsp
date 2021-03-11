<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
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
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<c:if test="${! empty param.id}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentProductId" value="${pid}"/>
</c:if>

<sql:query var="iqlim" dataSource="${pssdb}">
    SELECT count(*) AS nolim FROM supplieritem WHERE productId = ${currentProductId} AND inventory = 0;
</sql:query>
<c:set var="hasNoLimit" value="${iqlim.rows[0].nolim > 0}"/>
<sql:query var="iqinv" dataSource="${pssdb}">
    SELECT sum(inventory) AS inventory FROM supplieritem WHERE productId = ${currentProductId};
</sql:query> 
<c:set var="inventory" value="${iqinv.rows[0].inventory}"/>
               
<c:if test="${! empty param.recalculateinventory}">
    <%-- count ordered product --%>
    <sql:query var="pqo" dataSource="${pssdb}">
        SELECT SUM(custorderitem.quantity) AS ordered FROM custorderitem, saleproduct, product, sale, org 
            WHERE custorderitem.saleProductID = saleproduct.id AND 
                  product.num = saleproduct.num AND 
                  saleproduct.saleID = sale.id AND 
                  sale.id = org.activesaleID AND 
                  product.id = ${currentProductId};
    </sql:query>
    <c:set var="ordered" value="${pqo.rows[0].ordered}"/>
    <c:choose>
        <c:when test="${inventory == 0}">
            <c:set var="remaininginventory" value="-1"/>
            <c:set var="infomsg" scope="session" value="Inventory not specified so it has no limit."/>
        </c:when>
        <c:when test="${ordered > inventory}">
            <c:set var="infomsg" scope="session" value="Ordered product (${ordered}) already exceeds inventory (${inventory}). "/>
            <c:set var="remaininginventory" value="0"/>
        </c:when>
        <c:otherwise>
            <c:set var="remaininginventory" value="${inventory - ordered}"/>
            <c:set var="infomsg" scope="session" value="Inventory recalculated."/>
        </c:otherwise>
    </c:choose>
    
    <%-- construct SQL statement for update --%>    
    <sql:update var="updateCount" dataSource="${pssdb}">
      UPDATE product SET remaininginventory = ? WHERE id=?;
      <sql:param value="${remaininginventory}"/>
      <sql:param value="${currentProductId}"/>
    </sql:update>
    <c:redirect url="${pageContext.request.requestURI}" context="/"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select * from product where id = ?;
    <sql:param value="${currentProductId}"/>
</sql:query>
<c:set var="reminventory" value="${r.rows[0].remaininginventory}"/>

<psstags:breadcrumb title="Product - ${r.rows[0].name}" page="producteditadmin.jsp" var="currentProductId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="producteditadmin.jsp">
                          
 <psstags:tab name="Properties">
   <psstags:propsform table="product" itemid="${currentProductId}">
     <psstags:textfield label="Name" field="name" size="50"/>
     <psstags:textfield label="Number" field="num" size="5"/>
     <psstags:textfield label="Unit Price" field="unitprice" size="6"/>
     <psstags:textfield label="Alternate" field="alternate" size="5" note="The product number to be offered as an alternate; 0 means no alternate."/>
     <psstags:textfield label="Profit" field="prodprofit" size="6" note="The default profit value to be used in sales of this product; blank means sale default will be used."/>
   </psstags:propsform>
 </psstags:tab>
    
 <psstags:tab name="Inventory">
   <psstags:showinfomsg/>
   <p class="instructions">
   The inventory for active sales is the sum of the inventory values for the
   supplied products for this product item. If any inventory value is 0, then 
   there is no limit on the inventory and the remaining inventory is not 
   calculated. 
    </p>      
    <table class="propsform" align=center>
    <tr class="textfieldrow" valign="top">
        <td class="textfieldlabel2">Inventory for active sales:</td>
        <td class="textfieldvalue2"><c:out value="${hasNoLimit ? 'no limit': inventory}"/></td>
    </tr>  
    <tr class="textfieldrow" valign="top">
        <td class="textfieldlabel2">Remaining inventory:</td>
        <td class="textfieldvalue2"><c:out value="${reminventory == -1 ? 'unknown' : reminventory}"/></td>
    </tr> 
    <tr>
        <td colspan=2 style="text-align: center; white-space: nowrap">
            <form name="calcform" method="POST" action="${pageContext.request.requestURI}" onclick="hideinfomsg();">
            <input type="submit" name="recalculateinventory" value="Recalculate Remaining Inventory">
            </form>
        </td>
    </tr>
    </table>       
</psstags:tab>
   
</psstags:tabset>

</body>