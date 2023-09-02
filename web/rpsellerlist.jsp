<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
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

<psstags:breadcrumb title="Seller Listing" page="${pageContext.request.requestURI}"/>

<psstags:report title="Seller Listing"
                addRowCount="true"
                columnNames="Name,Family Name,Seller Group"
                columnTypes="text,text,text">
   <jsp:attribute name="query">
        SELECT DISTINCT CONCAT(seller.lastname, ', ', seller.firstname) as sname, seller.familyname, sellergroup.name 
            FROM seller, custorder, sellergroup
            WHERE seller.orgID = ${currentOrgId} and 
                  seller.sellergroupID = sellergroup.id and
                  custorder.sellerID = seller.id and
                  ${customcriteria}
            ORDER BY sellergroup.name, sname;
   </jsp:attribute>
</psstags:report>
</body>
</html>