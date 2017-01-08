<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.Date" %>
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

<psstags:breadcrumb title="Send Customer E-Mail" page="${pageContext.request.requestURI}"/>

<c:choose>
  <c:when test="${!empty param.customize}">
    <c:set var="dtfrom" value="${param.dtfrom}"/>
    <c:set var="dtto" value="${param.dtto}"/>
  </c:when>
  <c:when test="${!empty currentOrgId && currentOrgId != 0}">
    <sql:query var="dt" dataSource="${pssdb}">
        SELECT salestart, saleend FROM sale,org WHERE org.id = ? and org.activesaleID = sale.id;
      <sql:param value="${currentOrgId}"/>
    </sql:query>
    <c:set var="dtfrom" value="${dt.rows[0].salestart}"/>
    <c:set var="dtto" value="${dt.rows[0].saleend}"/>
  </c:when>
  <c:otherwise>
    <c:set var="year" value="<%= new SimpleDateFormat("yyyy").format(new Date(System.currentTimeMillis())) %>"/>
    <c:set var="dtfrom" value="${year}-01-01"/>
    <c:set var="dtto" value="${year}-12-31"/>
  </c:otherwise>
</c:choose>

<div style="margin-top: 5px">
    <p>Customer e-mail addresses are selected for customers that have orders
        that fall within the dates below and for the selected seller group. To change 
        the e-mail address list, enter new selections and press the Update To List button.
    </p>
<script type="text/javascript" src="CalendarPopup.js"></script>
<script language="JavaScript">document.write(getCalendarStyles());</script>
<form name="reportform" method="POST" action="">
<span>
<span class="textfieldlabel2">Orders From Date:</span>
<input type="text" name="dtfrom" id="dtfrom" size="10" value="${dtfrom}"
       onFocus="calfrom.select(document.reportform.dtfrom,'dtfromanchor','yyyy-MM-dd'); return false;">
<span id="dtfromanchor">&nbsp;</span>
<div id="dtfromcal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
<script>
     var calfrom = new CalendarPopup("dtfromcal");
</script>

<span class="textfieldlabel2">To Date:</span>
<input type="text" name="dtto" size="10" value="${dtto}"
       onFocus="calto.select(document.reportform.dtto,'dttoanchor','yyyy-MM-dd'); return false;">
<span id="dttoanchor">&nbsp;</span>
<div id="dttocal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
<script>
     var calto = new CalendarPopup("dttocal");
</script>

<c:if test="${!empty currentOrgId && currentOrgId != 0}">
  <span class="textfieldlabel2">Seller Group:</span>
  <select name="groupid">
  <option value="0">All</option>
  <sql:query var="sgroups" dataSource="${pssdb}">
      SELECT id, name, insellergroupID FROM sellergroup WHERE orgID = ? ORDER BY name;
    <sql:param value="${currentOrgId}"/>
  </sql:query>
  <c:forEach var="sg" items="${sgroups.rows}">
    <option value="${sg.id}" <c:if test="${param.groupid == sg.id}">selected="true"</c:if> >${sg.name}</option>
  </c:forEach>
  </select>
</c:if>
<input type="submit" name="customize" value="Update To List" onclick="runWaitScreen()">
</span>
</form>
</div>

<c:set var="customdate">
  custorder.orderdate >= "${dtfrom}" and custorder.orderdate <= "${dtto}"
</c:set>
<c:set var="customcriteria" value="${customdate}"/>
<c:if test="${!empty param.groupid && param.groupid != 0}">
<c:set var="sgroupslist" value="${pss:getContainedSellerGroups(param.groupid, sgroups)}"/>
<c:set var="customsgroup">and seller.sellergroupID IN (${fn:join(sgroupslist, ",")})</c:set>
<c:set var="customcriteria">${customcriteria} ${customsgroup}</c:set>
</c:if>

<hr>
<form method="POST" action="sendcustemail2.jsp">
    <table>
        <tr>
            <td><span class="textfieldlabel2">From:</span></td>
            <td><input type="text" size="80" name="fromaddr"></td>
        </tr>
        <tr valign="top">
            <td><span class="textfieldlabel2">To:</span></td>
<sql:query var="r" dataSource="${pssdb}">
        SELECT DISTINCT CONCAT(customer.firstname, ' ', customer.lastname, ' &lt;', customer.email, '&gt;') as emailaddr
        FROM customer, custorder, seller  
        WHERE customer.orgID = ${currentOrgId} and 
        custorder.customerID = customer.id and
        custorder.sellerID = seller.id and
        email != "" and
        ${customcriteria}
        ORDER BY customer.lastname, customer.firstname;
</sql:query>
            <td>
<textarea name="toaddr" cols="70" rows="10"><c:forEach var="c" items="${r.rows}">
${c.emailaddr},</c:forEach>
</textarea>
            </td>
        </tr>
        <tr>
            <td><span class="textfieldlabel2">Subject:</span></td>
            <td><input type="text" size="80" name="subject"></td>
        </tr>
        <tr><td colspan="2"><span class="textfieldlabel2">Message:</span></td></tr>
        <tr><td colspan="2"><textarea name="message" cols="80" rows="35"></textarea></td></tr>
    </table>
<input type="submit" name="sendmsg" value="Send">
</form>
</body>
</html>