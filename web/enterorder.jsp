<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="javax.servlet.jsp.jstl.sql.Result"%>
<%@page import="java.util.SortedMap"%>
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
<script type="text/javascript" src="CalendarPopup.js"></script>
<script language="JavaScript">document.write(getCalendarStyles());</script>
<script language="JavaScript">
// Prevent <Enter> from submitting the form
var nav = window.Event ? true : false;
if (nav) {
   window.captureEvents(Event.KEYDOWN);
   window.onkeydown = NetscapeEventHandler_KeyDown;
} else {
   document.onkeydown = MicrosoftEventHandler_KeyDown;
}

function NetscapeEventHandler_KeyDown(e) {
  if (e.which == 13 && e.target.type != 'textarea' && e.target.type != 'submit' && e.target.type != 'reset') { return false; }
  if (e.which == 9 && e.target.name == 'orderdate') {
    document.orderform.productnum.focus();
    cal.hideCalendar();
    return false;
  } 
  return true;
}

function MicrosoftEventHandler_KeyDown() {
  if (event.keyCode == 13 && event.srcElement.type != 'textarea' && event.srcElement.type != 'submit' && event.srcElement.type != 'reset')
    return false;
  if (event.keyCode == 9 && event.srcElement.name == 'orderdate') {
    document.orderform.productnum.focus();
    cal.hideCalendar();
    return false;
  } 
  return true;
}
</script>
</head>
<body onload="dojo.widget.getWidgetById('phone').textInputNode.focus();">
<%@include file="/WEB-INF/jspf/banner.jspf"%>

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

<psstags:breadcrumb title="Enter Order for ${sale.name}" page="enterorder.jsp"/>

