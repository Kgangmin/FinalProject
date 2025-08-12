<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

<div class="mail-compose-container">
    <h3>메일 작성</h3>
    <form action="<%=ctxPath%>/mail/send" method="post" enctype="multipart/form-data">
        
        <div class="form-group">
            <label for="receiver">받는사람</label>
            <input type="text" class="form-control" name="receiver" id="receiver" placeholder="사번 또는 이메일 입력" required>
        </div>

        <div class="form-group">
            <label for="subject">제목</label>
            <input type="text" class="form-control" name="emailTitle" id="subject" required>
        </div>

        <div class="form-group">
            <label for="content">내용</label>
            <textarea class="form-control" name="emailContent" id="content" rows="10" required></textarea>
        </div>

        <div class="form-group">
            <label for="file">첨부파일</label>
            <input type="file" name="attachments" id="file" multiple>
        </div>

        <button type="submit" class="btn btn-primary">보내기</button>
        <a href="<%=ctxPath%>/mail/email" class="btn btn-secondary">취소</a>
    </form>
</div>

<style>
.mail-compose-container {
    margin-left: 260px; /* 사이드바 공간 확보 */
    padding: 20px;
}
</style>
