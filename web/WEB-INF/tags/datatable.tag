<%@tag description="put the tag description here" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="psstags" tagdir="/WEB-INF/tags" %> 
<%@taglib prefix="pss" uri="/WEB-INF/tlds/pss.tld" %>

<%@attribute name="title" required="true"%>
<%@attribute name="table" required="true"%>
<%@attribute name="filter"%>
<%@attribute name="order"%>
<%@attribute name="initialValues" description="Values used to populate a row created by the default New... behavior.  The default is VALUES (). This attribute is ignored if the itemnewpage attribute is given."%>
<%@attribute name="columnNames" required="true"%>
<%@attribute name="columns" required="true"%>
<%@attribute name="itemsPerPage" description="If greater than 0, break the table up into pages with the specified number of items per page."%>
<%@attribute name="itemeditpage" description="Page used when an item in the table is selected. If omitted, items in the table are not selectable."%>
<%@attribute name="itemnewpage" description="Page used when New... is clicked, if omitted a default behavior is provided."%>
<%@attribute name="itemactionfrag" fragment="true" description="Fragment used to generate action column content."%>
<%@attribute name="itemactionlabel" description="Label on button used for the action column"%>
<%@attribute name="itemactioncol" description="True if the first column is used for the action column"%>
<%@attribute name="extradeletesql" description="SQL statement executed before each delete. One parameter, the record id, is passed to the statement."%>
<%@attribute name="limitdeletetable"%>
<%@attribute name="limitdeletetablekey"%>
<%@attribute name="limitdeletekey" description="Field in table to be compared with limitdeletetable.limitdeletetablekey."%>
<%@attribute name="hiddenfilter" description="Clause added to filter to display hidden rows"%>
<%@attribute name="hiddenmsg" description="Prompt for the display hidden row checkbox."%>
<%@variable name-given="rowide"%>
<%@variable name-given="rowid"%>
<%@variable name-given="rowactioncol"%>

<%@include file="/WEB-INF/jspf/dbsrc.jspf" %>

<c:if test="${! empty param.ButtonAdd}">
    <c:if test="${!empty itemnewpage}">
      <c:redirect url="${itemnewpage}"/>
    </c:if>
    <c:if test="${empty initialValues}">
        <c:set var="initialValues" value="VALUES ()"/>
    </c:if>
    <sql:update var="updateCount" dataSource="${pssdb}">
        INSERT into ${table} ${initialValues};
    </sql:update>
    <sql:query var="r" sql="select max(id) from ${table};" dataSource="${pssdb}"/>
    <psstags:encrypt var="rowide" value="${r.rowsByIndex[0][0]}"/>
    <c:url var="editurl" value="${itemeditpage}">
        <c:param name="id" value="${rowide}"/>
    </c:url>
    <c:redirect url="${editurl}"/>
</c:if>

<c:if test="${! empty param.ButtonDelete}">
  <c:forEach var="i" items="${paramValues.itemcheckbox}">
    <c:if test="${!empty extradeletesql}">
      <sql:update var="updateCount" dataSource="${pssdb}" sql="${extradeletesql}">
        <sql:param value="${i}"/>
      </sql:update>
    </c:if>
    <sql:update var="updateCount" dataSource="${pssdb}">
    DELETE from ${table} where id = ?;
      <sql:param value="${i}"/>
    </sql:update>
  </c:forEach>
  <c:redirect url="${pageContext.request.requestURI}" context="/"/>
</c:if>

<sql:transaction dataSource="${pssdb}">
<c:set var="countfield" value="0"/>
<c:set var="counttable" value=""/>
<c:if test="${!empty limitdeletetable}">
    <sql:update var="s">
        CREATE TABLE temp${tid}_limitdel ( id INTEGER, count INTEGER, PRIMARY KEY (id) );
    </sql:update>
    <c:forEach var="c" items="${fn:split(limitdeletetable, ',')}">
        <sql:update var="s">
            REPLACE INTO temp${tid}_limitdel SELECT ${table}.id,COUNT(${c}.id) as count
            FROM ${table},${c} WHERE ${table}.${limitdeletekey} = ${c}.${limitdeletetablekey} GROUP BY ${table}.id HAVING count > 0 ;
        </sql:update>
    </c:forEach>
    <c:set var="countfield" value="count"/>
    <c:set var="counttable" value="LEFT JOIN temp${tid}_limitdel ON ${table}.id = temp${tid}_limitdel.id"/>
</c:if>
        <c:if test="${! empty param.checkDisplayHidden}">
            <c:set var="filter" value="${filter} ${hiddenfilter}"/>
        </c:if>
