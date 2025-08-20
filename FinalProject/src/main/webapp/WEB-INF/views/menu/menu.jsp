<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>

<!-- 사이드바 -->
<div class="sidebar bg-white" style="
    position: fixed;
    top: 70px; /* 상단바 높이만큼 아래 */
    left: 0;
    width: 170px;
    height: calc(100vh - 70px);
    padding-top: 20px;
    border-right: 1px solid #dee2e6;
    z-index: 1020;
    overflow-y: auto;
">
    <ul class="nav flex-column">
        <li class="nav-item"><a class="nav-link" href="<%=ctxPath %>/">홈</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= ctxPath%>/schedule/scheduleManagement">일정관리</a></li>
        <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/mail/email">메일</a></li>
        <li class="nav-item"><a class="nav-link" href="#">채팅</a></li>
        <li class="nav-item"><a class="nav-link" href="#">근태관리</a></li>
        <li class="nav-item"><a class="nav-link" href="#">공지사항</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= ctxPath%>/board/boardHome">게시판</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= ctxPath%>/draft/draftlist">전자결재신청</a></li>
        <li class="nav-item"><a class="nav-link" href="#">설문</a></li>
        <li class="nav-item"><a class="nav-link" href="#">조직도</a></li>
        <li class="nav-item"><a class="nav-link" href="#">날씨</a></li>
        <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/emp/emp_layout">사원관리</a></li>
    </ul>
</div>