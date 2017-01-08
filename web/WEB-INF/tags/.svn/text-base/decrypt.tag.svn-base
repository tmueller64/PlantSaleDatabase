<%@tag description="Decrypt a value that was encrypted with the encrypt tag" pageEncoding="UTF-8"%>
<%@tag import="javax.crypto.*"%>
<%@tag import="java.net.URLDecoder"%>
<%@tag import="java.security.*"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 

<%@attribute name="var" required="true" rtexprvalue="false" description="Variable into which to store the decrypted value"%>
<%@attribute name="value" required="true"%>
<%
try {
    Key k = (Key)jspContext.getAttribute("ciphkey", PageContext.SESSION_SCOPE);
    Cipher dciph = Cipher.getInstance("DES");
    dciph.init(Cipher.DECRYPT_MODE, k);
    String v = URLDecoder.decode(value, "UTF-8");
    byte[] evb = v.getBytes("ISO-8859-1");
    byte[] vb = dciph.doFinal(evb);
    jspContext.setAttribute(var, new String(vb, "ISO-8859-1"), PageContext.REQUEST_SCOPE);
} catch (GeneralSecurityException e) {
    throw new IllegalAccessException("Attempt to access a page using invalid parameters.");
}
%>