<sql:query var="r">
    select ${countfield},${table}.id,${columns} from ${table} ${counttable} ${filter} ${order} 
</sql:query>
    <sql:update var="s">
        DROP TABLE IF EXISTS temp${tid}_limitdel;
    </sql:update>
</sql:transaction>

<div class="pssTblMgn">
<table class="pssTbl" title="${title}" summary="${title}" id="DataTableTbl">
<caption class="pssTblTtlTxt">${title} (${r.rowCount} rows)</caption>
<form name="DataTable" method="POST" action="${pageContext.request.requestURI}?${pageContext.request.queryString}">
<tr>
<td class="pssTblActTd" colspan="3" nowrap="nowrap">
<input name="ButtonAdd" type="submit" class="pssTblBtn1" value="New..." <c:if test="${empty itemeditpage}">disabled="true"</c:if> onmouseover="javascript: if (this.disabled==0) this.className='pssTblBtn1Hov'" onfocus="javascript: if (this.disabled==0) this.className='pssTblBtn1Hov'" />
<input name="ButtonDelete" type="submit" class="pssTblBtn1Dis" value="Delete" disabled="disabled" onmouseover="javascript: if (this.disabled==0) this.className='pssTblBtn1Hov'" onfocus="javascript: if (this.disabled==0) this.className='pssTblBtn1Hov'" />
<c:if test="${! empty hiddenfilter}">
    <input name="checkDisplayHidden" type="checkbox" value="checked" ${param.checkDisplayHidden} onclick="javascript:document.DataTable.submit()">${hiddenmsg}
</c:if>
</td>
</tr>

<tr>
<th class="pssTblColHdrSel" width="3%" align="center" nowrap="nowrap" scope="col">
<a href="#" name="SelectAllHref" title="Select Items Currently Displayed" onclick="javascript:var f=document.DataTable;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && e.name.indexOf('itemcheckbox') != -1 && !e.disabled) e.checked=true;}toggleTblButtonState('DataTable', 'DataTableTbl', 'tblButton', 'ButtonDelete', this);return false;javascript:var f=document.DataTable;if (f != null) {f.action=this.href;f.submit();return false}"><img name="SelectAllImage" src="images/check_all.gif" alt="Select Items Currently Displayed" align="top" border="0" height="13" width="15" /></a>
<a href="#" name="DeselectAllHref" title="Deselect Items Currently Displayed" onclick="javascript:var f=document.DataTable;for (i=0; i<f.elements.length; i++) {var e=f.elements[i];if (e.name && e.name.indexOf('itemcheckbox') != -1) e.checked=false;}toggleTblButtonState('DataTable', 'DataTableTbl', 'tblButton', 'ButtonDelete', this);return false;javascript:var f=document.DataTable;if (f != null) {f.action=this.href;f.submit();return false}"><img name="DeselectAllImage" src="images/uncheck_all.gif" alt="Deselect Items Currently Displayed" align="top" border="0" height="13" width="15" /></a>
</th>
<c:forEach var="chdr" items="${columnNames}" varStatus="status">
   <c:choose>
     <c:when test="${fn:endsWith(chdr, '.id')}">
     </c:when>
     <c:otherwise>
      <th class="pssTblColHdr">${chdr}</th>
     </c:otherwise>
    </c:choose>
 </c:forEach>
 <c:if test="${!empty itemactionlabel}">
   <th class="pssTblColHdr">${itemactionlabel}</th>
 </c:if>
</tr>

<%-- NOTE: currentpage and gotopage start at 1, not 0 --%>
<c:set var="beginrow" value="0"/>
<c:set var="endrow" value="${r.rowCount - 1}"/>
<c:if test="${itemsPerPage > 0 && r.rowCount > itemsPerPage && param.onepage != 'true'}">
  <c:set var="currentpage" value="1"/>
  <c:set var="maxpages" value="${pss:divideRoundUp(r.rowCount, itemsPerPage)}"/>
  <c:if test="${!empty param.gotopage}">
    <c:set var="currentpage" value="${param.gotopage}"/>
    <c:if test="${currentpage < 1}"><c:set var="currentpage" value="1"/></c:if>
    <c:if test="${currentpage > maxpages}"><c:set var="currentpage" value="${maxpages}"/></c:if>    
    <c:set var="beginrow" value="${(currentpage - 1) * itemsPerPage}"/>
  </c:if>
  <c:set var="endrow" value="${beginrow + itemsPerPage - 1}"/>
  <c:set var="showPageButtons" value="${true}"/>
</c:if>

