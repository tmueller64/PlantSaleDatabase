<%@tag description="Tab tag" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@attribute name="name"%>
<c:choose>
    <c:when test="${empty tabNames}">
       <c:set var="tabNames" value="${name}" scope="request"/>
    </c:when>
    <c:otherwise>
       <c:set var="tabNames" value="${tabNames},${name}" scope="request"/>
    </c:otherwise>
</c:choose>
<c:if test="${name == selectedTab}">
<jsp:doBody/>
</c:if>


