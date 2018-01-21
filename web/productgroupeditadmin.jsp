<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@taglib prefix="pss" uri="/WEB-INF/tlds/pss.tld" %>
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
    <c:set scope="session" var="currentProductGroupId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select name from productgroup where id = ?;
    <sql:param value="${currentProductGroupId}"/>
</sql:query>
<psstags:breadcrumb title="Product Group - ${r.rows[0].name}" page="productgroupeditadmin.jsp" var="currentProductGroupId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="productgroupeditadmin.jsp">
<psstags:tab name="Properties">
  <psstags:propsform table="productgroup" itemid="${currentProductGroupId}">
     <psstags:textfield label="Name" field="name" size="32"/>
   </psstags:propsform>
</psstags:tab>
<psstags:tab name="Products">
  <c:if test="${! empty param.save}">
    <sql:transaction dataSource="${pssdb}">
      <sql:update var="updateStatus">
          DELETE FROM productgroupmember WHERE productgroupID = ?;
          <sql:param value="${currentProductGroupId}"/>
      </sql:update>
      <c:forEach var="p" items="${paramValues.member}">
        <sql:update var="updateStatus">
            INSERT INTO productgroupmember (productgroupID, productNum) VALUES (?, ?);
          <sql:param value="${currentProductGroupId}"/>
          <sql:param value="${p}"/> 
        </sql:update>
      </c:forEach>
    </sql:transaction>
    <c:set var="infomsg" scope="session" value="Save completed."/>
    <c:redirect url="productgroupeditadmin.jsp"/>
  </c:if>
<script>

</script>
<p class="instructions">
The table below shows the products that are selected for this product group. 
</p>
<p class="instructions">
After checking the boxes as desired, click the Save button to save the changes.
</p>
<psstags:showinfomsg/>

<div class="pssTblMgn">
<form name="productform" method="POST" action="productgroupeditadmin.jsp" onclick="hideinfomsg();">
<table border="0" style="width: 75%">
<caption class="pssTblTtlTxt">Products for ${r.rows[0].name} Product Group</caption>
<tr>
<th class="pssTblColHdrSel" width="3%" align="center" nowrap="nowrap" scope="col">
<a href="#" name="SelectAllHref" title="Select Items Currently Displayed" onclick="javascript:var f=document.productform;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && (e.name == 'member')) e.checked=true;};return false;"><img name="SelectAllImage" src="images/check_all.gif" alt="Select Items Currently Displayed" align="top" border="0" height="13" width="15" /></a>
<a href="#" name="DeselectAllHref" title="Deselect Items Currently Displayed" onclick="javascript:var f=document.productform;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && (e.name == 'member')) e.checked=false;};return false;"><img name="DeselectAllImage" src="images/uncheck_all.gif" alt="Deselect Items Currently Displayed" align="top" border="0" height="13" width="15" /></a>
</th>
<th style="text-align: left" class="pssTblColHdr" colspan="2">Product</th>
<th colspan="0"></th>
</tr>
<sql:transaction dataSource="${pssdb}">
    <sql:query var="product">
        SELECT product.id,
               product.name,
               product.num, 
               memberid
        FROM product 
        LEFT JOIN (SELECT id as memberid, productNum, productgroupID FROM productgroupmember WHERE productgroupID = ?) 
            AS pg ON product.num = pg.productNum
        ORDER BY rightNum(product.num);
      <sql:param value="${currentProductGroupId}"/>
    </sql:query>
</sql:transaction>
<c:forEach var="p" items="${product.rows}">
  <c:choose>
    <c:when test="${not empty p.memberid}">
      <c:set var="checked">checked="true"</c:set>   
    </c:when>
    <c:otherwise>
      <c:set var="checked" value=""/>
    </c:otherwise>
  </c:choose>
<tr>
<td><input type="checkbox" value="${p.num}" name="member" id="checkbox_${p.num}" ${checked} </td>
<td>${p.name} <font size="-1">(${p.num})</font></td>
</tr>  
</c:forEach>
<tr>
<td colspan="2">
<input type="submit" name="save" value="Save" style="position: relative; left: 30px;">
<input type="reset" value="Reset" style="position: relative; left: 50px;">
</td>
</td>
</table>
</form>
</div>
</psstags:tab>

</psstags:tabset>
</body>