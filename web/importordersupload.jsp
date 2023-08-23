<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="javax.servlet.jsp.jstl.sql.Result"%>
<%@page import="java.util.SortedMap"%>
<%@page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@page import="javax.servlet.http.*" %>
<%@page import="org.apache.commons.fileupload.*" %>
<%@page import="org.apache.commons.fileupload.disk.*" %>
<%@page import="org.apache.commons.fileupload.servlet.*" %>
<%@page import="org.apache.commons.csv.*" %>
<%@page import="com.jj.*" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
<script type="text/javascript">
    function enableIfSellerSet(orderId) {
        document.getElementById("itemcheckbox_" + orderId).disabled = true;
        if (document.getElementById("seller_" + orderId).value != "0") {
            document.getElementById("itemcheckbox_" + orderId).disabled = false;
        }
    }
</script>

<c:if test="${empty currentSaleId}">
  <sql:query var="r" dataSource="${pssdb}">
      SELECT activesaleID from org where org.id = ?;
    <sql:param value="${currentOrgId}"/>
  </sql:query>
  <c:set var="currentSaleId" value="${r.rows[0].activesaleID}"/>
</c:if>

<sql:query var="saleq" dataSource="${pssdb}">
    SELECT sale.name as name, salestart, saleend, org.phonenumber as phonenumber
        from sale, org where sale.id = ? and sale.orgID = org.id;
  <sql:param value="${currentSaleId}"/>
</sql:query>
<c:set var="sale" value="${saleq.rows[0]}"/>

<psstags:breadcrumb title="Import On-line Orders for ${sale.name}" page="importorders.jsp"/>


<%-- Read saleproduct data --%>
<sql:query var="r" dataSource="${pssdb}">
    SELECT saleproduct.id, saleproduct.num, saleproduct.unitprice 
    FROM saleproduct
    WHERE saleproduct.saleID = ?;
   <sql:param value="${currentSaleId}"/>
</sql:query>
<% Map<String, OrderProductInfo> saleProducts = new HashMap<String, OrderProductInfo>(); %>
<c:forEach var="p" items="${r.rowsByIndex}">
    <c:set var="prodId" value="${p[0]}"/>
    <c:set var="prodNum" value="${p[1]}"/>
    <c:set var="prodPrice" value="${p[2]}"/>
    <%
        OrderProductInfo opi = new OrderProductInfo();
        opi.setNum((String)pageContext.getAttribute("prodNum"));
        opi.setId((Integer)pageContext.getAttribute("prodId"));
        opi.setAmount(Double.valueOf("" + pageContext.getAttribute("prodPrice")));
        saleProducts.put(opi.getNum(), opi);
    %>
</c:forEach>


<%-- Read seller data --%>
<sql:query var="r" dataSource="${pssdb}">
    SELECT seller.id, seller.firstname, seller.lastname FROM seller
    WHERE seller.orgID = ?;
   <sql:param value="${currentOrgId}"/>
</sql:query>
<% 
    Map<String, Integer> sellers = new HashMap<String, Integer>(); 
    Map<String, Integer> sellersPrompt = new TreeMap<String, Integer>();
    request.setAttribute("sellersPrompt", sellersPrompt);
%>
<c:forEach var="p" items="${r.rowsByIndex}">
    <c:set var="sellerId" value="${p[0]}"/>
    <c:set var="firstName" value="${p[1]}"/>
    <c:set var="lastName" value="${p[2]}"/>
    <%
        sellers.put((String)pageContext.getAttribute("firstName") + " " +
                (String)pageContext.getAttribute("lastName"), 
                (Integer)pageContext.getAttribute("sellerId"));
        sellersPrompt.put((String)pageContext.getAttribute("lastName") + ", " +
                (String)pageContext.getAttribute("firstName"), 
                (Integer)pageContext.getAttribute("sellerId"));
    %>
</c:forEach>


<%-- Read customer data --%>
<sql:query var="r" dataSource="${pssdb}">
    SELECT customer.id, customer.phonenumber FROM customer
    WHERE customer.orgID = ?;
   <sql:param value="${currentOrgId}"/>
</sql:query>
<% 
    Map<String, Integer> customers = new HashMap<String, Integer>(); 
%>
<c:forEach var="p" items="${r.rowsByIndex}">
    <c:set var="customerId" value="${p[0]}"/>
    <c:set var="phone" value="${p[1]}"/>
    <%
        customers.put((String)pageContext.getAttribute("phone"), 
                (Integer)pageContext.getAttribute("customerId"));
        
    %>
</c:forEach>


<%-- Read existing order transaction id data --%>
<sql:query var="r" dataSource="${pssdb}">
    SELECT specialrequest FROM custorder 
    WHERE saleID = ? and specialrequest like 'TID:%';
   <sql:param value="${currentSaleId}"/>
</sql:query>
<% 
    Set<String> existingTIDs = new HashSet<String>(); 
%>
<c:forEach var="p" items="${r.rowsByIndex}">
    <c:set var="tid" value="${p[0]}"/>
    <%
        String tid = (String)pageContext.getAttribute("tid");
        existingTIDs.add(tid.replaceAll("TID: ", ""));
    %>
</c:forEach>


