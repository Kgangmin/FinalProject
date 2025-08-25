<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<style>
  /* --- 날씨 위젯 전용 미니 카드 스타일 --- */
  .widget-weather .wx-card{ display:flex; gap:14px; align-items:center; }
  .widget-weather .wx-icon{ font-size:40px; line-height:1; }
  .widget-weather .wx-temp{ font-size:28px; font-weight:700; }
  .widget-weather .wx-summary{ font-size:14px; color:#666; }
  .widget-weather .wx-meta{ display:grid; grid-template-columns:auto auto; gap:4px 10px; font-size:13px; color:#444; }
  .widget-weather .wx-meta .k{ color:#777; }
  .widget-weather .wx-updated{ font-size:12px; color:#888; margin-top:4px; }
  .widget-weather .widget-body{ padding:14px 16px; }
  .widget .widget-header{ display:flex; justify-content:space-between; align-items:center; padding:8px 12px; border-bottom:1px solid #eee; }
  .widget .widget-title{ font-weight:600; }
  .drag-handle{ cursor:move; color:#777; font-size:12px; user-select:none; }
  .widget-resizer{ position:absolute; right:4px; bottom:4px; width:12px; height:12px; cursor:nwse-resize; background:linear-gradient(135deg, transparent 50%, #bbb 50%); border-radius:2px; }
  .dashboard-grid{ position:relative; }
  .dash-widget{ background:#fff; border:1px solid #e5e5e5; border-radius:8px; box-shadow:0 1px 2px rgba(0,0,0,.04); }
  .no-drop{ outline:2px dashed #e74c3c; }
  body.dashboard-editing .drag-handle{ color:#444; }
</style>

<div class="content-wrapper">
  <!-- 대시보드 툴바 -->
  <div class="dashboard-toolbar">
    <div class="h5 mb-0">대시보드</div>
    <div>
      <button type="button" id="btnToggleEdit" class="btn btn-outline-secondary btn-sm">레이아웃 편집</button>
      <button type="button" id="btnResetLayout" class="btn btn-outline-danger btn-sm">초기화</button>
    </div>
  </div>

  <!-- 위젯 그리드 -->
  <div id="dashboard" class="dashboard-grid">

    <!-- ===== 날씨 위젯 (미니 카드) ===== -->
    <section class="widget widget-weather dash-widget" data-id="weather" data-widget-id="weather" style="width: 360px;">
      <div class="widget-header">
        <div class="d-flex align-items-center" style="gap:8px;">
          <span class="drag-handle">↕︎ 이동</span>
          <h6 class="widget-title mb-0">현재 날씨</h6>
        </div>
        <div class="widget-actions">
          <button type="button" id="btnWeatherRefresh" class="btn btn-sm btn-outline-secondary">새로고침</button>
          <a class="btn btn-sm btn-primary" href="<%=ctxPath%>/weather">더보기</a>
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
          <button type="button" id="btnMailRefresh" class="btn btn-sm btn-outline-secondary">새로고침</button>
          <a class="btn btn-sm btn-primary" href="<%=ctxPath%>/mail/email?folder=inbox">더보기</a>
        </div>
      </div>

      <div class="widget-body">
        <ul id="mailWidgetList" class="mail-list"><!-- Ajax로 채움 --></ul>
      </div>
      <span class="widget-resizer" aria-hidden="true"></span>
    </section>

    <!-- (필요 시 다른 위젯 추가) -->

  </div>
</div>

<!-- ===== 대시보드 공용 스크립트 (이동/리사이즈/저장/초기화 + 위젯 로딩) ===== -->
<script>
(function(){
  const CTX  = '<%=ctxPath%>';
  const grid = document.getElementById('dashboard');

  console.log('[DASH] INIT');

  // -------------------------------
  // 컨테이너 높이 갱신
  // -------------------------------
  function recalcCanvasSize() {
    let bottomMax = 0;
    grid.querySelectorAll('.dash-widget').forEach(el => {
      const top = parseFloat(el.style.top) || 0;
      const h   = el.offsetHeight;
      bottomMax = Math.max(bottomMax, top + h);
    });
    grid.style.minHeight = Math.max(bottomMax + 40, 300) + 'px';
  }

  // -------------------------------
  // 초기 DOM을 절대좌표로 1회 고정
  // -------------------------------
  function freezeAllToAbsolute(){
    console.log('[DASH] (1) freezeAllToAbsolute');
    const gridRect = grid.getBoundingClientRect();
    grid.querySelectorAll('.dash-widget').forEach(el => {
      const r = el.getBoundingClientRect();
      el.style.position = 'absolute';
      el.style.left     = (r.left - gridRect.left + grid.scrollLeft) + 'px';
      el.style.top      = (r.top  - gridRect.top  + grid.scrollTop)  + 'px';
      el.style.width    = r.width  + 'px';
      el.style.height   = r.height + 'px';
    });
    console.log('freeze ->', { count: grid.querySelectorAll('.dash-widget').length });
    recalcCanvasSize();
  }

  // -------------------------------
  // 위젯 찾기/디버그 헬퍼
  // -------------------------------
  function normalizeId(v){ return (v==null ? '' : String(v)).trim(); }

  function logExistingWidgets(){
    const rows = Array.from(grid.querySelectorAll('.dash-widget')).map(el=>({
      'attr data-id': el.getAttribute('data-id'),
      'attr data-widget-id': el.getAttribute('data-widget-id'),
      'dataset.id': el.dataset.id,
      'dataset.widgetId': el.dataset.widgetId,
      'class': el.className
    }));
    console.groupCollapsed('[DASH] existing .dash-widget list');
    console.table(rows);
    console.groupEnd();
  }

  function findWidgetEl(rawId){
    const id = normalizeId(rawId);
    if (!id) return null;

    const trySelect = (val)=>{
      const esc = (window.CSS && CSS.escape) ? CSS.escape(val) : String(val).replace(/"/g,'\\"');
      return grid.querySelector(`.dash-widget[data-id="${esc}"], .dash-widget[data-widget-id="${esc}"]`);
    };
    let el = trySelect(id);
    if (el) return el;

    const lid = id.toLowerCase();
    el = Array.from(grid.querySelectorAll('.dash-widget')).find(w=>{
      const a = normalizeId(w.dataset.id).toLowerCase();
      const b = normalizeId(w.dataset.widgetId).toLowerCase();
      return a === lid || b === lid;
    });
    return el || null;
  }

  function verifyApplied(el, it, opt){
    opt = opt || {};
    const tol = 1; // 1px 허용
    const want = {
      left: (it.posX!=null ? (it.posX|0) : null),
      top:  (it.posY!=null ? (it.posY|0) : null),
      w:    (it.sizeW!=null? (it.sizeW|0): null),
      h:    (it.sizeH!=null? (it.sizeH|0): null),
    };
    const got = {
      left: parseFloat(el.style.left)||0,
      top:  parseFloat(el.style.top)||0,
      w:    parseFloat(el.style.width)||el.offsetWidth,
      h:    parseFloat(el.style.height)||el.offsetHeight
    };
    if (want.left!=null && Math.abs(got.left - want.left) > tol) el.style.left   = want.left + 'px';
    if (want.top !=null && Math.abs(got.top  - want.top ) > tol) el.style.top    = want.top  + 'px';
    if (want.w   !=null && Math.abs(got.w    - want.w   ) > tol) el.style.width  = want.w    + 'px';
    if (want.h   !=null && Math.abs(got.h    - want.h   ) > tol) el.style.height = want.h    + 'px';
    const ok = (want.left==null || Math.abs((parseFloat(el.style.left)||0)   - want.left) <= tol)
            && (want.top ==null || Math.abs((parseFloat(el.style.top)||0)    - want.top ) <= tol)
            && (want.w   ==null || Math.abs((parseFloat(el.style.width)||el.offsetWidth)  - want.w) <= tol)
            && (want.h   ==null || Math.abs((parseFloat(el.style.height)||el.offsetHeight) - want.h) <= tol);

    const tag = opt.tag || (opt.retry ? 'retry' : 'first');
    console.log(`verifyApplied(${tag})`, { want, got:{
      left: parseFloat(el.style.left)||0,
      top:  parseFloat(el.style.top)||0,
      w:    parseFloat(el.style.width)||el.offsetWidth,
      h:    parseFloat(el.style.height)||el.offsetHeight
    }, ok });

    if (!ok && opt.retry){
      if (want.left!=null) el.style.left   = want.left + 'px';
      if (want.top !=null) el.style.top    = want.top  + 'px';
      if (want.w   !=null) el.style.width  = want.w    + 'px';
      if (want.h   !=null) el.style.height = want.h    + 'px';
    }
  }

  // ------------------------------------------------------
  // DB 레이아웃 적용
  // ------------------------------------------------------
  function applyDbLayout(list){
    console.groupCollapsed('[DASH] (2) applyDbLayout: list size=', Array.isArray(list) ? list.length : 'N/A');
    logExistingWidgets();

    if (!Array.isArray(list)) {
      console.warn('list is not array', list);
      console.groupEnd();
      return;
    }

    list.forEach(it => {
      const rawId = it.widgetId || it.WIDGET_ID;
      const id    = normalizeId(rawId);
      const el    = findWidgetEl(id);

      if (!el) {
        console.warn('no element for id:', id, ' — 위의 테이블 참고');
        return;
      }

      el.style.setProperty('position', 'absolute', 'important');
      if (it.posX  != null) el.style.left   = it.posX + 'px';
      if (it.posY  != null) el.style.top    = it.posY + 'px';
      if (it.sizeW != null) el.style.width  = it.sizeW + 'px';
      if (it.sizeH != null) el.style.height = it.sizeH + 'px';

      if (!el.dataset.id && id) el.setAttribute('data-id', id);

      console.log('apply DB ->', id, {posX: it.posX, posY: it.posY, sizeW: it.sizeW, sizeH: it.sizeH}, 'after:', {
        left: el.style.left, top: el.style.top, width: el.style.width, height: el.style.height
      });

      verifyApplied(el, it);
      requestAnimationFrame(() => verifyApplied(el, it, {retry:true}));
      setTimeout(() => verifyApplied(el, it, {retry:true, tag:'t+120ms'}), 120);
    });

    recalcCanvasSize();
    console.groupEnd();
  }

  async function loadLayoutFromServer(){
    try{
      console.log('[DASH] (FETCH) GET /api/dashboard/widgets');
      const res = await fetch(CTX + '/api/dashboard/widgets', {
        credentials: 'include',
        cache: 'no-store',
        headers: { 'Accept': 'application/json' }
      });
      console.log('HTTP', res.status);
      if (!res.ok) throw new Error('HTTP '+res.status);

      const ct = res.headers.get('content-type') || '';
      console.log('content-type:', ct);
      if (!ct.includes('application/json')) throw new Error('Not JSON response');

      const data = await res.json();
      console.log('payload:', data);

      if (data && data.ok) {
        await new Promise(requestAnimationFrame);
        applyDbLayout(data.list);
      }
    }catch(e){
      console.warn('loadLayoutFromServer failed:', e);
    }
  }

  // ------------------------------------------------------
  // 저장: 현재 위젯 좌표/크기
  // ------------------------------------------------------
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
    }catch(e){
      console.warn('saveLayoutToServer failed', e);
    }
  }

  // ------------------------------------------------------
  // 드래그 이동 + 겹침 방지
  // ------------------------------------------------------
  let active = null, offX = 0, offY = 0;

  function isOverlapping(mover){
    const mr = mover.getBoundingClientRect();
    let overlapped = false;
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

  // ------------------------------------------------------
  // 리사이즈 핸들
  // ------------------------------------------------------
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

        const onMove = (ev)=>{
          const dx = ev.clientX - sx;
          const dy = ev.clientY - sy;
          el.style.position = 'absolute';
          el.style.width  = Math.max(MIN_W, sw + dx) + 'px';
          el.style.height = Math.max(MIN_H, sh + dy) + 'px';
          recalcCanvasSize();
        };
        const onUp = ()=>{
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

  // ------------------------------------------------------
  // 편집 토글 & 초기화
  // ------------------------------------------------------
  const btnToggleEdit = document.getElementById('btnToggleEdit');
  const btnResetLayout = document.getElementById('btnResetLayout');

  btnToggleEdit?.addEventListener('click', ()=>{
    const on = !document.body.classList.contains('dashboard-editing');
    document.body.classList.toggle('dashboard-editing', on);
    btnToggleEdit.textContent = on ? '편집 종료' : '레이아웃 편집';
  });

  btnResetLayout?.addEventListener('click', ()=>{
    grid.querySelectorAll('.dash-widget').forEach(el=>{
      el.style.left = ''; el.style.top  = '';
      el.style.width = ''; el.style.height = '';
      el.style.position = '';
      el.classList.remove('no-drop');
    });
    recalcCanvasSize();
    // 서버 초기화 API가 있으면 여기서 호출
  });

  // ------------------------------------------------------
  // 메일 위젯 Ajax (기존)
  // ------------------------------------------------------
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

  // ------------------------------------------------------
  // 날씨 위젯 로딩
  // ------------------------------------------------------
  function chooseIcon(sky, pty, isDay){
    if (pty && pty !== 0){
      // PTY: 1 비, 2 비/눈, 3 눈, 5 빗방울, 6 빗방울눈날림, 7 눈날림
      if (pty === 3 || pty === 7) return '🌨️';
      if (pty === 2) return '🌧️🌨️';
      if (pty === 1 || pty === 5 || pty === 6) return '🌧️';
      return '🌦️';
    }
    // SKY: 1 맑음, 3 구름많음, 4 흐림
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

	    // 빈 데이터라면 메시지
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
	    console.warn('renderWeatherCard error', e);
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
    // 위치 우선 시도 → 실패 시 한독빌딩 좌표 폴백
    const FALLBACK = { lat:37.499447, lon:127.033263 };
    const run = async (pos)=>{
      try{
        const lat = pos?.coords?.latitude ?? FALLBACK.lat;
        const lon = pos?.coords?.longitude ?? FALLBACK.lon;
        console.log('[WEATHER] call summary', {lat, lon});
        const data = await fetchSummary(lat, lon);
        renderWeatherCard(data);
      }catch(e){
        console.warn('[WEATHER] fetch failed:', e);
        document.getElementById('wxSummary').textContent = '날씨 API 호출 실패';
      }
    };

    if (navigator.geolocation){
      let done = false;
      const timer = setTimeout(()=>{ if(!done) run(null); }, 2500);
      navigator.geolocation.getCurrentPosition(
        (pos)=>{ done = true; clearTimeout(timer); run(pos); },
        ()=>{ done = true; clearTimeout(timer); run(null); },
        { enableHighAccuracy:false, timeout:2000, maximumAge:600000 }
      );
    }else{
      run(null);
    }
  }

  // ------------------------------------------------------
  // 초기화 순서
  // ------------------------------------------------------
  async function init(){
    const widgets = grid.querySelectorAll('.dash-widget');
    console.log('widgets found:', widgets.length);

    freezeAllToAbsolute();
    await loadLayoutFromServer();
    bindDragHandles();
    bindResizeHandles();
    recalcCanvasSize();

    // 디버그용 API
    window.debugDashboard = window.debugDashboard || {};
    window.debugDashboard.dump = logExistingWidgets;

    // 메일 위젯
    $('#btnMailRefresh').on('click', loadMailWidget);
    loadMailWidget();

    // 날씨 위젯
    document.getElementById('btnWeatherRefresh')?.addEventListener('click', loadWeatherWidget);
    loadWeatherWidget();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
