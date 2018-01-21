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
    <c:set scope="session" var="currentSupplierId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select name from supplier where id = ?;
    <sql:param value="${currentSupplierId}"/>
</sql:query>

<psstags:breadcrumb title="Supplier - ${r.rows[0].name}" page="suppliereditadmin.jsp" var="currentSupplierId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="suppliereditadmin.jsp">
<psstags:tab name="Properties">
   <psstags:propsform table="supplier" itemid="${currentSupplierId}">
     <psstags:textfield label="Name" field="name" size="30"/>
     <psstags:textfield label="Address" field="address" size="100"/>
     <psstags:textfield label="City" field="city" size="50"/>
     <psstags:textfield label="State" field="state" size="20"/>  
     <psstags:textfield label="Zip" field="postalcode" size="20"/>
     <psstags:textfield label="Phone" field="phonenumber" size="30"/>
     <psstags:textfield label="Fax" field="faxnumber" size="30"/>
     <psstags:textfield label="Contact Name" field="contactname" size="30"/>
   </psstags:propsform>

</psstags:tab>
<psstags:tab name="Supplied Products">
 <psstags:datatable title="Supplied Products"
    table="supplieritem"
    filter=",product WHERE supplierID = ${currentSupplierId} and productID = product.id"
    order="ORDER by rightNum(product.num)"
    initialValues="(supplierID) VALUES (${currentSupplierId})"
    columnNames="Name,Number,Units Per Flat,Cost Per Flat,Inventory"
    columns="product.name,product.num,unitsperflat,costperflat,inventory"
    itemeditpage="supplieritemeditadmin.jsp"/>
  </psstags:tab>
<psstags:tab name="Orders & Deliveries">
 <psstags:datatable title="Supplier Orders"
    table="supplierorder"
    filter="WHERE supplierID = ${currentSupplierId}"
    order="ORDER by expecteddeliverydate"
    initialValues="(supplierID) VALUES (${currentSupplierId})"
    columnNames="Expected Date,Address,City"
    columns="expecteddeliverydate,deladdress,delcity"
    itemnewpage="supplierordernewadmin.jsp"
    itemeditpage="supplierordereditadmin.jsp"
    extradeletesql="UPDATE saleproductorder SET supplierorderID = 0 WHERE supplierorderID = ?"
    itemactionlabel="Print">
    <jsp:attribute name="itemactionfrag">
      <c:url var="orderurl" value="supplierorderprintadmin.jsp">
        <c:param name="id" value="${rowide}"/>
      </c:url>
      <c:url var="iwurl" value="supplierworksheetprintadmin.jsp">
        <c:param name="id" value="${rowide}"/>
      </c:url>
      <input type="button" value="Order" onclick="window.open('${orderurl}')"/>
      <input type="button" value="Inventory Worksheet" onclick="window.open('${iwurl}')"/>
    </jsp:attribute>
 </psstags:datatable>
 <p class="instructions">
   The sales from this year in the list below have not been assigned for a supplier delivery.
   To schedule a sale for delivery, create a new supplier order or edit an existing order.
 </p>
 <psstags:report title="Unassigned Sale Orders"
                columnNames="Organization,Sale"
                columnTypes="text,text"
                doNotCustomize="true">
   <jsp:attribute name="query">
        SELECT DISTINCT org.name,sale.name
        FROM org,sale,saleproduct,saleproductorder
        WHERE org.id = sale.orgID and sale.id = saleproduct.saleID and 
              saleproductorder.saleproductID = saleproduct.id and 
              saleproductorder.supplierorderID = 0 and
              year(sale.saleend) = year(curdate()) and
              saleproductorder.supplierID = "${currentSupplierId}";
   </jsp:attribute>
</psstags:report>
</psstags:tab>

</psstags:tabset>
</body>