<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="javax.servlet.jsp.jstl.sql.Result"%>
<%@page import="java.util.SortedMap"%>
<%@page import = "java.io.*,java.util.*, javax.servlet.*" %>
<%@page import = "javax.servlet.http.*" %>
<%@page import="com.jj.*" %>
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
</head>
<body>
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<c:if test="${empty currentSaleId}">
  <sql:query var="r" dataSource="${pssdb}">
      SELECT activesaleID from org where org.id = ?;
    <sql:param value="${currentOrgId}"/>
  </sql:query>
  <c:set var="currentSaleId" value="${r.rows[0].activesaleID}"/>
</c:if>

<sql:query var="saleq" dataSource="${pssdb}">
    SELECT sale.name as name, salestart, saleend, org.phonenumber as phonenumber
        from sale, org where sale.id = ? and sale.orgID = org.id;
  <sql:param value="${currentSaleId}"/>
</sql:query>
<c:set var="sale" value="${saleq.rows[0]}"/>

<psstags:breadcrumb title="Import On-line Orders for ${sale.name}" page="importordersadmin.jsp"/>

<c:if test="${!empty errormsg}">
     <div class=errorMessage><span>${errormsg}</span></div>
     <c:set var="errormsg" scope="session" value=""/>
</c:if>
<psstags:showinfomsg/>

<h2>On-line Order Import Results</h2>

