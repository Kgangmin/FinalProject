<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<style>
  /* 레이아웃 변수 */
  :root{
    --topbar-h: 70px;
    --menu-w: 170px;    /* 기존 메뉴 폭 */
    --chatbar-w: 200px; /* 요구사항: 200px */
    --bg-chat: #eaf6ff; /* 연한 하늘색 */
  }

  /* 헤더에 잘리는 문제 방지: 본문 상단 패딩 */
  body.chat-page .content-wrapper{
    margin-left: calc(var(--menu-w) + var(--chatbar-w));
    padding: 0;
    padding-top: var(--topbar-h);
  }

  /* 좌측 기존 메뉴 오른쪽에 붙는 채팅방 사이드바 */
  .chat-sidebar{
    position: fixed;
    top: var(--topbar-h);
    left: var(--menu-w);
    width: var(--chatbar-w);
    height: calc(100vh - var(--topbar-h));
    background: #fff;
    border-right: 1px solid #dee2e6;
    overflow: hidden;
    z-index: 1020;
  }
  .chat-sidebar .cs-head{ padding: 8px; border-bottom: 1px solid #eee; }
  .chat-sidebar .cs-head .search-box{ display:flex; gap:6px; align-items:center; }
  .chat-sidebar input[type="text"]{ width:100%; }
  .chat-sidebar .cs-tools{ display:flex; gap:6px; padding:8px; border-bottom:1px solid #f1f1f1; }
  .chat-sidebar .cs-body{ height: calc(100% - 102px); overflow-y: auto; }

  .room-item{
    display:flex; justify-content:space-between; align-items:center;
    padding:8px 10px; border-bottom:1px solid #f7f7f7; cursor:pointer;
  }
  .room-item:hover{ background:#f7f9fb; }
  .room-title{ font-weight:600; font-size:14px; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; max-width:120px; }
  .room-meta{ font-size:12px; color:#777; }
  .pin-btn{ border:none; background:transparent; cursor:pointer; font-size:14px; }
  .unread-badge{ background:#ffbe0b; color:#000; border-radius:999px; font-size:11px; padding:0 6px; margin-left:6px; }

  /* 본문(채팅 대화 영역) */
  .chat-wrap{
    min-height: calc(100vh - var(--topbar-h));
    background: var(--bg-chat);
    display:flex; flex-direction:column;
    padding-top: 48px;
  }
  .chat-head{
  position: fixed;
  top: var(--topbar-h);  /* 헤더 바로 밑 */
  left: calc(var(--menu-w) + var(--chatbar-w)); /* 메뉴+채팅방 사이드바 우측에서 시작 */
  right: 0;
  height: 48px;
  background:#fff;
  border-bottom:1px solid #dee2e6;
  padding:8px 12px;
  display:flex; align-items:center; justify-content:space-between;
  z-index:1050; /* 헤더보다 살짝 낮게 */
}
  .chat-body{ flex:1; overflow-y:auto; padding:12px; }
  .chat-foot{ background:#fff; border-top:1px solid #dee2e6; padding:8px; }

  /* 메시지 버블 */
  .msg{ display:flex; gap:8px; margin-bottom:10px; align-items:flex-start; }
  .msg.me{ flex-direction: row-reverse; }
  .msg .avatar{ width:32px; height:32px; border-radius:50%; object-fit:cover; border:1px solid #ddd; }
  .bubble{ max-width:60%; background:#fff; border:1px solid #e5e5e5; border-radius:10px; padding:8px 10px; color:#000; }
  .msg.me .bubble{ background:#fff3b0; }
  .bubble .top-line{ display:flex; gap:8px; align-items:center; margin-bottom:4px; font-size:12px; color:#333; font-weight:600; }
  .bubble .meta-line{ text-align:right; font-size:11px; color:#555; margin-top:4px; }
  .read-remain{ display:inline-block; min-width:16px; text-align:center; margin-left:6px; background:#eee; border-radius:8px; padding:0 4px; font-size:11px; color:#333; }
  .read-remain.hidden{ display:none; }

  /* ===== 칩/자동완성 (대화상대 추가) ===== */
  .member-field{ min-height:42px; gap:6px; position:relative; padding:6px 8px; }
  .member-input-inline{ border:0; outline:0; flex:1 0 180px; min-width:120px; background:transparent; }
  .member-suggest{ position:absolute; left:0; right:0; top:100%; z-index:2000; display:none;
                   max-height:260px; overflow:auto; background:#fff; border:1px solid #ddd; border-radius:6px; }
  .member-suggest .list-group-item{ cursor:pointer; padding:6px 10px; }
  .member-suggest .highlight{ background:#f1f3f5; }
  .member-chip{
    display:inline-flex; align-items:center; gap:6px;
    padding:3px 8px; border-radius:999px; margin:2px 0;
    border:1px solid #9ec5fe; background:#e7f1ff; color:#0d6efd; font-size:.875rem; line-height:1.2;
  }
  .member-chip .chip-x{ cursor:pointer; font-weight:bold; opacity:.7; }
  .member-chip .chip-x:hover{ opacity:1; }
  .member-field:focus-within{ box-shadow:0 0 0 .2rem rgba(13,110,253,.15); }
  
  .chat-foot .btn-send {
  padding: 4px 10px;   /* 버튼 안쪽 여백 */
  font-size: 13px;     /* 글자 크기 */
  line-height: 1.2;
   white-space: nowrap; 
}
</style>

<!-- 채팅방 사이드바 -->
<aside class="chat-sidebar">
  <div class="cs-head">
    <div class="search-box">
      <input id="roomSearch" type="text" class="form-control form-control-sm" placeholder="방/참여자 검색">
      <button id="btnSearchRoom" class="btn btn-sm btn-outline-secondary">🔍</button>
    </div>
  </div>
  <div class="cs-tools">
    <button id="btnNewRoom" class="btn btn-sm btn-primary" style="flex:1;">새 채팅방</button>
    <button id="btnReloadRooms" class="btn btn-sm btn-outline-secondary">새로고침</button>
  </div>
  <div id="roomList" class="cs-body"><!-- 방 목록 --></div>
</aside>

<!-- 본문 -->
<div class="content-wrapper chat-wrap">
  <div class="chat-head">
    <div>
      <span class="font-weight-bold" id="roomTitle">채팅</span>
      <small class="text-muted ml-2" id="roomParticipants"></small>
    </div>
    <div>
      <button id="btnAddMember" class="btn btn-sm btn-outline-primary">대화상대 추가</button>
      <button id="btnLeaveRoom" class="btn btn-sm btn-outline-danger ml-1">나가기</button>
    </div>
  </div>

  <div id="chatBody" class="chat-body"><!-- 메시지 --></div>

  <div class="chat-foot">
    <form id="sendForm" class="d-flex" autocomplete="off">
      <input id="msgInput" class="form-control mr-2" placeholder="메시지를 입력하세요">
      <button class="btn btn-primary btn-send">전송</button>
    </form>
  </div>
</div>

<!-- ===== 대화상대 추가 모달(칩+자동완성) ===== -->
<div class="modal fade" id="addMemberModal" tabindex="-1" role="dialog" aria-labelledby="addMemberModalTitle" aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h6 class="modal-title mb-0" id="addMemberModalTitle">대화상대 추가</h6>
        <button class="close" data-dismiss="modal" aria-label="Close"><span>&times;</span></button>
      </div>
      <div class="modal-body">
        <label class="font-weight-bold d-block mb-2">대화상대(사내)</label>
        <div id="memberField" class="member-field form-control d-flex flex-wrap align-items-center">
          <input id="memberInput" type="text" class="member-input-inline" placeholder="이름/부서/이메일 입력 후 Enter">
          <div id="memberSuggest" class="member-suggest list-group shadow-sm"></div>
        </div>
        <small class="text-muted">여러 명 선택 가능 · Enter/Tab/쉼표로 확정</small>
      </div>
      <div class="modal-footer">
        <button id="btnApplyMembers" class="btn btn-primary">추가</button>
      </div>
    </div>
  </div>
</div>

<!-- SockJS/STOMP (CDN) -->
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

<script>
(function(){
  // 페이지 타입 표시(헤더/레이아웃 조정용)
  document.body.classList.add('chat-page');

  const CTX = '<%=ctxPath%>';
  const API = CTX + '/api/chat';

  // 로그인 사용자
  const ME = {
    id:  '${sessionScope.loginuser.emp_no}',
    name:'${sessionScope.loginuser.emp_name}',
    profile:'${sessionScope.loginuser.emp_save_filename}'
  };

  // 상태
  let currentRoom = null;
  let stomp = null;
  const subscriptions = {}; // roomId -> subscription

  // ===== 유틸 =====
  function esc(s){
    return (s==null?'':String(s)).replace(/[&<>"']/g, function(m){
      return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[m];
    });
  }
  function ts(d){ try{ const dt = new Date(d); return dt.toLocaleString(); }catch(_){ return ''; } }
  function avatarUrl(fn){ return CTX + '/images/emp_profile/' + (fn||'default.png'); }
  function debounce(fn, wait){ let t=null; return function(){ clearTimeout(t); const a=arguments, th=this; t=setTimeout(function(){ fn.apply(th,a); }, wait||300); }; }

  // ===== 방 목록 =====
  async function loadRooms(){
    const q = $('#roomSearch').val().trim();
    const res = await fetch(CTX + '/api/chat/rooms' + (q?('?q='+encodeURIComponent(q)):''), {credentials:'include'});
    const data = await res.json().catch(()=>({ok:false}));
    if (!data.ok) return;
    renderRoomList(data.list||[], data.unread||{});
  }

  function renderRoomList(rooms, unreadMap){
    const $list = $('#roomList'); 
    $list.empty();

    rooms.forEach(function(r){
      const $item = $('<div>', { 'class':'room-item' })
        .attr('data-room-id', r.roomId || '')
        .attr('data-room-name', r.name || '');

      const $left = $('<div>');
      const $title = $('<div>', { 'class':'room-title' }).text(r.name || '');
      const $meta  = $('<div>', { 'class':'room-meta'  }).text(((r.participantIds||[]).length) + '명');
      $left.append($title, $meta);

      const unread = unreadMap && unreadMap[r.roomId] ? unreadMap[r.roomId] : 0;
      const $right = $('<div>', { 'class':'d-flex align-items-center' });
      const $badge = $('<span>', { 'class':'unread-badge' }).text(unread > 0 ? unread : '');
      if (unread <= 0) $badge.css('display','none');

      const pinned = (r.pinnedBy || []).includes(ME.id);
      const $pin = $('<button>', { 'class':'pin-btn ml-2', title:'상단고정', type:'button' })
                    .text(pinned ? '📌' : '📍');

      $right.append($badge, $pin);
      $item.append($left, $right);

      $item.on('click', function(e){
        if ($(e.target).is('.pin-btn')) return;
        enterRoom(r);
      });
      $pin.on('click', async function(){
        const pin = !(r.pinnedBy || []).includes(ME.id);
        await fetch(CTX + '/api/chat/rooms/'+encodeURIComponent(r.roomId)+'/pin', {
          method:'POST', headers:{'Content-Type':'application/json'},
          credentials:'include', body: JSON.stringify({pin})
        }).catch(()=>{});
        loadRooms();
      });

      $list.append($item);
    });
  }

  // ===== 방 입장 =====
  async function enterRoom(r){
    currentRoom = r;
    $('#roomTitle').text(r.name||'');
    $('#roomParticipants').text((r.participantIds||[]).length + '명 참여');

    const res = await fetch(CTX + '/api/chat/rooms/'+encodeURIComponent(r.roomId)+'/messages?size=80', {credentials:'include'});
    const data = await res.json().catch(()=>({ok:false, list:[]}));
    $('#chatBody').empty();
    if (data.ok && Array.isArray(data.list)) data.list.forEach(addMessageBubble);

    scrollToBottom();

    ensureStomp(function(){
      subscribeRoom(r.roomId);
      sendRead(r.roomId);
    });
  }
  
//===== 채팅방 나가기 =====
  $('#btnLeaveRoom').off('click').on('click', async function(){
    if(!currentRoom) return;
    if(!confirm('이 채팅방을 나가시겠습니까?')) return;
    
    const url = API + '/rooms/' + encodeURIComponent(currentRoom.roomId) + '/leave';

    const res = await fetch(url, {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      credentials: 'include',
      body: JSON.stringify({ userId: ME.id })
    }).catch(()=>null);

    if(res && res.ok){
      alert('채팅방에서 나갔습니다.');
      currentRoom = null;
      $('#chatBody').empty();
      $('#roomTitle').text('채팅');
      $('#roomParticipants').text('');
      loadRooms(); // 방 목록 갱신
    } else {
      alert('나가기 처리 중 오류가 발생했습니다.');
    }
  });

  // ===== 메시지 표시 =====
  function addMessageBubble(m){
    const me = (m.senderId === ME.id);
    const total = (currentRoom && currentRoom.participantIds ? currentRoom.participantIds.length : 0);
    const read  = (m.readBy && m.readBy.length) || 0;
    const remain = Math.max(0, total - read);

    const $row = $('<div>', { 'class':'msg' + (me ? ' me' : '') });

    const $avatar = $('<img>', { 'class':'avatar', alt:'avatar' }).attr('src', avatarUrl(m.senderProfile));
    const $bubble = $('<div>', { 'class':'bubble' });

    const $top = $('<div>', { 'class':'top-line' });
    $top.append($('<span>').text(m.senderName || ''));

    const $content = $('<div>', { 'class':'content' }).text(m.content || '');

    const $meta = $('<div>', { 'class':'meta-line' });
    $meta.append($('<span>').text(ts(m.createdAt)));
    const $remain = $('<span>', { 'class':'read-remain' }).text(remain > 0 ? remain : '');
    if (remain <= 0) $remain.addClass('hidden');
    $meta.append($remain);

    $bubble.append($top, $content, $meta);
    $row.append($avatar, $bubble);

    $('#chatBody').append($row);
  }

  function updateReadReceipts(userId){
    if (!currentRoom) return;
    // 간단화: 모든 버블의 잔여 수를 다시 계산(한 명 읽을 때마다 -1)
    $('#chatBody .msg').each(function(){
      const $b = $(this).find('.read-remain');
      const val = parseInt($b.text()||'0', 10);
      if (!isNaN(val) && val>0) {
        const newVal = val - 1;
        if (newVal<=0) $b.addClass('hidden').text('');
        else $b.text(newVal);
      }
    });
  }

  function scrollToBottom(){
    const el = document.getElementById('chatBody');
    el.scrollTop = el.scrollHeight;
  }

  // ===== 전송/읽음 =====
  $('#sendForm').off('submit').on('submit', function(e){
    e.preventDefault();
    const txt = $('#msgInput').val().trim();
    if (!txt || !currentRoom || !stomp || !stomp.connected) return;
    stomp.send('/app/rooms/'+currentRoom.roomId+'/send', {}, JSON.stringify({
      senderId: ME.id, senderName: ME.name, senderProfile: ME.profile, content: txt
    }));
    $('#msgInput').val('');
  });

  function sendRead(roomId){
    if (!stomp || !stomp.connected || !roomId) return;
    stomp.send('/app/rooms/'+roomId+'/read', {}, JSON.stringify({ userId: ME.id }));
  }

  // ===== STOMP 연결/구독 =====
  function ensureStomp(onConnected){
    if (stomp && stomp.connected){ if(typeof onConnected==='function') onConnected(); return; }
    const sock = new SockJS(CTX + '/ws-chat');
    stomp = Stomp.over(sock);
    stomp.debug = null;
    stomp.connect({}, function(){
      if(typeof onConnected==='function') onConnected();
      if (currentRoom && currentRoom.roomId) subscribeRoom(currentRoom.roomId);
    });
  }

  function subscribeRoom(roomId){
    if (!stomp || !stomp.connected || subscriptions[roomId]) return;
    subscriptions[roomId] = stomp.subscribe('/topic/rooms/'+roomId, function(frame){
      const msg = JSON.parse(frame.body || '{}');
      if (msg.type === 'message' && msg.data){
        addMessageBubble(msg.data);
        scrollToBottom();
      } else if (msg.type === 'readReceipt'){
        updateReadReceipts(msg.userId);
      }
    });
  }

  // ===== 새 방 만들기/검색/새로고침 =====
  $('#btnNewRoom').on('click', async function(){
    const name = prompt('새 채팅방 이름을 입력하세요.');
    if (!name) return;
    const res = await fetch(CTX + '/api/chat/rooms', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'include',
      body: JSON.stringify({name})
    }).catch(()=>null);
    const data = res ? await res.json().catch(()=>({ok:false})) : {ok:false};
    if (data.ok && data.room){
      await loadRooms();
      enterRoom(data.room);
    }
  });

  $('#btnSearchRoom').on('click', loadRooms);
  $('#btnReloadRooms').on('click', loadRooms);
  $('#roomSearch').on('keydown', function(e){ if (e.key==='Enter') loadRooms(); });

  // ====== 대화상대 추가 (칩 + 자동완성) ======
  function initMemberField(wrapId, inputId, suggestId){
    const wrap   = document.getElementById(wrapId);
    const input  = document.getElementById(inputId);
    const listEl = document.getElementById(suggestId);

    const selected = new Map(); // empNo -> info

    function has(empNo){ return selected.has(String(empNo)); }

    function addChip(info){
      const empNo = String(info.empNo||'').trim();
      if(!empNo || has(empNo)) return;

      selected.set(empNo, info);

      const chip = document.createElement('span');
      chip.className = 'member-chip';
      chip.setAttribute('data-empno', empNo);

      let label = (info.name||'');
      if(info.email) label += ' <'+info.email+'>';
      if(info.deptName) label += ' · '+info.deptName;

      chip.innerHTML = '<span class="chip-label">'+esc(label)+'</span><span class="chip-x" aria-label="remove" title="삭제">&times;</span>';

      chip.querySelector('.chip-x').addEventListener('click', function(){
        selected.delete(empNo);
        if(chip.parentNode) chip.parentNode.removeChild(chip);
      });

      wrap.insertBefore(chip, input);
      input.value='';
      hideSuggest();
    }

    function hideSuggest(){ listEl.style.display='none'; listEl.innerHTML=''; activeIndex=-1; }

    function showSuggest(items){
      if(!items || items.length===0){ hideSuggest(); return; }
      let html='';
      for(let i=0;i<items.length;i++){
        const it = items[i];
        let right = it.email || '';
        if(it.deptName){ right += (right?' · ':'') + it.deptName; }
        html += '<button type="button" class="list-group-item list-group-item-action" data-idx="'+i+'">'
              +   '<div class="d-flex justify-content-between align-items-center">'
              +     '<div><strong>'+esc(it.name||'')+'</strong></div>'
              +     '<div class="small text-muted">'+esc(right)+'</div>'
              +   '</div>'
              + '</button>';
      }
      listEl.innerHTML = html;
      listEl.style.display='block';

      Array.prototype.forEach.call(listEl.querySelectorAll('.list-group-item'), function(btn){
        btn.addEventListener('click', function(){
          const i = parseInt(btn.getAttribute('data-idx'),10);
          addChip(items[i]);
          input.focus();
        });
      });

      activeIndex=-1;
    }

    // 서버 검색 (백엔드: empNo/empName/deptName/empEmail/saveFilename alias 필요)
    const doSearch = debounce(function(q){
      q = String(q||'').trim();
      if(q.length < 1){ hideSuggest(); return; }
      fetch(CTX + '/api/chat/users?q=' + encodeURIComponent(q), { credentials:'include', headers:{'Accept':'application/json'} })
        .then(function(r){ return r.json(); })
        .then(function(res){
          if(!res || res.ok===false) { hideSuggest(); return; }
          let list = res.list || [];
          list = list.filter(function(it){ return it && it.empNo && !has(it.empNo); });
          // 표준화
          list = list.map(function(it){
            return {
              empNo: String(it.empNo||''),
              name: it.empName || it.name || '',
              deptName: it.deptName || it.teamName || '',
              email: it.empEmail || it.email || '',
              saveFilename: it.saveFilename || it.empSaveFilename || ''
            };
          });
          showSuggest(list);
        })
        .catch(function(){ hideSuggest(); });
    }, 250);

    // 입력 이벤트
    input.addEventListener('input', function(){ doSearch(input.value); });

    // 자동완성 키보드 탐색
    let activeIndex=-1;
    input.addEventListener('keydown', function(e){
      const key = e.key;
      const listOpen = (listEl.style.display!=='none');

      // 자동완성 탐색
      if(listOpen && (key==='ArrowDown' || key==='ArrowUp' || key==='Enter')){
        const items = listEl.querySelectorAll('.list-group-item');
        if(items.length===0) return;
        e.preventDefault();
        if(key==='ArrowDown') activeIndex = (activeIndex+1) % items.length;
        else if(key==='ArrowUp') activeIndex = (activeIndex-1+items.length) % items.length;
        Array.prototype.forEach.call(items, function(el,i){
          if(i===activeIndex) el.classList.add('highlight'); else el.classList.remove('highlight');
        });
        if(key==='Enter' && activeIndex>-1){ items[activeIndex].click(); activeIndex=-1; }
        return;
      }

      // Enter/Tab/쉼표/세미콜론: 자동완성 선택 유도(프리텍스트 추가는 비활성)
      if((key==='Enter' || key==='Tab' || key===',' || key===';') && input.value.trim()!==''){
        e.preventDefault();
        return;
      }

      // Backspace: 입력 비었을 때 마지막 칩 삭제
      if(key==='Backspace' && input.value.trim()===''){
        const chips = wrap.querySelectorAll('.member-chip');
        if(chips.length>0){
          const last = chips[chips.length-1];
          const empNo = last.getAttribute('data-empno');
          selected.delete(empNo);
          last.remove();
        }
      }
    });

    // 모달 닫힘 시 포커스 해제(aria 경고 완화)
    $('#addMemberModal').on('hidden.bs.modal', function(){
      if (document.activeElement) document.activeElement.blur();
      hideSuggest();
      input.value='';
    });

    return {
      getEmpNos: function(){ return Array.from(selected.keys()); },
      clearAll: function(){
        selected.clear();
        wrap.querySelectorAll('.member-chip').forEach(function(n){ n.remove(); });
        hideSuggest();
        input.value='';
      },
      focus: function(){ input.focus(); }
    };
  }

  const memberField = initMemberField('memberField','memberInput','memberSuggest');

  // 모달 오픈
  $('#btnAddMember').off('click').on('click', function(){
    $('#addMemberModal').modal('show');
    setTimeout(function(){ memberField.focus(); }, 120);
  });

  // 적용
  $('#btnApplyMembers').off('click').on('click', async function(){
    if(!currentRoom) { $('#addMemberModal').modal('hide'); return; }
    const empNos = memberField.getEmpNos();
    if(empNos.length===0){ $('#addMemberModal').modal('hide'); return; }

    await fetch(CTX + '/api/chat/rooms/'+encodeURIComponent(currentRoom.roomId)+'/participants', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      credentials:'include',
      body: JSON.stringify({ empNos })
    }).catch(function(){});

    $('#addMemberModal').modal('hide');
    memberField.clearAll();
    loadRooms();
  });

  // 초기 로드
  loadRooms();
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
