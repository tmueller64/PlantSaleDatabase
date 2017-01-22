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
    <c:set scope="session" var="currentSellerId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select firstname, lastname from seller where id = ?;
    <sql:param value="${currentSellerId}"/>
</sql:query>
<psstags:breadcrumb title="Seller - ${r.rows[0].firstname} ${r.rows[0].lastname}" page="selleredit.jsp" var="currentSellerId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="selleredit.jsp">
<psstags:tab name="Properties">
  <psstags:propsform table="seller" itemid="${currentSellerId}">
     <psstags:textfield label="First Name" field="firstname" size="30"/>
     <psstags:textfield label="Last Name" field="lastname" size="50"/>
     <psstags:textfield label="Family Name" field="familyname" size="50"/>  
     <psstags:inputfield label="Seller Group">
        <select name="sellergroupID">
          <sql:query var="sgroups" dataSource="${pssdb}">
            select id, name from sellergroup where orgID = ? order by name;
            <sql:param value="${currentOrgId}"/>
          </sql:query>
          <c:forEach var="sg" items="${sgroups.rows}">
            <option value="${sg.id}" <c:if test="${row['sellergroupID'] == sg.id}">selected="true"</c:if> >
              ${sg.name}
            </option>
          </c:forEach>
        </select>
     </psstags:inputfield>
   </psstags:propsform>
</psstags:tab>

<psstags:tab name="Orders">
 <psstags:datatable title="Seller Orders"
    table="custorder"
    filter="LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN customer ON custorder.customerID = customer.id
            WHERE custorder.sellerID = ${currentSellerId}
            GROUP BY customer.lastname, customer.firstname, custorder.orderdate, custorder.id"
    order="ORDER BY custorder.orderdate, customer.lastname, customer.firstname"
    columnNames="Order Date,Customer,Amount"
    columns="orderdate,concat(customer.lastname,', ',customer.firstname),sum(custorderitem.quantity * saleproduct.unitprice)"
    itemsPerPage="30"
    itemeditpage="editorder.jsp"
    itemnewpage="enterorder.jsp"
    extradeletesql="UPDATE product INNER JOIN
                     (SELECT product.id, quantity FROM product, custorderitem, saleproduct
                        WHERE orderId = ? AND saleproductID = saleproduct.id AND 
                              product.num = saleproduct.num AND
                              product.remaininginventory >= 0)
                      AS orditem ON product.id = orditem.id
                    SET remaininginventory = remaininginventory + orditem.quantity;
         DELETE FROM custorderitem WHERE orderID = ?"/>
</psstags:tab>

</psstags:tabset>
</body>
</html>