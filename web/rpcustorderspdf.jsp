<%@page pageEncoding="UTF-8" import="java.io.*, java.math.BigDecimal, com.lowagie.text.*, com.lowagie.text.pdf.*"%><%@
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
PdfPCell cell;
BigDecimal total = BigDecimal.ZERO;
Paragraph pp;

Font hdrfont = FontFactory.getFont(FontFactory.HELVETICA, 14, Font.BOLD);
Font hdr2font = FontFactory.getFont(FontFactory.HELVETICA, 14, Font.BOLD);

%><sql:transaction dataSource="${pssdb}"><sql:query var="rq">
    SELECT DISTINCT CONCAT(seller.lastname, ', ', seller.firstname) as sname, 
          orderdate,
          CONCAT(customer.lastname, ', ', customer.firstname) as cname, 
          customer.phonenumber, customer.address,
          CONCAT(customer.city, ', ', customer.state, '  ', customer.postalcode) as address2,
          custorder.id,
          saleproduct.num, custorderitem.quantity, saleproduct.name, 
          custorderitem.quantity * saleproduct.unitprice as pcost
     FROM custorderitem, custorder, saleproduct, customer, seller
     WHERE seller.orgID = ? AND
           custorderitem.orderID = custorder.id AND
           custorderitem.saleproductID = saleproduct.id AND
           custorder.customerID = customer.id AND
           custorder.sellerID = seller.id AND
           saleproduct.num >= ? AND saleproduct.num <= ?
       ORDER BY customer.lastname, customer.firstname, custorder.orderdate, custorder.id, saleproduct.num;
   <sql:param value="${currentOrgId}"/>
   <sql:param value="${pnumfrom}"/>
   <sql:param value="${pnumto}"/>
    </sql:query><c:set var="curorderid" value=""
/></sql:transaction><c:forEach var="rqr" items="${rq.rows}"
><c:if test="${rqr.id != curorderid}"
><c:if test="${not empty curorderid}"
><%
    cell = new PdfPCell();
    cell.setBorder(0);
    table.addCell(cell);
    table.addCell(cell);
    cell = new PdfPCell(new Paragraph("Total:"));
    cell.setBorder(0);
    cell.setHorizontalAlignment(Paragraph.ALIGN_RIGHT);
    table.addCell(cell);
    cell = new PdfPCell(new Paragraph(total.toString()));
    cell.setBorder(0);
    cell.setHorizontalAlignment(Paragraph.ALIGN_RIGHT);
    table.addCell(cell);
    document.add(table); // output the table for the previous order
    document.newPage();
%></c:if
><c:set var="curorderid" value="${rqr.id}"
/><c:set var="orderdate" value="${rqr.orderdate}"
/><c:set var="custname" value="${rqr.cname}"
/><c:set var="custaddress" value="${rqr.address}"
/><c:set var="custaddress2" value="${rqr.address2}"
/><c:set var="custphone" value="${rqr.phonenumber}"
/><c:set var="sellername" value="${rqr.sname}"
/><%
    pp = new Paragraph("Plant Sale Customer Order", hdrfont);
    pp.setAlignment(Paragraph.ALIGN_CENTER);
    document.add(pp);
    document.add(new Paragraph("Customer:", hdr2font));
    document.add(new Paragraph((String)pageContext.getAttribute("custname")));
    document.add(new Paragraph((String)pageContext.getAttribute("custaddress")));
    document.add(new Paragraph((String)pageContext.getAttribute("custaddress2")));
    document.add(new Paragraph((String)pageContext.getAttribute("custphone")));
    document.add(new Paragraph("Seller: " + (String)pageContext.getAttribute("sellername")));
    document.add(new Paragraph("Order date: " + pageContext.getAttribute("orderdate").toString()));
    document.add(new Paragraph(" ")); // blank line before table
    pp = new Paragraph("--------------------------------------------------------------------------------------------------");
    pp.setAlignment(Paragraph.ALIGN_CENTER);
    document.add(pp);
    document.add(new Paragraph(" "));
    document.add(new Paragraph(" "));
    total = BigDecimal.ZERO;
    table = new PdfPTable(4);
    table.setTotalWidth(document.getPageSize().width());
    table.setHeaderRows(1);
    table.setWidths(new int[]{10, 50, 20, 20});
    cell = new PdfPCell(new Paragraph("Num"));
    cell.setHorizontalAlignment(Paragraph.ALIGN_CENTER);
    table.addCell(cell);
    table.addCell("Product Name");
    cell = new PdfPCell(new Paragraph("Quantity"));
    cell.setHorizontalAlignment(Paragraph.ALIGN_CENTER);
    table.addCell(cell);
    cell = new PdfPCell(new Paragraph("Amount"));
    cell.setHorizontalAlignment(Paragraph.ALIGN_RIGHT);
    table.addCell(cell);
%></c:if
><c:set var="c1" value="${rqr.num} "
/><c:set var="c2" value="${rqr.name} "
/><c:set var="c3" value="${rqr.quantity} "
/><c:set var="c4" value="${rqr.pcost}"
/><%  
    cell = new PdfPCell(new Paragraph((String)pageContext.getAttribute("c1")));
    cell.setHorizontalAlignment(Paragraph.ALIGN_CENTER);
    table.addCell(cell);
    table.addCell((String)pageContext.getAttribute("c2"));
    cell = new PdfPCell(new Paragraph((String)pageContext.getAttribute("c3")));
    cell.setHorizontalAlignment(Paragraph.ALIGN_CENTER);
    table.addCell(cell);
    cell = new PdfPCell(new Paragraph(pageContext.getAttribute("c4").toString()));
    cell.setHorizontalAlignment(Paragraph.ALIGN_RIGHT);
    table.addCell(cell);
    total = total.add((BigDecimal)pageContext.getAttribute("c4"));
%></c:forEach
><%
if (table != null) {
    cell = new PdfPCell();
    cell.setBorder(0);
    table.addCell(cell);
    table.addCell(cell);
    cell = new PdfPCell(new Paragraph("Total:"));
    cell.setBorder(0);
    cell.setHorizontalAlignment(Paragraph.ALIGN_RIGHT);
    table.addCell(cell);
    cell = new PdfPCell(new Paragraph(total.toString()));
    cell.setBorder(0);
    cell.setHorizontalAlignment(Paragraph.ALIGN_RIGHT);
    table.addCell(cell);
    document.add(table);
}
document.close();
DataOutput output = new DataOutputStream( response.getOutputStream() );
byte[] bytes = buffer.toByteArray();
response.setContentLength(bytes.length);
for( int i = 0; i < bytes.length; i++ ) { output.writeByte( bytes[i] ); }
%>