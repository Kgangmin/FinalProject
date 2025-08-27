<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<style>
  /* --- 공통 위젯 카드 & 툴바 --- */
  .widget .widget-header{ display:flex; justify-content:space-between; align-items:center; padding:8px 12px; border-bottom:1px solid #eee; }
  .widget .widget-title{ font-weight:600; }
  .drag-handle{ cursor:move; color:#777; font-size:12px; user-select:none; }
  .widget-resizer{ position:absolute; right:4px; bottom:4px; width:12px; height:12px; cursor:nwse-resize; background:linear-gradient(135deg, transparent 50%, #bbb 50%); border-radius:2px; }
  .dashboard-grid{ position:relative; }
  .dash-widget{ background:#fff; border:1px solid #e5e5e5; border-radius:8px; box-shadow:0 1px 2px rgba(0,0,0,.04); }
  .no-drop{ outline:2px dashed #e74c3c; }
  body.dashboard-editing .drag-handle{ color:#444; }

  /* --- 날씨 위젯 미니 카드 --- */
  .widget-weather .widget-body{ padding:14px 16px; }
  .widget-weather .wx-card{ display:flex; gap:14px; align-items:center; }
  .widget-weather .wx-icon{ font-size:40px; line-height:1; }
  .widget-weather .wx-temp{ font-size:28px; font-weight:700; }
  .widget-weather .wx-summary{ font-size:14px; color:#666; }
  .widget-weather .wx-meta{ display:grid; grid-template-columns:auto auto; gap:4px 10px; font-size:13px; color:#444; }
  .widget-weather .wx-meta .k{ color:#777; }
  .widget-weather .wx-updated{ font-size:12px; color:#888; margin-top:4px; }

  /* ===== 캘린더(네이버 스타일) ===== */
  :root{
    --nv-green:#03c75a;
    --nv-gray:#f5f6f7;
    --nv-border:#eceef0;
    --nv-text:#111;
    --nv-muted:#67727e;
    --nv-dot:#e74c3c;  /* 일정 빨간 점 */
  }
  .widget-calendar .widget-body{ padding:12px 14px 14px; }
  .widget-calendar.dash-widget{
    background:#fff; border:1px solid var(--nv-border); border-radius:12px;
    box-shadow:0 1px 2px rgba(0,0,0,.04);
  }
  .nv-cal .cal-head{
    display:flex; align-items:center; justify-content:space-between;
    margin-bottom:6px;
  }
  .nv-cal .cal-head .month{
    font-weight:700; color:var(--nv-text); font-size:16px;
  }
  .nv-cal .cal-head .nav-btn{
    width:28px; height:28px; line-height:28px; text-align:center;
    border:none; border-radius:50%; background:transparent; color:#333;
    font-size:18px; padding:0; cursor:pointer;
  }
  .nv-cal .cal-head .nav-btn:hover{ background:var(--nv-gray); }
  .nv-cal .dow{
    display:grid; grid-template-columns:repeat(7,1fr);
    margin:0 2px 6px; font-size:12px; color:var(--nv-muted);
  }
  .nv-cal .dow .sun{ color:#ff4d4f; font-weight:600; }
  .nv-cal .dow .sat{ color:#2f6fff; font-weight:600; }
  .nv-cal .grid{
    display:grid; grid-template-columns:repeat(7,1fr); gap:6px;
  }
  .nv-cal .cell{
    position:relative; background:#fff; border:1px solid var(--nv-border);
    border-radius:10px; padding:8px 12px 10px 8px;
    min-height:var(--cell-h, 46px);
    overflow:hidden;
    transition:background .12s ease, border-color .12s ease;
  }
  .nv-cal .cell:hover{ background:#fafafa; }
  .nv-cal .cell.other{ opacity:.45; }
  .nv-cal .cell .num{ font-size:13px; color:#333; font-weight:500; position:relative; z-index:1; }
  .nv-cal .cell.today .num{ display:inline-block; padding:0 6px; line-height:20px; background:var(--nv-green); color:#fff; border-radius:999px; }
  .nv-cal .cell .dot{ position:absolute; top:6px; right:6px; width:6px; height:6px; border-radius:50%; background:var(--nv-dot); display:none; z-index:2; }
  .nv-cal .cell.has-event .dot{ display:block; }
  .today-panel{ margin-top:10px; border-top:1px solid var(--nv-border); padding-top:8px; }
  .today-panel .today-title{ font-size:13px; color:#333; font-weight:600; margin-bottom:6px; }
  .today-list{ list-style:none; margin:0; padding:0; max-height:120px; overflow:auto; }
  .today-list li{ font-size:13px; color:#333; padding:4px 2px; white-space:nowrap; text-overflow:ellipsis; overflow:hidden; }
  .today-list li .badge{ display:inline-block; font-size:11px; padding:0 6px; line-height:18px; border-radius:999px; background:#eef1f3; color:#55606a; margin-right:6px; }
  .today-list li.empty{ color:#9aa4ad; }

  /* ★ 위젯 도킹 바 */
  .widget-dock{
    position:fixed;
    top:70px; /* header.jsp의 탑바 높이 */
    left:var(--dock-left,170px); /* menu.jsp 사이드바 폭 기본 170px, JS에서 실제 폭으로 업데이트 */
    width:48px;
    height:calc(100vh - 70px);
    display:flex;
    flex-direction:column;
    align-items:center;
    gap:10px;
    padding:10px 6px;
    border-right:1px dashed #e5e7eb;
    background:transparent;
    z-index:1030;
    pointer-events:none; /* 컨테이너는 클릭 막고 */
  }
  .widget-dock .dock-btn{
    pointer-events:auto; /* 버튼만 클릭 가능 */
    width:36px; height:36px; border-radius:10px;
    border:1px solid #e5e7eb; background:#fff;
    display:flex; align-items:center; justify-content:center;
    box-shadow:0 1px 2px rgba(0,0,0,.04);
    cursor:pointer; user-select:none;
  }
  .widget-dock .dock-btn[disabled]{ opacity:.35; cursor:not-allowed; }
  .widget-dock .dock-icon{ font-size:18px; line-height:1; }
  
	  /* ===== 채팅 위젯 ===== */
	.widget-chat .widget-body{ padding:12px 14px; }
	.chat-list{ list-style:none; margin:0; padding:0; }
	.chat-list li{
	  display:flex; align-items:center; gap:10px;
	  padding:8px 6px; border-bottom:1px solid #f2f2f2;
	}
	.chat-list li:last-child{ border-bottom:0; }
	.chat-list .avatar{
	  width:34px; height:34px; border-radius:50%; object-fit:cover;
	  border:1px solid #e5e5e5;
	}
	.chat-list .room{
	  flex:1 1 auto; min-width:0;
	}
	.chat-list .room .title{
	  display:flex; align-items:center; gap:6px;
	  font-weight:600; font-size:14px; color:#111;
	  white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
	}
	.chat-list .room .snippet{
	  font-size:12px; color:#666; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
	}
	.chat-list .meta{
	  flex:0 0 auto; text-align:right; min-width:64px;
	}
	.chat-list .meta .time{ font-size:11px; color:#999; }
	.chat-list .badge-unread{
	  display:inline-block; min-width:18px; padding:0 6px;
	  font-size:11px; line-height:18px; text-align:center;
	  border-radius:999px; background:#ffbe0b; color:#000;
	}
	  
	  
	.widget-survey .widget-body{ padding:12px 14px; }
	.svw-tabs{ display:flex; gap:6px; border-bottom:1px solid #eee; margin-bottom:8px; overflow:auto; }
	.svw-tab{
	  border:none; background:transparent; padding:6px 10px; cursor:pointer; border-bottom:2px solid transparent;
	  font-size:13px; color:#666; white-space:nowrap;
	}
	.svw-tab:hover{ color:#111; }
	.svw-tab.active{ color:#111; font-weight:600; border-color:#007bff; }
	
	.svw-card{ border:1px solid #e5e5e5; border-radius:8px; padding:10px 12px; background:#fff; }
	.svw-card .ttl{ font-weight:700; font-size:14px; margin-bottom:6px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
	.svw-card .meta{ font-size:12px; color:#666; margin-bottom:8px; display:grid; grid-template-columns:auto 1fr; gap:2px 8px; }
	.svw-card .actions{ display:flex; gap:8px; }
	.svw-empty{ color:#9aa4ad; font-size:13px; padding:8px 2px; }
</style>

<!-- ★ 도킹 바 & 숨김 보관함 -->
<div id="widgetDock" class="widget-dock" aria-label="위젯 도킹 바">
  <button type="button" class="dock-btn" data-widget-id="weather" title="날씨 위젯 추가">
    <span class="dock-icon" aria-hidden="true">🌤️</span>
  </button>
  <button type="button" class="dock-btn" data-widget-id="mail" title="메일 위젯 추가">
    <span class="dock-icon" aria-hidden="true">✉️</span>
  </button>
  <button type="button" class="dock-btn" data-widget-id="calendar" title="캘린더 위젯 추가">
    <span class="dock-icon" aria-hidden="true">📆</span>
  </button>
   <button type="button" class="dock-btn" data-widget-id="chat" title="채팅 위젯 추가">
    <span class="dock-icon" aria-hidden="true">💬</span>
  </button>
  <button type="button" class="dock-btn" data-widget-id="survey" title="설문 위젯 추가">
  	<span class="dock-icon" aria-hidden="true">📜</span>
  </button>
</div>
<div id="widgetStorage" style="display:none;"></div>

<div class="content-wrapper">
  <!-- 대시보드 툴바 -->
  <div class="dashboard-toolbar">
    <div class="h5 mb-0">대시보드</div>
    <div>
      <button type="button" id="btnToggleEdit" class="btn btn-outline-secondary btn-sm">대시보드 편집</button>
      <button type="button" id="btnResetLayout" class="btn btn-outline-danger btn-sm">초기화</button>
    </div>
  </div>

  <!-- 위젯 그리드 -->
  <div id="dashboard" class="dashboard-grid">

    <!-- ===== 날씨 위젯 ===== -->
    <section class="widget widget-weather dash-widget" data-id="weather" data-widget-id="weather" style="width: 360px;">
      <div class="widget-header">
        <div class="d-flex align-items-center" style="gap:8px;">
          <span class="drag-handle">↕︎ 이동</span>
          <h6 class="widget-title mb-0">현재 날씨</h6>
        </div>
        <div class="widget-actions">
          <!-- ★ ‘더보기’ 링크 제거 → + 토글 버튼으로 교체 -->
          <button type="button"
                  class="btn btn-sm btn-light widget-toggle"
                  data-widget-id="weather"
                  data-more-href="<%=ctxPath%>/weather"
                  title="날씨 더보기">+</button>
        </div>
      </div>
      <div class="widget-body">
        <div class="wx-card">
          <div class="wx-icon" id="wxIcon">☀️</div>
          <div>
            <div class="wx-temp" id="wxTemp">-</div>
            <div class="wx-summary" id="wxSummary">-</div>
            <div class="wx-updated" id="wxUpdated">-</div>
          </div>
        </div>
        <div style="height:8px;"></div>
        <div class="wx-meta">
          <div class="k">최고/최저</div><div id="wxMaxMin">-</div>
          <div class="k">습도</div><div id="wxHum">-</div>
          <div class="k">바람</div><div id="wxWind">-</div>
          <div class="k">강수확률</div><div id="wxPop">-</div>
        </div>
      </div>
      <span class="widget-resizer" aria-hidden="true"></span>
    </section>

    <!-- ===== 메일 위젯 ===== -->
    <section class="widget widget-mail dash-widget" data-id="mail" data-widget-id="mail" style="width: 540px;">
      <div class="widget-header">
        <div class="d-flex align-items-center" style="gap:8px;">
          <span class="drag-handle">↕︎ 이동</span>
          <h6 class="widget-title mb-0">받은 메일 (최근 10개)</h6>
        </div>
        <div class="widget-actions">
          <!-- ★ ‘더보기’ 링크 제거 → + 토글 버튼으로 교체 -->
          <button type="button"
                  class="btn btn-sm btn-light widget-toggle"
                  data-widget-id="mail"
                  data-more-href="<%=ctxPath%>/mail/email?folder=inbox"
                  title="메일 더보기">+</button>
        </div>
      </div>
      <div class="widget-body">
        <ul id="mailWidgetList" class="mail-list"><!-- Ajax로 채움 --></ul>
      </div>
      <span class="widget-resizer" aria-hidden="true"></span>
    </section>

    <!-- ===== 캘린더 위젯 (네이버 스타일) ===== -->
    <section class="widget widget-calendar dash-widget" data-id="calendar" data-widget-id="calendar" style="width: 360px;">
      <div class="widget-header">
        <div class="d-flex align-items-center" style="gap:8px;">
          <span class="drag-handle">↕︎ 이동</span>
          <h6 class="widget-title mb-0">캘린더</h6>
        </div>
        <div class="widget-actions">
          <!-- ★ ‘더보기’ 링크 제거 → + 토글 버튼으로 교체 -->
          <button type="button"
                  class="btn btn-sm btn-light widget-toggle"
                  data-widget-id="calendar"
                  data-more-href="<%= ctxPath%>/schedule/scheduleManagement"
                  title="캘린더로 이동">+</button>
        </div>
      </div>

      <div class="widget-body">
        <!-- (기존 캘린더 DOM 동일) -->
        <div class="mini-cal nv-cal">
          <div class="cal-head">
            <button type="button" class="nav-btn" id="calPrev" aria-label="이전 달">‹</button>
            <div class="month" id="calMonthLabel">0000. 00.</div>
            <button type="button" class="nav-btn" id="calNext" aria-label="다음 달">›</button>
          </div>
          <div class="dow" id="calDowRow">
            <div class="sun">일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div class="sat">토</div>
          </div>
          <div class="grid" id="calGrid"><!-- JS로 날짜 셀 생성 --></div>
        </div>
        <div class="today-panel">
          <div class="today-title">오늘 일정</div>
          <ul id="todaysList" class="today-list"><li class="empty">불러오는 중…</li></ul>
        </div>
      </div>

      <span class="widget-resizer" aria-hidden="true"></span>
    </section>
	
	<!-- ===== 채팅 위젯 ===== -->
	<section class="widget widget-chat dash-widget" data-id="chat" data-widget-id="chat" style="width: 420px;">
	  <div class="widget-header">
	    <div class="d-flex align-items-center" style="gap:8px;">
	      <span class="drag-handle">↕︎ 이동</span>
	      <h6 class="widget-title mb-0">채팅</h6>
	    </div>
	    <div class="widget-actions">
	      <button type="button"
	              class="btn btn-sm btn-light widget-toggle"
	              data-widget-id="chat"
	              data-more-href="http://192.168.0.25:9090/finalproject/chat"
	              title="채팅으로 이동">+</button>
	    </div>
	  </div>
	  <div class="widget-body">
	    <ul id="chatWidgetList" class="chat-list"><!-- Ajax로 채움 --></ul>
	  </div>
	  <span class="widget-resizer" aria-hidden="true"></span>
	</section>
	
	<!-- ===== 설문 위젯 ===== -->
	<section class="widget widget-survey dash-widget" data-id="survey" data-widget-id="survey" style="width: 420px;">
	  <div class="widget-header">
	    <div class="d-flex align-items-center" style="gap:8px;">
	      <span class="drag-handle">↕︎ 이동</span>
	      <h6 class="widget-title mb-0">설문</h6>
	    </div>
	    <div class="widget-actions">
	      <!-- 편집 중: × / 일반: + (더보기 이동) -->
	      <button type="button"
	              class="btn btn-sm btn-light widget-toggle"
	              data-widget-id="survey"
	              data-more-href="<%=ctxPath%>/survey/list?type=ongoing"
	              title="설문으로 이동">+</button>
	    </div>
	  </div>
	  <div class="widget-body">
	    <div class="svw-tabs" id="svwTabs"><!-- 탭 버튼들 --></div>
	    <div id="svwContent"><div class="svw-empty">불러오는 중…</div></div>
	  </div>
	  <span class="widget-resizer" aria-hidden="true"></span>
	</section>
  </div>
</div>

<script>
(function(){
  const CTX  = '<%=ctxPath%>';
  const grid = document.getElementById('dashboard');
  const dock = document.getElementById('widgetDock');
  const storage = document.getElementById('widgetStorage');

  // ------------------------------- 도킹 바 위치 동기화 (사이드바 폭 반영)
  function updateDockLeft(){
    const sb = document.querySelector('.sidebar');
    if (sb){
      const w = sb.offsetWidth || 170;
      dock.style.setProperty('--dock-left', w + 'px');
    }
  }
  window.addEventListener('resize', updateDockLeft);
  document.addEventListener('DOMContentLoaded', updateDockLeft);

  // ------------------------------- 컨테이너 높이 갱신
  function recalcCanvasSize() {
    let bottomMax = 0;
    grid.querySelectorAll('.dash-widget').forEach(el => {
      const top = parseFloat(el.style.top) || 0;
      const h   = el.offsetHeight;
      bottomMax = Math.max(bottomMax, top + h);
    });
    grid.style.minHeight = Math.max(bottomMax + 40, 300) + 'px';
  }

  // ------------------------------- 초기 DOM을 절대좌표로 고정
  function freezeAllToAbsolute(){
    const gridRect = grid.getBoundingClientRect();
    grid.querySelectorAll('.dash-widget').forEach(el => {
      const r = el.getBoundingClientRect();
      el.style.position = 'absolute';
      el.style.left     = (r.left - gridRect.left + grid.scrollLeft) + 'px';
      el.style.top      = (r.top  - gridRect.top  + grid.scrollTop)  + 'px';
      el.style.width    = r.width  + 'px';
      el.style.height   = r.height + 'px';
    });
    recalcCanvasSize();
  }

  // ------------------------------- 유틸
  function normalizeId(v){ return (v==null ? '' : String(v)).trim(); }
  function findWidgetEl(rawId){
    const id = normalizeId(rawId);
    if (!id) return null;
    const esc = (window.CSS && CSS.escape) ? CSS.escape(id) : id.replace(/"/g,'\\"');
    return grid.querySelector('.dash-widget[data-id="'+esc+'"]')
        || grid.querySelector('.dash-widget[data-widget-id="'+esc+'"]')
        || storage.querySelector('.dash-widget[data-id="'+esc+'"]')
        || storage.querySelector('.dash-widget[data-widget-id="'+esc+'"]');
  }
  function widgetInGrid(el){
    return !!(el && el.parentElement === grid);
  }

  // ------------------------------- DB 레이아웃 적용 (기존 유지)
  async function loadLayoutFromServer(){
    try{
      const res = await fetch(CTX + '/api/dashboard/widgets', {
        credentials: 'include',
        cache: 'no-store',
        headers: { 'Accept': 'application/json' }
      });
      if (!res.ok) return;
      const data = await res.json();
      if (data && data.ok) {
        await new Promise(requestAnimationFrame);
        applyDbLayout(data.list);
      }
    }catch(e){}
  }
  function applyDbLayout(list){
    if (!Array.isArray(list)) return;
    list.forEach(it => {
      const rawId = it.widgetId || it.WIDGET_ID;
      const id    = normalizeId(rawId);
      const el    = findWidgetEl(id);
      if (!el) return;
      el.style.setProperty('position', 'absolute', 'important');
      if (it.posX  != null) el.style.left   = it.posX + 'px';
      if (it.posY  != null) el.style.top    = it.posY + 'px';
      if (it.sizeW != null) el.style.width  = it.sizeW + 'px';
      if (it.sizeH != null) el.style.height = it.sizeH + 'px';
      if (!el.dataset.id && id) el.setAttribute('data-id', id);
    });
    recalcCanvasSize();
  }
  async function saveLayoutToServer(){
    const items = Array.from(grid.querySelectorAll('.dash-widget')).map(el => {
      const id = el.dataset.id || el.dataset.widgetId;
      return {
        widgetId: id,
        x: Math.round(parseFloat(el.style.left)  || 0),
        y: Math.round(parseFloat(el.style.top)   || 0),
        width:  Math.round(el.offsetWidth),
        height: Math.round(el.offsetHeight),
        col: 0, row: 0, w: 0, h: 0
      };
    });
    try{
      await fetch(CTX + '/api/dashboard/widgets', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ widgets: items })
      });
    }catch(e){}
  }

  // ------------------------------- 편집 토글 시 버튼 모양/동작 업데이트
  function updateWidgetActionButtons(){
    const editing = document.body.classList.contains('dashboard-editing');
    document.querySelectorAll('.widget-toggle').forEach(btn=>{
      if (editing){
        btn.textContent = '×';
        btn.classList.remove('btn-primary');
        btn.classList.add('btn-outline-danger');
        btn.title = '위젯 제거';
      }else{
        btn.textContent = '+';
        btn.classList.remove('btn-outline-danger');
        btn.classList.add('btn-primary');
        btn.title = '더보기';
      }
    });
    // 도킹바 버튼 활성/비활성 (그리드에 없는 위젯만 활성)
    document.querySelectorAll('#widgetDock .dock-btn').forEach(b=>{
      const id = b.getAttribute('data-widget-id');
      const el = findWidgetEl(id);
      b.disabled = widgetInGrid(el); // 그리드에 있으면 비활성
    });
  }

  // ------------------------------- 위젯 제거/추가
  function removeWidget(id){
    const el = findWidgetEl(id);
    if (!el || !widgetInGrid(el)) return;
    // 현재 위치 저장(복귀시 참고)
    el.dataset._lastLeft = el.style.left;
    el.dataset._lastTop  = el.style.top;
    el.dataset._lastW    = el.style.width;
    el.dataset._lastH    = el.style.height;
    storage.appendChild(el);
    recalcCanvasSize();
    updateWidgetActionButtons();
    saveLayoutToServer();
  }
  function addWidget(id){
    const el = findWidgetEl(id);
    if (!el || widgetInGrid(el)) return;
    grid.appendChild(el);
    // 기존 위치 복원, 없으면 기본 배치
    el.style.position = 'absolute';
    el.style.left  = el.dataset._lastLeft || '16px';
    el.style.top   = el.dataset._lastTop  || (16 + 40 * (grid.querySelectorAll('.dash-widget').length % 5)) + 'px';
    el.style.width = el.dataset._lastW    || el.style.width || '360px';
    el.style.height= el.dataset._lastH    || el.style.height || '220px';
    recalcCanvasSize();
    updateWidgetActionButtons();
    saveLayoutToServer();
  }

  // ------------------------------- 헤더의 +/× 버튼 클릭 처리
  grid.addEventListener('click', function(e){
    const btn = e.target.closest('.widget-toggle');
    if (!btn) return;
    const id = btn.getAttribute('data-widget-id');
    const editing = document.body.classList.contains('dashboard-editing');
    if (editing){
      // × 동작: 제거
      removeWidget(id);
    }else{
      // + 동작: 기존 ‘더보기’로 이동
      const href = btn.getAttribute('data-more-href');
      if (href && href !== '#') location.href = href;
    }
  });

  // ------------------------------- 도킹 바 아이콘 클릭 → 위젯 복귀
  dock.addEventListener('click', function(e){
    const b = e.target.closest('.dock-btn');
    if (!b || b.disabled) return;
    const id = b.getAttribute('data-widget-id');
    addWidget(id);
  });

  // ------------------------------- 드래그/리사이즈(기존 코드 일부 정리)
  let active = null, offX = 0, offY = 0;
  function isOverlapping(mover){
    const mr = mover.getBoundingClientRect(); let overlapped = false;
    grid.querySelectorAll('.dash-widget').forEach(el => {
      if (el === mover) return;
      const r = el.getBoundingClientRect();
      const hit = !(mr.right < r.left || mr.left > r.right || mr.bottom < r.top || mr.top > r.bottom);
      if (hit) overlapped = true;
    });
    return overlapped;
  }
  function onDragMove(e){
    if(!active) return;
    const gridRect = grid.getBoundingClientRect();
    let nx = e.clientX - gridRect.left - offX;
    let ny = e.clientY - gridRect.top  - offY;
    nx = Math.max(0, nx);
    ny = Math.max(0, ny);
    active.style.left = nx + 'px';
    active.style.top  = ny + 'px';
    if (isOverlapping(active)) active.classList.add('no-drop');
    else                       active.classList.remove('no-drop');
    recalcCanvasSize();
  }
  function onDragEnd(){
    if(!active) return;
    if (active.classList.contains('no-drop')) {
      active.style.left = active.dataset._origLeft;
      active.style.top  = active.dataset._origTop;
      active.classList.remove('no-drop');
    } else {
      saveLayoutToServer();
    }
    document.removeEventListener('mousemove', onDragMove);
    document.removeEventListener('mouseup', onDragEnd);
    active = null;
  }
  function bindDragHandles(){
    grid.querySelectorAll('.dash-widget .drag-handle').forEach(handle => {
      handle.addEventListener('mousedown', function(e){
        const el = e.target.closest('.dash-widget');
        if (!el) return;
        if (!document.body.classList.contains('dashboard-editing')) return;
        e.preventDefault();
        const r = el.getBoundingClientRect();
        const gridRect = grid.getBoundingClientRect();
        active = el;
        offX = e.clientX - r.left;
        offY = e.clientY - r.top;
        if (!el.style.left || !el.style.top) {
          el.style.left = (r.left - gridRect.left) + 'px';
          el.style.top  = (r.top  - gridRect.top)  + 'px';
          el.style.position = 'absolute';
        }
        el.dataset._origLeft = el.style.left;
        el.dataset._origTop  = el.style.top;
        document.addEventListener('mousemove', onDragMove);
        document.addEventListener('mouseup', onDragEnd);
      });
    });
  }
  function bindResizeHandles(){
    grid.querySelectorAll('.dash-widget .widget-resizer').forEach(handle => {
      handle.addEventListener('mousedown', function(e){
        if (!document.body.classList.contains('dashboard-editing')) return;
        e.preventDefault();
        e.stopPropagation();
        const el = e.target.closest('.dash-widget');
        const MIN_W = 240, MIN_H = 160;
        const sx = e.clientX, sy = e.clientY;
        const sw = el.offsetWidth, sh = el.offsetHeight;
        document.body.classList.add('resizing');
        const onMove = function(ev){
          const dx = ev.clientX - sx;
          const dy = ev.clientY - sy;
          el.style.position = 'absolute';
          el.style.width  = Math.max(MIN_W, sw + dx) + 'px';
          el.style.height = Math.max(MIN_H, sh + dy) + 'px';
          recalcCanvasSize();
          if (el.classList.contains('widget-calendar')) adjustCalendarCellSize();
        };
        const onUp = function(){
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
          document.body.classList.remove('resizing');
          saveLayoutToServer();
        };
        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    });
  }

  // ------------------------------- 편집 토글 & 초기화
  const btnToggleEdit = document.getElementById('btnToggleEdit');
  const btnResetLayout = document.getElementById('btnResetLayout');

  btnToggleEdit?.addEventListener('click', ()=>{
    const on = !document.body.classList.contains('dashboard-editing');
    document.body.classList.toggle('dashboard-editing', on);
    btnToggleEdit.textContent = on ? '편집 종료' : '대시보드 편집';
    updateWidgetActionButtons();
  });

  btnResetLayout?.addEventListener('click', ()=>{
    grid.querySelectorAll('.dash-widget').forEach(el=>{
      el.style.left = ''; el.style.top  = '';
      el.style.width = ''; el.style.height = '';
      el.style.position = '';
      el.classList.remove('no-drop');
    });
    // 숨겨진 위젯도 모두 복귀
    storage.querySelectorAll('.dash-widget').forEach(el=> grid.appendChild(el));
    recalcCanvasSize();
    updateWidgetActionButtons();
    saveLayoutToServer();
  });

  // ------------------------------- 메일 위젯 Ajax (기존 유지)
  function renderMailList(list) {
    var $ul = $('#mailWidgetList');
    if (!list || !list.length) {
      $ul.html('<li class="text-muted small">표시할 메일이 없습니다.</li>');
      return;
    }
    var html = '';
    for (var i=0; i<list.length; i++){
      var m = list[i];
      var unread = (m.isRead === 'N');
      var dotCls = unread ? '' : 'read';
      var subject = m.emailTitle ? m.emailTitle : '(제목없음)';
      var href = CTX + '/mail/detail?emailNo=' + encodeURIComponent(m.emailNo);
      var attachHtml = (m.hasAttach === 'Y') ? ' <span class="text-muted">📎</span>' : '';
      html += '<li class="mail-item">'
        +   '<span class="read-dot ' + dotCls + '"></span>'
        +   '<div class="subject"><a href="' + href + '">' + subject + '</a>' + attachHtml + '</div>'
        +   '<div class="time">' + (m.sentAt || '') + '</div>'
        + '</li>';
    }
    $ul.html(html);
  }
  function loadMailWidget() {
    $.ajax({
      url: CTX + '/mail/list',
      method: 'GET',
      dataType: 'json',
      data: { folder:'inbox', unread:'N', star:'N', attach:'N', page:1, size:10 },
      success: function(res){ renderMailList((res && res.list) || []); },
      error: function(){ $('#mailWidgetList').html('<li class="text-danger small">메일을 불러오지 못했습니다.</li>'); }
    });
  }

  // ------------------------------- 날씨 위젯 (기존 유지)
  function chooseIcon(sky, pty, isDay){
    if (pty && pty !== 0){
      if (pty === 3 || pty === 7) return '🌨️';
      if (pty === 2) return '🌧️🌨️';
      if (pty === 1 || pty === 5 || pty === 6) return '🌧️';
      return '🌦️';
    }
    if (sky === 1) return isDay ? '☀️' : '🌙';
    if (sky === 3) return '⛅️';
    if (sky === 4) return '☁️';
    return isDay ? '☀️' : '🌙';
  }
  function fmtN(n, suf){ return (n==null || isNaN(n)) ? '-' : (Math.round(n) + (suf||'')); }
  function fmtP(n){ return (n==null || isNaN(n)) ? '-' : (Math.round(n) + '%'); }
  function renderWeatherCard(data){
    try{
      if (!data || !data.current) {
        document.getElementById('wxSummary').textContent = '날씨 데이터 없음';
        return;
      }
      const cur = data.current || {};
      const daily = data.daily || [];
      const today = daily.length ? daily[0] : {};
      const now = new Date();
      const isDay = now.getHours() >= 6 && now.getHours() < 18;

      if (cur.temperature == null && cur.summary == null && cur.sky == null && cur.pty == null) {
        document.getElementById('wxSummary').textContent = '날씨 데이터 없음';
        return;
      }
      const icon = chooseIcon(cur.sky, cur.pty, isDay);
      document.getElementById('wxIcon').textContent = icon;
      document.getElementById('wxTemp').textContent = fmtN(cur.temperature, '°C');
      document.getElementById('wxSummary').textContent = cur.summary ? String(cur.summary) : '-';
      document.getElementById('wxUpdated').textContent = '업데이트: ' + now.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
      document.getElementById('wxMaxMin').textContent = fmtN(today.tmax, '°C') + ' / ' + fmtN(today.tmin, '°C');
      document.getElementById('wxHum').textContent = fmtN(cur.humidity, '%');
      document.getElementById('wxWind').textContent = (cur.windSpeed==null ? '-' : (Math.round(cur.windSpeed*10)/10 + ' m/s'));
      document.getElementById('wxPop').textContent = fmtP(today.popDay);
    }catch(e){
      document.getElementById('wxSummary').textContent = '날씨 데이터를 표시할 수 없습니다.';
    }
  }
  async function fetchSummary(lat, lon){
    const url = new URL(CTX + '/api/weather/summary', window.location.origin);
    if (typeof lat === 'number' && typeof lon === 'number'){
      url.searchParams.set('lat', String(lat));
      url.searchParams.set('lon', String(lon));
    }
    const res = await fetch(url.toString(), { headers:{'Accept':'application/json'}, credentials:'include', cache:'no-store' });
    if (!res.ok) throw new Error('HTTP '+res.status);
    const ct = res.headers.get('content-type') || '';
    if (!ct.includes('application/json')) throw new Error('Not JSON');
    return res.json();
  }
  async function loadWeatherWidget(){
    const FALLBACK = { lat:37.499447, lon:127.033263 };
    const run = async function(pos){
      try{
        const lat = (pos && pos.coords && typeof pos.coords.latitude === 'number') ? pos.coords.latitude : FALLBACK.lat;
        const lon = (pos && pos.coords && typeof pos.coords.longitude === 'number') ? pos.coords.longitude : FALLBACK.lon;
        const data = await fetchSummary(lat, lon);
        renderWeatherCard(data);
      }catch(e){
        document.getElementById('wxSummary').textContent = '날씨 API 호출 실패';
      }
    };
    if (navigator.geolocation){
      let done = false;
      const timer = setTimeout(function(){ if(!done) run(null); }, 2500);
      navigator.geolocation.getCurrentPosition(
        function(pos){ done = true; clearTimeout(timer); run(pos); },
        function(){ done = true; clearTimeout(timer); run(null); },
        { enableHighAccuracy:false, timeout:2000, maximumAge:600000 }
      );
    }else{
      run(null);
    }
  }

  /* ===== 캘린더 위젯 (기존 유지) ===== */
  let calState = { y: null, m: null }; // m: 0~11
  function p2(n){ n = parseInt(n,10); return (n<10 ? '0'+n : ''+n); }
  function fmtMonthLabel(y,m){ return y + '. ' + (m+1) + '.'; }

  function buildCalendarGrid(y, m){
    const gridEl = document.getElementById('calGrid');
    const label = document.getElementById('calMonthLabel');
    if(!gridEl || !label) return;
    gridEl.innerHTML = '';
    label.textContent = fmtMonthLabel(y,m);

    const first = new Date(y, m, 1);
    const firstDow = first.getDay(); // 0~6
    const nextFirst = new Date(y, m+1, 1);
    const lastDate = new Date(nextFirst - 1).getDate();

    const prevMonthLast = new Date(y, m, 0).getDate();
    for(let i=0;i<firstDow;i++){
      const d = prevMonthLast - firstDow + 1 + i;
      gridEl.appendChild(makeCell(y, m-1, d, true));
    }
    for(let d=1; d<=lastDate; d++){
      gridEl.appendChild(makeCell(y, m, d, false));
    }
    const total = firstDow + lastDate;
    const remain = (7 - (total % 7)) % 7;
    for(let i=1;i<=remain;i++){
      gridEl.appendChild(makeCell(y, m+1, i, true));
    }

    const today = new Date();
    if (today.getFullYear() === y && today.getMonth() === m){
      var q = '[data-date="' + y + '-' + p2(m+1) + '-' + p2(today.getDate()) + '"]';
      const cell = gridEl.querySelector(q);
      if (cell) cell.classList.add('today');
    }
    adjustCalendarCellSize();
  }

  function makeCell(y, m, d, other){
    const real = new Date(y, m, d);
    const y2 = real.getFullYear(), m2 = real.getMonth(), d2 = real.getDate();
    const cell = document.createElement('div');
    cell.className = 'cell' + (other ? ' other' : '');
    cell.dataset.date = y2 + '-' + p2(m2+1) + '-' + p2(d2);
    const num = document.createElement('div'); num.className = 'num'; num.textContent = d2;
    const dot = document.createElement('span'); dot.className = 'dot';
    cell.appendChild(num); cell.appendChild(dot);
    return cell;
  }

  async function fetchMonthEvents(y, m){
    const start = new Date(y, m, 1);
    const end   = new Date(y, m+1, 1);
    const toIsoLocal = function(d){ return new Date(d).toISOString(); };
    const s = toIsoLocal(start), e = toIsoLocal(end);
    const qs = function(url, params){
      const u = new URL(url, window.location.origin);
      Object.keys(params).forEach(function(k){ u.searchParams.set(k, params[k]); });
      return u.toString();
    };
    const reqs = [
      fetch(qs(CTX + '/schedule/events',      {start:s, end:e}),      {credentials:'include'}).then(function(r){return r.ok?r.json():[];}).catch(function(){return[];}),
      fetch(qs(CTX + '/schedule/events/dept', {start:s, end:e}),      {credentials:'include'}).then(function(r){return r.ok?r.json():[];}).catch(function(){return[];}),
      fetch(qs(CTX + '/schedule/events/comp', {start:s, end:e}),      {credentials:'include'}).then(function(r){return r.ok?r.json():[];}).catch(function(){return[];})
    ];
    const arrs = await Promise.all(reqs);
    return (arrs[0]||[]).concat(arrs[1]||[]).concat(arrs[2]||[]);
  }

  function markEventDays(events, y, m){
    const gridEl = document.getElementById('calGrid');
    if(!gridEl) return;
    events.forEach(function(ev){
      const st = ev.start ? new Date(ev.start) : null;
      const en = ev.end   ? new Date(ev.end)   : st;
      if(!st) return;
      const end = (en && en >= st) ? en : st;
      const cur = new Date(st.getFullYear(), st.getMonth(), st.getDate());
      const last= new Date(end.getFullYear(), end.getMonth(), end.getDate());
      while(cur <= last){
        if (cur.getFullYear()===y && cur.getMonth()===m){
          const key = y + '-' + p2(m+1) + '-' + p2(cur.getDate());
          const cell = gridEl.querySelector('[data-date="' + key + '"]');
          if (cell) cell.classList.add('has-event');
        }
        cur.setDate(cur.getDate()+1);
      }
    });
  }

  function renderTodayList(events){
    const ul = document.getElementById('todaysList');
    if(!ul) return;
    ul.innerHTML = '';
    const t = new Date();
    const start = new Date(t.getFullYear(), t.getMonth(), t.getDate(), 0,0,0);
    const end   = new Date(t.getFullYear(), t.getMonth(), t.getDate(), 23,59,59);
    const hits = (events||[]).filter(function(ev){
      const st = ev.start ? new Date(ev.start) : null;
      const en = ev.end   ? new Date(ev.end)   : st;
      if(!st) return false;
      const e2 = (en && en >= st) ? en : st;
      return !(e2 < start || st > end);
    });
    if (!hits.length){
      ul.innerHTML = '<li class="empty">일정이 없습니다.</li>';
      return;
    }
    function label(t){ return (t==='DEPT'?'업무':(t==='COMP'?'회사':'개인')); }
    hits.sort(function(a,b){
      return (a.start||'').localeCompare(b.start||'') || (a.title||'').localeCompare(b.title||'');
    });
    hits.slice(0,20).forEach(function(ev){
      const li = document.createElement('li');
      const badge = document.createElement('span');
      badge.className = 'badge'; badge.textContent = label(ev.type);
      li.appendChild(badge);
      li.appendChild(document.createTextNode(ev.title||'(제목 없음)'));
      ul.appendChild(li);
    });
  }

  function adjustCalendarCellSize(){
    const gridEl = document.getElementById('calGrid');
    if (!gridEl) return;
    const gridWidth = gridEl.clientWidth || 0;
    if (!gridWidth) return;
    const cellH = Math.max(42, Math.floor((gridWidth / 7) * 0.85));
    gridEl.style.setProperty('--cell-h', cellH + 'px');
  }

  async function refreshCalendarWidget(){
    const y = calState.y, m = calState.m;
    buildCalendarGrid(y,m);
    const events = await fetchMonthEvents(y,m);
    markEventDays(events, y, m);
    renderTodayList(events);
  }

  function setupCalendarWidget(){
    const now = new Date();
    calState.y = now.getFullYear();
    calState.m = now.getMonth();

    var btnPrev = document.getElementById('calPrev');
    var btnNext = document.getElementById('calNext');
    var btnRef  = document.getElementById('btnCalRefresh'); // (삭제됨) 안전 참조만 남김

    if (btnPrev) btnPrev.addEventListener('click', function(){
      calState.m -= 1;
      if (calState.m < 0){ calState.m = 11; calState.y--; }
      refreshCalendarWidget();
    });
    if (btnNext) btnNext.addEventListener('click', function(){
      calState.m += 1;
      if (calState.m > 11){ calState.m = 0; calState.y++; }
      refreshCalendarWidget();
    });
    if (btnRef)  btnRef.addEventListener('click', refreshCalendarWidget);

    const calWidget = document.querySelector('.widget-calendar.dash-widget');
    if (calWidget && 'ResizeObserver' in window){
      new ResizeObserver(function(){ adjustCalendarCellSize(); }).observe(calWidget);
    }
    window.addEventListener('resize', adjustCalendarCellSize);

    refreshCalendarWidget();
  }
  
  /* ===== 채팅 위젯 Ajax ===== */
  function avatarUrlSimple(fn){
    // 채팅 페이지와 동일 규칙 사용
    var f = (fn && String(fn).trim()) ? fn : 'default_profile.jpg';
    return CTX + '/resources/images/emp_profile/' + encodeURIComponent(f);
  }

  function renderChatList(items){
    var $ul = $('#chatWidgetList');
    if (!items || !items.length){
      $ul.html('<li class="text-muted small">표시할 채팅방이 없습니다.</li>');
      return;
    }
    var html = '';
    for (var i=0;i<items.length;i++){
      var r = items[i];
      var last = r._lastMsg || {};  // 우리가 채워 넣은 최신 메시지
      var unread = r._unread || 0;
      var avatar = avatarUrlSimple(last.senderProfile || 'default_profile.jpg');
      var time = last.createdAt ? new Date(last.createdAt).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : '';
      html += ''
        + '<li>'
        +   '<img class="avatar" src="'+ avatar +'" alt="avatar">'
        +   '<div class="room">'
        +     '<div class="title">'+ (r.name || '(제목없음)') + (unread>0 ? ' <span class="badge-unread">'+unread+'</span>' : '') + '</div>'
        +     '<div class="snippet">'+ (last.content ? String(last.content) : '최근 메시지 없음') +'</div>'
        +   '</div>'
        +   '<div class="meta"><div class="time">'+ time +'</div></div>'
        + '</li>';
    }
    $ul.html(html);
  }

  async function loadChatWidget(){
    try{
      // 1) 방 목록 로드
      const res = await fetch(CTX + '/api/chat/rooms', {
        credentials: 'include',
        headers: { 'Accept': 'application/json' },
        cache: 'no-store'
      });
      if(!res.ok) throw new Error('rooms HTTP '+res.status);
      const data = await res.json();
      const rooms = (data && data.list) ? data.list : [];
      const unreadMap = (data && data.unread) ? data.unread : {};

      // 2) 최근활동 순서 상위 3개 방만 선택
      const top = rooms.slice(0, 3);

      // 3) 각 방의 최신 메시지 1건씩 병렬 조회
      const latestReqs = top.map(r =>
        fetch(CTX + '/api/chat/rooms/'+ encodeURIComponent(r.roomId) +'/messages?size=1', {
          credentials:'include',
          headers:{'Accept':'application/json'},
          cache:'no-store'
        }).then(resp => resp.ok ? resp.json() : {ok:false, list:[]})
          .then(j => (j && j.list && j.list[0]) ? j.list[0] : null)
          .catch(()=>null)
      );
      const lastList = await Promise.all(latestReqs);

      // 4) 렌더링용으로 합치기
      for (let i=0; i<top.length; i++){
        top[i]._lastMsg = lastList[i];
        top[i]._unread = unreadMap[top[i].roomId] || 0;
      }
      renderChatList(top);
    }catch(e){
      $('#chatWidgetList').html('<li class="text-danger small">채팅 정보를 불러오지 못했습니다.</li>');
    }
  }
  
  async function loadSurveyWidget(){
	  const box = document.getElementById('svwContent');
	  const tabs = document.getElementById('svwTabs');
	  if (!box || !tabs) return;

	  // 서버에서 “참여 가능 설문” JSON을 내려주세요.
	  // 기대 응답: { ok:true, list:[ {surveyId,title,startDate,endDate,ownerName,participatedYn,status} ] }
	  let list = [];
	  try{
	    const res = await fetch('<%=ctxPath%>/survey/api/available?size=5', {
	      headers:{ 'Accept': 'application/json' }, credentials:'include', cache:'no-store'
	    });
	    if (!res.ok) throw new Error('HTTP '+res.status);
	    const data = await res.json();
	    list = (data && data.list) ? data.list.filter(s => s.status==='ONGOING' && s.participatedYn!=='Y') : [];
	  }catch(e){
	    box.innerHTML = '<div class="svw-empty">설문 정보를 불러오지 못했습니다.</div>';
	    return;
	  }

	  if (!list.length){
	    tabs.innerHTML = '';
	    box.innerHTML = '<div class="svw-empty">참여 가능한 진행중 설문이 없습니다.</div>';
	    return;
	  }

	  renderSurveyTabs(list);
	  renderSurveyCard(list, 0); // 첫 번째 탭 선택
	}

  
  function renderSurveyTabs(items){
	  const tabs = document.getElementById('svwTabs');
	  if (!tabs) return;
	  tabs.innerHTML = '';
	  items.forEach((it, idx) => {
	    const b = document.createElement('button');
	    b.type = 'button';
	    b.className = 'svw-tab' + (idx===0 ? ' active' : '');
	    // 탭 라벨: 제목이 길면 잘라서 표시
	    const title = (it.title || '(제목 없음)');
	    b.textContent = (items.length<=4 ? title : (idx+1)+'. '+title);
	    b.title = title;
	    b.dataset.idx = String(idx);
	    b.addEventListener('click', () => {
	      tabs.querySelectorAll('.svw-tab').forEach(x => x.classList.remove('active'));
	      b.classList.add('active');
	      renderSurveyCard(items, idx);
	    });
	    tabs.appendChild(b);
	  });
	}

  
  function renderSurveyCard(items, idx){
	  const item = items[idx];
	  const box  = document.getElementById('svwContent');
	  if (!box) return;

	  const title = item.title || '(제목 없음)';
	  const period = (item.startDate || '') + ' ~ ' + (item.endDate || '');
	  const owner = item.ownerName || '-';
	  const link  = '<%=ctxPath%>/survey/detail?sid=' + encodeURIComponent(item.surveyId);

	  box.innerHTML =
	    '<div class="svw-card">'
	    + '  <div class="ttl" title="'+ escapeHtml(title) +'">'+ escapeHtml(title) +'</div>'
	    + '  <div class="meta">'
	    + '    <div>기간</div><div>'+ escapeHtml(period) +'</div>'
	    + '    <div>작성자</div><div>'+ escapeHtml(owner) +'</div>'
	    + '  </div>'
	    + '  <div class="actions">'
	    + '    <a class="btn btn-primary btn-sm" href="'+ link +'">설문 참여 / 상세</a>'
	    + '  </div>'
	    + '</div>';
	}

	// XSS 방지용 간단 이스케이프
	function escapeHtml(s){
	  if (s == null) return '';
	  return String(s)
	    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
	    .replace(/"/g,'&quot;').replace(/'/g,'&#39;');
	}



  // ------------------------------- 초기화
  async function init(){
    freezeAllToAbsolute();
    await loadLayoutFromServer();
    bindDragHandles();
    bindResizeHandles();
    recalcCanvasSize();
    updateDockLeft();
    updateWidgetActionButtons(); // ★ 초기 버튼 상태 동기화

    // 메일
    $('#btnMailRefresh').on('click', function(){}); // 버튼 삭제됨, 참조 무해화
    loadMailWidget();

    // 날씨
    var wxBtn = document.getElementById('btnWeatherRefresh'); // 버튼 삭제됨, 참조만 무해화
    if (wxBtn) wxBtn.addEventListener('click', loadWeatherWidget);
    loadWeatherWidget();

    // 캘린더
    setupCalendarWidget();
    
 	// 채팅
    loadChatWidget();
 	
 	// 설문
    loadSurveyWidget();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
