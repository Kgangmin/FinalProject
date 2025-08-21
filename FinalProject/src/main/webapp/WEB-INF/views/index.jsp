<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

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

    <!-- 메일 위젯 -->
    <section class="widget widget-mail dash-widget" data-id="mail" data-widget-id="mail">
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

      <!-- 코너 리사이즈 핸들 -->
      <span class="widget-resizer" aria-hidden="true"></span>
    </section>

    <!-- (필요 시 다른 위젯 추가) -->

  </div>
</div>

<!-- ===== 대시보드 공용 스크립트 (이동/리사이즈/저장/초기화) ===== -->
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

    // 대소문자 무시 매칭
    const lid = id.toLowerCase();
    el = Array.from(grid.querySelectorAll('.dash-widget')).find(w=>{
      const a = normalizeId(w.dataset.id).toLowerCase();
      const b = normalizeId(w.dataset.widgetId).toLowerCase();
      return a === lid || b === lid;
    });
    return el || null;
  }

  // 적용 결과 검증(리트라이)
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
      // 한 번 더 강제 반영
      if (want.left!=null) el.style.left   = want.left + 'px';
      if (want.top !=null) el.style.top    = want.top  + 'px';
      if (want.w   !=null) el.style.width  = want.w    + 'px';
      if (want.h   !=null) el.style.height = want.h    + 'px';
    }
  }

  // ------------------------------------------------------
  // DB 레이아웃 적용 (widgetId, posX,posY,sizeW,sizeH)
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

      // 절대좌표 + 값 반영(우선순위 높게)
      el.style.setProperty('position', 'absolute', 'important');
      if (it.posX  != null) el.style.left   = it.posX + 'px';
      if (it.posY  != null) el.style.top    = it.posY + 'px';
      if (it.sizeW != null) el.style.width  = it.sizeW + 'px';
      if (it.sizeH != null) el.style.height = it.sizeH + 'px';

      // id 보정
      if (!el.dataset.id && id) el.setAttribute('data-id', id);

      console.log('apply DB ->', id, {posX: it.posX, posY: it.posY, sizeW: it.sizeW, sizeH: it.sizeH}, 'after:', {
        left: el.style.left, top: el.style.top, width: el.style.width, height: el.style.height
      });

      verifyApplied(el, it); // 즉시 검증
      requestAnimationFrame(() => verifyApplied(el, it, {retry:true}));              // 레이아웃 안정 후
      setTimeout(() => verifyApplied(el, it, {retry:true, tag:'t+120ms'}), 120);     // 혹시 몰라 한 번 더
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
        await new Promise(requestAnimationFrame); // 한 프레임 양보
        applyDbLayout(data.list);
      }
    }catch(e){
      console.warn('loadLayoutFromServer failed:', e);
    }
  }

  // ------------------------------------------------------
  // 저장: 현재 모든 위젯 좌표/크기를 서버로
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
  // 드래그 이동(자유 px) + 겹침 방지(no-drop)
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

        // 되돌리기용 저장
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
  // 리사이즈 핸들(코너) 종료 시 저장
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
  // 편집 토글 & 초기화 버튼
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
      el.style.position = ''; // 흐름으로
      el.classList.remove('no-drop');
    });
    recalcCanvasSize();
    // 필요 시 서버 초기화 API 호출을 별도 구현
  });

  // ------------------------------------------------------
  // 초기화 순서
  //   (1) 초기 DOM → 절대좌표로 고정(freeze)
  //   (2) 서버(DB) 레이아웃 덮어쓰기
  //   (3) 드래그/리사이즈 바인딩
  //   (4) 메일 위젯 로딩
  // ------------------------------------------------------
  async function init(){
    const widgets = grid.querySelectorAll('.dash-widget');
    console.log('widgets found:', widgets.length);

    freezeAllToAbsolute();          // 먼저 고정(그리드 개입 차단)
    await loadLayoutFromServer();   // DB 값 덮어쓰기
    bindDragHandles();
    bindResizeHandles();
    recalcCanvasSize();

    // 디버그용 API
    window.debugDashboard = window.debugDashboard || {};
    window.debugDashboard.dump = logExistingWidgets;

    // 메일 위젯
    $('#btnMailRefresh').on('click', loadMailWidget);
    loadMailWidget();
  }

  // ---- 메일 위젯 Ajax (기존 그대로) ----
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
  // ---------------------------------------

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
