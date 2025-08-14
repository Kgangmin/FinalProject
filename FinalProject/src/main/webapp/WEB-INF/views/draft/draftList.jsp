<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%= ctxPath %>/css/draftlist.css">

<script type="text/javascript">
	function filter() {
		document.getElementById('filterForm').submit();
	}
</script>

<div class="container-fluid">

  <!-- 2차 사이드바 -->
  <aside class="sub-sidebar">
    <div class="sec-title">신청 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="<%= ctxPath %>/draft/write">신청하기</a>
      <a class="nav-link" href="<%= ctxPath %>/draft/list">나의 신청목록</a>
    </nav>

    <div class="sec-title">승인 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="<%= ctxPath %>/draft/approve">승인하기</a>
      <a class="nav-link" href="<%= ctxPath %>/draft/shared">공유 · 열람가능</a>
    </nav>

    <div class="sec-title">관리자 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="<%= ctxPath %>/draft/admin/list">모든 신청목록</a>
      <a class="nav-link" href="<%= ctxPath %>/draft/admin/files">모든 파일목록</a>
      <a class="nav-link" href="<%= ctxPath %>/draft/admin/settings">기본정보 설정</a>
    </nav>
  </aside>

  <!-- 본문 -->
  <main class="main-with-sub p-4">

    <!-- 상단: 제목 + 검색 -->
    <div class="d-flex align-items-start justify-content-between mb-3">
      <div>
        <h4 class="font-weight-bold mb-1">나의 신청목록</h4>
        <div class="text-muted small">
          내가 진행한 신청의 목록입니다. 검색 화면에서 신청 검색 하거나 결제 상태를 클릭하면 정렬 할 수 있습니다 
        </div>
      </div>

      <form class="input-group" action="<%= ctxPath %>/draft/draftList" method="get" style="max-width:460px;">
        <input type="hidden" name="approval_status" value="${param.approval_status}">
        <input type="search" name="searchWord" value="${param.searchWord}" class="form-control" placeholder="검색">
        <div class="input-group-append">
          <button class="btn btn-outline-secondary" type="submit">검색</button>
        </div>
      </form>
    </div>

    <!-- 상태 탭 -->
    <div class="card shadow-sm mb-3">
	  <div class="card-body py-2" style="display: inline-flex; justify-content: space-between;">
	
	    <!-- 데스크톱용: 탭 -->
	    <ul class="nav nav-pills flex-wrap gap-2 status-tabs" style="width: 300px;">
	      <li class="nav-item"><a class="nav-link ${approval_status=='' ?'active':''}" href="<%= ctxPath %>/draft/draftList?approval_status=&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=1">전체</a></li>
	      <li class="nav-item"><a class="nav-link ${approval_status=='대기'?'active':''}" href="<%= ctxPath %>/draft/draftList?approval_status=대기&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=1">대기</a></li>
	      <li class="nav-item"><a class="nav-link ${approval_status=='승인'?'active':''}" href="<%= ctxPath %>/draft/draftList?approval_status=승인&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=1">승인</a></li>
	      <li class="nav-item"><a class="nav-link ${approval_status=='반려'?'active':''}" href="<%= ctxPath %>/draft/draftList?approval_status=반려&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=1">반려</a></li>
	    </ul>

	    <!-- 필터 폼 -->
	    <form id="filterForm" class="d-inline" action="<%= ctxPath %>/draft/draftList" method="get">
		  <input type="hidden" name="approval_status" value="${approval_status}">
		  <input type="hidden" name="searchWord" value="${param.searchWord}">
		  <input type="hidden" name="page" value="1">
		  <div class="type-select">
		   	<select class="form-control" name="draft_type" onchange="filter()">
		    	<option value="">전체</option>
		    	<option value="EXPENSE" ${param.draft_type == 'EXPENSE' ? 'selected' : ''}>지출결의서</option>
		    	<option value="PROPOSAL" ${param.draft_type == 'PROPOSAL' ? 'selected' : ''}>업무기안서</option>
		    	<option value="LEAVE" ${param.draft_type == 'LEAVE' ? 'selected' : ''}>휴가신청서</option>
			</select>
		  </div>
	  	</form>
	  </div>
	</div>

    
	<div class="list-section">
	  <div class="list-box card shadow-sm">
	    <div class="list-group list-group-flush">
	      <c:forEach var="doc" items="${arrList}">
	        <a class="list-group-item list-group-item-action py-3" style="border-bottom: solid 1px #dee2e6;" href="<%= ctxPath %>/draft/detail?draft_no=${doc.draft_no}">
	          <div class="d-flex w-100 justify-content-between">
	            <div class="pr-3">
	              <div class="font-weight-semibold">
	                <span class="text-muted">[${doc.draft_type=='EXPENSE' ? '지출결의서' :
	                                           doc.draft_type=='PROPOSAL' ? '업무기안서' :
	                                           doc.draft_type=='LEAVE' ? '휴가신청서' : '' }]<c:if test="${doc.is_attached != 'N'}"><small>💾</small></c:if></span>
	                <c:choose>
					    <c:when test="${fn:length(doc.draft_title) > 30}">
					        ${fn:substring(doc.draft_title, 0, 30)}...
					    </c:when>
					    <c:otherwise>
					        ${doc.draft_title}
					    </c:otherwise>
					</c:choose>
	                
	              </div>
	              <small class="text-muted">${doc.draft_date}</small>
	            </div>
	            <div class="text-nowrap d-flex align-items-center">
	              <span class="badge
	                ${doc.approval_status=='승인' ? 'badge-success' :
	                  doc.approval_status=='반려' ? 'badge-danger' :
	                  'badge-secondary'}">
	                ${doc.approval_status}
	              </span>
	            </div>
	          </div>
	        </a>
	      </c:forEach>
	
	      <c:if test="${empty arrList}">
	        <div class="list-empty-msg text-muted">표시할 문서가 없습니다.</div>
	      </c:if>
	    </div>
	  </div>
	
	  <nav class="mt-3">
	    <ul class="pagination justify-content-center">
	      <li class="page-item ${page<=1?'disabled':''}">
	        <a class="page-link" href="<%= ctxPath %>/draft/draftList?approval_status=${approval_status}&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=${page-1}">이전</a>
	      </li>
	      <c:forEach var="p" begin="1" end="${totalPage}">
	        <li class="page-item ${page== p ?'active':''}">
	          <a class="page-link" href="<%= ctxPath %>/draft/draftList?approval_status=${approval_status}&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=${p}">${p}</a>
	        </li>
	      </c:forEach>
	      <li class="page-item ${page>=totalPage?'disabled':''}">
	        <a class="page-link" href="<%= ctxPath %>/draft/draftList?approval_status=${approval_status}&searchWord=${param.searchWord}&draft_type=${param.draft_type}&page=${page+1}">다음</a>
	      </li>
	    </ul>
	  </nav>
	
	</div>

  </main>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
