<%@tag description="Throw an exception" pageEncoding="UTF-8"%>

<%@attribute name="msg" required="true"%>

<%
    throw new RuntimeException(msg);
%>
