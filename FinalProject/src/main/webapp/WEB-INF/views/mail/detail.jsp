<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%= ctxPath %>/css/email.css">

<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="mail-wrap">
  <!-- 좌측 사이드바 재사용 -->
  <jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

  <!-- 우측: 상세 본문 -->
  <section class="flex-grow-1">
    <div class="mail-card card" style="border:1px solid #e9ecef;">
      <!-- 헤더: 제목 + 액션 -->
      <div class="card-header d-flex align-items-center justify-content-between">
        <div class="h6 mb-0">
         제목 :  ${detail.emailTitle}
        </div>
        <div class="d-flex align-items-center" style="gap:.5rem;">
		  <button type="button" id="btnStar" class="btn btn-soft"
		          data-emailno="${detail.emailNo}"
		          data-canstar="${detail.isImportant != null ? 'Y' : 'N'}"
		          title="${detail.isImportant != null ? '중요 표시' : '보낸메일함에서는 중요표시를 사용할 수 없습니다.'}">
		    <span id="starIcon"><c:out value="${detail.isImportant == 'Y' ? '★' : '☆'}"/></span>
		  </button>
          <!-- 삭제(6번 단계에서 서버 연동 예정) -->
          <button type="button" id="btnDelete" class="btn btn-outline-danger btn-sm">삭제</button>
          <a href="<%=ctxPath%>/mail/email" class="btn btn-outline-secondary btn-sm">목록</a>
        </div>
      </div>

      <div class="card-body">
        <!-- 발신/수신 정보 -->
        <div class="mb-3">
          <div class="text-muted small">보낸사람</div>
          <div class="font-weight-bold">
            ${detail.fromName} &lt;${detail.fromEmail}&gt;
            <span class="text-muted"> · ${detail.sentAt}</span>
          </div>
        </div>

        <div class="mb-3">
          <div class="text-muted small">받는사람</div>
          <div>${detail.toNames} <span class="text-muted">(&nbsp;${detail.toEmails}&nbsp;)</span></div>
        </div>

        <!-- 첨부파일 목록 -->
        <c:if test="${not empty files}">
          <div class="mb-3">
            <div class="text-muted small">첨부</div>
            <ul class="list-unstyled mb-0">
              <c:forEach var="f" items="${files}">
                <li>
                  <a href="<%=ctxPath%>/mail/file/${f.email_file_no}">
                    ${f.email_origin_filename}
                  </a>
                  <span class="text-muted small">(${f.email_filesize} bytes)</span>
                </li>
              </c:forEach>
            </ul>
          </div>
        </c:if>

        <hr>

        <!-- 본문 -->
        <div style="white-space:pre-line; font-size:1rem;">
          ${detail.emailContent}
        </div>
      </div>
    </div>
  </section>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
<script>
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page');

    const btnStar = document.getElementById('btnStar');
    const starIcon = document.getElementById('starIcon');

    if (btnStar) {
      btnStar.addEventListener('click', function(){
        if (btnStar.dataset.canstar !== 'Y') {
          // 보낸메일함 상세 등 → 비활성
          return;
        }
        const emailNo = btnStar.dataset.emailno;
        const toStar = (starIcon.textContent !== '★'); // 현재 별 모양 보고 판단
        const nextValue = toStar ? 'Y' : 'N';
        const prev = starIcon.textContent;

        btnStar.disabled = true;
        // 낙관적 UI
        starIcon.textContent = toStar ? '★' : '☆';

        $.ajax({
          url: '<%=ctxPath%>/mail/api/important',
          method: 'POST',
          data: { emailNo: emailNo, value: nextValue },
          success: function(res){
            if (!res || res.ok !== true) {
              // 롤백
              starIcon.textContent = prev;
              alert('중요표시 변경에 실패했습니다.');
            }
          },
          error: function(xhr){
            // 롤백
            starIcon.textContent = prev;
            if (xhr && xhr.responseJSON && xhr.responseJSON.reason === 'not_recipient') {
              alert('이 메일은 중요표시 대상이 아닙니다.');
            } else {
              alert('네트워크 오류 또는 서버 오류입니다.');
            }
          },
          complete: function(){
            btnStar.disabled = false;
          }
        });
      });
    }

    // 삭제 버튼은 6단계에서 서버 연동 예정
    document.getElementById('btnDelete').addEventListener('click', function(){
      alert('삭제는 6단계에서 서버와 연결합니다.');
    });
  });
</script>
