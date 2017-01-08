<%@tag description="Tabset Tag" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@ attribute name="height"        description="Table height"%>
<%@ attribute name="width"         description="Table width"%>
<%@ attribute name="defaultTab"    description="Name for default selected tab"%>
<%@ attribute name="path"          description="Self redirecting path"%>

<c:if test="${! empty param.tab}">
  <c:set var="selectedTab" scope="session" value="${param.tab}"/>
  <c:set var="selectedTabPage" scope="session" value="${path}"/>
</c:if>
<c:if test="${empty selectedTab || path != selectedTabPage}">
    <c:set var="selectedTab" scope="session" value="${defaultTab}"/>
    <c:set var="selectedTabPage" scope="session" value="${path}"/>
</c:if>
<jsp:doBody var="tabpanel"/>
<div class="tabset">
<ul class="tabs">
<c:forEach var="tabName" items="${tabNames}" varStatus="status">
   <c:choose>
     <c:when test="${tabName == selectedTab}">
      <li class="current">
      <span>${tabName}</span>
      </li>
     </c:when>
     <c:otherwise>
      <li>
       <c:url var="taburl" value="${path}">
         <c:param name="tab" value="${tabName}"/>
       </c:url>
       <span onclick='document.location="${taburl}"'>${tabName}</span>
      </li>
     </c:otherwise>
    </c:choose>
 </c:forEach>
 </ul>
<div style="width: ${width}; height: ${height}" class="tabpanel"> 
${tabpanel}
</div>
</div>