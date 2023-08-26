<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<%@include file="/WEB-INF/jspf/head.jspf"%>
<script type="text/javascript" src="CalendarPopup.js"></script>
<script language="JavaScript">document.write(getCalendarStyles());</script>
</head>
<body onLoad="updatelist();">
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<psstags:breadcrumb title="Edit Order" page="editorder.jsp"/>

<c:if test="${! empty param.id}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentOrderId" value="${pid}"/>
</c:if>

<c:if test="${! empty param.submit}">
    <%-- validate date value - throws exception if invalid --%>
    <fmt:parseDate value="${param.orderdate}" type="date" pattern="yyyy-MM-dd" var="d"/>
    <sql:transaction dataSource="${pssdb}">
      <sql:query var="r">
          SELECT sale.id FROM sale,custorder 
            WHERE salestart <= ? and saleend >= ? and custorder.id = ? and sale.id = custorder.saleID;
        <sql:param value="${param.orderdate}"/>
        <sql:param value="${param.orderdate}"/>
        <sql:param value="${currentOrderId}"/>
      </sql:query>
      <c:if test="${r.rowCount < 1}">
        <c:set var="errormsg" scope="session" value="The entered date is invalid for this order."/>
        <c:redirect url="${pageContext.request.requestURI}" context="/"/>
      </c:if>
            
      <sql:update var="s">
        DROP TABLE IF EXISTS temp${tid}_updateorder;
      </sql:update>   
      <sql:update var="s">
        CREATE TABLE temp${tid}_updateorder ( saleproductID INTEGER, quantity INTEGER );
      </sql:update>
        
      <%-- add the products from this order back to the inventory --%>
      <sql:update var="returnInv">
          INSERT INTO temp${tid}_updateorder (saleproductID, quantity)
            SELECT saleproductID, -quantity FROM custorderitem
                WHERE orderID = ?
          <sql:param value="${currentOrderId}"/>
      </sql:update>  
      
      <%-- subtract the updates quantities from the inventory --%>
      <c:set var="id" value=""/>
      <c:forTokens var="i" items="${param.items}" delims=":">
        <c:choose>
          <c:when test="${empty id}"><c:set var="id" value="${i}"/></c:when>
          <c:otherwise>
            <sql:update var="updateCount">
             INSERT INTO temp${tid}_updateorder (saleproductID, quantity)
                    VALUES (?, ?);
              <sql:param value="${id}"/>
              <sql:param value="${i}"/>
            </sql:update>   
            <c:set var="id" value=""/>
          </c:otherwise>
        </c:choose>
      </c:forTokens>
      
      <c:set var="orderid" value="${currentOrderId}"/>
      <%@include file="/WEB-INF/jspf/checkandupdateinv.jspf"%>
      
      <c:if test="${empty errormsg}">
        <sql:update var="updateCount">
          UPDATE custorder SET sellerID = ?, orderdate = ?, specialrequest = ?, donation = ?, doublechecked = ?
                 WHERE id = ?;
           <sql:param value="${param.seller}"/>
           <sql:param value="${param.orderdate}"/>
           <sql:param value="${param.srequest}"/>
           <sql:param value="${!empty param.donation ? param.donation : 0}"/>
           <sql:param value="${!empty param.doublechecked ? 1 : 0}"/>
           <sql:param value="${currentOrderId}"/>
        </sql:update>   

        <sql:update var="updateCount">
            DELETE FROM custorderitem WHERE orderID = ?;
          <sql:param value="${currentOrderId}"/>
        </sql:update>
      
        <sql:update var="updateCount">
            INSERT INTO custorderitem (orderID, saleproductID, quantity)
              SELECT ?, saleproductID, quantity FROM temp${tid}_updateorder
                  WHERE quantity > 0;
            <sql:param value="${orderid}"/>
        </sql:update>                
      </c:if>
                  
      <sql:update var="s">
            DROP TABLE IF EXISTS temp${tid}_updateorder;
      </sql:update>   
            
    </sql:transaction> 
    <c:set var="infomsg" scope="session" value='Order ${empty errormsg ? "" : "not"} updated.'/>    
    <c:redirect url="${pageContext.request.requestURI}" context="/"/>
</c:if>

<script>
pn = new Array();
pq = new Array();
po = new Array();
pp = new Array();

<sql:query var="r" dataSource="${pssdb}">
    SELECT saleproduct.id, saleproduct.name, saleproduct.num, saleproduct.unitprice 
    FROM saleproduct, custorder
    WHERE custorder.id = ? and custorder.saleID = saleproduct.saleID;
   <sql:param value="${currentOrderId}"/>
</sql:query>
<c:forEach var="p" items="${r.rowsByIndex}">
  pn["${p[2]}"] = '${fn:replace(p[1],"'","\\'")}'; po["${p[2]}"] = ${p[0]}; pp["${p[2]}"] = ${p[3]}; pq["${p[2]}"] = 0;
</c:forEach>

