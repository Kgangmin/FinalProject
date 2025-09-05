<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!-- 상세 전용 CSS (list.jsp와 동일 레이아웃 변수/클래스 사용) -->
<link rel="stylesheet" href="<%= ctxPath %>/css/draftdetail.css" />
<script type="text/javascript">

</script>

<form id="DocsForm" name="DocsForm" action="<%= ctxPath %>/draft/${draft_type}" method="post" enctype="multipart/form-data">
	<div class="container-fluid">
	  <!-- 2차 사이드바 -->
	  <jsp:include page="/WEB-INF/views/draft/draftSidebar.jsp" />
	
	  <!-- 본문 -->
	  <main class="main-with-sub p-4">
	 <div class="page-head mb-3 page-head--with-actions">
		  <div class="page-head-left">
		    <h4 class="font-weight-bold mb-1">${draft_type=='EXPENSE' ? '지출결의서' :
	                                           draft_type=='PROPOSAL' ? '업무기안서' :
	                                           draft_type=='LEAVE' ? '휴가신청서' : '' }</h4>
		    <div class="text-muted small">
		      내가 신청한 결제의 상세페이지입니다 내용을 수정하거나 확인 할수 있습니다
		    </div>
		  </div>
		
		  <!-- 오른쪽 버튼 -->
		  <div class="page-actions">
		    <!-- 폼 안에 있으니 type=submit 으로 저장/수정 전송 -->
		    <c:if test="${draft.approval_status != '승인'}">
		    	<button type="button" class="btn-action primary" name="button_submit">수정</button>
		    </c:if>
		    <!-- 목록으로 이동 -->
		    <a href="<%=ctxPath%>/draft/draftlist" class="btn-action secondary">목록</a>
		  </div>
		</div>
	    <!-- 상세 본문 카드: 내부는 기존 내용 유지 -->
	    <div class="detail-section card shadow-sm p-4">
	     <jsp:include page="/WEB-INF/views/draft/${draft_type}.jsp" />
	    </div>
	  </main>
	</div>
</form>
<jsp:include page="/WEB-INF/views/footer/footer.jsp" />

