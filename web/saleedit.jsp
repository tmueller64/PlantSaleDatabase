<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
<script type="text/javascript" src="CalendarPopup.js"></script>
<script language="JavaScript">document.write(getCalendarStyles());</script>
</head>
<body>
<%@include file="/WEB-INF/jspf/banner.jspf"%>
<c:if test="${! empty param.id}">
    <psstags:decrypt var="pid" value="${param.id}"/>
    <c:set scope="session" var="currentSaleId" value="${pid}"/>
</c:if>
<script type="text/javascript"> var djConfig = {isDebug: false}; </script>
<script type="text/javascript" src="./dojo.js"></script>

<sql:query var="r" dataSource="${pssdb}">
    select name from sale where id = ?;
    <sql:param value="${currentSaleId}"/>
</sql:query>
<psstags:breadcrumb title="Sale - ${r.rows[0].name}" page="saleedit.jsp" var="currentSaleId"/>

<psstags:tabset     defaultTab="Properties"
                        height="700px"
                         width="100%"
                          path="saleedit.jsp">
<psstags:tab name="Properties">
  <psstags:propsform table="sale" itemid="${currentSaleId}">
    <jsp:attribute name="validate">
       <fmt:parseDate value="${param.salestart}" type="date" pattern="yyyy-MM-dd" var="d"/>
       <fmt:parseDate value="${param.saleend}" type="date" pattern="yyyy-MM-dd" var="d"/>
    </jsp:attribute>
    <jsp:body>
     <psstags:textfield label="Name" field="name" size="30"/>
     <psstags:textfield label="Theme" field="theme" size="50"/>
     <psstags:textfield label="Coordinator Name(s)" field="coordname" size="30"/>
     <psstags:inputfield label="Sale Start">
     <input type="text" name="salestart" id="salestart" value="${row['salestart']}" size="15"
            onFocus="cals.select(document.inputform.salestart,'salestartanchor','yyyy-MM-dd'); return false;">
     <span id="salestartanchor">&nbsp;</span>
     <div id="salestartcal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
     <script>
     var cals = new CalendarPopup("salestartcal");
     </script>
     </psstags:inputfield>
     <psstags:inputfield label="Sale End">
     <input type="text" name="saleend" id="saleend" value="${row['saleend']}" size="15"
            onFocus="cale.select(document.inputform.saleend,'saleendanchor','yyyy-MM-dd'); return false;">
     <span id="saleendanchor">&nbsp;</span>
     <div id="saleendcal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
     <script>
     var cale = new CalendarPopup("saleendcal");
     </script>
     </psstags:inputfield>
     <psstags:textfield label="Profit" field="profit" size="5"/>
    </jsp:body>
   </psstags:propsform>
<p>
   Note: To make this the active sale, select it on the <a href="orgedit.jsp?tab=Properties">Properties tab</a> for the organization.
</p>
</psstags:tab>


  
<psstags:tab name="Customer Orders">
<script>
dojo.require("dojo.io");
dojo.require("dojo.io.BrowserIO");
function toggledoublecheck(turl) {
    var request = dojo.io.bind({
        url: turl        
        });
}
</script>
These are the orders that have been entered for this sale.
 <psstags:datatable title="Customer Orders"
    table="custorder"
    filter="LEFT JOIN custorderitem ON custorder.id = custorderitem.orderID
            LEFT JOIN saleproduct ON custorderitem.saleproductID = saleproduct.id
            INNER JOIN customer ON custorder.customerID = customer.id
            INNER JOIN seller ON custorder.sellerID = seller.id
            WHERE custorder.saleID = ${currentSaleId}"
    order="GROUP BY customer.lastname, customer.firstname, custorder.orderdate, custorder.id 
           ORDER BY custorder.orderdate, customer.lastname, customer.firstname, seller.lastname, seller.firstname"
    initialValues="(saleID) VALUES (${currentSaleId})"
    columnNames="Order Date,Customer,Seller,Amount"
    columns="custorder.doublechecked,orderdate,concat(customer.lastname,', ',customer.firstname),concat(seller.lastname,', ',seller.firstname),sum(custorderitem.quantity * saleproduct.unitprice)"
    hiddenfilter="AND custorder.doublechecked = false"
    hiddenmsg="Display only orders that have not been double checked"
    itemsPerPage="30"
    itemeditpage="editorder.jsp"
    itemnewpage="enterorder.jsp"
    extradeletesql="UPDATE product INNER JOIN
                     (SELECT product.id, quantity FROM product, custorderitem, saleproduct
                        WHERE orderId = ? AND saleproductID = saleproduct.id AND 
                              product.num = saleproduct.num AND
                              product.remaininginventory >= 0)
                      AS orditem ON product.id = orditem.id
                    SET remaininginventory = remaininginventory + orditem.quantity;
                DELETE FROM custorderitem WHERE orderID = ?"
    itemactioncol="true"
    itemactionlabel="Double Checked">
    <jsp:attribute name="itemactionfrag">
      <c:url var="toggleurl" value="toggleorderdc.jsp">
        <c:param name="id" value="${rowide}"/>
      </c:url>
      <input type="checkbox" value="yes" ${rowactioncol == "true" ? "checked" : ""} onclick="toggledoublecheck('${toggleurl}')"/>
    </jsp:attribute>
 </psstags:datatable>
