<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctxPath = request.getContextPath();
%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:set var="employeeEmail" value="${not empty loginEmp.emp_email ? loginEmp.emp_email : loginEmp.ex_email}"/>

<!-- 프로필 이미지 URL (없을 때 기본 이미지로 대체) -->
<c:choose>
  <c:when test="${not empty loginEmp.emp_save_filename}">
    <c:set var="profileImgUrl"
           value="${ctx}/resources/images/emp_profile/${loginEmp.emp_save_filename}"/>
  </c:when>
  <c:otherwise>
    <!-- 프로젝트에 기본 이미지 하나 두세요: /resources/images/emp_profile/default.png -->
    <c:set var="profileImgUrl"
           value="${ctx}/resources/images/emp_profile/default.png"/>
  </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>HANB</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <!-- CSS -->
  <link rel="stylesheet" href="<%= ctxPath %>/bootstrap-4.6.2-dist/css/bootstrap.min.css">

  <!-- JS -->
  <script src="<%= ctxPath %>/js/jquery-3.7.1.min.js"></script>
  <script src="<%= ctxPath %>/bootstrap-4.6.2-dist/js/bootstrap.bundle.min.js"></script>

  <style>
  :root{
    --topbar-h: 70px;
    --sidebar-w: 220px;
    --dashboard-toolbar-h: 58px;
    --bg-body: #f8f9fa;
    --border-color: #dee2e6;
    --panel-bg: #fff;
    --shadow: 0 2px 6px rgba(0,0,0,.06);
  }

  html, body {
    margin: 0; padding: 0; height: 100%;
    overflow-x: hidden;
    background: var(--bg-body);
  }

  /* 컨테이너류 여백 제거 */
  .container, .container-fluid, #mycontainer, #mycontent, #myheader {
    padding-left: 0 !important; padding-right: 0 !important;
    margin-left: 0 !important; margin-right: 0 !important;
  }

  /* Topbar */
  .topbar-fixed {
    position: fixed; top: 0; left: 0; right: 0;
    height: var(--topbar-h); z-index: 1200; /* 가장 위 */
    background: #fff; border-bottom: 1px solid var(--border-color);
    padding: 0 16px; display: flex; align-items: center;
  }

  /* Sidebar */
  .sidebar {
    position: fixed; top: var(--topbar-h); left: 0;
    width: var(--sidebar-w);
    height: calc(100vh - var(--topbar-h));
    background: #fff; border-right: 1px solid var(--border-color);
    z-index: 1020; overflow-y: auto; padding: 12px 0 16px; margin: 0;
  }
  .sidebar .nav { margin: 0; padding: 0; }
  .sidebar .nav-link { color:#000; font-weight:500; padding:8px 16px; }
  .sidebar .nav-link:hover { background:#f1f1f1; }

  /* Content */
  .content-wrapper {
    padding-top: var(--topbar-h);   /* 탑바 아래부터 시작 */
    margin-left: var(--sidebar-w);    /* 사이드바 오른쪽 */
    margin-top: 0 !important;
  }

  /* ===== 대시보드 공통 ===== */
  body.dashboard-page .content-wrapper { padding-left: 16px;
										  padding-right: 16px;
										  padding-bottom: 16px; box-sizing: border-box; }

  .dashboard-toolbar {
    position: sticky;
    top: var(--topbar-h);                 /* content-wrapper 내부 기준 sticky */
    z-index: 1100;
    background: #fff;
    border-bottom: 1px solid var(--border-color);
    padding: 10px 16px;
    display: flex; align-items: center; justify-content: space-between;
     margin-top: calc(-1 * var(--dashboard-toolbar-h));
    margin-bottom: 0;
  }

  .dashboard-grid {
     position: relative;                /* absolute 자식의 기준 */
  	 display: block;                    /* 그리드 제거 */
  	 min-height: calc(100vh - var(--topbar-h) - 32px);
  }

  /* 위젯 카드 */
  .widget {
    background: #fff; border:1px solid var(--border-color);
    border-radius: 10px; box-shadow: var(--shadow);
    display:flex; flex-direction:column; overflow:hidden;
    user-select:none;
  }
  .widget-header {
    padding:10px 12px; border-bottom:1px solid var(--border-color);
    display:flex; align-items:center; justify-content:space-between;
  }
  .widget-title { margin:0; font-weight:600; }
  .widget-actions { display:flex; align-items:center; gap:8px; }
  .widget-body { padding:10px 12px; overflow:auto; }

  /* 편집 표시 */
  .widget[data-edit="on"] .drag-handle,
  .dashboard-editing .drag-handle { display:inline-flex; }
  .drag-handle {
    display:none; cursor: move;
    padding:2px 6px; border:1px dashed #ccc; border-radius:6px;
    font-size:12px; background:#fafafa;
  }

  /* 자유 리사이즈 위젯 */
  .dash-widget {position: absolute; min-width:240px; min-height:160px; }
  .dash-widget .widget-resizer{
    position:absolute; right:6px; bottom:6px; width:14px; height:14px;
    border-right:2px solid #adb5bd; border-bottom:2px solid #adb5bd;
    cursor: se-resize; opacity:0; transition:opacity .15s ease;
  }
  .dashboard-editing .dash-widget .widget-resizer{ opacity:.9; }
  body.resizing { user-select:none; cursor: se-resize; }
  .dash-widget.no-drop{
  	outline: 2px dashed #dc3545;  /* 빨간 점선 */
  	outline-offset: -2px;
  	cursor: not-allowed;
  }

  /* 메일 위젯 전용 */
  .widget-mail .mail-list { list-style:none; margin:0; padding:0; }
  .widget-mail .mail-item {
    display:grid; grid-template-columns:14px 1fr auto; gap:8px;
    padding:6px 0; border-bottom:1px solid #f1f1f1;
  }
  .widget-mail .mail-item:last-child { border-bottom:0; }
  .widget-mail .read-dot { width:9px; height:9px; border-radius:50%; background:#0d6efd; align-self:center; }
  .widget-mail .read-dot.read { background:transparent; border:1px solid #ced4da; }
  .widget-mail .subject { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .widget-mail .subject a { color:#212529; text-decoration:none; }
  .widget-mail .subject a:hover { text-decoration:underline; }
  .widget-mail .time { color:#6c757d; font-size:12px; white-space:nowrap; align-self:center; }

  /* 메일 페이지 전용 고정 레이아웃이 다른 페이지를 가리지 않도록 */
  body:not(.mail-page) .mail-sidebar,
  body:not(.mail-page) .mail-wrap section.flex-grow-1 {
    position: static !important;
    top:auto !important; left:auto !important; right:auto !important; bottom:auto !important;
    overflow: visible !important;
  }

	.profile-actions{
  padding:12px 16px 16px;
  display:grid;
  grid-template-columns:1fr 1fr; /* 두 칸 동일 폭 */
  gap:8px;
  align-items:stretch;           /* 같은 높이로 늘이기 */
}

.profile-actions .btn{
  width:100%;
  min-height:44px;               /* 동일 높이 */
  display:flex;                  /* 텍스트 중앙 정렬 */
  align-items:center;
  justify-content:center;
  padding:0 12px;                /* 세로 패딩 0으로 균일화 */
  margin:0;                      /* 잔여 여백 제거 */
  line-height:1;                 /* 라인하이트 차이 제거 */
  white-space:nowrap;            /* 줄바꿈 방지 */
  border-radius:12px;
  box-sizing:border-box;
}

	.profile-dropdown .dropdown-menu.profile-card{
	  width:320px; border:none; border-radius:16px;
	  box-shadow:0 8px 24px rgba(0,0,0,.12);
	}
	
	.profile-card-head{
	  position:relative; padding:18px 16px 12px; border-bottom:1px solid #f1f1f1;
	}
	
	.profile-card-head .close.profile-close{
	  position:absolute; right:10px; top:8px; font-size:22px; line-height:1; opacity:.6;
	}
	
	.profile-card-head .close.profile-close:hover{ opacity:1; }
	.profile-card-head .name{ font-weight:700; font-size:16px; }
	.profile-card-head .sub{ color:#6c757d; font-size:13px; line-height:1.2; }
	.profile-card-head .email{ color:#495057; font-size:13px; margin-top:6px; word-break:break-all; }
	.profile-actions{ padding:12px 16px 16px; display:grid; grid-template-columns:1fr 1fr; gap:8px; }
	.profile-actions .btn{ border-radius:12px; }
	
	@media (max-width:420px){
	  .profile-dropdown .dropdown-menu.profile-card{ width:92vw; }
	}

  /* 반응형 */
  @media (max-width: 1200px){
    .content-wrapper { margin-left:0; padding-top: calc(var(--topbar-h) + 8px); }
  }
  @media (max-width: 992px){
    .dashboard-grid { grid-template-columns: repeat(6, 1fr); }
  }
  
  </style>
  <script>
  $(function(){
    $(document).on('click', '.profile-close', function(e){
      e.preventDefault();
      $('#profileDropdown').dropdown('hide');
    });
  });
</script>
  
  
</head>
<body>
<div id="mycontainer">
  <!-- 상단바 -->
  <nav class="navbar navbar-expand-lg navbar-light bg-white topbar-fixed">
    <a class="navbar-brand font-weight-bold text-primary" href="<%=ctxPath %>/index">HANB</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#topNavDropdown">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="topNavDropdown">
      <div class="ml-auto d-flex align-items-center">
        <button type="button" class="btn btn-outline-secondary mr-2" id="statusBtn">🔔</button>
        <c:if test="${not empty loginEmp}">
  <div class="dropdown profile-dropdown">
    <button class="btn btn-outline-dark d-flex align-items-center"
            type="button" id="profileDropdown"
            data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      <img src="${profileImgUrl}"
           onerror="this.onerror=null;this.src='${ctx}/resources/images/emp_profile/default.png';"
           alt="avatar" class="rounded-circle mr-2" width="28" height="28">
      <span>${loginEmp.emp_name}</span>
    </button>

    <div class="dropdown-menu dropdown-menu-right p-0 shadow profile-card"
         aria-labelledby="profileDropdown">
      <!-- 상단 프로필 -->
      <div class="profile-card-head">
        <button type="button" class="close profile-close" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>

        <div class="text-center w-100">
          <img src="${profileImgUrl}"
               onerror="this.onerror=null;this.src='${ctx}/resources/images/emp_profile/default.png';"
               alt="avatar" class="rounded-circle mb-2" width="72" height="72">
          <div class="name">${loginEmp.emp_name}</div>
          <div class="sub">${loginEmp.rank_name}</div>
          <div class="sub">${loginEmp.dept_name}</div>
          <div class="email">${employeeEmail}</div>
        </div>
      </div>

      <!-- 하단 액션 -->
      <div class="profile-actions">
        <a class="btn btn-outline-dark btn-block" href="<%= ctxPath %>/emp/emp_layout">내 정보</a>
        <a class="btn btn-outline-dark btn-block" href="<%= ctxPath %>/logout">로그아웃</a>
      </div>
    </div>
  </div>
</c:if>
        <button class="btn btn-outline-secondary ml-2" id="searchBtn">🔍</button>
      </div>
    </div>
  </nav>

  <!-- 사이드바 -->
  <div id="myheader">
    <jsp:include page="../menu/menu.jsp" />
  </div>

  <!-- 본문 시작 -->
  <div id="mycontent" class="content-wrapper">
