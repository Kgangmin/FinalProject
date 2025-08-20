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
  const CTX = '<%=ctxPath%>';

  // 페이지 타입 표시
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('dashboard-page');
  });

  // ===== 저장 키 =====
  const LS_POS_KEY  = 'dashboard.positions';      // ★ 위젯 위치(left/top) 저장
  const LS_SIZE_KEY = 'dashboard.widgetSizes';    // (이미 사용) 너비/높이 저장
  const LS_ORDER_KEY = 'dashboard.order';         // (미사용) 순서 저장 키는 남겨두지만 쓰지 않음

  // ===== 위치 저장/복원 유틸 =====
  function loadPositions(){
    try { return JSON.parse(localStorage.getItem(LS_POS_KEY) || '{}'); }
    catch(e){ return {}; }
  }
  function savePositions(map){
    localStorage.setItem(LS_POS_KEY, JSON.stringify(map));
  }
  function savePosition(el){
    const id = el.dataset.widgetId || el.dataset.id;
    if(!id) return;
    const map = loadPositions();
    map[id] = {
      left: parseInt(el.style.left || 0, 10),
      top : parseInt(el.style.top  || 0, 10)
    };
    savePositions(map);
  }
  function applySavedPositions(){
    const grid = document.getElementById('dashboard');
    const map = loadPositions();
    document.querySelectorAll('.dash-widget[data-widget-id], .dash-widget[data-id]').forEach(el=>{
      const id = el.dataset.widgetId || el.dataset.id;
      const pos = map[id];
      if (pos && (pos.left!=null) && (pos.top!=null)) {
        // 절대배치로 적용
        ensureAbsolute(el, grid);
        el.style.left = pos.left + 'px';
        el.style.top  = pos.top  + 'px';
      }
    });
  }

  // ===== 사이즈 저장/복원(기존) =====
  function loadSizes(){
    try { return JSON.parse(localStorage.getItem(LS_SIZE_KEY) || '{}'); }
    catch(e){ return {}; }
  }
  function saveSize(el){
    const id = el.dataset.widgetId || el.dataset.id;
    if (!id) return;
    const sizes = loadSizes();
    sizes[id] = { w: el.offsetWidth, h: el.offsetHeight };
    localStorage.setItem(LS_SIZE_KEY, JSON.stringify(sizes));
  }
  function applySavedSizes(){
    const sizes = loadSizes();
    document.querySelectorAll('.dash-widget[data-widget-id], .dash-widget[data-id]').forEach(el=>{
      const id = el.dataset.widgetId || el.dataset.id;
      const s = sizes[id];
      if (s && s.w && s.h) {
        el.style.width  = s.w + 'px';
        el.style.height = s.h + 'px';
      }
    });
  }

  // ===== 편집 모드 토글 =====
  const grid = document.getElementById('dashboard');
  const btnToggleEdit = document.getElementById('btnToggleEdit');
  const btnResetLayout = document.getElementById('btnResetLayout');
  let editing = false;

  btnToggleEdit.addEventListener('click', function(){
    editing = !editing;
    grid.classList.toggle('editing', editing);
    document.body.classList.toggle('dashboard-editing', editing);

    // 편집 켤 때: 저장된 위치가 있으면 절대배치로 전환
    if (editing) {
      toAbsoluteAll();
    }
    btnToggleEdit.textContent = editing ? '편집 종료' : '레이아웃 편집';
  });

  btnResetLayout.addEventListener('click', function(){
    localStorage.removeItem(LS_ORDER_KEY);
    localStorage.removeItem(LS_SIZE_KEY);
    localStorage.removeItem(LS_POS_KEY);   // ★ 위치도 초기화
    location.reload();
  });

  // ===== 절대배치 전환 보조 =====
  function ensureAbsolute(el, grid){
    if (getComputedStyle(el).position === 'absolute') return;
    const rect = el.getBoundingClientRect();
    const parentRect = grid.getBoundingClientRect();
    el.style.position = 'absolute';
    el.style.left = (rect.left - parentRect.left) + 'px';
    el.style.top  = (rect.top  - parentRect.top)  + 'px';
    // 그리드 레이아웃의 열/행 배치를 받지 않도록 grid span류/고정 클래스를 제거(있다면)
    el.classList.remove('w-3','w-4','w-6','w-12','h-1','h-2','h-3');
  }

  function toAbsoluteAll(){
    const widgets = grid.querySelectorAll('.dash-widget');
    widgets.forEach(el=>{
      ensureAbsolute(el, grid);
    });
  }

  // ===== 자유 위치 이동(↕︎ 이동 핸들) =====
  function bindMoveHandles(){
    grid.querySelectorAll('.drag-handle').forEach(handle=>{
      handle.addEventListener('mousedown', function(e){
        if (!editing) return;             // 편집 모드에서만
        e.preventDefault();
        e.stopPropagation();

        const el = e.target.closest('.dash-widget');
        if (!el) return;

        ensureAbsolute(el, grid);         // 필요시 절대배치로 전환

        const startX = e.clientX;
        const startY = e.clientY;
        const startLeft = parseInt(el.style.left || 0, 10);
        const startTop  = parseInt(el.style.top  || 0, 10);

        el.classList.add('moving');

        const onMove = (ev)=>{
          const dx = ev.clientX - startX;
          const dy = ev.clientY - startY;

          // 부모 영역 기준으로 경계 클램프
          const parentRect = grid.getBoundingClientRect();
          const maxLeft = parentRect.width  - el.offsetWidth;
          const maxTop  = parentRect.height - el.offsetHeight;

          let newLeft = startLeft + dx;
          let newTop  = startTop  + dy;

          if (newLeft < 0) newLeft = 0;
          if (newTop  < 0) newTop  = 0;
          if (newLeft > maxLeft) newLeft = maxLeft;
          if (newTop  > maxTop)  newTop  = maxTop;

          el.style.left = newLeft + 'px';
          el.style.top  = newTop  + 'px';
        };

        const onUp = ()=>{
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
          el.classList.remove('moving');
          savePosition(el);               // ★ 최종 위치 저장
        };

        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    });
  }

  // ===== 리사이즈 핸들(코너) =====
  function makeResizable(el){
    const handle = el.querySelector('.widget-resizer');
    if(!handle) return;

    handle.addEventListener('mousedown', function(e){
      if(!document.body.classList.contains('dashboard-editing')) return;
      e.preventDefault();
      e.stopPropagation();

      ensureAbsolute(el, grid); // 크기 조정 시에도 절대배치

      const startX = e.clientX;
      const startY = e.clientY;
      const startW = el.offsetWidth;
      const startH = el.offsetHeight;
      const MIN_W = 240, MIN_H = 160;

      document.body.classList.add('resizing');

      const onMove = (ev)=>{
        const dx = ev.clientX - startX;
        const dy = ev.clientY - startY;
        const newW = Math.max(MIN_W, startW + dx);
        const newH = Math.max(MIN_H, startH + dy);
        el.style.width  = newW + 'px';
        el.style.height = newH + 'px';
      };
      const onUp = ()=>{
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
        document.body.classList.remove('resizing');
        saveSize(el);        // 너비/높이 저장
        savePosition(el);    // 리사이즈 후 위치도 같이 저장(옵션)
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });
  }

  function initResizableWidgets(){
    document.querySelectorAll('.dash-widget').forEach(makeResizable);
  }

  // ===== 메일 위젯 데이터 로딩(기존) =====
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
      html += ''
        + '<li class="mail-item">'
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

  // ===== 초기화 =====
  function init(){
    // 크기/위치 먼저 복원(위치가 있으면 절대배치 자동 적용됨)
    applySavedSizes();
    applySavedPositions();

    // 핸들 바인딩
    initResizableWidgets();
    bindMoveHandles();

    // 데이터 로드
    loadMailWidget();

    // 새로고침 버튼
    $('#btnMailRefresh').on('click', loadMailWidget);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
