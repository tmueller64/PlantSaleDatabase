<%@tag description="Show infomsg" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:if test="${!empty infomsg}">
    <script>
      document.getElementById("bannerbar").innerHTML = "<div class=infoMessage id='infoMessage'><span>${infomsg}</span></div>";
    </script>
     <c:set var="infomsg" scope="session" value=""/>
</c:if>