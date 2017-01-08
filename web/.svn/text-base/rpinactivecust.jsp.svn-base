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

<psstags:breadcrumb title="Inactive Customer Report" page="${pageContext.request.requestURI}"/>

<p>The Inactive Customer Report provides a listing of customers whose last order
was placed within the date range specified below. When using this report, keep in
mind that if a person has more than one customer record, because of a phone number change for example,
there may be newer orders for the person associated with other records even though
the person is listed in this report.
</p>
<psstags:report title="Inactive Customer Report"
                addRowCount="true"
                columnNames="Name,Address,City,Zip,Phone,Email,Last Order Date"
                columnTypes="text,text,text,text,text,text,text">
   <jsp:attribute name="query">
        SELECT CONCAT(firstname, ' ', lastname), address, city, postalcode, phonenumber, email, orderdate
            FROM (SELECT customer.firstname as firstname,
                         customer.lastname as lastname,
                         customer.email as email,
                         customer.address as address,
                         customer.city as city,
                         customer.postalcode as postalcode,
                         customer.phonenumber as phonenumber,
                         MAX(orderdate) as orderdate
                     FROM custorder, customer, seller WHERE custorder.customerID = customer.id and
                                                    custorder.sellerID = seller.id and
                                                    customer.orgID = ${currentOrgId} ${customsgroup}
                     GROUP BY custorder.customerID) as custorder
            WHERE ${customdate}
            ORDER BY lastname, firstname
   </jsp:attribute>
</psstags:report>
</body>
</html>