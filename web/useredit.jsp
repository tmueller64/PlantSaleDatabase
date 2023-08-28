<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
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
    <c:set scope="session" var="currentUserId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select username from user where id = ?;
    <sql:param value="${currentUserId}"/>
</sql:query>
<psstags:breadcrumb title="User - ${r.rows[0].username}" page="useredit.jsp" var="currentUserId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="useredit.jsp">
<psstags:tab name="Properties">
  <psstags:propsform table="user" itemid="${currentUserId}">
     <jsp:attribute name="validate">
       <c:if test="${param.role == 'admin' && userrole != 'admin'}">
         <c:redirect url="accessviolation.html"/>
       </c:if>
     </jsp:attribute>
     <jsp:body>
       <psstags:textfield label="Username" field="username" size="32"/>
       <psstags:textfield label="Password" field="password" size="32"/>
       <psstags:inputfield label="Role">
         <select name="role">
          <c:if test="${userrole == 'admin'}">
            <option value="admin" <c:if test="${row['role'] == 'admin'}">selected="true"</c:if>>Administrator</option>
          </c:if>
          <option value="orgadmin" <c:if test="${row['role'] == 'orgadmin'}">selected="true"</c:if>>Organization Administrator</option>
          <option value="dataentry" <c:if test="${row['role'] == 'dataentry'}">selected="true"</c:if>>Order Data Entry</option>
          <option value="orgreports" <c:if test="${row['role'] == 'orgreports'}">selected="true"</c:if>>Organization Reports</option>
         </select>
       </psstags:inputfield>
     </jsp:body>
   </psstags:propsform>
</psstags:tab>
</psstags:tabset>
</body>
</html>