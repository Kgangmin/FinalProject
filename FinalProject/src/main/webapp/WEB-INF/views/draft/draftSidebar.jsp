<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String ctxPath = request.getContextPath();
%>    
    
<style>

:root{
  --topbar-h: 70px;     /* header.jsp 높이와 동일 */
  --sidebar-w: 170px;   /* 1차 사이드바 폭 */
  --sub-w: 200px;       /* 2차 사이드바 폭 */
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
</style>
     <!-- 2차 사이드바 -->
  <aside class="sub-sidebar">
    <div class="sec-title">신청 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="<%= ctxPath %>/draft/write">신청하기</a>
      <a class="nav-link" href="<%= ctxPath %>/draft/draftlist">나의 신청목록</a>
    </nav>

    <div class="sec-title">승인 기능</div>
    <nav class="nav flex-column">
      <a class="nav-link" href="<%= ctxPath %>/draft/approvelist">승인하기</a>
    </nav>

  </aside>
  <jsp:include page="/WEB-INF/views/draft/draftTypeModal.jsp" />
  
    