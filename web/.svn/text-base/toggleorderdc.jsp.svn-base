<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>
<psstags:accesscheck/>
<c:if test="${! empty param.id}">
  <psstags:decrypt var="pid" value="${param.id}"/>
  <sql:update var="cq" dataSource="${pssdb}">
     UPDATE custorder SET  doublechecked = !doublechecked WHERE id = ?;
     <sql:param value="${pid}"/>
  </sql:update>  
  Customer order updated.
</c:if>