</psstags:tab>

<c:if test="${userrole == 'admin'}">

<psstags:tab name="Products">

<c:if test="${! empty param.save}">
    <sql:transaction dataSource="${pssdb}">
    <c:forEach var="p" items="${paramValues.delete_row}">
        <sql:update var="updateStatus">
            DELETE FROM saleproduct WHERE num = ? and saleID = ?;
          <sql:param value="${p}"/>
          <sql:param value="${currentSaleId}"/>
        </sql:update>
    </c:forEach>
    <c:forEach var="p" items="${paramValues.insert_row}">
        <sql:update var="updateStatus">
            INSERT INTO saleproduct (saleID, name, num, unitprice) 
                SELECT ?, name, num, unitprice FROM product WHERE num = ?;
          <sql:param value="${currentSaleId}"/>
          <sql:param value="${p}"/> 
        </sql:update>
    </c:forEach>
    <c:forEach var="p" items="${paramValues.update_row}">
        <sql:query var="r" sql="SELECT name,unitprice FROM product WHERE num = ${p}"/>
        <sql:update var="updateStatus">
            UPDATE saleproduct SET name = ?, unitprice = ?
                WHERE num = ? and saleID = ?;
          <sql:param value="${r.rows[0].name}"/>
          <sql:param value="${r.rows[0].unitprice}"/>
          <sql:param value="${p}"/>
          <sql:param value="${currentSaleId}"/>
        </sql:update> 
    </c:forEach>
    </sql:transaction>
    <c:set var="infomsg" scope="session" value="Save completed."/>
    <c:redirect url="saleedit.jsp"/>
</c:if>
<script>
function setState(a, b)
{
    c1 = document.getElementById(a);
    c2 = document.getElementById(b);
    if (c1.checked) c2.disabled = false;
    else c2.disabled = true;
}
function setHidden(a, b)
{
    c1 = document.getElementById(a);
    c2 = document.getElementById(b);
    if (c1.checked) c2.value = "";
    else c2.value = c1.value;
}

</script>
<p class="instructions">
The table below shows the products that are selected for this sale. Some selected products 
may have new information available from the master product table. Select the new information 
checkbox to update this sale to use the new information. 
</p>
<p class="instructions">
To discontinue offering a product as part of this sale, uncheck the check box. If a product 
is currently included in any customer order for this sale, it cannot be discontinued. 
</p>
<p class="instructions">
After checking the boxes as desired, click the Save button to save the changes.
</p>
<psstags:showinfomsg/>

<div class="pssTblMgn">
<form name="productform" method="POST" action="saleedit.jsp" onclick="hideinfomsg();">
<table border="0" style="width: 75%">
<caption class="pssTblTtlTxt">Products for ${r.rows[0].name}</caption>
<tr>
<th class="pssTblColHdrSel" width="3%" align="center" nowrap="nowrap" scope="col">
<a href="#" name="SelectAllHref" title="Select Items Currently Displayed" onclick="javascript:var f=document.productform;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && (e.name == 'insert_row' || e.name == 'delete_row_shown') && !e.disabled) e.checked=true;};return false;"><img name="SelectAllImage" src="images/check_all.gif" alt="Select Items Currently Displayed" align="top" border="0" height="13" width="15" /></a>
<a href="#" name="DeselectAllHref" title="Deselect Items Currently Displayed" onclick="javascript:var f=document.productform;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && (e.name == 'insert_row' || e.name == 'delete_row_shown')) e.checked=false;};return false;"><img name="DeselectAllImage" src="images/uncheck_all.gif" alt="Deselect Items Currently Displayed" align="top" border="0" height="13" width="15" /></a>
</th>
<th style="text-align: left" class="pssTblColHdr" colspan="0">Product</th>
</tr>
<sql:transaction dataSource="${pssdb}">
    <sql:query var="product">
        SELECT product.id + 0 AS prodid,
        CONCAT(product.name, "") AS prodname,
        product.num,
        product.unitprice + 0 AS prodprice,
        salename,
        saleprice,
        saleprodid,
        count(orderID) as ordercount
        FROM product 
        LEFT JOIN (SELECT id AS saleprodid, name AS salename, num, unitprice AS saleprice 
          FROM saleproduct WHERE saleID = ${currentSaleId}) AS sp
          ON product.num = sp.num
        LEFT JOIN custorderitem ON sp.saleprodid = custorderitem.saleproductID 
        GROUP BY product.id 
        ORDER BY product.num;
    </sql:query>
