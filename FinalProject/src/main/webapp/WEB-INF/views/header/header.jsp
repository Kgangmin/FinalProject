<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    
    import { library } from @fortawesome/free-regular-svg-icons

    <style>
        /* =========================
   Global Reset & Variables
   ========================= */
:root {
  --topbar-h: 70px;
  --sidebar-w: 220px;
  --bg-body: #f8f9fa;
  --border-color: #dee2e6;
  --panel-bg: #fff;
  --shadow: 0 2px 6px rgba(0,0,0,.06);
}

html, body {
  margin: 0;
  padding: 0;
  overflow-x: hidden;        /* 좌우 스크롤 방지 */
  background-color: var(--bg-body);
  height: 100%;
}

/* Bootstrap 컨테이너류 여백 제거 (좌우·상하 모두) */
.container, .container-fluid, #mycontainer, #mycontent, #myheader {
  padding-left: 0 !important;
  padding-right: 0 !important;
  margin-left: 0 !important;
  margin-right: 0 !important;
}

/* 기본 타이포/링크 */
h1, h2, h3, h4, h5, h6 { margin-top: 0; }
a { text-decoration: none; }

/* =========================
   Topbar
   ========================= */
.topbar-fixed {
  position: fixed;
  top: 0; left: 0; right: 0;
  height: var(--topbar-h);
  z-index: 1050;
  background-color: #fff;
  border-bottom: 1px solid var(--border-color);
  padding: 0 16px;           /* 좌우 여백 최소화 */
  margin: 0;
  display: flex;
  align-items: center;
}

/* =========================
   Sidebar
   ========================= */
.sidebar {
  position: fixed;
  top: var(--topbar-h);       /* 상단바 바로 아래 */
  left: 0;
  width: var(--sidebar-w);
  height: calc(100vh - var(--topbar-h));
  background-color: #fff;
  border-right: 1px solid var(--border-color);
  z-index: 1020;
  overflow-y: auto;
  padding: 12px 0 16px;       /* 상단 여백 최소화 */
  margin: 0;
}

/* 사이드바 네비 스타일 */
.sidebar .nav { margin: 0; padding: 0; }
.sidebar .nav-link {
  color: #000;
  font-weight: 500;
  padding: 8px 16px;
}
.sidebar .nav-link:hover {
  background-color: #f1f1f1;
}

/* =========================
   Content Wrapper
   ========================= */
.content-wrapper {
  /* 상단/좌측에 ‘딱’ 맞추기 */
  padding-top: var(--topbar-h);   /* 상단바 높이만큼 아래 */
  margin-left: var(--sidebar-w);  /* 사이드바 너비만큼 오른쪽 */
  margin-top: 0 !important;       /* 음수 마진 등 보정값 제거 */
}

/* 필요 시 제목 줄 간격 조절 */
.content-wrapper > h4 { margin: 12px 0 16px; }

/* =========================
   Panels / Cards
   ========================= */
.panel {
  background: var(--panel-bg);
  border-radius: 10px;
  box-shadow: var(--shadow);
}
.panel-header {
  padding: 12px 16px;
  border-bottom: 1px solid var(--border-color);
  font-weight: 600;
}
.panel-body {
  padding: 14px 16px;
}

/* =========================
   Schedule Layout (좌측 컨트롤 + 우측 메인)
   ========================= */
.schedule-layout {
  display: grid;
  grid-template-columns: var(--sidebar-w) 1fr;  /* 시각적 정렬용, 실제 사이드바는 고정 */
  gap: 16px;
  max-width: 100%;
  box-sizing: border-box;
}

/* 좌측 컨트롤 패널 폭을 실제 사이드바 폭과 통일감 있게 */
.schedule-layout > aside.panel {
  width: var(--sidebar-w);
}

/* =========================
   Calendar Area (FullCalendar)
   ========================= */
#mainCalendar {
  background: #fff;
  border-radius: 10px;
  padding: 10px;
  min-height: 540px;       /* 초기 높이감 */
}

/* FullCalendar 기본 툴바 숨김(외부 툴바 사용하는 경우) */
.fc .fc-toolbar { display: none; }
.fc { font-size: 14px; }
.fc-daygrid-day-number { font-size: 0.95rem; }

/* 커스텀 툴바(있다면) */
.calendar-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 0 0 10px 0;
}
.calendar-toolbar .left,
.calendar-toolbar .right {
  display: flex;
  align-items: center;
  gap: 8px;
}
.calendar-toolbar .view-switch .btn { padding: 4px 10px; }

/* =========================
   Legends / Dots
   ========================= */
.legend-dot {
  width: 10px; height: 10px;
  border-radius: 50%;
  display: inline-block;
  margin-right: 6px;
  vertical-align: middle;
}
.legend-company { background: #e83e8c; }  /* 사내 */
.legend-my      { background: #3788d8; }  /* 내 */

/* =========================
   Utilities
   ========================= */
/* 가로 스크롤 방지 보강 */
.row, .col, .container, .container-fluid {
  max-width: 100%;
  box-sizing: border-box;
}

/* 이미지/미디어가 영역을 넘치지 않도록 */
img, video {
  max-width: 100%;
  height: auto;
  display: block;
}

/* =========================
   Responsive
   ========================= */
@media (max-width: 1200px) {
  /* 좁은 화면에서는 사이드바를 상단 고정 → 본문 좌측 마진 제거 */
  .content-wrapper {
    margin-left: 0;
    padding-top: calc(var(--topbar-h) + 8px);
  }
  .schedule-layout {
    grid-template-columns: 1fr;   /* 상하 배치 */
    gap: 12px;
  }
  .schedule-layout > aside.panel {
    width: 100%;
  }
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
                        ${sessionScope.loginuser.emp_name}
                    </button>
                    <div class="dropdown-menu dropdown-menu-right">
                        <a class="dropdown-item" href="#">내 정보</a>
                        <a class="dropdown-item" href="<%= ctxPath%>/login/logout">로그아웃</a>
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