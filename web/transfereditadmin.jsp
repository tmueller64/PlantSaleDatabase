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
            <c:set scope="session" var="currentTransferId" value="${pid}"/>
        </c:if>

        <sql:query var="r" dataSource="${pssdb}">
            SELECT saleproduct.name as name FROM saleproduct,transfer WHERE transfer.id = ? and transfer.saleproductID = saleproduct.id;
            <sql:param value="${currentTransferId}"/>
        </sql:query>

        <psstags:breadcrumb title="Transferred Product - ${r.rows[0].name}" page="transfereditadmin.jsp" var="currentTransferId"/>

        <psstags:tabset defaultTab="Properties"
   height="700px"
   width="100%"
   path="transfereditadmin.jsp">
                          
   <psstags:tab name="Properties">
       <psstags:propsform table="transfer" itemid="${currentTransferId}">
           <%-- drop down for product --%>
           <psstags:inputfield label="Product">
               <sql:query var="pq" dataSource="${pssdb}">
                   SELECT id, num, name FROM saleproduct WHERE saleID = ? ORDER BY rightNum(num);
                   <sql:param value="${currentSaleId}"/>
               </sql:query>
               <select name="saleproductID">
                   <c:forEach var="p" items="${pq.rows}">
                       <option value="${p.id}" <c:if test="${row['saleproductID'] == p.id}">selected="true"</c:if>>${p.num}. ${p.name}</option>
                   </c:forEach>
               </select>
           </psstags:inputfield>
           <psstags:inputfield label="From Sale">
               <sql:query var="sq" dataSource="${pssdb}">
                   SELECT DISTINCT org.name as oname, sale.name as sname, sale.id as sid
                        FROM org,sale WHERE org.id = sale.orgID and sale.id != ? ORDER BY org.name, sale.name;
                  <sql:param value="${currentSaleId}"/>
               </sql:query>
               <select name="fromsaleID">
                   <option value="0">--Select a sale--</option>
                   <c:forEach var="s" items="${sq.rows}">
                       <option value="${s.sid}" <c:if test="${row['fromsaleID'] == s.sid}">selected="true"</c:if>>${s.oname} - ${s.sname}</option>
                   </c:forEach>
               </select>
           </psstags:inputfield>
           <psstags:textfield label="Expected Quantity (units)" field="expectedquantity" size="6"/>
           <psstags:textfield label="Actual Quantity (units)" field="actualquantity" size="6"/>
       </psstags:propsform>
   </psstags:tab>
               
        </psstags:tabset>

    </body>
</html>