<c:if test="${! empty param.submit}">
  <c:set var="lastcity" scope="session" value="${param.city}"/>
  <c:set var="laststate" scope="session" value="${param.state}"/>
  <c:set var="lastzip" scope="session" value="${param.zip}"/>
  <c:set var="lastdate" scope="session" value="${param.orderdate}"/>
  <%-- validate date value - throws exception if invalid --%>
  <fmt:parseDate value="${param.orderdate}" type="date" pattern="yyyy-MM-dd" var="d"/>
  
  <sql:query var="r" dataSource="${pssdb}"
             sql="select sale.id from sale,org where salestart <= ? and saleend >= ? and sale.id = ?;">
    <sql:param value="${param.orderdate}"/>
    <sql:param value="${param.orderdate}"/>
    <sql:param value="${currentSaleId}"/>
  </sql:query>
  <c:if test="${r.rowCount < 1}">
    <c:set var="errormsg" scope="session" value="The entered date is invalid for the ${sale.name}."/>
    <c:redirect url="${pageContext.request.requestURI}" context="/"/>
  </c:if>

  <sql:transaction dataSource="${pssdb}">   
     
    <sql:update var="s">
        DROP TABLE IF EXISTS temp${tid}_updateorder;
    </sql:update> 
    <sql:update var="s">
        CREATE TABLE temp${tid}_updateorder ( saleproductID INTEGER, quantity INTEGER );
    </sql:update>
    <c:set var="id" value=""/>
    <c:forTokens var="i" items="${param.items}" delims=":">
      <c:choose>
        <c:when test="${empty id}"><c:set var="id" value="${i}"/></c:when>
        <c:otherwise>
          <sql:update var="updateCount">
             INSERT INTO temp${tid}_updateorder (saleproductID, quantity)
                    VALUES (?, ?);
              <sql:param value="${id}"/>
              <sql:param value="${i}"/>
          </sql:update>  
          <c:set var="id" value=""/>
        </c:otherwise>
      </c:choose>
    </c:forTokens>
    <%@include file="/WEB-INF/jspf/checkandupdateinv.jspf"%>   
    
    <c:if test="${empty errormsg}">
        <%-- proceed with entering the order --%>
        <c:choose>
          <c:when test="${empty param.custid}">
            <sql:update var="updateCount">
              INSERT INTO customer (orgID, firstname, lastname, address, city, state, postalcode, phonenumber, email, phonenumber2)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
              <sql:param value="${currentOrgId}"/>
              <sql:param value="${param.firstname}"/>
              <sql:param value="${param.lastname}"/>
              <sql:param value="${param.address}"/>
              <sql:param value="${param.city}"/>
              <sql:param value="${param.state}"/>
              <sql:param value="${param.zip}"/>
              <sql:param value="${param.areacode}${param.phone}"/>
              <sql:param value="${param.email}"/>
              <sql:param value="${param.phonenumber2}"/>
            </sql:update>
            <sql:query var="r" sql="select max(id) from customer;"/>
            <c:set var="custid" value="${r.rowsByIndex[0][0]}"/>
          </c:when>
          <c:otherwise>
            <sql:update var="updateCount">
              UPDATE customer SET firstname=?, lastname=?, address=?, city=?, state=?, postalcode=?, phonenumber=?, email=?, phonenumber2=?
                     WHERE id = ?;
              <sql:param value="${param.firstname}"/>
              <sql:param value="${param.lastname}"/>
              <sql:param value="${param.address}"/>
              <sql:param value="${param.city}"/>
              <sql:param value="${param.state}"/>
              <sql:param value="${param.zip}"/>
              <sql:param value="${param.areacode}${param.phone}"/>
              <sql:param value="${param.email}"/>
              <sql:param value="${param.phonenumber2}"/>
              <sql:param value="${param.custid}"/>
            </sql:update>
            <c:set var="custid" value="${param.custid}"/>
          </c:otherwise>
        </c:choose>

        <sql:update var="updateCount">
          INSERT INTO custorder (customerID, sellerID, saleID, orderdate, specialrequest, donation)
                 VALUES (?, ?, ?, ?, ?, ?);
           <sql:param value="${custid}"/>
           <sql:param value="${param.seller}"/>
           <sql:param value="${currentSaleId}"/>
           <sql:param value="${param.orderdate}"/>
           <sql:param value="${param.srequest}"/>
           <sql:param value="${!empty param.donation ? param.donation : 0}"/>
        </sql:update>       
        <sql:query var="r" sql="select max(id) from custorder;"/>
        <c:set var="orderid" value="${r.rowsByIndex[0][0]}"/>

        <sql:update var="updateCount">
            INSERT INTO custorderitem (orderID, saleproductID, quantity)
              SELECT ?, saleproductID, quantity FROM temp${tid}_updateorder;
            <sql:param value="${orderid}"/>
        </sql:update>  
     </c:if> 
              
     <sql:update var="s">
            DROP TABLE IF EXISTS temp${tid}_updateorder;
     </sql:update>                
  </sql:transaction>  
  <c:set var="infomsg" scope="session" value='Order ${empty errormsg ? "" : "not"} entered.'/>               
  <c:redirect url="${pageContext.request.requestURI}" context="/"/>
</c:if>

