<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%
    String ctxPath = request.getContextPath();
%>
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

  /* 반응형 */
  @media (max-width: 1200px){
    .content-wrapper { margin-left:0; padding-top: calc(var(--topbar-h) + 8px); }
  }
  @media (max-width: 992px){
    .dashboard-grid { grid-template-columns: repeat(6, 1fr); }
  }
  </style>
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
        <button type="button" class="btn btn-outline-secondary mr-2" id="statusBtn">온라인</button>
        <div class="dropdown">
          <button class="btn btn-outline-dark dropdown-toggle" type="button" id="profileDropdown" data-toggle="dropdown">
            <%-- ${sessionScope.loginuser.emp_name} --%>
            <sec:authentication property="principal.username"/>
          </button>
          <div class="dropdown-menu dropdown-menu-right">
            <a class="dropdown-item" href="<%= ctxPath%>/emp/emp_layout">내 정보</a>
            <a class="dropdown-item" href="<%= ctxPath%>/logout">로그아웃</a>
          </div>
        </div>
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