<c:if test="${endrow >= beginrow}">
<c:forEach var="row" items="${r.rowsByIndex}" begin="${beginrow}" end="${endrow}">

    <c:set var="haveid" value="false"/>
    <c:set var="havecount" value="false"/>
    <c:set var="havelink" value="false"/>
    <c:set var="deletedisabled" value=""/>
    <c:set var="actioncol" value="${itemactioncol}"/>
        
    <c:forEach var="col" items="${row}">
        <c:choose>
           <c:when test="${havecount == false}">
             <c:if test="${col > 0}">
               <c:set var="deletedisabled">disabled="true"</c:set>
             </c:if>
             <c:set var="havecount" value="true"/>
           </c:when>
           <c:when test="${havecount == true && haveid == false}">
<tr>
<td class=pssTblTdSel align="center">
<input type="checkbox" name="itemcheckbox" ${deletedisabled} value="${col}" class="pssTblCb" onclick="toggleTblButtonState('DataTable', 'DataTableTbl', 'tblButton', 'ButtonDelete', this)" onkeypress="javascript:  if (event.keyCode == 13) return false" />
</td>
            <c:set var="haveid" value="true"/>
            <c:set var="rowid" value="${col}"/>
           </c:when>
           <c:when test="${actioncol == true}">
            <c:set var="actioncol" value="false"/>
            <c:set var="rowactioncol" value="${col}"/>
           </c:when>
           <c:when test="${havelink == false && !empty itemeditpage}">
            <td class="pssTblTd">
            <psstags:encrypt var="rowide" value="${rowid}"/>
            <c:url var="editurl" value="${itemeditpage}">
              <c:param name="id" value="${rowide}"/>
            </c:url>
            <a href="${editurl}"><c:out value="${empty col ? '(empty)' : col}"/></a>
            </td>
            <c:set var="havelink" value="true"/>
           </c:when>
           <c:otherwise>
            <td class="pssTblTd">${col}</td>
           </c:otherwise>
        </c:choose>
    </c:forEach>
    <c:if test="${!empty itemactionlabel}">
      <td class="pssTblTd">
        <jsp:invoke fragment="itemactionfrag"/>
      </td>
    </c:if>
</tr>
</c:forEach>
</c:if>
</form>

<c:if test="${showPageButtons}">
<tr>
<c:url var="qs" value="${pageContext.request.requestURI}" context="/">
  <c:forEach var="a" items="${param}">
    <c:if test="${a.key != 'gotopage' && a.key != 'onepage' && a.key != 'gobutton'}">
      <c:param name="${a.key}" value="${a.value}"/>
      <c:set var="hiddenfields">${hiddenfields}
        <input type="hidden" name="${a.key}" value="${a.value}"/>
      </c:set>
    </c:if>
  </c:forEach>
</c:url>
<td class="pssTblActTd" colspan="0" nowrap="nowrap">
<form method="GET" action="<c:url value='${pageContext.request.requestURI}' context='/'/>">
<a href="<c:url value='${qs}' context='/'><c:param name='gotopage' value='1'/></c:url>" title="Go to First Page"><img src="images/pagination_first.gif" alt="Go to First Page" height="20" width="23" border="0" align="top" /></a>
<a  href="<c:url value='${qs}' context='/'><c:param name='gotopage' value='${currentpage > 1 ? currentpage - 1 : currentpage}'/></c:url>" title="Go to Previous Page"><img src="images/pagination_prev.gif" alt="Go to Previous Page" height="20" width="23" border="0" align="top" /></a>
Page: 
<input type="text" size="3" name="gotopage" onkeypress="if (event.keyCode==13) {var e=document.getElementById('gobutton'); if (e != null) e.click(); return false}" value="${currentpage}" />
of ${maxpages}
<input name="gobutton" id="gobutton" title="Go To Selected Page" type="submit" value="  Go  " />
${hiddenfields}
<a href="<c:url value='${qs}' context='/'><c:param name='gotopage' value='${currentpage < maxpages ? currentpage + 1 : currentpage}'/></c:url>" title="Go to Next Page"><img src="images/pagination_next.gif" alt="Go to Next Page" height="20" width="23" border="0" align="top" /></a>
<a href="<c:url value='${qs}' context='/'><c:param name='gotopage' value='${maxpages}'/></c:url>" title="Go to Last Page"><img src="images/pagination_last.gif" alt="Go to Last Page" height="20" width="23" border="0" align="top" /></a>
<a href="<c:url value='${qs}' context='/'><c:param name='onepage' value='true'/></c:url>" title="Show Data in Single Page"><img src="images/scrollpage.gif" alt="Show Data in Single Page" height="20" width="36" border="0" align="top" /></a>
</form>
</td>
</tr>

</c:if>
</table>
</div>