<script type="text/javascript"> var djConfig = {isDebug: false}; </script>
<script type="text/javascript" src="./dojo.js"></script>
<script type="text/javascript">
	dojo.require("dojo.widget.ComboBox");
	
	dojo.widget.SubComboBox = function(){
		dojo.widget.html.ComboBox.call(this);
		this.widgetType = "SubComboBox";
	}

	dojo.inherits(dojo.widget.SubComboBox, dojo.widget.html.ComboBox);

	dojo.lang.extend(dojo.widget.SubComboBox, {
    
                selectOption: function(evt){
                    this.constructor.superclass.selectOption.call(this, evt);
                    var v = this.getValue();
                    for (var i in this.dataProvider.cache) {
                        if (v == i) {
                            var d = this.dataProvider.cache[i];
                            if (d[1].length > 7) {
                                dojo.widget.getWidgetById('phone').setValue(d[1].substring(3));
                                document.orderform.areacode.value = d[1].substring(0, 3);
                            }
                            else {
                                dojo.widget.getWidgetById('phone').setValue(d[1]);
                                document.orderform.areacode.value = '';
                            }
                            document.orderform.firstname.value = d[2];
                            dojo.widget.getWidgetById('lastname').setValue(d[3]);
                            document.orderform.address.value = d[4];
                            document.orderform.city.value = d[5];
                            document.orderform.state.value = d[6];
                            document.orderform.zip.value = d[7];
                            document.orderform.email.value = d[8];
                            document.orderform.phonenumber2.value = d[9];
                            document.orderform.custid.value = d[10];
                            t = document.getElementById("custstatus");
                            t.innerHTML = "Existing Customer Information:";
                            break;
                        }
                    }
                },

                onKeyUp: function(evt){
                    // remove non-digets from phone numbers
                    this.setValue(this.textInputNode.value.replace(/[^0-9]/g, ''));
                    this.constructor.superclass.onKeyUp.call(this, evt);
                },
            
		fillInTemplate: function(args, frag){
			this.constructor.superclass.fillInTemplate.call(this, args, frag);
			//dojo.html.addClass(this.downArrowNode, "hide");
			this.autoComplete = false;
			this.dataProvider = {
                                dan: this.downArrowNode,
                               	inFlight: false,
                               	activeRequest: null,
                               	searchUrl: "lookupcust.jsp?what=phone&ss=",
                               	cache: {},
                               	
                                addToCache: function(data){
                                        for (var i = 0; i < data.length; i++) {
                                            this.cache[data[i][0]] = data[i];
                                        }
                		},

				startSearch: function(searchStr){
					if (searchStr.length < 6) {
                                            return;
                                        }
                                        
					if(this.inFlight){
                                            // FIXME: implement backoff!
                                        }
                                        // check if value already in cache
                                        var cachedata = new Array();
                                        var j = 0;
                                        for (var i in this.cache) {
                                            if (i.indexOf(searchStr) != -1) {
                                                cachedata[j++] = this.cache[i];
                                            }
                                        }
                                        if (cachedata.length > 0) {
                                            this.provideSearchResults(cachedata);
                                            return;
                                        }
                                        var tss = encodeURIComponent(searchStr);
                                        var realUrl = this.searchUrl + tss;
                                        var _this = this;
                                        var request = dojo.io.bind({
                                            url: realUrl,
                                            method: "get",
                                            mimetype: "text/javascript",
                                            load: function(type, data, evt){
                                                _this.inFlight = false;
                                                _this.addToCache(data);
                                                _this.provideSearchResults(data);
                                            }
                                        });
                                        this.inFlight = true;
				}
			};
		}
		
	});
	dojo.widget.tags.addParseTreeHandler("dojo:subcombobox");

	dojo.widget.SubComboBox2 = function(){
		dojo.widget.html.ComboBox.call(this);
		this.widgetType = "SubComboBox2";
	}

	dojo.inherits(dojo.widget.SubComboBox2, dojo.widget.html.ComboBox);

	dojo.lang.extend(dojo.widget.SubComboBox2, {
    
                selectOption: function(evt){
                    this.constructor.superclass.selectOption.call(this, evt);
                    var v = this.getValue();
                    for (var i in this.dataProvider.cache) {
                        if (v == i) {
                            var d = this.dataProvider.cache[i];
                            if (d[1].length > 7) {
                                dojo.widget.getWidgetById('phone').setValue(d[1].substring(3));
                                document.orderform.areacode.value = d[1].substring(0, 3);
                            }
                            else {
                                dojo.widget.getWidgetById('phone').setValue(d[1]);
                                document.orderform.areacode.value = '';
                            }
                            document.orderform.firstname.value = d[2];
                            dojo.widget.getWidgetById('lastname').setValue(d[3]);
                            document.orderform.address.value = d[4];
                            document.orderform.city.value = d[5];
                            document.orderform.state.value = d[6];
                            document.orderform.zip.value = d[7];
                            document.orderform.email.value = d[8];
                            document.orderform.phonenumber2.value = d[9];
                            document.orderform.custid.value = d[10];
                            t = document.getElementById("custstatus");
                            t.innerHTML = "Existing Customer Information:";
                            break;
                        }
                    }
                },
            
		fillInTemplate: function(args, frag){
			this.constructor.superclass.fillInTemplate.call(this, args, frag);
			//dojo.html.addClass(this.downArrowNode, "hide");
			this.autoComplete = false;
			this.dataProvider = {
                                dan: this.downArrowNode,
                               	inFlight: false,
                               	activeRequest: null,
                               	searchUrl: "lookupcust.jsp?what=lastname&ss=",
                               	cache: {},
                               	
                                addToCache: function(data){
                                        for (var i = 0; i < data.length; i++) {
                                            this.cache[data[i][0]] = data[i];
                                        }
                		},

				startSearch: function(searchStr){
					if (searchStr.length < 3) {
                                            return;
                                        }
                                        
					if (this.inFlight){
                                            // FIXME: implement backoff!
                                        }
                                        // check if value already in cache
                                        var cachedata = new Array();
                                        var j = 0;
                                        for (var i in this.cache) {
                                            if (i.indexOf(searchStr) != -1) {
                                                cachedata[j++] = this.cache[i];
                                            }
                                        }
                                        if (cachedata.length > 0) {
                                            this.provideSearchResults(cachedata);
                                            return;
                                        }
                                        var tss = encodeURIComponent(searchStr);
                                        var realUrl = this.searchUrl + tss.toLowerCase();
                                        var _this = this;
                                        var request = dojo.io.bind({
                                            url: realUrl,
                                            method: "get",
                                            mimetype: "text/javascript",
                                            load: function(type, data, evt){
                                                _this.inFlight = false;
                                                _this.addToCache(data);
                                                _this.provideSearchResults(data);
                                            }
                                        });
                                        this.inFlight = true;
				}
			};
		}
		
	});
	dojo.widget.tags.addParseTreeHandler("dojo:subcombobox2");

