<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.*" %>
<%@page import="javax.mail.*" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
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
</head>
<body>
<%@include file="/WEB-INF/jspf/banner.jspf"%>

<psstags:breadcrumb title="Send Customer E-Mail Confirmation" page="${pageContext.request.requestURI}"/>

<%--
<%
String fromaddr = request.getParameter("fromaddr");
try {
Properties props = new Properties();
props.put("mail.smtp.host", TBD);
Session jmSess = Session.getInstance(props, null);
MimeMessage jmMsg = new MimeMessage(jmSess);
String charset = "UTF-8";

String from = prefs.fromAddress;
InternetAddress[] ia = parseAddress(from, charset);
if (ia.length != 1) {
	throw new javax.mail.SendFailedException("invalid from address");
}
jmMsg.setFrom(ia[0]);
jmMsg.setReplyTo(ia[0]);
jmMsg.setRecipients(Message.RecipientType.TO, parseAddress(to, charset));

jmMsg.setSubject(MimeUtility.encodeText(subject, charset, null));
jmMsg.setSentDate(new Date());
jmMsg.setHeader("X-Mailer", "Plant Sale System"); 

String msgbody = body;
jmMsg.setText(msgbody, charset);

jmSess.getTransport("smtp").send(jmMsg);

}
catch (UnsupportedEncodingException uee) {
				// ns.c=The character set {0} being used to encode the message is not supported.
				problemMsg = getString("ns.c", new Object[] { charset });
			}
catch (javax.mail.SendFailedException sfe) {
				error("DraftMessage.send: " + sfe);
				// ns.d=Unable to send message concerning "{0}".  Make corrections and try again.
				problemMsg = getString("ns.d", new Object[] { subject });
			}
catch (javax.mail.MessagingException me) {
				error("DraftMessage.send: " + me);
				problemMsg = getString("ns.e", new Object[] { subject });
			}
catch (IOException ie) {
				error("SendMessage: " + ie);
				problemMsg = getString("ns.e", new Object[] { subject });
			}
%>
--%>
    <p>Subject: ${param.subject}</p>
    <p>Message:</p>
    <p>${param.message}</p>
    <c:set var="toaddrs" value="${fn:split(param.toaddr, ',')}"/>
    <c:forEach var="t" items="${toaddrs}">
        <c:if test="${!empty fn:trim(t)}">
        <c:set var="ta" value="${t}" scope="page"/>
        <p>Pretend the message was sent to [<%= ta %>] from [${param.fromaddr}].</p>

        </c:if>
    </c:forEach>
        
    <p><a href="orgedit.jsp">Return to Tasks</a></p>
</body>
</html>