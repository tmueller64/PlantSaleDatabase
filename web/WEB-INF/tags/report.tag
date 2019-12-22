<%@tag description="Report Page Tag" pageEncoding="UTF-8"%>
<%@tag import="java.util.ArrayList"%>
<%@tag import="java.util.SortedMap"%>
<%@tag import="java.text.SimpleDateFormat" %>
<%@tag import="java.util.Date" %>
<%@tag import="javax.servlet.jsp.jstl.sql.Result"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@taglib prefix="pss" uri="/WEB-INF/tlds/pss.tld" %>

<%@attribute name="title"%>
<%@attribute name="columnNames"%>
<%@attribute name="columnTypes"%>
<%@attribute name="addRowCount"%>
<%@attribute name="doNotUseOrg" description="If true, the report does not depend on the currentOrgId attribute being set"%>
<%@attribute name="doNotCustomize"%>
<%@attribute name="query" fragment="true"%>
<%@attribute name="prequery1" fragment="true"%>
<%@attribute name="prequery2" fragment="true"%>
<%@attribute name="postdrops"%>
<%@variable name-given="customcriteria"%>
<%@variable name-given="customdate"%>
<%@variable name-given="customsgroup"%>
<%@variable name-given="dtfrom"%>
<%@variable name-given="dtto"%>
<%@variable name-given="groupid"%>

<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>

<c:choose>
  <c:when test="${!empty param.customize}">
    <c:set var="dtfrom" value="${param.dtfrom}"/>
    <c:set var="dtto" value="${param.dtto}"/>
  </c:when>
  <c:when test="${!doNotUseOrg && !empty currentOrgId && currentOrgId != 0}">
    <sql:query var="dt" dataSource="${pssdb}">
        SELECT salestart, saleend FROM sale,org WHERE org.id = ? and org.activesaleID = sale.id;
      <sql:param value="${currentOrgId}"/>
    </sql:query>
    <c:set var="dtfrom" value="${dt.rows[0].salestart}"/>
    <c:set var="dtto" value="${dt.rows[0].saleend}"/>
  </c:when>
  <c:otherwise>
    <c:set var="year" value='<%= new SimpleDateFormat("yyyy").format(new Date(System.currentTimeMillis())) %>'/>
    <c:set var="dtfrom" value="${year}-01-01"/>
    <c:set var="dtto" value="${year}-12-31"/>
  </c:otherwise>
</c:choose>

<c:if test="${!doNotCustomize}">
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

<c:if test="${!doNotUseOrg && !empty currentOrgId && currentOrgId != 0}">
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
<input type="submit" name="customize" value="Customize" onclick="runWaitScreen()">
</span>
</form>
</div>
</c:if>
<c:set var="colTypes" value="${fn:split(columnTypes, ',')}"/>
<c:set var="customdate">
  custorder.orderdate >= "${dtfrom}" and custorder.orderdate <= "${dtto}"
</c:set>
<c:set var="customcriteria" value="${customdate}"/>
<c:if test="${!empty param.groupid && param.groupid != 0}">
<c:set var="sgroupslist" value="${pss:getContainedSellerGroups(param.groupid, sgroups)}"/>
<c:set var="customsgroup">and seller.sellergroupID IN (${fn:join(sgroupslist, ",")})</c:set>
<c:set var="customcriteria">${customcriteria} ${customsgroup}</c:set>
</c:if>

        <sql:transaction dataSource="${pssdb}">
            <c:if test="${! empty prequery1}">
                <sql:update var="u">
                    <jsp:invoke fragment="prequery1"/>
                </sql:update>
            </c:if>
            <c:if test="${! empty prequery2}">
                <sql:update var="u">
                    <jsp:invoke fragment="prequery2"/>
                </sql:update>
            </c:if>
            <sql:query var="r">
                <jsp:invoke fragment="query"/>
            </sql:query>
            <c:if test="${! empty postdrops}">
                <sql:update var="u">
                    DROP TABLE ${postdrops};
                </sql:update>
            </c:if>
        </sql:transaction>

<div class="report">
<table title="${title}" summary="${title}">
<caption>${title}<c:if test="${addRowCount}"> (${r.rowCount} rows)</c:if></caption>
<thead>
    <tr>
        <c:forEach var="chdr" items="${columnNames}" varStatus="status">
            <th>${chdr}</th>
        </c:forEach>
    </tr>
</thead>

<c:forEach var="row" items="${r.rowsByIndex}">
    <tbody><tr>     
            <c:forEach var="col" items="${row}" varStatus="coln">
                <c:choose>
                    <c:when test="${colTypes[coln.index] == 'number'}">
                        <td class="number"><fmt:formatNumber value="${col}" maxFractionDigits="0"/></td>
                    </c:when>
                    <c:when test="${colTypes[coln.index] == 'money'}">
                        <td class="number"><fmt:formatNumber value="${col}" type="currency"/></td>
                    </c:when>
                    <c:otherwise>
                        <td class="text">${col}</td>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
    </tr></tbody>
</c:forEach>

</table>
</div>

