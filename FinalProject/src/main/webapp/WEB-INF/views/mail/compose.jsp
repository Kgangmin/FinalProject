<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctxPath = request.getContextPath();
%>
<link rel="stylesheet" href="<%= ctxPath %>/css/email.css">

<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="mail-wrap">
  <!-- 좌측: 메일 전용 사이드바 재사용 -->
  <jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

  <!-- 우측: 메일 작성 폼 -->
  <section class="flex-grow-1">
    <div class="mail-card card" style="border:1px solid #e9ecef;">
      <div class="card-header">
        <div class="h6 mb-0">메일 쓰기</div>
      </div>
      <div class="card-body">
        <form id="composeForm" action="<%=ctxPath%>/mail/send" method="post" enctype="multipart/form-data" autocomplete="off">

          <!-- 받는사람: 사내이메일(콤마로 여러 명 가능) -->
          <div class="form-group">
            <label for="to_emp_email_csv" class="font-weight-bold">받는사람(사내이메일)</label>
            <input type="text" class="form-control" id="to_emp_email_csv" name="to_emp_email_csv"
                   placeholder="예) user1@hanb.com,user2@hanb.com" value="${param.to}" required>
            <small class="text-muted">여러 명이면 쉼표(,)로 구분</small>
          </div>

          <!-- 보낸사람(사내이메일) - readonly -->
          <div class="form-group">
            <label class="font-weight-bold">보낸사람</label>
            <input type="text" class="form-control" value="${sessionScope.loginuser.emp_email}(${sessionScope.loginuser.emp_name})" readonly>
          </div>

          <!-- 제목 -->
          <div class="form-group">
            <label for="email_title" class="font-weight-bold">제목</label>
            <input type="text" class="form-control" id="email_title" name="email_title" value="${param.subject}" required>
          </div>

          <!-- 내용 -->
          <div class="form-group">
            <label for="email_content" class="font-weight-bold">내용</label>
            <textarea class="form-control" id="email_content" name="email_content" rows="12" required><c:out value="${param.content}"/></textarea>
          </div>

          <!-- 첨부 -->
          <div class="form-group">
            <label for="attachments" class="font-weight-bold">첨부파일</label>
            <input type="file" id="attachments" name="attachments" multiple class="form-control-file">
          </div>

          <div class="d-flex justify-content-end">
            <a href="<%=ctxPath%>/mail/email" class="btn btn-outline-secondary mr-2">취소</a>
            <button type="submit" class="btn btn-primary">보내기</button>
          </div>
        </form>
      </div>
    </div>
  </section>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
<script>
  // 메일 페이지 레이아웃 활성화
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page');
  });
</script>
