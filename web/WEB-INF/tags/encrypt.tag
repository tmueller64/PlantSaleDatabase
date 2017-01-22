<%@tag description="Encrypt a value" pageEncoding="UTF-8"%>
<%@tag import="javax.crypto.*"%>
<%@tag import="java.security.Key"%>
<%@tag import="java.net.URLEncoder"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 

<%@attribute name="var" required="true" rtexprvalue="false" description="Variable into which to store the encrypted value"%>
<%@attribute name="value" required="true"%>

<%
Key k = (Key)jspContext.getAttribute("ciphkey", PageContext.SESSION_SCOPE);
Cipher eciph = Cipher.getInstance("DES");
eciph.init(Cipher.ENCRYPT_MODE, k);
byte[] vb = value.getBytes("ISO-8859-1");
byte[] evb = eciph.doFinal(vb);
String v = URLEncoder.encode(new String(evb, "ISO-8859-1"), "UTF-8");
jspContext.setAttribute(var, v, PageContext.REQUEST_SCOPE);
%>
