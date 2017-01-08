<%@tag description="Access Check" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%> 
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- perform access check --%>
<c:if test="${empty userrole}">
  <c:set var="infomsg" scope="session" value="Login is required.  Your previous login session may have expired."/>
  <c:redirect url="index.jsp"/>
</c:if>
<c:if test="${(userrole == 'dataentry' && (!fn:endsWith(pageContext.request.requestURI, '/enterorder.jsp') &&
                                           !fn:endsWith(pageContext.request.requestURI, '/lookupcust.jsp'))) ||
              (userrole == 'orgadmin' && fn:endsWith(pageContext.request.requestURI, 'admin.jsp'))}">
  <c:redirect url="accessviolation.html"/>
</c:if>

