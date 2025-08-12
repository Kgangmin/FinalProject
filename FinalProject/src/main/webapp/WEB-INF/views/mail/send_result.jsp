<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<link rel="stylesheet" href="<%= ctxPath %>/css/email.css">

<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="mail-wrap">
  <!-- 좌측: 메일 전용 사이드바 재사용 -->
  <jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

  <!-- 우측: 성공 카드 -->
  <section class="flex-grow-1">
    <div class="mail-card card" style="border:1px solid #e9ecef;">
      <div class="card-body d-flex align-items-center justify-content-center" style="min-height: 320px; text-align:center;">
        <div>
          <div class="mb-3">
            <!-- 부트스트랩 아이콘이 없으면 텍스트로 대체됩니다 -->
            <span class="d-inline-block rounded-circle" style="width:68px;height:68px;line-height:68px;border:1px solid #e9ecef;">
              ✅
            </span>
          </div>
          <h5 class="mb-2 font-weight-bold">메일 발송에 성공했습니다</h5>
          <p class="text-muted mb-4">작성하신 메일이 정상적으로 발송되었습니다.</p>
          <a href="<%=ctxPath%>/mail/email" class="btn btn-primary">메일함으로 돌아가기</a>
        </div>
      </div>
    </div>
  </section>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
<script>
  // 메일 전용 레이아웃 활성화(상단바/사이드바 간격 맞춤)
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page');
  });
</script>