</script>

<script>

pn = new Array();
pq = new Array();
po = new Array();
pp = new Array();

<sql:query var="r" dataSource="${pssdb}">
    SELECT saleproduct.id, saleproduct.name, saleproduct.num, saleproduct.unitprice 
    FROM saleproduct
    WHERE saleproduct.saleID = ?;
   <sql:param value="${currentSaleId}"/>
</sql:query>
<c:forEach var="p" items="${r.rowsByIndex}">
  pn["${p[2]}"] = '${fn:replace(p[1],"'","\\'")}'; po["${p[2]}"] = ${p[0]}; pp["${p[2]}"] = ${p[3]}; pq["${p[2]}"] = 0;
</c:forEach>

</script>

<c:if test="${!empty errormsg}">
     <div class=errorMessage><span>${errormsg}</span></div>
     <c:set var="errormsg" scope="session" value=""/>
</c:if>
<psstags:showinfomsg/>

<div class="orderform">
<c:set var="lastareacode" value="${fn:substring(sale.phonenumber, 0, 3)}"/>
<c:if test="${!empty currentCustomerId}">
  <sql:query var="custq" dataSource="${pssdb}">
      SELECT * from customer where customer.id = ?;
    <sql:param value="${currentCustomerId}"/>
  </sql:query>
  <c:set var="cust" value="${custq.rows[0]}"/>
  <c:set var="lastphone" value="${cust.phonenumber}"/>
  <c:set var="lastareacode" value="${fn:substring(cust.phonenumber, 0, 3)}"/>
  <c:set var="lastphonenum" value="${fn:substring(cust.phonenumber, 3, fn:length(cust.phonenumber) - 3)}"/>
  <c:set var="lastfirstname" value="${cust.firstname}"/>
  <c:set var="lastlastname" value="${cust.lastname}"/>
  <c:set var="lastaddress" value="${cust.address}"/>
  <c:set var="lastcity" value="${cust.city}"/>
  <c:set var="laststate" value="${cust.state}"/>
  <c:set var="lastzip" value="${cust.postalcode}"/>
  <c:set var="lastemail" value="${cust.email}"/>
  <c:set var="lastphonenumber2" value="${cust.phonenumber2}"/>
</c:if>
      <div id="custstatus-orig" style="display: none">New Customer Information:</div>
<form name="orderform" method="POST" action="enterorder.jsp" onsubmit="return checkData(document.orderform)" onclick="hideinfomsg();">
<table border="0">
    <tr><td colspan="6" id="custstatus">New Customer Information:</td></tr>
<tr><td class="textfieldlabel">Phone:</td>
<td colspan="5" nowrap>
    <table><tr><td>
