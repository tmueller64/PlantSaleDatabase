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

<c:if test="${! empty param.id and userrole == 'admin'}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentOrgId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select name from org where id = ?;
    <sql:param value="${currentOrgId}"/>
</sql:query>

<psstags:breadcrumb title="Organization - ${r.rows[0].name}" page="orgedit.jsp"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="orgedit.jsp">

 <psstags:tab name="Properties">
   <psstags:propsform table="org" itemid="${currentOrgId}">
     <psstags:textfield label="Name" field="name" size="50"/>
     <psstags:textfield label="Address" field="address" size="100"/>
     <psstags:textfield label="City" field="city" size="30"/>
     <psstags:textfield label="State" field="state" size="10"/>  
     <psstags:textfield label="Zip" field="postalcode" size="10"/>
     <psstags:textfield label="Phone" field="phonenumber" size="15"/>
     <psstags:textfield label="Contact Name" field="contactname" size="50"/>
     <psstags:inputfield label="Active Sale">
        <select name="activesaleID">
          <sql:query var="sales" dataSource="${pssdb}">
            select id, name from sale where orgID = ?;
            <sql:param value="${currentOrgId}"/>
          </sql:query>
          <option value="0" <c:if test="${row['activesaleID'] == 0}">selected="true"</c:if>>No Active Sale</option>
          <c:forEach var="s" items="${sales.rows}">
            <option value="${s.id}" <c:if test="${row['activesaleID'] == s.id}">selected="true"</c:if>>
              ${s.name}
            </option>
          </c:forEach>
        </select>
     </psstags:inputfield>
   </psstags:propsform>
 </psstags:tab>

   <psstags:tab name="Users">
    <psstags:datatable title="Users"
    table="user"
    filter="where orgID = ${currentOrgId}"
    order="ORDER BY username"
    initialValues="(orgID) VALUES (${currentOrgId})"
    columnNames="Username,Role"
    columns="username,role"
    itemeditpage="useredit.jsp"/>
   </psstags:tab>
   <psstags:tab name="Customers">
    <psstags:datatable title="Customers"
    table="customer"
    filter="where orgID = ${currentOrgId}"
    order="ORDER BY lastname,firstname"
    initialValues="(orgID) VALUES (${currentOrgId})"
    columnNames="Last Name,First Name,Address,City,Phone"
    columns="lastname,firstname,address,city,phonenumber"
    itemsPerPage="30"
    itemeditpage="customeredit.jsp"
    limitdeletetable="custorder" limitdeletetablekey="customerID" limitdeletekey="id"/>
    <p class="instructions">
    Note: a customer cannot be deleted until all orders for the customer have been deleted.
    </p>
   </psstags:tab>
   <psstags:tab name="Sellers">
    <psstags:datatable title="Sellers"
    table="seller"
    filter="LEFT JOIN sellergroup ON seller.sellergroupID = sellergroup.id WHERE seller.orgID = ${currentOrgId}"
    order="ORDER BY lastname,firstname"
    initialValues="(orgID) VALUES (${currentOrgId})"
    columnNames="Last Name,First Name,Family Name,Seller Group"
    columns="lastname,firstname,familyname,sellergroup.name"
    itemsPerPage="30"
    itemeditpage="selleredit.jsp"
    limitdeletetable="custorder" limitdeletetablekey="sellerID" limitdeletekey="id"/>
    <p class="instructions">
    Note: a seller cannot be deleted until all orders for the seller have been deleted.
    </p>
   </psstags:tab>
   <psstags:tab name="Seller Groups">
    <psstags:datatable title="Seller Groups"
    table="sellergroup"
    filter="WHERE sellergroup.orgID = ${currentOrgId}"
    order="ORDER BY sellergroup.name"
    initialValues="(orgID) VALUES (${currentOrgId})"
    columnNames="Name,# in Group,Active for Order Entry"
    columns="sellergroup.name,count,active"
    itemeditpage="sellergroupedit.jsp"
    limitdeletetable="seller" limitdeletetablekey="sellergroupID" limitdeletekey="id"/>
    <p class="instructions">
    Note: a seller group cannot be deleted until there are no sellers in the group.
    </p>
   </psstags:tab>
   <psstags:tab name="Sales">
    <psstags:datatable title="Sales"
    table="sale"
    filter=",org where orgID = ${currentOrgId} and org.id = sale.orgID"
    order="ORDER BY sale.name"
    initialValues="(orgID) VALUES (${currentOrgId})"
    columnNames="Name,Sale Start,Sale End,Active?"
    columns="sale.name,salestart,saleend,activesaleID=sale.id"
    itemeditpage="saleedit.jsp"
    limitdeletetable="custorder" limitdeletetablekey="saleID" limitdeletekey="id"
    extradeletesql="DELETE FROM saleproduct WHERE saleID = ?"/>
    <p class="instructions">
    Note: a sale cannot be deleted until all orders for the sale have been deleted.
    </p>
   </psstags:tab>
 
   <psstags:tab name="Tasks">
   <ul class="tasklist">
    <li><a href="enterorder.jsp">Enter Orders</a></li>
    <li><a href="importorders.jsp">Import On-line Orders</a></li>
    <!-- <li><a href="sendcustemail.jsp">Send E-Mail to Customers</a> (NOTE: DO NOT USE)</li> -->
</ul>
   </psstags:tab>

<psstags:tab name="Reports">
<p class="instructions">Select one of the following reports:</p>
<h2>Pre-Sale Reports</h2>
<ul class="tasklist">
<li><a href="rpfamcustlist.jsp" onclick="runWaitScreen()">Per Family/Seller Customer Listing</a></li>
</ul>

<h2>Prize Administration Reports</h2>
<ul class="tasklist">
<li><a href="rpssbname.jsp" onclick="runWaitScreen()">Seller Sales sorted by Name</a></li>
<li><a href="rpssbgroup.jsp" onclick="runWaitScreen()">Top Sellers sorted by Seller Group</a></li>
<li><a href="rpssbstotal.jsp" onclick="runWaitScreen()">Top Sellers</a></li>
<li><a href="rpsgroupsum.jsp" onclick="runWaitScreen()">Seller Group Summary</a></li>
<li><a href="rptotalsales.jsp" onclick="runWaitScreen()">Total Sales</a></li>
</ul>
<h2>Database Content Reports</h2>
<ul class="tasklist">
<li><a href="rpcustlist.jsp" onclick="runWaitScreen()">Customer Listing</a></li>
<li><a href="rpsellerlist.jsp" onclick="runWaitScreen()">Seller Listing</a></li>
<li><a href="rporderlist.jsp" onclick="runWaitScreen()">Order Listing</a></li>
<li><a href="rpspecreq.jsp" onclick="runWaitScreen()">Special Request Listing</a></li>
<li><a href="rpemail.jsp" onclick="runWaitScreen()">Customer Email Address Report</a></li>
<li><a href="rpsbproduct.jsp" onclick="runWaitScreen()">Sales by Product</a></li>
</ul>
<h2>Administrator Reports</h2>
<c:if test="${userrole == 'admin'}">
<ul class="tasklist">
  <li><a onclick="window.open('rporderextras.jsp');">Print Active Sale Order Information</a><li>
  <li><a onclick="window.open('rpinvoiceadmin.jsp');">Print Active Sale Invoice</a><li>
  <li><a href="rpinvoicedetailadmin.jsp" onclick="runWaitScreen()">Active Sale Invoice Detail</a>
</ul>
</c:if>
</psstags:tab>
 </psstags:tabset>

</body>
</html>