<sql:transaction dataSource="${pssdb}">   

    <sql:update var="s">
        DROP TABLE IF EXISTS temp${tid}_updateorder;
    </sql:update> 
    <sql:update var="s">
        CREATE TABLE temp${tid}_updateorder ( saleproductID INTEGER, quantity INTEGER );
    </sql:update>
    <c:forEach var="i" items="${paramValues.itemcheckbox}">
        <c:set var="order" value="${newOrderInfo[i]}"/>
        <c:forEach var="product" items="${order.products}">
            <sql:update var="updateCount">
                INSERT INTO temp${tid}_updateorder (saleproductID, quantity) VALUES (?, ?);
                  <sql:param value="${product.id}"/>
                  <sql:param value="${product.quantity}"/>
            </sql:update>  
        </c:forEach>
    </c:forEach>
    <%@include file="/WEB-INF/jspf/checkandupdateinv.jspf"%>   
    <sql:update var="s">
            DROP TABLE IF EXISTS temp${tid}_updateorder;
    </sql:update>   

    <%-- Try to enter orders that do not have products that are over inventory 
         by detected and removing those orders that do. --%>
    <c:set var="ordersToEnter" value="${paramValues.itemcheckbox}"/>
    <c:if test="${not empty errormsg}">
        <div class=errorMessage><span>${errormsg}</span></div>
        <c:set var="errormsg" scope="session" value=""/>
        <sql:update var="s">
            DROP TABLE IF EXISTS temp${tid}_updateorder;
        </sql:update> 
        <sql:update var="s">
            CREATE TABLE temp${tid}_updateorder ( saleproductID INTEGER, quantity INTEGER );
        </sql:update>
        <h3>Oversold Orders (not entered)</h3>
        <c:set var="unenteredOrderCount" value="0"/>
        <table class="pssTbl" title="Oversold Orders" summary="Oversold Orders" id="DataTableTbl">
            <tr>
                <th class="pssTblColHdr">Date</th>
                <th class="pssTblColHdr">Customer</th>
                <th class="pssTblColHdr">Seller</th>
                <th class="pssTblColHdr">Transaction ID</th>
                <th class="pssTblColHdr">Order Amount</th>
            </th>
        <% 
           List<String> ordersToEnter = new ArrayList<String>(); 
           pageContext.setAttribute("ordersToEnter", ordersToEnter);
        %>
        <c:forEach var="i" items="${paramValues.itemcheckbox}">
            <c:set var="order" value="${newOrderInfo[i]}"/>
            <c:set var="ok" value="true"/>
            <c:forEach var="product" items="${order.products}">
                <c:if test="${fn:contains(oversoldProducts, product.id)}">
                    <c:set var="ok" value="false"/>
                </c:if>
            </c:forEach>
            <c:choose>
                <c:when test="${ok == 'true'}">
                    <c:forEach var="product" items="${order.products}">
                        <sql:update var="updateCount">
                            INSERT INTO temp${tid}_updateorder (saleproductID, quantity) VALUES (?, ?);
                              <sql:param value="${product.id}"/>
                              <sql:param value="${product.quantity}"/>
                        </sql:update>  
                    </c:forEach>
                    <% ordersToEnter.add((String)pageContext.getAttribute("i")); %>
                </c:when>
                <c:otherwise>
                    <c:set var="unenteredOrderCount" value="${unenteredOrderCount + 1}"/>
                    <c:choose>
                        <c:when test="${order.sellerId == null}">
                            <c:set var="sellerIdParam" value="seller_${order.id}"/>
                            <c:set var="sellerId" value="${param[sellerIdParam]}"/>
                        </c:when>    
                        <c:otherwise>
                            <c:set var="sellerId" value="${order.sellerId}"/>
                        </c:otherwise>
                    </c:choose>
                    <tr>
                        <td class="pssTblTd">${order.date}</td>
                        <td class="pssTblTd">
                            ${order.firstName} ${order.lastName}, ${order.address}, ${order.city} ${order.state} ${order.zip}, ${order.email}, ${order.phone}
                        </td>
                        <td class="pssTblTd">${sellerIds[sellerId]}
                            <c:if test="${sellerId == unmatchedSellerId}">Unmatched Seller (${order.sellerName})</c:if>
                        </td>
                        <td class="pssTblTd">${order.transactionId}</td>
                        <td class="pssTblTd" align="right">$${order.totalSale}</td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </c:forEach>
        </table>
                    
        <%@include file="/WEB-INF/jspf/checkandupdateinv.jspf"%>   
        <sql:update var="s">
                DROP TABLE IF EXISTS temp${tid}_updateorder;
        </sql:update>   
        <p>Did not enter ${unenteredOrderCount} oversold on-line order${unenteredOrderCount != 1 ? "s":""}.</p>
    </c:if>

    <c:choose>
      <c:when test="${not empty errormsg}">
            <div class=errorMessage>
                <p><b>ERROR:</b> Inventory exceeded even after ignoring orders that cause inventory to be exceeded. 
                    No orders entered.</p>
                <span>${errormsg}</span></div>
            <c:set var="errormsg" scope="session" value=""/>
      </c:when>
      
      <c:otherwise>
  
   <div>
    <% 
        Map<String, Integer> newCustomers = new HashMap<String, Integer>(); 
    %>
    <c:set var="enteredOrderCount" value="0"/>
    <h3>Entered Orders</h3>
    <table class="pssTbl" title="Entered Orders" summary="Entered Orders" id="DataTableTbl">
        <tr>
            <th class="pssTblColHdr">Date</th>
            <th class="pssTblColHdr">Customer</th>
            <th class="pssTblColHdr">Seller</th>
            <th class="pssTblColHdr">Transaction ID</th>
            <th class="pssTblColHdr">Order Amount</th>
        </th>

    <c:forEach var="i" items="${ordersToEnter}">
        <c:set var="order" value="${newOrderInfo[i]}"/>
        <%
            OrderInfo order = (OrderInfo)pageContext.getAttribute("order");
            if (order.getCustId() == null && newCustomers.containsKey(order.getPhone())) {
                order.setCustId(newCustomers.get(order.getPhone()).toString());
            }
        %>
        <%-- proceed with entering the order --%>
        <c:choose>
          <c:when test="${empty order.custId}">
            <sql:update var="updateCount">
              INSERT INTO customer (orgID, firstname, lastname, address, city, state, postalcode, phonenumber, email, phonenumber2)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
              <sql:param value="${currentOrgId}"/>
              <sql:param value="${order.firstName}"/>
              <sql:param value="${order.lastName}"/>
              <sql:param value="${order.address}"/>
              <sql:param value="${order.city}"/>
              <sql:param value="${order.state}"/>
              <sql:param value="${order.zip}"/>
              <sql:param value="${order.phone}"/>
              <sql:param value="${order.email}"/>
              <sql:param value=""/> <%-- no phonenumber2 for these orders --%>
            </sql:update>
            <sql:query var="r" sql="select max(id) from customer;"/>
            <c:set var="custid" value="${r.rowsByIndex[0][0]}"/>
            <c:set var="custphone" value="${order.phone}"/>
            <%
                newCustomers.put((String)pageContext.getAttribute("custphone"), 
                                 (Integer)pageContext.getAttribute("custid"));
            %>
          </c:when>
          <c:otherwise>

            <sql:update var="updateCount">
              UPDATE customer SET firstname=?, lastname=?, address=?, city=?, state=?, postalcode=?, phonenumber=?, email=?, phonenumber2=?
                     WHERE id = ?;
              <sql:param value="${order.firstName}"/>
              <sql:param value="${order.lastName}"/>
              <sql:param value="${order.address}"/>
              <sql:param value="${order.city}"/>
              <sql:param value="${order.state}"/>
              <sql:param value="${order.zip}"/>
              <sql:param value="${order.phone}"/>
              <sql:param value="${order.email}"/>
              <sql:param value=""/>
              <sql:param value="${order.custId}"/>
            </sql:update>
            <c:set var="custid" value="${order.custId}"/>
          </c:otherwise>
        </c:choose>

        <c:set var="enteredSeller" value=""/>
        <c:choose>
            <c:when test="${order.sellerId == null}">
                <c:set var="sellerIdParam" value="seller_${order.id}"/>
                <c:set var="sellerId" value="${param[sellerIdParam]}"/>
                <c:if test="${sellerId == unmatchedSellerId}">
                    <c:set var="enteredSeller" value=" Seller: ${order.sellerName}"/>
                </c:if>
            </c:when>    
            <c:otherwise>
                <c:set var="sellerId" value="${order.sellerId}"/>
            </c:otherwise>
        </c:choose>
        
        <sql:update var="updateCount">
          INSERT INTO custorder (customerID, sellerID, saleID, orderdate, specialrequest, donation)
                 VALUES (?, ?, ?, ?, ?, ?);
           <sql:param value="${custid}"/>
           <sql:param value="${sellerId}"/>
           <sql:param value="${currentSaleId}"/>
           <sql:param value="${order.date}"/>
           <sql:param value="TID: ${order.transactionId}${enteredSeller}"/>
           <sql:param value="0"/>
        </sql:update>       
        <sql:query var="r" sql="select max(id) from custorder;"/>
        <c:set var="orderid" value="${r.rowsByIndex[0][0]}"/>

        <c:forEach var="product" items="${order.products}">
            <sql:update var="updateCount">
              INSERT INTO custorderitem (orderID, saleproductID, quantity) VALUE (?, ?, ?)
                  <sql:param value="${orderid}"/>
                  <sql:param value="${product.id}"/> 
                  <sql:param value="${product.quantity}"/>
            </sql:update>
        </c:forEach>
        <c:set var="enteredOrderCount" value="${enteredOrderCount + 1}"/>
        
        <tr>
            <td class="pssTblTd">${order.date}</td>
            <td class="pssTblTd">
                ${order.firstName} ${order.lastName}, ${order.address}, ${order.city} ${order.state} ${order.zip}, ${order.email}, ${order.phone}
            </td>
            <td class="pssTblTd">${sellerIds[sellerId]}
                <c:if test="${sellerId == unmatchedSellerId}">Unmatched Seller (${order.sellerName})</c:if>
            </td>
            <td class="pssTblTd">${order.transactionId}</td>
            <td class="pssTblTd" align="right">$${order.totalSale}</td>
        </tr>
            
    </c:forEach>
    </table>
    <p>Entered ${enteredOrderCount} on-line order${enteredOrderCount != 1 ? "s":""}.</p>
  </div>
  </c:otherwise>
</c:choose>


</sql:transaction>  


</body>
</html>