<input type="text" name="areacode" id="areacode" value="${lastareacode}" size="3">
            </td><td>
<input dojoType="subcombobox" name="phone" id="phone" value="${lastphonenum}" size="15">
            </td></tr></table>
</td>
</tr>
<tr><td class="textfieldlabel">First Name:</td><td colspan="2"><input type="text" name="firstname" size="15" value="${lastfirstname}"></td>
<td class="textfieldlabel2">Last Name:</td>
<td colspan="2"><input dojoType="subcombobox2" name="lastname" id="lastname" size="15" value="${lastlastname}"><input type="hidden" name="custid" value="${currentCustomerId}"></td>
</tr>
<tr><td class="textfieldlabel">Address:</td><td colspan="5"><input type="text" name="address" size="40" value="${lastaddress}"></td></tr>
<tr><td class="textfieldlabel">City:</td>
<td><input type="text" name="city" size="18" value="${lastcity}"></td>
<td class="textfieldlabel2">State:</td>
<td><input type="text" name="state" size="2" maxlength="2" value="${laststate}"></td>
<td class="textfieldlabel2">Zip:</td><td><input type="text" name="zip" size="9" value="${lastzip}"></td>
</tr>
<tr><td class="textfieldlabel">Email:</td><td colspan="5"><input type="text" name="email" size="50" value="${lastemail}"></td></tr>
<tr><td class="textfieldlabel">Alt. Phone:</td><td colspan="5"><input type="text" name="phonenumber2" size="12" value="${lastphonenumber2}"></td></tr>
<tr><td colspan="6">Order Information:</td></tr>
<tr valign="top"><td class="textfieldlabel">Seller:</td>
<td colspan="2">
<select name="seller" size="5">
<option <c:if test="${empty currentSellerId}">selected</c:if> value="0">Select a Seller</option>
<sql:query var="r" dataSource="${pssdb}">
    SELECT seller.id as id, lastname, firstname FROM seller,sellergroup 
        WHERE seller.orgID = ? and seller.sellergroupID = sellergroup.id and sellergroup.active = "yes"
        ORDER BY lastname, firstname;
    <sql:param value="${currentOrgId}"/>
</sql:query>
<c:forEach var="s" items="${r.rows}">
  <option <c:if test="${s.id == currentSellerId}">selected</c:if> value="${s.id}">${s.lastname}, ${s.firstname}</option>
</c:forEach>
</select>
</td>
<td class="textfieldlabel2">Date:</td>
<td colspan="2">
<script>
var now = new Date();
var cal = new CalendarPopup("orderdatecal");
cal.addDisabledDates(null, "${sale.salestart}");
cal.addDisabledDates("${sale.saleend}", null);
</script>
<input type="text" name="orderdate" id="orderdate" value="${lastdate}" size="15"
onFocus="cal.select(document.orderform.orderdate,'orderanchor','yyyy-MM-dd'); return false;">
<span id="orderanchor">&nbsp;</span>
<div id="orderdatecal" style="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></div>
</td>
</tr>

<tr><td class="textfieldlabel">Product #:</td><td><input type="text" name="productnum" size="5"></td>
<td class="textfieldlabel2">Quantity:</td><td colspan="3"><input type="text" name="quantity" size="4" onchange="edititem()"></td>
</tr>
</table>

<table border=0>
<tr><td>
<input type="hidden" name="items" value="">
<textarea name="itemdisplay" cols="65" rows="7" wrap="off" value="" onFocus="resetrefocus()">
</textarea>
</td></tr>
<tr><td align="right">
Total: <input type="text" name="total" value="0.00" size="10" onfocus="document.orderform.submit.focus();">
</td></tr>
</table>
<table border="0" width="100%">
<tr valign="top"><td class="textfieldlabel">Special Request:</td>
<td><input type="text" name="srequest" size="45" value=""></td>
</tr>
<tr valign="top">
<td class="textfieldlabel">Donation:</td>
<td><input type="text" name="donation" size="15" value=""></td>
</tr>
</table>
<p>
<center>
<input type="submit" name="submit" value="Submit">
<input type="reset" name="reset" value="Reset" onclick="clearitems();">
</center>
</form>
</div>
</body>
</html>