</sql:transaction>

<c:forEach var="p" items="${product.rows}">
  <c:set var="change2" value=""/>
  <c:set var="changebox"><td></td><td></td></c:set>
  <c:set var="disabled" value=""/>
  <c:choose>
    <c:when test="${!empty p.saleprodid}">
      <c:set var="name" value="${p.salename}"/>
      <c:set var="price" value="${p.saleprice}"/>
      <c:set var="checked">checked="true"</c:set>
      <c:set var="cboxname" value="delete_row_shown"/>
      <c:set var="cboxdel"><input type="hidden" id="delete_${p.num}_hidden" name="delete_row" value=""></c:set>
      <c:set var="change1">setHidden('checkbox_${p.num}', 'delete_${p.num}_hidden');</c:set>
      <c:if test="${p.prodname != p.salename || p.prodprice != p.saleprice}">
        <c:set var="change2">setState('checkbox_${p.num}', 'update_${p.num}');</c:set>
        <c:set var="changebox">
          <td><input type="checkbox" value="${p.num}" name="update_row" id="update_${p.num}">Use new info: ${p.prodname}</td><td align="right"><fmt:formatNumber value="${p.prodprice}" type="currency"/></td>
        </c:set>
      </c:if>
      <c:if test="${p.ordercount > 0}">
        <c:set var="disabled">disabled="true"</c:set>
      </c:if>
    </c:when>
    <c:otherwise>
      <c:set var="name" value="${p.prodname}"/>
      <c:set var="price" value="${p.prodprice}"/>
      <c:set var="checked" value=""/>
      <c:set var="cboxname" value="insert_row"/>
      <c:set var="cboxdel" value=""/>
      <c:set var="change1" value=""/>
    </c:otherwise>
  </c:choose>
<tr>
<td><input type="checkbox" value="${p.num}" name="${cboxname}" id="checkbox_${p.num}" ${checked} ${disabled} onchange="${change1} ${change2}">${cboxdel}</td>
<td>${name} <font size="-1">(${p.num} ${p_saleprodid})</font></td>
<td align="right"><fmt:formatNumber value="${price}" type="currency"/></td>
${changebox}
</tr>  
</c:forEach>
<tr>
<td colspan="5">
<input type="submit" name="save" value="Save" style="position: relative; left: 30px;">
<input type="reset" value="Reset" style="position: relative; left: 50px;">
</td>
</td>
</table>
</form>
</div>

</psstags:tab>

  <psstags:tab name="Supplier Order">
  <c:if test="${ ! empty param.save}">
    <sql:transaction dataSource="${pssdb}">
        <c:forEach var="p" items="${param}">
            <c:if test="${fn:startsWith(p.key, 'sorder_')}">
                <c:set var="pa" value="${fn:split(p.key, '_')}"/>
                <c:set var="val" value="${p.value}"/>
                <c:if test="${empty val}"><c:set var="val" value="0"/></c:if>
                <c:choose>
                        <c:when test="${pa[1] > 0}">
                            <sql:update var="updateResult">
                                UPDATE saleproductorder SET flatsordered = "${val}" WHERE id = "${pa[1]}";
                            </sql:update>
                        </c:when>
                        <c:when test="${val == 0}">
                        </c:when>
                        <c:otherwise>
                            <sql:update var="updateResult">
                                INSERT INTO saleproductorder (saleproductID, supplierID, flatsordered) VALUES (${pa[2]}, ${pa[3]}, ${val});
                            </sql:update>
                        </c:otherwise>
                </c:choose>
            </c:if>
        </c:forEach>
    </sql:transaction>
  <c:set var="infomsg" scope="session" value="Save completed."/>
  <c:redirect url="saleedit.jsp"/>
