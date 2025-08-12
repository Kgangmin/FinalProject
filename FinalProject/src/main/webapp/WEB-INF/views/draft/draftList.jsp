<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<
<style>
:root{
  --topbar-h: 70px;     /* header.jsp 높이와 동일 */
  --sidebar-w: 170px;   /* 1차 사이드바 폭 */
  --sub-w: 240px;       /* 2차 사이드바 폭 */
  --gap: 8px;          /* 2차 사이드바와 본문 간격 */
}

/* 2차 사이드바 */
.sub-sidebar{
  position: fixed;
  top: var(--topbar-h);
  left: var(--sidebar-w);
  width: var(--sub-w);
  height: calc(100vh - var(--topbar-h));
  overflow: auto;
  background: #fff;
  border-right: 1px solid #dee2e6;
  padding: 12px 16px;
}

.sub-sidebar .sec-title{
  font-weight: 600;
  padding: 6px 0;
  margin-bottom: 8px;
  border-bottom: 1px solid #e9ecef;
  color: #555;
}
.sub-sidebar nav{
  padding-bottom: 8px;
  margin-bottom: 12px;
  border-bottom: 1px dashed #e9ecef;
}

.sub-sidebar .nav-link{
  color: #555;
  padding: 6px 0;
  text-decoration: none;
}

.sub-sidebar .nav-link:hover {
  background-color: #e9ecef;
  border-radius: 4px; 
  text-decoration: none; 
}
	

.main-with-sub{
  padding-top: var(--topbar-h);
  margin-left: calc(var(--sidebar-w) + var(--sub-w) + var(--gap));
  width: calc(100vw - (var(--sidebar-w) + var(--sub-w) + var(--gap)));
  max-width: none;
  padding-right: 24px;
}


</style>

<div class="container-fluid">

  <!-- 2차 사이드바 -->
  <aside class="sub-sidebar">

    <div class="sec-title">신청 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/write">신청하기</a>
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/list">
        나의 신청목록
        <c:if test="${counts.inProgress gt 0}">
          <span class="badge badge-danger ml-1"><c:out value="${counts.inProgress}" /></span>
        </c:if>
      </a>
    </nav>

    <div class="sec-title">승인 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/approve">승인하기</a>
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/shared">공유 · 열람가능</a>
    </nav>

    <div class="sec-title">관리자 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/admin/list">모든 신청목록</a>
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/admin/files">모든 파일목록</a>
      <a class="nav-link" href="${pageContext.request.contextPath}/draft/admin/settings">기본정보 설정</a>
    </nav>

  </aside>

  <!-- 본문 -->
  <main class="main-with-sub p-4">

    <!-- 상단: 제목 + 검색 -->
    <div class="d-flex align-items-start justify-content-between mb-3">
      <div>
        <h4 class="font-weight-bold mb-1">나의 신청목록</h4>
        <div class="text-muted small">
          내가 진행한 신청의 목록입니다. 검색 화면에서 신청 검색이나 CSV 다운로드를 할 수 있습니다.
        </div>
      </div>

      <form class="input-group" action="${pageContext.request.contextPath}/draft/list" method="get" style="max-width:460px;">
        <input type="hidden" name="status" value="${param.status}">
        <input type="search" name="q" value="${param.q}" class="form-control" placeholder="검색">
        <div class="input-group-append">
          <button class="btn btn-outline-secondary" type="submit">검색</button>
        </div>
      </form>
    </div>

    <!-- 상태 탭 -->
    <c:set var="s" value="${empty param.status ? 'IN_PROGRESS' : param.status}" />
    <div class="card shadow-sm mb-3">
      <div class="card-body py-2">
        <ul class="nav nav-pills flex-wrap">
          <li class="nav-item"><a class="nav-link ${s=='IN_PROGRESS'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=IN_PROGRESS">진행중 (${counts.inProgress})</a></li>
          <li class="nav-item"><a class="nav-link ${s=='ALL'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=ALL">모두</a></li>
          <li class="nav-item"><a class="nav-link ${s=='DONE'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=DONE">완료 (${counts.done})</a></li>
          <li class="nav-item"><a class="nav-link ${s=='REJECTED'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=REJECTED">반려 (${counts.rejected})</a></li>
          <li class="nav-item"><a class="nav-link ${s=='DENIED'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=DENIED">거절 (${counts.denied})</a></li>
          <li class="nav-item"><a class="nav-link ${s=='TEMP'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=TEMP">임시보관 (${counts.temp})</a></li>
          <li class="nav-item"><a class="nav-link ${s=='CANCELED'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=CANCELED">취소 (${counts.canceled})</a></li>
          <li class="nav-item"><a class="nav-link ${s=='DONE_CANCELED'?'active':''}" href="${pageContext.request.contextPath}/draft/list?status=DONE_CANCELED">완료 후 취소 (${counts.doneCanceled})</a></li>
        </ul>
      </div>
    </div>

    <!-- 리스트 -->
    <div class="list-group shadow-sm">
      <c:forEach var="doc" items="${docs}">
        <a class="list-group-item list-group-item-action py-3" href="${pageContext.request.contextPath}/draft/detail?id=${doc.id}">
          <div class="d-flex w-100 justify-content-between">
            <div class="pr-3">
              <div class="font-weight-semibold">
                <span class="text-muted">[${doc.formName}]</span> ${doc.title}
              </div>
              <small class="text-muted">
                ID: ${doc.id} · ${doc.writerName}
                (<fmt:formatDate value="${doc.createdAt}" pattern="yyyy/MM/dd"/>)
                · 현재의 단계: ${doc.currentStepApprover}
              </small>
            </div>
            <div class="text-nowrap d-flex align-items-center">
              <span class="badge
                ${doc.status=='진행중' ? 'badge-success' :
                  doc.status=='반려' ? 'badge-danger' :
                  doc.status=='임시보관' ? 'badge-secondary' :
                  doc.status=='완료' ? 'badge-primary' : 'badge-light'}">
                ${doc.status}
              </span>
            </div>
          </div>
        </a>
      </c:forEach>

      <c:if test="${empty docs}">
        <div class="list-group-item text-center text-muted py-5">표시할 문서가 없습니다.</div>
      </c:if>
    </div>

    <!-- 페이지네이션 -->
    <nav class="mt-4">
      <ul class="pagination justify-content-center">
        <li class="page-item ${page<=1?'disabled':''}">
          <a class="page-link" href="${pageContext.request.contextPath}/draft/list?status=${s}&q=${param.q}&page=${page-1}">이전</a>
        </li>
        <c:forEach var="p" begin="1" end="${totalPages}">
          <li class="page-item ${p==page?'active':''}">
            <a class="page-link" href="${pageContext.request.contextPath}/draft/list?status=${s}&q=${param.q}&page=${p}">${p}</a>
          </li>
        </c:forEach>
        <li class="page-item ${page>=totalPages?'disabled':''}">
          <a class="page-link" href="${pageContext.request.contextPath}/draft/list?status=${s}&q=${param.q}&page=${page+1}">다음</a>
        </li>
      </ul>
    </nav>

  </main>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
