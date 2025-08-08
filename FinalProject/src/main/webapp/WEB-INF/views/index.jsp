<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="container">
    <div class="row mt-3">
        <div class="col-md-4">
            <div class="widget-box">업무 진행정도</div>
            <div class="widget-box">캘린더</div>
        </div>
        <div class="col-md-4">
            <div class="widget-box">날씨</div>
            <div class="widget-box">공지사항</div>
        </div>
        <div class="col-md-4">
            <div class="widget-box">게시판</div>
            <div class="widget-box">메시지</div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
