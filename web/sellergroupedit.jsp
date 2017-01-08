<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
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
<c:if test="${! empty param.id}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentSellerGroupId" value="${pid}"/>
</c:if>

<sql:query var="r" dataSource="${pssdb}">
    select name from sellergroup where id = ?;
    <sql:param value="${currentSellerGroupId}"/>
</sql:query>
<psstags:breadcrumb title="Seller Group - ${r.rows[0].name}" page="sellergroupedit.jsp" var="currentSellerGroupId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="sellergroupedit.jsp">
<psstags:tab name="Properties">
  <psstags:propsform table="sellergroup" itemid="${currentSellerGroupId}">
     <psstags:textfield label="Name" field="name" size="32"/>
     <psstags:inputfield label="Active for Order Entry">
        <select name="active">
          <option value="yes" <c:if test="${row['active'] == 'yes'}">selected="true"</c:if>>yes</option>
          <option value="no" <c:if test="${row['active'] != 'yes'}">selected="true"</c:if>>no</option>
        </select>
     </psstags:inputfield>
     <psstags:inputfield label="Containing Seller Group">
        <select name="insellergroupID">
          <sql:query var="sgroups" dataSource="${pssdb}">
            select id, name from sellergroup where orgID = ? and id != ? order by name;
            <sql:param value="${currentOrgId}"/>
            <sql:param value="${currentSellerGroupId}"/>
          </sql:query>
          <option value="0" <c:if test="${row['insellergroupID'] == 0}">selected="true"</c:if> >None</option>
          <c:forEach var="sg" items="${sgroups.rows}">
            <option value="${sg.id}" <c:if test="${row['insellergroupID'] == sg.id}">selected="true"</c:if> >
              ${sg.name}
            </option>
          </c:forEach>
        </select>
     </psstags:inputfield>

   </psstags:propsform>
</psstags:tab>

<psstags:tab name="Seller List">
  <sql:query var="sgroups" dataSource="${pssdb}">
      SELECT id, name, insellergroupID FROM sellergroup WHERE orgID = ? ORDER BY name;
    <sql:param value="${currentOrgId}"/>
  </sql:query>
  <c:set var="sgroupslist" value="${pss:getContainedSellerGroups(currentSellerGroupId, sgroups)}"/>

  <psstags:report title="${r.rows[0].name} Seller List"
                columnNames="Last Name, First Name, Family name, Primary Seller Group"
                columnTypes="text,text,text,text"
                doNotCustomize="true"
                addRowCount="true">
    <jsp:attribute name="query">
        SELECT lastname, firstname, familyname, sellergroup.name
        FROM seller, sellergroup
        WHERE sellergroupID IN (${fn:join(sgroupslist, ",")}) and sellergroupID = sellergroup.id
        ORDER BY lastname, firstname;
    </jsp:attribute>    
  </psstags:report>
</psstags:tab>
</psstags:tabset>
</body>