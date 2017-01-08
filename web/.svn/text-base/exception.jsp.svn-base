<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page isErrorPage="true" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
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

<div style="background-color: rgb(0, 0, 0); height: 24px; width: 100%"> </div>
<% 
    Throwable t = (Throwable)exception;
    String msg = "";
    while (t != null)
    {
        if (t instanceof java.sql.SQLException) {
            msg = t.getMessage();
            break;
        }
        if (t instanceof JspException) {
            t = ((JspException)t).getRootCause();
        } else {
            t = t.getCause();
        }
    }
    if (t == null) {
        msg = "Unrecognized error.";
        pageContext.setAttribute("detailedmsg", exception.getMessage());
    }
    pageContext.setAttribute("msg", msg);
%>
<div class=errorMessage><span>${msg}</span></div>
<p class="instructions">
The database system has detected an error, either caused by invalid data entry or by a 
bug in the system.
</p>
<p class="instructions">
Press the Back button to continue or contact the administrator. 
</p>
<c:if test="${!empty detailedmsg}">
<p class="instructions">
Detailed information about the exception:
</p>
<pre>
${detailedmsg}
</pre>
</c:if>
</body>
</html>