</c:if>
<p class="instructions">
The table below shows how many units of each product have been ordered for this sale with blanks to
fill in for the number of units to be ordered from suppliers and the number of flats to be ordered
from each supplier.  
</p>
<p class="instructions">
After entering the desired amounts, click the Save button to save the changes.
</p>
<psstags:showinfomsg/>

<div class="pssTblMgn">
<form name="orderform" method="POST" action="saleedit.jsp" onclick="hideinfomsg();">
<table border="0" style="width: 75%">
<caption class="pssTblTtlTxt">Order Information for ${r.rows[0].name}</caption>

<sql:transaction dataSource="${pssdb}">
    <sql:update var="v">
        SET SESSION SQL_BIG_SELECTS=1;
    </sql:update>
    <sql:query var="suppliers">
        SELECT DISTINCT supplier.id as id, supplier.name as name
        FROM supplier,saleproduct,supplieritem,product
        WHERE saleproduct.saleID = ? and saleproduct.num = product.num and
        product.id = supplieritem.productID;
        <sql:param value="${currentSaleId}"/>
    </sql:query>
    <c:set var="sheader" value=""/>
    <c:set var="sjoins">
        LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS trincount FROM saleproduct,transfer
                          WHERE tosaleID = ${currentSaleId} AND transfer.saleproductID = saleproduct.id
                          GROUP BY num) AS trin on saleproduct.id = trin.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(expectedquantity) AS troutcount FROM saleproduct,transfer
                          WHERE fromsaleID = ${currentSaleId} AND transfer.saleproductID = saleproduct.id
                          GROUP BY num) AS trout on saleproduct.id = trout.id
        LEFT JOIN (SELECT saleproduct.id AS id, sum(custorderitem.quantity) AS unitsordered FROM saleproduct,custorderitem
                          WHERE saleproduct.saleID = ${currentSaleId} and saleproduct.id = custorderitem.saleproductID
                          GROUP BY saleproduct.id) AS custorder on saleproduct.id = custorder.id
    </c:set>
    <c:set var="sfields">
        trincount, troutcount, unitsordered
    </c:set>
    
    <c:forEach var="s" items="${suppliers.rows}">
        <c:set var="sheader">${sheader}<th class="pssTblColHdr">${s.name} Order</th></c:set>
        <c:set var="sfields">${sfields}, s${s.id}id, s${s.id}ordered, s${s.id}unitsperflat</c:set>
        <c:set var="sjoins">${sjoins} 
            LEFT JOIN (SELECT saleproduct.id AS id, saleproductorder.id AS s${s.id}id, 
                              flatsordered AS s${s.id}ordered, unitsperflat AS s${s.id}unitsperflat  
                       FROM saleproduct
		       LEFT JOIN product ON saleproduct.num = product.num 
		       LEFT JOIN supplieritem ON product.id = supplieritem.productID 
		       LEFT JOIN saleproductorder ON saleproduct.id = saleproductorder.saleproductID AND
                                                     supplieritem.supplierID = saleproductorder.supplierID
                       WHERE supplieritem.supplierID = ${s.id} AND
                             saleproduct.saleID = ${currentSaleId}) AS supp_${s.id} ON saleproduct.id = supp_${s.id}.id
        </c:set>
    </c:forEach>

    <sql:query var="product">        
        SELECT saleproduct.id + 0 as prodid,
        CONCAT(saleproduct.name, "") as prodname,
        saleproduct.num + 0 as num,
        ${sfields}
        FROM saleproduct
        ${sjoins}
        WHERE saleproduct.saleID = ${currentSaleId}
        ORDER BY saleproduct.num;       
    </sql:query>    
</sql:transaction>

<tr>
<th class="pssTblColHdr">Product</th>
<th class="pssTblColHdr">Pre-Sold<br><font size="-1">(units)</font></th>
<th class="pssTblColHdr">Extras<br><font size="-1">(units)</font></th>
<th class="pssTblColHdr">Total Order<br><font size="-1">(units)</font></th>
${sheader}
<th class="pssTblColHdr">Transfers<br><font size="-1">(units)</font></th>
</tr>
<c:set var="jscript">
 ounits = new Array();
 trin = new Array();
 trout = new Array();
 upf = new Array();
