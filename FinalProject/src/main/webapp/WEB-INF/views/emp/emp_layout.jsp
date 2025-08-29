<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
	String ctxPath = request.getContextPath();
	String subPage = (String) request.getAttribute("subPage");
%>

<link rel="stylesheet" href="<%=ctxPath%>/css/emp/emp_layout.css"/>


<title> 사원 관리 | 인사시스템 </title>

<!-- 헤더 -->
<jsp:include page="../header/header.jsp"/>

<div class="container-fluid emp-layout">

    <!-- 사원관리 서브 사이드바 -->
    <div class="emp-sidebar-wrapper">
        <jsp:include page="emp_sidebar.jsp"/>
    </div>

    <!-- 사원관리 컨텐츠 -->
    <div class="emp-content-wrapper">
        <jsp:include page="${subPage}.jsp"/>
    </div>

</div>

<!-- 푸터 -->
<jsp:include page="../footer/footer.jsp"/>
