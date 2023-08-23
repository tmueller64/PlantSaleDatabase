<%@page contentType="text/html"%>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.Date" %>
<%@page import="javax.servlet.jsp.jstl.sql.Result"%>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@include file="/WEB-INF/jspf/head.jspf"%>
</head>
<body>
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<psstags:breadcrumb title="Product Sales Detail Report" page="${pageContext.request.requestURI}"/>


<c:choose>
  <c:when test="${!empty param.customize}">
    <c:set var="dtfrom" value="${param.dtfrom}"/>
    <c:set var="dtto" value="${param.dtto}"/>
  </c:when>
  <c:otherwise>
    <c:set var="year" value='<%= new SimpleDateFormat("yyyy").format(new Date(System.currentTimeMillis())) %>'/>
    <c:set var="dtfrom" value="${year}-01-01"/>
    <c:set var="dtto" value="${year}-12-31"/>
  </c:otherwise>
</c:choose>

<div style="margin-top: 5px">
<script type="text/javascript" src="CalendarPopup.js"></script>
<script language="JavaScript">document.write(getCalendarStyles());</script>
<form name="reportform" method="POST" action="">
<span>
<span class="textfieldlabel2">From:</span>
<input type="text" name="dtfrom" id="dtfrom" size="10" value="${dtfrom}"
       onFocus="calfrom.select(document.reportform.dtfrom,'dtfromanchor','yyyy-MM-dd'); return false;">
<span id="dtfromanchor">&nbsp;</span>
<div id="dtfromcal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
<script>
     var calfrom = new CalendarPopup("dtfromcal");
</script>

<span class="textfieldlabel2">To:</span>
<input type="text" name="dtto" size="10" value="${dtto}"
       onFocus="calto.select(document.reportform.dtto,'dttoanchor','yyyy-MM-dd'); return false;">
<span id="dttoanchor">&nbsp;</span>
<div id="dttocal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
<script>
     var calto = new CalendarPopup("dttocal");
</script>
<c:set var="customdate">
  custorder.orderdate >= "${dtfrom}" and custorder.orderdate <= "${dtto}"
</c:set>
  
  <span class="textfieldlabel2">Product:</span>
  <select name="productnum">
  <option value="0">Select a Product</option>
  <sql:query var="pnums" dataSource="${pssdb}">
      SELECT saleproduct.num, saleproduct.name FROM saleproduct, custorderitem, custorder
        WHERE custorder.id = custorderitem.orderID and
              custorderitem.saleproductID = saleproduct.id and
              ${customdate}
        GROUP BY saleproduct.num ORDER BY rightNum(saleproduct.num);
  </sql:query>
  <c:forEach var="pnum" items="${pnums.rows}">
    <c:if test="${param.productnum == pnum.num}"> 
      <c:set var="productname" value="${pnum.name}"/>
    </c:if>
    <option value="${pnum.num}" <c:if test="${param.productnum == pnum.num}">selected="true"</c:if> >${pnum.num} - ${pnum.name}</option>
  </c:forEach>
  </select>
<input type="submit" name="customize" value="Customize" onclick="runWaitScreen()">
</span>
</form>
</div>

<c:set var="customcriteria" value="${customdate}"/>
<c:if test="${!empty param.productnum && param.productnum != 0}">
<c:set var="customcriteria">${customcriteria} AND saleproduct.num = "${param.productnum}"</c:set>
</c:if>

<div class="report">
    
<c:choose>
<c:when test="${!empty param.productnum && param.productnum != 0}">
        
  <sql:transaction dataSource="${pssdb}">
      <sql:query var="r">
        SELECT saleproduct.name as productname, org.name as orgname, 
               CONCAT(customer.lastname, ", ", customer.firstname) as custname, 
               customer.phonenumber, customer.email,
               sum(custorderitem.quantity) as oquan
        FROM org, custorderitem, saleproduct, custorder, customer
        WHERE org.id = customer.orgID and
              custorder.customerID = customer.id and
              custorder.id = custorderitem.orderID and
              custorderitem.saleproductID = saleproduct.id and
              ${customcriteria}
        GROUP BY custorderitem.saleproductID, customer.id
        ORDER BY org.name, custname;
   
      </sql:query>
  </sql:transaction>

  <c:set var="title" value="Sales Detail Report for Product: ${productname}"/>
  <c:set var="columnNames" value="pname,Organization,Name,Phone,Email,Quantity"/>
  <c:set var="columnTypes" value="hidden,span,text,text,text,number"/>
  <c:set var="colTypes" value="${fn:split(columnTypes, ',')}"/>

<table title="${title}" summary="${title}">
<caption>${title}</caption>
<thead>
    <tr>
        <c:forEach var="chdr" items="${columnNames}" varStatus="status">
            <c:if test="${colTypes[status.index] != 'hidden'}">
              <th>${chdr}</th>
            </c:if>
        </c:forEach>
    </tr>
</thead>
<tbody>
<c:set var="lastspan" value=""/>
<c:forEach var="row" items="${r.rowsByIndex}">
    <tr>     
            <c:forEach var="col" items="${row}" varStatus="coln">
                <c:choose>
                    <c:when test="${colTypes[coln.index] == 'number'}">
                        <td class="number"><fmt:formatNumber value="${col}" maxFractionDigits="0"/></td>
                    </c:when>
                    <c:when test="${colTypes[coln.index] == 'money'}">
                        <td class="number"><fmt:formatNumber value="${col}" type="currency"/></td>
                    </c:when>
                    <c:when test="${colTypes[coln.index] == 'hidden'}">
                    </c:when>
                    <c:when test="${colTypes[coln.index] == 'span'}">
                        <c:if test="${col != lastspan}">
                            <c:set var="lastspan" value="${col}"/>
                            <td class="text" colspan="5">${col}</td></tr><tr>
                        </c:if>
                        <td></td>
                    </c:when>
                    <c:otherwise>
                        <td class="text">${col}</td>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
    </tr>
</c:forEach>
</tbody>
</table>

</c:when>
<c:otherwise>
    <p>This report provides the list of customers that have ordered the selected 
        product, sorted by organization. Select the desired product from the <b>Product</b>
        drop down above and click "Customize".</p>
    <p>Only products sold in the selected 
        date range are available in the drop down; if the desired product is not
        listed, adjust the dates as needed and click "Customize", then select the 
        desired product.</p>
</c:otherwise>

</c:choose>
</div>    
</body>
</html>