</c:set>
<c:forEach var="p" items="${product.rows}">
<tr>
<td style="white-space: nowrap">${p.prodname} <font size="-1">(${p.num})</font></td>
<td align="right" style="padding-right: 10px">${p.unitsordered}</td>
<td id="unitsextra_${p.num}" align="right" style="padding-right: 10px">0</td>
<td id="unitstoorder_${p.num}" align="right" style="padding-right: 10px">0</td>
<c:set var="highestnum" value="${p.num}"/>
<c:set var="jscript">${jscript}
  ounits[${p.num}] = ${0 + p.unitsordered};
  trin[${p.num}] = ${0 + p.trincount};
  trout[${p.num}] = ${0 + p.troutcount};
</c:set>
<c:forEach var="s" items="${suppliers.rows}" varStatus="si">
  <c:set var="unitsperflat">s${s.id}unitsperflat</c:set>
  <c:set var="ordered">s${s.id}ordered</c:set>
  <c:set var="sid">s${s.id}id</c:set>
  <c:set var="sidv">0</c:set>
  <c:if test="${!empty p[sid]}"><c:set var="sidv">${p[sid]}</c:set></c:if>
  <td style="white-space: nowrap">
    <c:if test="${p[unitsperflat] > 0}">
        ${p[unitsperflat]} x <input type="text" id="sorder_${p.num}_${si.index}" name="sorder_${sidv}_${p.prodid}_${s.id}" value="${p[ordered]}" size="3" onchange="update_order();">
        <c:set var="n" value="${pss:divideRoundUp(p.unitsordered, p[unitsperflat])}"/>
        <font size="-2">(${n})</font>
        <c:set var="jscript">${jscript} 
            upf["${p.num}_${si.index}"] = ${p[unitsperflat]};
        </c:set>  
    </c:if>
  </td>
</c:forEach>
  <td style="white-space: nowrap">
  <c:if test="${p.trincount > 0}">in: ${p.trincount} </c:if>
  <c:if test="${p.troutcount > 0}">out: ${p.troutcount} </c:if>
  </td>
</tr>  
</c:forEach>
<tr>
<td colspan="5">
<input type="submit" name="save" value="Save" style="position: relative; left: 30px;">
<input type="reset" value="Reset" style="position: relative; left: 50px;">
</td>
</tr>
</table>
</form>
<script>
${jscript}
    highestnum = ${highestnum};
    numsupp = ${suppliers.rowCount};
    function update_order() {
      for (i = 1; i <= highestnum; i++) {
        vi = trin[i] - trout[i];
        v = document.getElementById("unitstoorder_" + i);
        if (v != null) {
          for (s = 0; s < numsupp; s++) {
            o = document.getElementById("sorder_" + i + "_" + s);
            if (o != null) vi += upf[i + "_" + s] * o.value;
            }
          v.innerHTML = "" + vi;
          if (vi < ounits[i]) v.style.color = "red";
          else v.style.color = "black";
          v = document.getElementById("unitsextra_" + i);
          var e = vi - ounits[i];
          if (e < 0) e = 0;
          v.innerHTML = "" + e;
        }
      }
    }   

update_order();
</script>
</div>
  
  </psstags:tab>
  
   <psstags:tab name="Supplier Deliveries">
<c:if test="${!empty param.save}">
 <sql:transaction dataSource="${pssdb}">
  <c:forEach var="p" items="${param}">
    <c:if test="${fn:startsWith(p.key, 'sdeliv_')}">
      <c:set var="pa" value="${fn:split(p.key, '_')}"/>
      <c:set var="val" value="${p.value}"/>
      <c:if test="${empty val}"><c:set var="val" value="0"/></c:if>
      <c:choose>
        <c:when test="${pa[1] > 0}">
           <sql:update var="updateResult">
              UPDATE saleproductorder SET flatsdelivered = "${val}" WHERE id = "${pa[1]}";
           </sql:update>
        </c:when>
        <c:when test="${val == 0}">
        </c:when>
        <c:otherwise>
           <sql:update var="updateResult">
              INSERT INTO saleproductorder (saleproductID, supplierID, flatsdelivered) VALUES (${pa[2]}, ${pa[3]}, ${val});
           </sql:update>
        </c:otherwise>
      </c:choose>
    </c:if>
  </c:forEach>
 </sql:transaction>
  <c:set var="infomsg" scope="session" value="Save completed."/>
  <c:redirect url="saleedit.jsp"/>
</c:if>
<p class="instructions">
The table below is for entering the number of flats of each product that were delivered for a sale. 
This data is copied from the inventory worksheets for the sale. 
</p>
<p class="instructions">
After entering the delivered amounts, click the Save button to save the changes.
</p>
<psstags:showinfomsg/>

