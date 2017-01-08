<%@tag description="Properties Form Tag" pageEncoding="UTF-8"%>
<%@tag import="java.util.HashMap"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>

<%@attribute name="table" required="true"%>
<%@attribute name="itemid" required="true"%>
<%@attribute name="validate" fragment="true"%>

<c:if test="${! empty param.save}">
    <%-- validate the update --%>
    <jsp:invoke fragment="validate"/>    
    <c:if test="${!empty errormsg}">
      <c:redirect url="${pageContext.request.requestURI}" context="/"/>
    </c:if>
    
    <%-- construct SQL statement for update --%>
    <c:set var="updstmt" value=""/>
    <c:forEach var="p" items="${paramValues}">
        <c:if test="${rowfields[p.key] && p.key != 'id'}">
          <c:set var="updstmt">
              <c:choose>
                  <c:when test="${empty updstmt}">${p.key}=?</c:when>
                  <c:otherwise>${updstmt}, ${p.key}=?</c:otherwise>
              </c:choose>
          </c:set>
       </c:if>
    </c:forEach>
    <sql:update var="updateCount" dataSource="${pssdb}">
      UPDATE ${table} SET ${updstmt}
        WHERE id=?;
      <c:forEach var="p" items="${paramValues}">
        <c:if test="${rowfields[p.key] && p.key != 'id'}">
          <sql:param value="${p.value[0]}"/>
        </c:if>
      </c:forEach>
      <sql:param value="${itemid}"/>
    </sql:update>
    <c:set var="infomsg" scope="session" value="Save completed."/>
    <c:redirect url="${pageContext.request.requestURI}" context="/"/>
</c:if>

<c:if test="${!empty errormsg}">
     <div class=errorMessage><span>${errormsg}</span></div>
     <c:set var="errormsg" scope="session" value=""/>
</c:if>
<psstags:showinfomsg/>

<sql:query var="r" dataSource="${pssdb}">
    select * from ${table} where id = ?;
    <sql:param value="${itemid}"/>
</sql:query>
<% jspContext.setAttribute("row", new java.util.HashMap(), PageContext.SESSION_SCOPE); %>
<% jspContext.setAttribute("rowfields", new java.util.HashMap(), PageContext.SESSION_SCOPE); %>

<c:forEach var="c" items="${r.columnNames}" varStatus="ci">
  <c:set target="${row}" property="${c}" value="${r.rowsByIndex[0][ci.index]}"/> 
  <c:set target="${rowfields}" property="${c}" value="true"/> 
</c:forEach>

<form name="inputform" method="POST" action="${pageContext.request.requestURI}" onclick="hideinfomsg();">
<table class="propsform" align=center>
<jsp:doBody/>
<tr>
<td colspan=2 style="text-align: center; white-space: nowrap">
<input type="submit" name="save" value="Save">
<input type="reset" value="Reset">
</td>
</tr>
</table>
</form>


