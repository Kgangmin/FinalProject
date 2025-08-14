<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<link rel="stylesheet" href="<%= ctxPath %>/css/email.css">

<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="mail-wrap">
  <!-- 좌측: 메일 전용 사이드바 재사용 -->
  <jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

  <!-- 우측: 내게쓰기 폼 -->
  <section class="flex-grow-1">
    <div class="mail-card card" style="border:1px solid #e9ecef;">
      <div class="card-header">
        <div class="h6 mb-0">내게쓰기</div>
      </div>

      <div class="card-body">
        <!-- 기존 /mail/send 로 그대로 전송하여 기존 로직 활용 -->
        <form id="composeToMeForm" action="<%=ctxPath%>/mail/send" method="post" enctype="multipart/form-data" autocomplete="off">
          <!-- 히든: 수신자 = 본인 사내이메일 -->
          <input type="hidden" name="to_emp_email_csv" value="${sessionScope.loginuser.emp_email}"/>

          <!-- 제목 -->
          <div class="form-group">
            <label for="email_title" class="font-weight-bold">제목</label>
            <input type="text" class="form-control" id="email_title" name="email_title" required>
          </div>

          <!-- 내용 -->
          <div class="form-group">
            <label for="email_content" class="font-weight-bold">내용</label>
            <textarea class="form-control" id="email_content" name="email_content" rows="12" required></textarea>
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
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page');
  });
</script>