<div class="pssTblMgn">
<form name="orderform" method="POST" action="saleedit.jsp" onclick="hideinfomsg();">
<table border="0" style="width: 75%">
<caption class="pssTblTtlTxt">Received Delivery Information for ${r.rows[0].name}</caption>
<sql:transaction dataSource="${pssdb}">
<sql:update var="v">
    SET SESSION SQL_BIG_SELECTS=1;
</sql:update>

<sql:query var="suppliers">
    SELECT DISTINCT supplier.id as id, supplier.name as name
        FROM supplier,saleproduct,supplieritem,product
        WHERE saleproduct.saleID = ? and saleproduct.num = product.num and
              product.id = supplieritem.productID;
   <sql:param value="${currentSaleId}"/>
</sql:query>
<c:set var="sheader" value=""/>
<c:set var="sfields" value=""/>
<c:set var="sjoins" value=""/>
<c:forEach var="s" items="${suppliers.rows}">
  <c:set var="sheader">${sheader}<th class="pssTblColHdr">${s.name} Order</th></c:set>
  <c:set var="sfields">${sfields}, s${s.id}.id + 0 as s${s.id}id, s${s.id}.flatsordered + 0 as s${s.id}ordered, s${s.id}.flatsdelivered + 0 as s${s.id}delivered</c:set>
  <c:set var="sjoins">${sjoins}
       LEFT JOIN saleproductorder AS s${s.id} ON s${s.id}.saleproductID = saleproduct.id AND s${s.id}.supplierID = ${s.id}
  </c:set>
</c:forEach>

<sql:query var="product">
    SELECT saleproduct.id + 0 as prodid,
           CONCAT(saleproduct.name, "") as prodname,
           saleproduct.num + 0 as num          
           ${sfields}
       FROM saleproduct
       ${sjoins}
       WHERE saleproduct.saleID = ?
       ORDER BY saleproduct.num;       
  <sql:param value="${currentSaleId}"/>
</sql:query>
</sql:transaction>
<tr>
<th class="pssTblColHdr">Product</th>
${sheader}
</tr>
<c:forEach var="p" items="${product.rows}" varStatus="pi">
<tr>
<td style="white-space: nowrap">${p.prodname} <font size="-1">(${p.num})</font></td>
<c:forEach var="s" items="${suppliers.rows}" varStatus="si">
  <c:set var="ordered">s${s.id}ordered</c:set>
  <c:set var="delivered">s${s.id}delivered</c:set>
  <c:set var="sid">s${s.id}id</c:set>
  <c:set var="sidv">0</c:set>
  <c:if test="${!empty p[sid]}"><c:set var="sidv">${p[sid]}</c:set></c:if>
  <td style="white-space: nowrap">
    <input type="text" tabindex="${(si.index * product.rowCount) + pi.index + 1}" id="sdeliv_${p.num}_${si.index}" name="sdeliv_${sidv}_${p.prodid}_${s.id}" value="${p[delivered]}" size="3"/>
        <font size="-2">(${p[ordered]})</font> 
  </td>
</c:forEach>
</tr>  
</c:forEach>
<tr>
<td colspan="5">
<input type="submit" tabindex="0" name="save" value="Save" style="position: relative; left: 30px;">
<input type="reset" tabindex="0" value="Reset" style="position: relative; left: 50px;">
</td>
</tr>
</table>
</form>
</div>
  
  </psstags:tab>
  
  <psstags:tab name="Transfers">
   <psstags:datatable title="Item Transfers to this Sale"
    table="transfer"
    filter=",saleproduct,sale,org
            WHERE transfer.tosaleID = ${currentSaleId} and 
                  transfer.saleproductID = saleproduct.id and
                  transfer.fromsaleID = sale.id and
                  sale.orgID = org.id"
    order="ORDER BY saleproduct.num"
    initialValues="(tosaleID) VALUES (${currentSaleId})"
    columnNames="Product,Expected Quantity,Actual Quantity,From Sale"
    columns="saleproduct.name,transfer.expectedquantity,transfer.actualquantity,CONCAT(org.name,' - ',sale.name)"
    itemeditpage="transfereditadmin.jsp"/>
   <input style="position: relative; left: 50px" type="button" value="Print Transfer Worksheet" onclick="window.open('transferworksheetprintadmin.jsp')"/>
  </psstags:tab>
</c:if>
        
</psstags:tabset>
</body>