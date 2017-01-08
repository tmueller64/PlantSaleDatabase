<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>
<psstags:accesscheck/>
<c:choose>
    <c:when test="${param.what == 'phone'}">
        <sql:query var="cq" dataSource="${pssdb}">
            SELECT * FROM customer WHERE orgID = "${currentOrgId}" and (phonenumber like "%${param.ss}%" or phonenumber2 like "%${param.ss}%");
        </sql:query>
    </c:when>
    <c:when test="${param.what == 'lastname'}">
        <sql:query var="cq" dataSource="${pssdb}">
            SELECT * FROM customer WHERE orgID = "${currentOrgId}" and lower(lastname) like "${param.ss}%";
        </sql:query>
    </c:when>
</c:choose>

[
<c:forEach var="c" items="${cq.rows}">
 ["${c.phonenumber} - ${c.lastname}, ${c.firstname}", "${c.phonenumber}", "${c.firstname}", "${c.lastname}", "${c.address}", "${c.city}", "${c.state}", "${c.postalcode}", "${c.email}", "${c.phonenumber2}", "${c.id}"],
</c:forEach>
];

