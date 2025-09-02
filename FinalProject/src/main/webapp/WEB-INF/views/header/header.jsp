<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctxPath = request.getContextPath();
%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:set var="employeeEmail" value="${not empty loginEmp.emp_email ? loginEmp.emp_email : loginEmp.ex_email}"/>

<c:choose>
  <c:when test="${not empty loginEmp.emp_save_filename}">
    <c:set var="profileImgUrl" value="${ctx}/resources/images/emp_profile/${loginEmp.emp_save_filename}"/>
  </c:when>
  <c:otherwise>
    <c:set var="profileImgUrl" value="${ctx}/resources/images/emp_profile/default.png"/>
  </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>HANB</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <link rel="stylesheet" href="<%= ctxPath %>/bootstrap-4.6.2-dist/css/bootstrap.min.css">
  <script src="<%= ctxPath %>/js/jquery-3.7.1.min.js"></script>
  <script src="<%= ctxPath %>/bootstrap-4.6.2-dist/js/bootstrap.bundle.min.js"></script>

  <style>
  :root{ --topbar-h:70px; --sidebar-w:220px; --dashboard-toolbar-h:58px; --bg-body:#f8f9fa; --border-color:#dee2e6; --panel-bg:#fff; --shadow:0 2px 6px rgba(0,0,0,.06); }
  html,body{ margin:0; padding:0; height:100%; overflow-x:hidden; background:var(--bg-body); }
  .container,.container-fluid,#mycontainer,#mycontent,#myheader{ padding-left:0!important; padding-right:0!important; margin-left:0!important; margin-right:0!important; }
  .topbar-fixed{ position:fixed; top:0; left:0; right:0; height:var(--topbar-h); z-index:1200; background:#fff; border-bottom:1px solid var(--border-color); padding:0 16px; display:flex; align-items:center; }
  .sidebar{ position:fixed; top:var(--topbar-h); left:0; width:var(--sidebar-w); height:calc(100vh - var(--topbar-h)); background:#fff; border-right:1px solid var(--border-color); z-index:1020; overflow-y:auto; padding:12px 0 16px; margin:0; }
  .sidebar .nav{ margin:0; padding:0; } .sidebar .nav-link{ color:#000; font-weight:500; padding:8px 16px; } .sidebar .nav-link:hover{ background:#f1f1f1; }
  .content-wrapper{ padding-top:var(--topbar-h); margin-left:var(--sidebar-w); margin-top:0!important; }
  body.dashboard-page .content-wrapper{ padding-left:16px; padding-right:16px; padding-bottom:16px; box-sizing:border-box; }
  .dashboard-toolbar{ position:sticky; top:var(--topbar-h); z-index:10; background:#fff; border-bottom:1px solid var(--border-color); padding:10px 16px; display:flex; align-items:center; justify-content:space-between; margin-top:calc(-1 * var(--dashboard-toolbar-h)); margin-bottom:0; }
  .dashboard-grid{ position:relative; display:block; min-height:calc(100vh - var(--topbar-h) - 32px); }
  .modal{ z-index:1300; } .modal-backdrop{ z-index:1250; }
  .widget{ background:#fff; border:1px solid var(--border-color); border-radius:10px; box-shadow:var(--shadow); display:flex; flex-direction:column; overflow:hidden; user-select:none; }
  .widget-header{ padding:10px 12px; border-bottom:1px solid var(--border-color); display:flex; align-items:center; justify-content:space-between; }
  .widget-title{ margin:0; font-weight:600; } .widget-actions{ display:flex; align-items:center; gap:8px; } .widget-body{ padding:10px 12px; overflow:auto; }
  .widget[data-edit="on"] .drag-handle,.dashboard-editing .drag-handle{ display:inline-flex; }
  .drag-handle{ display:none; cursor:move; padding:2px 6px; border:1px dashed #ccc; border-radius:6px; font-size:12px; background:#fafafa; }
  .dash-widget{ position:absolute; min-width:240px; min-height:160px; }
  .dash-widget .widget-resizer{ position:absolute; right:6px; bottom:6px; width:14px; height:14px; border-right:2px solid #adb5bd; border-bottom:2px solid #adb5bd; cursor:se-resize; opacity:0; transition:opacity .15s ease; }
  .dashboard-editing .dash-widget .widget-resizer{ opacity:.9; }
  body.resizing{ user-select:none; cursor:se-resize; }
  .dash-widget.no-drop{ outline:2px dashed #dc3545; outline-offset:-2px; cursor:not-allowed; }
  .widget-mail .mail-list{ list-style:none; margin:0; padding:0; }
  .widget-mail .mail-item{ display:grid; grid-template-columns:14px 1fr auto; gap:8px; padding:6px 0; border-bottom:1px solid #f1f1f1; }
  .widget-mail .mail-item:last-child{ border-bottom:0; }
  .widget-mail .read-dot{ width:9px; height:9px; border-radius:50%; background:#0d6efd; align-self:center; }
  .widget-mail .read-dot.read{ background:transparent; border:1px solid #ced4da; }
  .widget-mail .subject{ overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .widget-mail .subject a{ color:#212529; text-decoration:none; }
  .widget-mail .subject a:hover{ text-decoration:underline; }
  .widget-mail .time{ color:#6c757d; font-size:12px; white-space:nowrap; align-self:center; }
  body:not(.mail-page) .mail-sidebar, body:not(.mail-page) .mail-wrap section.flex-grow-1{ position:static!important; top:auto!important; left:auto!important; right:auto!important; bottom:auto!important; overflow:visible!important; }
  .profile-actions{ padding:12px 16px 16px; display:grid; grid-template-columns:1fr 1fr; gap:8px; align-items:stretch; }
  .profile-actions .btn{ width:100%; min-height:44px; display:flex; align-items:center; justify-content:center; padding:0 12px; margin:0; line-height:1; white-space:nowrap; border-radius:12px; box-sizing:border-box; }
  .profile-dropdown .dropdown-menu.profile-card{ width:320px; border:none; border-radius:16px; box-shadow:0 8px 24px rgba(0,0,0,.12); }
  .profile-card-head{ position:relative; padding:18px 16px 12px; border-bottom:1px solid #f1f1f1; }
  .profile-card-head .close.profile-close{ position:absolute; right:10px; top:8px; font-size:22px; line-height:1; opacity:.6; }
  .profile-card-head .close.profile-close:hover{ opacity:1; }
  .profile-card-head .name{ font-weight:700; font-size:16px; }
  .profile-card-head .sub{ color:#6c757d; font-size:13px; line-height:1.2; }
  .profile-card-head .email{ color:#495057; font-size:13px; margin-top:6px; word-break:break-all; }
  
  #statusBtn { position: relative; }
  #notifBadge{
  position: absolute;
  top: 0;
  right: 0;
  transform: translate(40%, -40%);
  min-width: 20px;
  height: 20px;
  padding: 0 6px;
  font-size: 12px;
  line-height: 20px;
  border-radius: 10px;
  box-shadow: 0 0 0 2px #fff; /* 테마에 맞게 버튼 테두리와 자연스럽게 */
  }
  @media (max-width:420px){ .profile-dropdown .dropdown-menu.profile-card{ width:92vw; } }
  @media (max-width:1200px){ .content-wrapper{ margin-left:0; padding-top:calc(var(--topbar-h) + 8px); } }
  @media (max-width:992px){ .dashboard-grid{ grid-template-columns: repeat(6, 1fr); } }
  </style>

  <script>
  $(function(){
	  
  	// 페이지 로드 후 한 번 갱신
  	refreshNotificationBadge();

  	// 60초마다 뱃지 갱신
  	setInterval(refreshNotificationBadge, 60000);
    
  	// 프로필 카드 닫기
    $(document).on('click', '.profile-close', function(e){
      e.preventDefault();
      $('#profileDropdown').dropdown('hide');
    });

    // 알림 버튼 → 모달 오픈 & 데이터 로드
    $("#statusBtn").on("click", function(){
      loadNotifications();
    });

    function loadNotifications(){
      const url = "${ctx}/api/notifications";
      const $ul = $("#notifList");
      $ul.empty().append(
        $('<li class="list-group-item text-center text-muted">').text('불러오는 중...')
      );

      $.getJSON(url)
        .done(function(list){
          renderNotifications(list);
          updateBadge(list ? list.length : 0);
          $("#notificationModal").modal('show');
        })
        .fail(function(xhr, status, err){
          console.error("GET /api/notifications failed:", status, err, "status:", xhr.status, "response:", xhr.responseText);
          $ul.empty().append(
            $('<li class="list-group-item text-danger text-center">').text('알림을 불러오지 못했습니다.')
          );
          $("#notificationModal").modal('show');
        });
    }

    function renderNotifications(list){
      const $ul = $("#notifList").empty();
      if(!list || list.length === 0){
        $ul.append(
          $('<li class="list-group-item text-center text-muted py-4">').text('새 알림이 없습니다.')
        );
        return;
      }

      list.forEach(function(n){
        const icon = iconByType(n.type);
        const time = n.time ? formatDateTime(n.time) : '';
        const $li = $('<li class="list-group-item d-flex align-items-start">');

        const $icon = $('<div class="mr-3" style="font-size:20px;">').text(icon);
        const $content = $('<div class="flex-grow-1">');
        const $title = $('<div class="font-weight-bold">').text(n.title || '알림');
        const $msg = $('<div class="text-muted small">').text(n.message || '');
        const $meta = $('<div class="small">').text(time);

        $content.append($title, $msg, $meta);
        $li.append($icon, $content)
           .css('cursor','pointer')
           .on('click', function(){
              if(n.targetUrl){ window.location.href = n.targetUrl; }
           });

        $("#notifList").append($li);
      });
    }

    function iconByType(type){
      switch(type){
        case 'MAIL': return '📧';
        case 'SCHEDULE': return '📅';
        case 'TASK': return '🗓️';
        case 'SURVEY': return '📝';
        case 'NOTICE': return '📢';
        default: return '🔔';
      }
    }

    function formatDateTime(iso){
      try{
        const d = new Date(iso);
        if(isNaN(d.getTime())) return '';
        const y = d.getFullYear();
        const m = String(d.getMonth()+1).padStart(2,'0');
        const day = String(d.getDate()).padStart(2,'0');
        const hh = String(d.getHours()).padStart(2,'0');
        const mm = String(d.getMinutes()).padStart(2,'0');
        return `${y}-${m}-${day} ${hh}:${mm}`;
      }catch(e){ return ''; }
    }

    function updateBadge(count){
    	  var $b = $("#notifBadge");
    	  if(!Number.isFinite(count)) count = 0;
    	  if(count > 0){
    	    $b.text(count > 99 ? "99+" : count).removeClass("d-none");
    	  }else{
    	    $b.addClass("d-none");
    	  }
    	}

    	function refreshNotificationBadge(){
    	  $.getJSON("${ctx}/api/notifications")
    	    .done(function(list){
    	      updateBadge(list ? list.length : 0);
    	    })
    	    .fail(function(){
    	      // 실패 시 배지 상태는 유지(아무 것도 안함)
    	    });
    	}
    
    // A11y: 모달 숨김 시 포커스 이동
    var $notifModal = $('#notificationModal');
    $notifModal.on('hide.bs.modal', function () {
      var $opener = $('#statusBtn');
      if ($opener.length) { $opener.trigger('focus'); } else { document.body.focus(); }
    });
    $notifModal.on('hidden.bs.modal', function () {
      var isStillInside = $(document.activeElement).closest('#notificationModal').length > 0;
      if (isStillInside) {
        var $opener = $('#statusBtn');
        if ($opener.length) { $opener.trigger('focus'); } else { document.body.focus(); }
      }
    });
  });
  </script>
</head>
<body>
<div id="mycontainer">
  <nav class="navbar navbar-expand-lg navbar-light bg-white topbar-fixed">
    <a class="navbar-brand font-weight-bold text-primary" href="<%=ctxPath %>/index">HANB</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#topNavDropdown">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="topNavDropdown">
      <div class="ml-auto d-flex align-items-center">
        <button type="button"
		        class="btn btn-outline-secondary mr-2 position-relative"
		        id="statusBtn">
		  🔔
		  <span id="notifBadge" class="badge badge-pill badge-danger d-none">0</span>
		</button>
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
            <div class="dropdown-menu dropdown-menu-right p-0 shadow profile-card" aria-labelledby="profileDropdown">
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
              <div class="profile-actions">
                <a class="btn btn-outline-dark btn-block" href="<%= ctxPath %>/emp/emp_layout">내 정보</a>
                <a class="btn btn-outline-dark btn-block" href="<%= ctxPath %>/logout">로그아웃</a>
              </div>
            </div>
          </div>
        </c:if>
      </div>
    </div>
  </nav>

  <div id="myheader"><jsp:include page="../menu/menu.jsp" /></div>

  <div id="mycontent" class="content-wrapper">
    <!-- ===== 알림센터 모달 ===== -->
    <div class="modal fade" id="notificationModal" tabindex="-1" role="dialog" aria-labelledby="notificationModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-scrollable modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h6 class="modal-title" id="notificationModalLabel">알림센터</h6>
            <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body p-0">
            <ul id="notifList" class="list-group list-group-flush"></ul>
          </div>
          <div class="modal-footer">
            <small class="text-muted">읽은 메일/공지, 마감된 설문·일정은 자동으로 사라집니다.</small>
          </div>
        </div>
      </div>
    </div>