<sql:query var="items" dataSource="${pssdb}">
    SELECT num, quantity FROM custorderitem,saleproduct WHERE orderID = ? and custorderitem.saleproductID = saleproduct.id;
  <sql:param value="${currentOrderId}"/>
</sql:query>
<c:forEach var="i" items="${items.rows}">
  pq["${i.num}"] = ${i.quantity};
</c:forEach>
</script>

<c:if test="${!empty errormsg}">
     <div class=errorMessage><span>${errormsg}</span></div>
     <c:set var="errormsg" scope="session" value=""/>
</c:if>
<psstags:showinfomsg/>

<sql:query var="orderq" dataSource="${pssdb}">
    SELECT * from custorder where id = ?;
  <sql:param value="${currentOrderId}"/>
</sql:query>
<c:set var="order" value="${orderq.rows[0]}"/>
<sql:query var="custq" dataSource="${pssdb}">
    SELECT * from customer where id = ?;
  <sql:param value="${order.customerID}"/>
</sql:query>
<c:set var="cust" value="${custq.rows[0]}"/>
<div class="orderform">
<form name="orderform" method="POST" action="editorder.jsp" onsubmit="return checkData(document.orderform)" onclick="hideinfomsg();">
<table border="0">
<tr valign="top">
<td class="textfieldlabel">Customer:</td>
<td class="textfieldvalue" colspan="3">${cust.firstname} ${cust.lastname}<br>
${cust.address}<br>
${cust.city}, ${cust.state}  ${cust.postalcode}<br>
${cust.email}
</td>
</tr>
<tr valign="top">
<td class="textfieldlabel">Phone:</td>
<td class="textfieldvalue" colspan="3">${cust.phonenumber}</td>
</tr>
<tr valign="top">
<td class="textfieldlabel">Alt. Phone:</td>
<td class="textfieldvalue" colspan="3">${cust.phonenumber2}</td>
</tr>
<tr valign="top">
<td class="textfieldlabel">Seller:</td>
<td class="textfieldvalue" colspan="3">
<select name="seller" size="5">
<option value="0">Select a Seller</option>
<sql:query var="r" dataSource="${pssdb}">
    SELECT DISTINCT seller.id as id, lastname, firstname FROM seller,sellergroup
        WHERE (seller.orgID = ? and seller.sellergroupID = sellergroup.id and sellergroup.active = "yes") or 
              (seller.id = ? and seller.sellergroupID = sellergroup.id)
        ORDER BY lastname, firstname;
    <sql:param value="${currentOrgId}"/>
    <sql:param value="${order.sellerID}"/>
</sql:query>
<c:forEach var="s" items="${r.rows}">
  <option value="${s.id}" <c:if test="${s.id == order.sellerID}">selected="true"</c:if>>${s.lastname}, ${s.firstname}</option>
</c:forEach>
</select>
</td>
</tr>
<tr valign="top">
<td class="textfieldlabel">
Date: 
</td>
<td class="textfieldvalue" colspan="3">
<script>
var now = new Date();
var cal = new CalendarPopup("orderdatecal");
</script>
<input type="text" name="orderdate" id="orderdate" value="${order.orderdate}" size="15"
onFocus="cal.select(document.orderform.orderdate,'orderanchor','yyyy-MM-dd'); return false;">
<span id="orderanchor">&nbsp;</spa>
<div id="orderdatecal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
</td>
</tr>

<tr valign="top">
<td class="textfieldlabel">Product #:</td>
<td class="textfieldvalue"><input type="text" name="productnum" size="5"></td>
<td class="textfieldlabel2">Quantity:</td>
<td class="textfieldvalue"><input type="text" name="quantity" size="4" onchange="edititem()"></td>
</tr>
</table>

<table border=0>
<tr><td>
<input type="hidden" name="items" value="">
<textarea name="itemdisplay" cols="65" rows="7" wrap="off" value="" onFocus="resetrefocus()">
</textarea>
</td></tr>
<tr><td align="right">
Total: <input type="text" name="total" value="0.00" size="10" onfocus="document.orderform.submit.focus();">
</td></tr>
</table>
<table border="0" width="100%">
<tr valign="top">
<td class="textfieldlabel">Special Request:</td>
<td class="textfieldvalue"><input type="text" name="srequest" size="45" value="${order.specialrequest}"
       <c:if test="${fn:startsWith(order.specialrequest, 'TID:')}">readonly</c:if> ></td>
</tr>
<tr valign="top">
<td class="textfieldlabel">Donation:</td>
<td class="textfieldvalue"><input type="text" name="donation" size="15" value="${order.donation}"></td>
</tr>
<tr valign="top">
    <td class="textfieldlabel">Double Checked:</td>
    <td class="textfieldvalue"><input type="checkbox" name="doublechecked" value="yes" ${order.doublechecked ? 'checked' : ''}></td>
</tr>
</table>
<p>
<center>
<input type="submit" name="submit" value="Save">
<input type="reset" name="reset" value="Reset" onclick="clearitems();">
</center>
</form>
</div>
</body>
</html>