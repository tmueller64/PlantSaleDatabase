<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="javax.crypto.*"%>
<%@page import="java.security.*"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<c:if test="${!empty param.login}">
    <c:set var="pssdb" value="jdbc/plantsale" scope="session"/>
    
  <sql:query var="u" dataSource="${pssdb}">
      SELECT * from user where username = ? and password = ?;
    <sql:param value="${param.username}"/>
    <sql:param value="${param.password}"/>
  </sql:query>
  <c:if test="${u.rowCount == 0}">
    <c:set var="infomsg" scope="session" value="Invalid login. Please try again."/>
    <c:redirect url="index.jsp"/>
  </c:if>
  <c:set var="userrole" value="${u.rows[0].role}" scope="session"/>
  <c:set var="username" value="${u.rows[0].username}" scope="session"/>
  <c:set var="currentOrgId" value="${u.rows[0].orgID}" scope="session"/>
  <c:set var="tid" value="<%= session.hashCode() %>" scope="session"/>
  <sql:update var="v" dataSource="${pssdb}">
      SET SESSION SQL_BIG_SELECTS=1;
  </sql:update>
  <%
    // Set up encryption support for role base authorization
    KeyGenerator kg = KeyGenerator.getInstance("DES");
    kg.init(56);
    Key k = kg.generateKey();
    session.setAttribute("ciphkey", k);
    /*
    Cipher eciph = Cipher.getInstance("DES");
    eciph.init(Cipher.ENCRYPT_MODE, k);
    Cipher dciph = Cipher.getInstance("DES");
    dciph.init(Cipher.DECRYPT_MODE, k);
    session.setAttribute("eciph", eciph);
    session.setAttribute("dciph", dciph);
  */
  %>
  <c:choose>
    <c:when test="${userrole == 'admin'}"><c:redirect url="admin.jsp"/></c:when>
    <c:when test="${userrole == 'orgadmin'}"><c:redirect url="orgedit.jsp"/></c:when>
    <c:when test="${userrole == 'dataentry'}"><c:redirect url="enterorder.jsp"/></c:when>
  </c:choose>
  <c:set var="infomsg" scope="session" value="Invalid user role. Please contact the administrator."/>
  <c:redirect url="index.jsp"/>    
</c:if>

<c:if test="${!empty param.logout}">
  <% session.invalidate(); %>
  <c:redirect url="index.jsp"/>
</c:if>

<html>
<head>
<%@include file="/WEB-INF/jspf/head.jspf"%>
</head>
<body style="background-color: rgb(0, 102, 0);">
<form method="POST" action="index.jsp">
<table border=0 style="height: 72px; width: 360px; left: 96px; top: 192px; position: absolute" cellpadding="2">
<tr>
<td style="color: #ffff00; height: 26px; text-align: right; width: 91px" class="textfieldlabel2">Username:</td>
<td style="width: 155px"><input type="text" name="username" size="16"></td>
</tr>
<tr>
<td style="color: #ffff00; height: 26px; text-align: right; width: 91px" class="textfieldlabel2">Password:</td>
<td style="width: 155px"><input type="password" name="password" size="16"></td>
</tr>
</table>
<div style="left: 191px; top: 288px; position: absolute; width: 89px" class="textfieldlabel2"><input type="submit" name="login" value="Login"/></div>
<div style="font-size: 9pt; left: 10px; top: 400px; position: absolute;" class="header2Message">
Questions? Contact Janet Saeger, 402-980-3807, janet@janetsjungle.com
</div>
<div style="color: #ffff00; left: 168px; top: 24px; position: absolute" class="headerMessage">Welcome to the Plant Sale System</div>
<img height="120" width="152" style="left: 0px; top: 0px; position: absolute" src="images/flwrpotsgr.gif"/>

<div style="height: 46px; left: 120px; top: 144px; position: absolute; width: 500px" class="titleMessage">
<c:choose>
  <c:when test="${!empty infomsg}">${infomsg}</c:when>
  <c:otherwise>Please login.</c:otherwise>
</c:choose>
<c:set var="infomsg" scope="session" value=""/>
</div>
</form>
</body>
</html>

