<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<%@include file="/WEB-INF/jspf/head.jspf"%>
</head>
<body>
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<psstags:breadcrumb title="Home" page="admin.jsp"/>

<psstags:tabset     defaultTab="Organizations"
                        height="700px"
                         width="100%"
                          path="admin.jsp">

<psstags:tab name="Organizations">
    <psstags:datatable title="Organizations"
    table="org"
    columnNames="Name,City,Contact"
    columns="org.name,org.city,org.contactname"
    order="ORDER by org.name"
    filter="where activesaleID > 0"
    hiddenfilter="or activesaleID = 0"
    hiddenmsg="Display organizations with no active sale"
    limitdeletetable="sale,user,sellergroup,seller,customer"
    limitdeletetablekey="orgID" limitdeletekey="id"
    itemeditpage="orgedit.jsp?tab=Properties"/>
    <p class="instructions">
    Note: an organization cannot be deleted from here unless all users, customers, sellers, seller groups and sales for the organization have been deleted.
    <br>An entire organization can be deleted from the <a href="admin.jsp?tab=Reports+%26+Tasks">Reports &amp; Tasks</a> tab. 
    </p>
   </psstags:tab>

<psstags:tab name="Products">
   <psstags:datatable title="Products"
    table="product"
    columnNames="Name, Number"
    columns="product.name,product.num"
    order="ORDER BY rightNum(product.num)"
    itemeditpage="producteditadmin.jsp"
    limitdeletetable="saleproduct" limitdeletetablekey="num" limitdeletekey="num"/>
    <p class="instructions">
    Note: a product cannot be deleted until the product number is not being used as part of any sale.
    </p>
</psstags:tab>

<psstags:tab name="Product Groups">
   <psstags:datatable title="Product Groups"
    table="productgroup"
    order="ORDER BY productgroup.name"
    columnNames="Name,# in Group"
    columns="productgroup.name,count"
    itemeditpage="productgroupeditadmin.jsp"
    limitdeletetable="productgroupmember" limitdeletetablekey="productgroupID" limitdeletekey="id"/>
</psstags:tab>
    
<psstags:tab name="Suppliers">
   <psstags:datatable title="Suppliers"
    table="supplier"
    columnNames="Name,City,Contact"
    columns="name,city,contactname"
    itemeditpage="suppliereditadmin.jsp"/>
</psstags:tab>

<psstags:tab name="Reports & Tasks">
<p class="instructions">Reports</p>
<ul class="tasklist">
<li><a href="rptotalsalesadmin.jsp" onclick="runWaitScreen()">Total Sales by Date</a></li>
<li><a href="rptotalsalesbyorgadmin.jsp" onclick="runWaitScreen()">Total Sales by Organization by Date</a></li>
<li><a href="rptotalsalesbyproductadmin.jsp" onclick="runWaitScreen()">Total Sales by Product by Date</a></li>
<li><a href="rptotalsalesbyproductfullflatadmin.jsp" onclick="runWaitScreen()">Total Sales by Product (Full Flats) by Date</a></li>
<li><a href="rpgrossprofitadmin.jsp" onclick="runWaitScreen()">Gross Profit for Active Sales</a></li>
</ul>
<p class="instructions">Tasks<p>
<ul class="tasklist">
    <li><a href="recalculateinventoryadmin.jsp">Recalculate Remaining Product Inventory</li>
    <li><a href="massdeleteadmin.jsp">Mass Delete of Old Data</li>
    <li><a href="orgdeleteadmin.jsp">Delete of Entire Organization</li>
    <li><a href="/cgi/mkbackup.cgi">Make Backup</a></li>
</ul>
</psstags:tab>
</psstags:tabset>
</body>
</html>
    
    
    
    
    
