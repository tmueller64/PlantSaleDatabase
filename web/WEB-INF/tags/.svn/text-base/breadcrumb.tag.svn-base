<%@tag description="Breadcrumb Tag" pageEncoding="UTF-8"%>
<%@tag import="java.util.ArrayList"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@attribute name="title" required="true"%>
<%@attribute name="page" required="true"%>
<%@attribute name="var"%>

<%
ArrayList bcl = (ArrayList)jspContext.findAttribute("breadcrumb");
ArrayList bclp = (ArrayList)jspContext.findAttribute("breadcrumbpath");
ArrayList bclpg = (ArrayList)jspContext.findAttribute("breadcrumbpage");
ArrayList bclv = (ArrayList)jspContext.findAttribute("breadcrumbvar");
String path = request.getRequestURI() + "?" + request.getQueryString();
if (bcl == null || bclp == null || bclpg == null || bclv == null) {
    bcl = new ArrayList();
    jspContext.setAttribute("breadcrumb", bcl, PageContext.SESSION_SCOPE);
    bclp = new ArrayList();
    jspContext.setAttribute("breadcrumbpath", bclp, PageContext.SESSION_SCOPE);
    bclpg = new ArrayList();
    jspContext.setAttribute("breadcrumbpage", bclpg, PageContext.SESSION_SCOPE);
    bclv = new ArrayList();
    jspContext.setAttribute("breadcrumbvar", bclv, PageContext.SESSION_SCOPE);
}
for (int i = 0; i < bclp.size(); i++) {
    if (page.equals((String)bclpg.get(i))) {
        // Erase everything from the breadcrumb after this level (including this level)
        while (bcl.size() > i) {
            // Erase the value of the variable at that level (but do not include this level)
            String v = (String)bclv.get(bclv.size() - 1);
            if (bcl.size() > i + 1 && v != null && v.length() > 0) {
                jspContext.setAttribute(v, null, PageContext.SESSION_SCOPE);
            }
            bcl.remove(bcl.size() - 1);
            bclp.remove(bclp.size() - 1);
            bclpg.remove(bclpg.size() - 1);
            bclv.remove(bclv.size() -1);
        }
    }
}
// add in this level
bcl.add(title);
bclp.add(path);
bclpg.add(page);
bclv.add(var);
%>

<div style="width: 100%;" class="breadcrumb">
    <c:forEach var="b" items="${breadcrumb}" varStatus="status">
        <c:choose>
            <c:when test="${status.last}">
       ${b}
            </c:when>
            <c:otherwise>
                <a href="${breadcrumbpath[status.index]}">${b}</a> <b>&gt;</b>
            </c:otherwise>
        </c:choose>
    </c:forEach>
    
</div>