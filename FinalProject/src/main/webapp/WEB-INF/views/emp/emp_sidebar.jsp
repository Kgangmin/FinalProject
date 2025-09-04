<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
    
<%
	String ctxPath = request.getContextPath();
	String subPage = (String) request.getAttribute("subPage");
%>

<aside class="emp-sidebar">
    <div class="sidebar-title">
        인사
    </div>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a href="<%=ctxPath%>/emp/emp_layout" class="nav-link <%= "emp_info".equals(subPage) ? "active" : "" %>">내 사원정보</a>
        </li>
        <li class="nav-item">
            <a href="<%=ctxPath%>/emp/emp_leave" class="nav-link <%= "emp_leave".equals(subPage) ? "active" : "" %>">휴가 관리</a>
        </li>
        <li class="nav-item">
            <a href="<%=ctxPath%>/emp/emp_certificate" class="nav-link <%= "emp_certificate".equals(subPage) ? "active" : "" %>">서류 발급</a>
        </li>
        <sec:authorize access="hasAuthority('HR_VIEW')">
			<li class="nav-item">
				<a href="<%=ctxPath%>/emp/emp_list"
					class="nav-link <%= "emp_list".equals(subPage) ? "active" : "" %>">사원 조회</a>
			</li>
		</sec:authorize>
		<sec:authorize access="hasAuthority('HR_REG')">
			<li class="nav-item">
				<a href="<%=ctxPath%>/emp/emp_register"
					class="nav-link <%= "emp_register".equals(subPage) ? "active" : "" %>">사원 신규등록</a>
			</li>
		</sec:authorize>
    </ul>
</aside>