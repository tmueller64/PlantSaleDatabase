<%@page pageEncoding="UTF-8" import="java.io.*, com.lowagie.text.*, com.lowagie.text.pdf.*"%><%@
   taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%><%@
   taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%><%@
   taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@
   taglib prefix="psstags" tagdir="/WEB-INF/tags"%><%@
   include file="/WEB-INF/jspf/dbsrc.jspf"%><%

   
response.setContentType( "application/pdf" );
Document document = new Document(PageSize.LETTER, 36, 36, 36, 36);
ByteArrayOutputStream buffer = new ByteArrayOutputStream();
PdfWriter.getInstance( document, buffer );
document.open();
PdfPTable table = new PdfPTable(3);

Font hdrfont = FontFactory.getFont(FontFactory.HELVETICA, 14, Font.BOLD);
Font hdr2font = FontFactory.getFont(FontFactory.HELVETICA, 14, Font.BOLD);

%><sql:query var="rq" dataSource="${pssdb}">
    SELECT distinct seller.familyname, CONCAT(seller.firstname, ' ', seller.lastname) as seller, CONCAT(customer.lastname, ', ', customer.firstname) as name, customer.address, customer.city, customer.phonenumber, customer.email
        FROM customer, custorder, seller
        WHERE custorder.customerID = customer.id and custorder.sellerID = seller.id and customer.orgID = ?
        ORDER BY seller.familyname, seller, name;
   <sql:param value="${currentOrgId}"/>
</sql:query><c:set var="curpg" value=""
/><c:forEach var="rqr" items="${rq.rows}"
><c:set var="pgname" value="${not empty rqr.familyname ? rqr.familyname : rqr.seller}"
/><c:if test="${pgname != curpg}"
><c:if test="${!empty curpg}"
><%
    document.add(table); // output the table for the previous family
    document.newPage();
%></c:if
><c:set var="curpg" value="${pgname}"
/><%
    Paragraph p = new Paragraph("Plant Sale Family/Seller Customer List", hdrfont);
    p.setAlignment(Paragraph.ALIGN_CENTER);
    document.add(p);
    p = new Paragraph("Family/Seller: " + (String)pageContext.getAttribute("curpg"), hdr2font);
    p.setAlignment(Paragraph.ALIGN_CENTER);
    document.add(p);
    document.add(new Paragraph(" ")); // blank line before table
    table = new PdfPTable(4);
    table.setTotalWidth(document.getPageSize().width());
%></c:if
><c:set var="c1" value="${rqr.name}"
/><c:set var="c2" value="${rqr.address}, ${rqr.city}"
/><c:set var="c3" value="${rqr.phonenumber}"
/><c:set var="c4" value="${rqr.email}"
/><%  
    table.addCell((String)pageContext.getAttribute("c1"));
    table.addCell((String)pageContext.getAttribute("c2"));
    table.addCell((String)pageContext.getAttribute("c3"));
    table.addCell((String)pageContext.getAttribute("c4"));
%></c:forEach
><%
if (table != null) document.add(table);
document.close();
DataOutput output = new DataOutputStream( response.getOutputStream() );
byte[] bytes = buffer.toByteArray();
response.setContentLength(bytes.length);
for( int i = 0; i < bytes.length; i++ ) { output.writeByte( bytes[i] ); }
%>