<%
    CSVParser csvParser = null;
    String contentType = request.getContentType();
    if (contentType != null && contentType.indexOf("multipart/form-data") >= 0) {
      int maxFileSize = 5000 * 1024;
      DiskFileItemFactory factory = new DiskFileItemFactory();
      factory.setSizeThreshold(maxFileSize);
      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setSizeMax(maxFileSize);
      
      try { 
         // Parse the request to get file items.
         List<FileItem> fileItems = upload.parseRequest(request);
         for (FileItem fi : fileItems) {
            if ( !fi.isFormField () ) {
                csvParser = CSVFormat.EXCEL.parse(new BufferedReader(new InputStreamReader(fi.getInputStream())));
                break;
            } 
         } 
      } catch(Exception ex) {
         out.println(ex);
      }
    } 
    int importedOrders = 0;
    int alreadyEnteredOrders = 0;
    Map<String, OrderInfo> newOrderInfo = new TreeMap<String,OrderInfo>(
        new Comparator<String>() {
            public int compare(String s1, String s2) {
                return Long.compare(Long.valueOf(s1), Long.valueOf(s2));
            }
        });
    
    if (csvParser != null) {
        CSVRecord header = null;
        for (CSVRecord record : csvParser) {
            if (header == null) {
                header = record;
                continue;
            }
            if (record.size() < 4) {
                continue;
            }
            importedOrders++;
            OrderInfo oi = PlantSale.parseCSVOrderData(record, saleProducts, sellers, customers, existingTIDs);
            if (oi == null) {
                alreadyEnteredOrders++;
                continue; 
            }
            newOrderInfo.put("" + oi.getId(), oi);
        }
    }
    int newOrders = newOrderInfo.size();
    request.getSession().setAttribute("newOrderInfo", newOrderInfo);
%>


<c:if test="${!empty errormsg}">
     <div class=errorMessage><span>${errormsg}</span></div>
     <c:set var="errormsg" scope="session" value=""/>
</c:if>
<psstags:showinfomsg/>
<h2>On-line Order Import Confirmation</h2>
<div class="pssTblMgn">
    <p>Uploaded information for <%= importedOrders %> on-line orders.</p>
    <p>Identified <%= alreadyEnteredOrders %> orders that have already been imported or manually entered.</p>

    <p>Identified the following <%= newOrders %> new orders. To enter these orders into the active sale, check each checkbox to confirm the order
    and click Enter Confirmed Orders. Orders with an unidentified seller must have a seller selected before being
    able to confirm the order. Orders with other errors cannot be confirmed until
    the missing or incorrect information is updated.</p>
    
    <form name="DataTable" action="importordersenter.jsp" method = "POST">
        
    <table class="pssTbl" title="New Orders" summary="New Orders" id="DataTableTbl">
        <tr>
            <th class="pssTblColHdrSel" width="3%" align="center" nowrap="nowrap" scope="col">
<a href="#" name="SelectAllHref" title="Confirm All Orders" onclick="javascript:var f=document.DataTable;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && e.name.indexOf('itemcheckbox') != -1 && !e.disabled) e.checked=true;} return false;"><img name="SelectAllImage" src="images/check_all.gif" alt="Confirm All Orders" align="top" border="0" height="13" width="15" /></a>
<a href="#" name="DeselectAllHref" title="Unconfirm All Orders" onclick="javascript:var f=document.DataTable;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && e.name.indexOf('itemcheckbox') != -1) e.checked=false;} return false;"><img name="DeselectAllImage" src="images/uncheck_all.gif" alt="Unconfirm All Orders" align="top" border="0" height="13" width="15" /></a>
</th>
            <th class="pssTblColHdr">Date</th>
            <th class="pssTblColHdr">Customer</th>
            <th class="pssTblColHdr">Seller</th>
            <th class="pssTblColHdr">Transaction ID</th>
            <th class="pssTblColHdr">Order Amount</th>
        </th>
        <c:forEach var="orderentry" items="${newOrderInfo}"> 
            <c:set var="order" value="${orderentry.value}"/>
            <tr>
                <td class="pssTblTdSel" align="center">
                <input type="checkbox" id="itemcheckbox_${order.id}" name="itemcheckbox" 
                       <c:if test="${order.sellerId == null || order.error != null}">disabled</c:if>
                       value="${order.id}" class="pssTblCb" onkeypress="javascript: if (event.keyCode == 13) return false" />
                </td>
                <td class="pssTblTd">${order.date}</td>
                <td class="pssTblTd">
                    <c:if test="${empty order.custId}"><b>(new)</b> </c:if>
                    ${order.firstName} ${order.lastName}, ${order.address}, ${order.city} ${order.state} ${order.zip}, ${order.email}, ${order.phone}
                </td>
                <td class="pssTblTd">${order.sellerName}</td>
                <td class="pssTblTd">${order.transactionId}</td>
                <td class="pssTblTd" align="right">$${order.totalSale}</td>
            </tr>
            <c:if test="${order.error != null}">
                <tr>
                    <td class="pssTblTdMsg"></td>
                    <td class="pssTblTdMsg" style="color: red" colspan="5">${order.error}</td>
                </tr>
            </c:if>
            <c:if test="${order.sellerId == null && order.error == null}">
                <tr>
                    <td class="pssTblTdMsg"></td>
                    <td class="pssTblTdMsg" style="color: red" colspan="2">Unable to identify seller in previous row from uploaded data:</td>
                    <td class="pssTblTdMsg" colspan="3">
                        <select id="seller_${order.id}" name="seller_${order.id}" size="2" onchange="javascript: enableIfSellerSet('${order.id}')">
                        <option selected value="0">Select a Seller</option>
                        <c:forEach var="s" items="${sellersPrompt}">
                            <option value="${s.value}">${s.key}</option>
                        </c:forEach>
                        </select>
                    </td>            
                </tr>
            </c:if>
        </c:forEach>
    </table>

    <p><input type="submit" name="submit" value="Enter Confirmed Orders"></p>
    </form>
</div>
</body>
</html>