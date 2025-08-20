<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<link rel="stylesheet" href="<%= ctxPath %>/css/email.css">

<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="mail-wrap">
  <!-- 좌측: 메일 전용 사이드바 (분리된 JSP 포함) -->
  <jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

  <!-- 메일 리스트 -->
  <section class="flex-grow-1">
    <div class="mail-card card">
      <!-- 툴바 -->
      <div class="mail-list-toolbar d-flex align-items-center justify-content-between">
        <div class="text-muted small">전체메일함</div>
        <!-- 우측 액션 -->
	  	<div class="btn-group">
		    <!-- 일반 폴더: 삭제 -->
		    <button type="button" class="btn btn-outline-danger btn-sm" id="btnDelete">삭제</button>
		    <!-- 휴지통 폴더: 복원 -->
		    <button type="button" class="btn btn-outline-primary btn-sm d-none" id="btnRestore">복원</button>
		    <button type="button" class="btn btn-danger btn-sm d-none" id="btnPurge">영구삭제</button>
	  	</div>
      </div>

      <div class="table-responsive">
        <table class="table mail-table mb-0">
          <thead>
            <tr>
              <th class="col-chk">
                <div class="custom-control custom-checkbox">
                  <input type="checkbox" class="custom-control-input" id="chkAll">
                  <label class="custom-control-label" for="chkAll">전체선택</label>
                </div>
              </th>
              <th class="col-star"></th>
              <th class="col-read">읽음</th>
              <th class="col-from">보낸사람</th>
              <th class="col-subject">메일제목</th>
              <th class="col-date">보낸날짜</th>
            </tr>
          </thead>
          <tbody id="mailTbody"><!-- AJAX로 채움 --></tbody>
        </table>
      </div>
      
      <!-- ★ 페이지네이션 바 -->
	<nav aria-label="메일 목록 페이지" class="mt-2">
	  <ul id="mailPager" class="pagination pagination-sm justify-content-center mb-0"><!-- JS로 렌더 --></ul>
	</nav>
    </div>
  </section>
</div>

<script>

	const CTX = '<%=ctxPath%>';

	// 로그인 사용자 번호(숨김 목록을 사용자별로 분리)
	const LOGIN_EMP_NO = '${sessionScope.loginuser.emp_no}';
	// localStorage 키
	const HIDDEN_KEY = 'mailHidden:' + LOGIN_EMP_NO;
	
	// ★ 한 페이지 크기 고정: 10
	const PAGE_SIZE = 10;
	// 현재 페이지 상태 보관
	let CURRENT_PAGE = 1;
	$(function() {
		
		console.log('[email] jQuery version =', $.fn.jquery);
	    console.log('[email] page ready. current folder =', $('.mail-folders .active').data('folder'),
	                'current filter =', $('.filter-tabs .btn.active').data('filter'));
		
	  function folderLabel(folder){
	      if(folder === 'tome')   return '내게쓴메일함';
	      if(folder === 'sent')   return '보낸메일함';
	      if(folder === 'inbox')  return '받은메일함';
	      if(folder === 'trash')  return '휴지통';
	      return '전체메일함';
	    }

	  function filterLabel(filter){
		  if(filter === 'unread') return ' · 안읽음';
		  if(filter === 'star')   return ' · 중요';
		  if(filter === 'attach') return ' · 첨부';
		  return '';
		}
	  function updateToolbarActions(folder) {
		  if (folder === 'trash') {
		    $('#btnDelete').addClass('d-none');
		    $('#btnRestore').removeClass('d-none');
		    $('#btnPurge').removeClass('d-none');
		  } else {
		    $('#btnDelete').removeClass('d-none');
		    $('#btnRestore').addClass('d-none');
		    $('#btnPurge').addClass('d-none'); 
		  }
		}
	  function getActiveFolder(){
		  return $('.mail-folders .active').data('folder')
		      || $('.mail-trash .active').data('folder')
		      || 'all';
		}
	  
  	function currentFilter() {
      // 활성화된 필터 탭 1개만 사용 (없으면 null)
      return $('.filter-tabs .btn.active').data('filter') || null;
    }  
  	
 // 폴더에 따라 필터 사용 가능 여부 제어
  	function updateFilterControls(folder) {
  	  const $unread = $('.filter-tabs .btn[data-filter="unread"]');
  	  const $star   = $('.filter-tabs .btn[data-filter="star"]');

  	// 첨부는 sent에서도 사용 가능
  	  const disable = (folder === 'sent' || folder === 'trash');

  	  if (disable) {
  	    // 비활성 + 선택 해제
  	    [$unread, $star].forEach($b => {
  	      $b.addClass('disabled').attr('aria-disabled', 'true');
  	      if ($b.hasClass('active')) $b.removeClass('active');
  	    });
  	  } else {
  	    [$unread, $star].forEach($b => {
  	      $b.removeClass('disabled').removeAttr('aria-disabled');
  	    });
  	  }
  	}
  	function renderPager(total, page, size){
  	  const $pager = $('#mailPager');
  	  $pager.empty();

  	  const totalPages = Math.max(1, Math.ceil((total || 0) / size));
  	  const cur = Math.min(Math.max(1, page), totalPages);
  	  const BLOCK = 5;                               // ★ 한 번에 보여줄 페이지 번호 개수
  	  const blockIndex = Math.floor((cur - 1) / BLOCK);
  	  const start = blockIndex * BLOCK + 1;
  	  const end = Math.min(start + BLOCK - 1, totalPages);

  	  // 유틸: li 생성
  	  const li = (label, targetPage, disabledOrActive) => {
  	    const $li = $('<li class="page-item"></li>');
  	    if (disabledOrActive === 'disabled') $li.addClass('disabled');
  	    if (disabledOrActive === 'active')   $li.addClass('active');
  	    const $a = $('<a class="page-link" href="#"></a>').text(label);
  	    if (targetPage) $a.attr('data-page', targetPage);
  	    $li.append($a);
  	    return $li;
  	  };

  	  // [맨처음] [이전]
  	  $pager.append(li('맨처음', 1, cur === 1 ? 'disabled' : ''));
  	  $pager.append(li('이전', Math.max(1, cur - 1), cur === 1 ? 'disabled' : ''));

  	  // 번호들
  	  for (let p = start; p <= end; p++) {
  	    $pager.append(li(String(p), p, p === cur ? 'active' : ''));
  	  }

  	  // [다음] [마지막]
  	  $pager.append(li('다음', Math.min(totalPages, cur + 1), cur === totalPages ? 'disabled' : ''));
  	  $pager.append(li('마지막', totalPages, cur === totalPages ? 'disabled' : ''));
  	}
 
 // URL의 folder 파라미터로 초기 폴더 활성화
  	const params = new URLSearchParams(location.search);
  	const urlFolder = params.get('folder');

  	if (urlFolder) {
  	  // 좌측 폴더 active 표시
  	  $('.mail-folders a.list-group-item, .mail-trash a.list-group-item').removeClass('active');
  	  const $link = $('.mail-folders a.list-group-item[data-folder="'+urlFolder+'"], .mail-trash a.list-group-item[data-folder="'+urlFolder+'"]');
  	  if ($link.length) $link.addClass('active');
  	}

  	// 초기 로딩
  	CURRENT_PAGE = 1; // 쓰고 있다면 초기화
  	loadMails({ page: 1, folder: urlFolder || 'all' });
    function loadMails(params) {
      const activeFolder = getActiveFolder();
      
      // 폴더에 따른 필터 활성화
      updateFilterControls(activeFolder);
      
      updateToolbarActions(activeFolder);
      
      const activeFilter = currentFilter();
      const defaults = {
    	        folder: activeFolder,
    	        unread: (activeFilter === 'unread' ? 'Y' : 'N'),
    	        star:   (activeFilter === 'star'   ? 'Y' : 'N'),
    	        attach: (activeFilter === 'attach' ? 'Y' : 'N'),
    	        page: CURRENT_PAGE,
    	        size: PAGE_SIZE
    	      };
      const query = $.extend({}, defaults, params || {});
      
      console.log('[email] loadMails query =', query);  // ★ 여기 추가
      // 헤더의 열 제목 바꾸기
      if (query.folder === 'sent') {
        $('.mail-table thead th.col-from').text('받는사람');
      } else {
        $('.mail-table thead th.col-from').text('보낸사람');
      }
      // 상단 툴바 타이틀도 업데이트
      $('.mail-list-toolbar .text-muted.small').text(folderLabel(query.folder) + filterLabel(activeFilter));
      
      $.ajax({
        url: '<%=ctxPath%>/mail/list',
        type: 'GET',
        data: query,
        dataType: 'json',
        success: function(res) {
        	 console.log('[email] /mail/list success:', {
        		    total: res.total,
        		    page: res.page,
        		    size: res.size,
        		    listLen: (res.list||[]).length
        		  });
        	// ★ 각 항목의 읽음 상태를 표로 확인
        	  console.table((res.list || []).map(x => ({
        	    emailNo: x.emailNo,
        	    isRead:  x.isRead,
        	    isImportant: x.isImportant
        	  })));
          // ✅ folder 넘겨주기
          renderRows(res.list || [], query.folder);
          
          const effectiveTotal = (function(){
        	  // 휴지통 + 모든 항목이 숨김으로 걸려 현재 페이지 표시가 0이면 total을 0처럼 처리
        	  const folderNow = $('.mail-folders .active').data('folder') || $('.mail-trash .active').data('folder') || 'all';
        	  const visibleRows = $('#mailTbody tr').length;
        	  if (folderNow === 'trash' && (res.list || []).length > 0 && visibleRows === 0) return 0;
        	  return res.total || 0;
        	})();
          renderPager(res.total || 0, query.page || 1, query.size || PAGE_SIZE);
        },
        error: function() {
          $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">목록을 불러오지 못했습니다.</td></tr>');
        }
      });
    }

 // localStorage에서 숨김 목록(Set<string>) 로드
    function loadHiddenSet() {
      try {
        const raw = localStorage.getItem(HIDDEN_KEY);
        const arr = raw ? JSON.parse(raw) : [];
        return new Set((arr || []).map(String));
      } catch (e) {
        console.warn('[email] failed to load hidden list', e);
        return new Set();
      }
    }

    // Set을 저장
    function saveHiddenSet(set) {
      try {
        localStorage.setItem(HIDDEN_KEY, JSON.stringify(Array.from(set)));
      } catch (e) {
        console.warn('[email] failed to save hidden list', e);
      }
    }

    // 여러 ID 추가
    function addHidden(ids) {
      const set = loadHiddenSet();
      (ids || []).forEach(id => set.add(String(id)));
      saveHiddenSet(set);
    }

    // 여러 ID 제거(복원 시)
    function removeHidden(ids) {
      const set = loadHiddenSet();
      (ids || []).forEach(id => set.delete(String(id)));
      saveHiddenSet(set);
    }

    // 현재 숨김 여부
    function isHidden(emailNo) {
      const set = loadHiddenSet();
      return set.has(String(emailNo));
    }
    
    function renderRows(rows, folder){
    	// ★ 안읽음 필터가 켜져 있으면 읽음(Y) 항목은 제거
    	  const activeFilter = currentFilter();
    	  let displayRows = rows || [];

    	  // sent 폴더는 수신행이 없어 '안읽음/중요' 개념이 없음 → 제외
    	  if (folder !== 'sent') {
    	    if (activeFilter === 'unread') {
    	      displayRows = displayRows.filter(r => r.isRead === 'N');
    	    } else if (activeFilter === 'star') {
    	      displayRows = displayRows.filter(r => r.isImportant === 'Y');
    	    }
    	  }

   		// ★ 영구숨김(localStorage) 적용: emailNo가 숨김 목록에 있으면 제외
   	 	const hiddenSet = loadHiddenSet();
   	  	displayRows = displayRows.filter(m => !hiddenSet.has(String(m.emailNo)));
   	  
   	  	if (activeFilter === 'attach') {
   	   	 displayRows = displayRows.filter(r => r.hasAttach === 'Y');
   	 	 }

   	  	if (!displayRows.length) {
   	   	 $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">메일이 없습니다.</td></tr>');
   	   	 return;
   	 	 }

   	  	const html = displayRows.map(function(m){
        const starActive = m.isImportant === 'Y';
        const unread = m.isRead === 'N';
        const hasAttach = m.hasAttach === 'Y';

        // 휴지통일 때는 ownerType으로 보낸사람/받는사람 표기 결정
        const owner = (folder === 'trash')
        ? (m.ownerType || (m.isRead == null ? 'S' : 'R'))
        : null;
        const nameForList =
          (folder === 'sent')       ? (m.toNames || '') :
          (folder === 'trash' && owner === 'S') ? (m.toNames || '') :
          (m.fromName || '');
          
        const detailUrl = CTX + '/mail/detail?emailNo=' + encodeURIComponent(m.emailNo);
        
        // sent 폴더는 수신행이 없어 중요표시 대상 아님 → UI 비활성화
        const canStar = (folder !== 'sent' && folder !== 'trash');
        
        return `
          <tr data-id="\${m.emailNo}" data-owner="\${owner || ''}">
            <td class="col-chk">
              <div class="custom-control custom-checkbox">
                <input type="checkbox" class="custom-control-input row-chk" id="row\${m.emailNo}">
                <label class="custom-control-label" for="row\${m.emailNo}"></label>
              </div>
            </td>
            <td class="col-star">
            <button type="button"
                    class="btn-star \${starActive ? 'active':''} \${canStar ? '' : 'disabled'}"
                    data-emailno="\${m.emailNo}"
                    data-canstar="\${canStar ? 'Y':'N'}"
                    aria-label="중요 표시"
                    \${canStar ? '' : 'title="보낸메일함에서는 중요표시를 사용할 수 없습니다."'}
            >
              \${starActive ? '★' : '☆'}
            </button>
          </td>
            <td class="col-read">
              <span class="read-dot \${unread ? '' : 'read'}" title="\${unread ? '안읽음':'읽음'}"></span>
            </td>
            <!-- ✅ 여기 nameForList 사용 -->
            <td class="col-from">\${nameForList}</td>
            <td class="col-subject">
            <a class="subject-link \${unread ? 'subject-unread':''}" href="\${detailUrl}">
              \${(m.emailTitle || '(제목없음)')}
            </a>
            \${hasAttach ? ' <span class="text-muted">📎</span>' : ''}
          </td>
            <td class="col-date">\${m.sentAt || ''}</td>
          </tr>`;
      }).join('');
      $('#mailTbody').html(html);
    }
    
 // 체크된 메일번호 수집
    function getSelectedIds() {
      const ids = [];
      $('#mailTbody .row-chk:checked').each(function(){
        const $tr = $(this).closest('tr');
        ids.push($tr.data('id'));
      });
      return ids;
    }

    // 휴지통에서 소유타입별 분류(R/S)
    function getSelectedIdsByOwner() {
      const recvs = [], sents = [];
      $('#mailTbody .row-chk:checked').each(function(){
        const $tr = $(this).closest('tr');
        const id = $tr.data('id');
        const owner = ($tr.data('owner') || 'R');
        if (owner === 'S') sents.push(id);
        else recvs.push(id);
      });
      return { recvs, sents };
    }
    
    if (typeof loadHiddenSet !== 'function') {
    	  const LOGIN_EMP_NO = '${sessionScope.loginuser != null ? sessionScope.loginuser.emp_no : "guest"}';
    	  const HIDDEN_KEY = 'mailHidden:' + LOGIN_EMP_NO;

    	  window.loadHiddenSet = function(){
    	    try {
    	      const raw = localStorage.getItem(HIDDEN_KEY);
    	      const arr = raw ? JSON.parse(raw) : [];
    	      return new Set((arr || []).map(String));
    	    } catch(e) { return new Set(); }
    	  };
    	  window.saveHiddenSet = function(set){
    	    try { localStorage.setItem(HIDDEN_KEY, JSON.stringify(Array.from(set))); } catch(e) {}
    	  };
    	  window.addHidden = function(ids){
    	    const s = loadHiddenSet();
    	    (ids || []).forEach(id => s.add(String(id)));
    	    saveHiddenSet(s);
    	  };
    	  window.removeHidden = function(ids){
    	    const s = loadHiddenSet();
    	    (ids || []).forEach(id => s.delete(String(id)));
    	    saveHiddenSet(s);
    	  };
    	}

    	/* =========================
    	   (B) 휴지통 전체 비우기 (페이지 반복 호출)
    	   ========================= */
    	function fetchTrashPage(page, size){
    	  return $.ajax({
    	    url: CTX + '/mail/list',
    	    method: 'GET',
    	    dataType: 'json',
    	    data: { folder: 'trash', page: page, size: size, unread:'N', star:'N', attach:'N' }
    	  });
    	}

    	async function emptyTrashAll() {
    	  if (!confirm('휴지통에 있는 모든 메일을 영구삭제 하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;

    	  const size = 200; // 한 번에 많이 가져오기(환경에 맞춰 조절)
    	  let page = 1;
    	  let total = 0;
    	  const allIds = new Set();

    	  try {
    	    while (true) {
    	      // 각 페이지 조회
    	      /* eslint-disable no-await-in-loop */
    	      const res = await fetchTrashPage(page, size);
    	      const list = (res && res.list) ? res.list : [];
    	      if (page === 1) total = res && res.total ? res.total : list.length;

    	      list.forEach(m => allIds.add(String(m.emailNo)));

    	      // 마지막 페이지 도달 시 종료
    	      const maxPage = Math.ceil((total || 0) / size);
    	      if (page >= maxPage || list.length === 0) break;
    	      page++;
    	    }

    	    // 수집된 모든 휴지통 메일을 숨김 처리
    	    addHidden(Array.from(allIds));

    	    alert('휴지통을 모두 비웠습니다.');
    	    // 휴지통 탭이 활성화되도록 보장하고 새로고침
    	    // (이미 trash가 아니면 trash를 active로)
    	    $('.mail-folders a.list-group-item, .mail-trash a.list-group-item').removeClass('active');
    	    $('.mail-trash a.list-group-item[data-folder="trash"]').addClass('active');
    	    loadMails({ page: 1 });
    	  } catch (e) {
    	    console.error('[email] emptyTrashAll error', e);
    	    alert('휴지통 비우기 중 오류가 발생했습니다.');
    	  }
    	}

    	/* =========================
    	   (C) 사이드바에서 올라온 이벤트 처리
    	   ========================= */
    	$(document).on('mail.emptyTrashAll', function(){
    	  // 휴지통 전체 비우기 실행
    	  emptyTrashAll();
    	});
    
    
    
    $('#btnDelete').on('click', function(){
    	  const ids = getSelectedIds();
    	  if (!ids.length) { alert('삭제할 메일을 선택하세요.'); return; }

    	  const activeFolder = $('.mail-folders .active').data('folder') || 'all';
    	  if (!confirm('선택한 메일을 휴지통으로 이동하시겠습니까?')) return;

    	  $.ajax({
    	    url: CTX + '/mail/api/delete',
    	    method: 'POST',
    	    traditional: true, // 배열 전송 시 쿼리스트링 형태 유지
    	    data: { folder: activeFolder, emailNos: ids },
    	    success: function(res){
    	      if (res && res.ok) {
    	        alert('휴지통으로 이동했습니다.');
    	        loadMails({ page: 1 }); // 새로고침
    	      } else {
    	        alert('삭제에 실패했습니다.');
    	      }
    	    },
    	    error: function(){
    	      alert('서버 오류로 삭제에 실패했습니다.');
    	    }
    	  });
    	});
    
    $('#btnRestore').on('click', function(){
    	  const picked = getSelectedIdsByOwner();
    	  if (!picked.recvs.length && !picked.sents.length) {
    	    alert('복원할 메일을 선택하세요.');
    	    return;
    	  }
    	  if (!confirm('선택한 메일을 복원하시겠습니까?')) return;

    	  $.ajax({
    	    url: CTX + '/mail/api/restore',
    	    method: 'POST',
    	    data: {
    	      recvs: picked.recvs.join(','),
    	      sents: picked.sents.join(',')
    	    },
    	    success: function(res){
    	      if (res && res.ok) {
    	    	  const ids = [];
    	    	    $('#mailTbody .row-chk:checked').each(function(){
    	    	      ids.push(String($(this).closest('tr').data('id')));
    	    	    });
    	    	    removeHidden(ids);
    	    	    
    	        alert('복원되었습니다.');
    	        loadMails({ page: 1 });
    	      } else {
    	        alert('복원에 실패했습니다.');
    	      }
    	    },
    	    error: function(){
    	      alert('서버 오류로 복원에 실패했습니다.');
    	    }
    	  });
    	});
    
    
 // 휴지통: 선택 항목 영구삭제(프론트 숨김)
    $('#btnPurge').on('click', function(){
      // 휴지통에서는 data-owner="R|S"로 수집하는 유틸을 이미 쓰고 있죠.
      // 숨김은 owner 구분 없이 emailNo 기준으로 처리하면 충분합니다.
      const ids = [];
      $('#mailTbody .row-chk:checked').each(function(){
        ids.push(String($(this).closest('tr').data('id')));
      });

      if (!ids.length) { alert('영구삭제할 메일을 선택하세요.'); return; }

      if (!confirm('선택한 메일을 영구삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;

      addHidden(ids);         // ★ localStorage 추가
      alert('영구삭제 되었습니다.');
      loadMails({ page: 1 }); // 목록 새로고침
    });
    

 // 중요표시 토글 (서버 연동)
    $(document).on('click', '.btn-star', function(e) {
      e.stopPropagation();

      const $btn = $(this);
      if ($btn.data('canstar') !== 'Y' || $btn.hasClass('disabled')) {
        // 보낸메일함 등: 동작 불가
        return;
      }

      const emailNo = $btn.data('emailno');
      const toStar = !$btn.hasClass('active'); // true면 'Y'로, false면 'N'으로
      const nextValue = toStar ? 'Y' : 'N';

      // 낙관적 UI: 즉시 토글
      const prevText = $btn.text();
      $btn.toggleClass('active').text(toStar ? '★' : '☆').prop('disabled', true);

      $.ajax({
        url: CTX + '/mail/api/important',
        method: 'POST',
        data: { emailNo: emailNo, value: nextValue },
        success: function(res){
          if (!res || res.ok !== true) {
            // 실패 → 롤백
            $btn.toggleClass('active').text(prevText);
            alert('중요표시 변경에 실패했습니다.');
          }
        },
        error: function(xhr){
          // 실패 → 롤백
          $btn.toggleClass('active').text(prevText);
          if (xhr && xhr.responseJSON && xhr.responseJSON.reason === 'not_recipient') {
            alert('이 메일은 중요표시 대상이 아닙니다.');
          } else {
            alert('네트워크 오류 또는 서버 오류입니다.');
          }
        },
        complete: function(){
          $btn.prop('disabled', false);
        }
      });
    });
 
 // 페이지 클릭
    $(document).on('click', '#mailPager .page-link', function(e){
      e.preventDefault();
      const $li = $(this).closest('.page-item');
      if ($li.hasClass('disabled') || $li.hasClass('active')) return;

      const target = parseInt($(this).data('page'), 10);
      if (!target || isNaN(target)) return;

      CURRENT_PAGE = target;
      loadMails({ page: CURRENT_PAGE });    // 기존 함수 재사용
    });

/*     // 읽음 토글 (API는 추후 구현)
    $('#mailTbody').on('click', 'tr', function(e) {
      if ($(e.target).closest('.custom-control, .btn-star').length) return;
      const $dot = $(this).find('.read-dot');
      const $subject = $(this).find('.col-subject span');
      const willRead = $dot.hasClass('read') ? 'N' : 'Y';
      if (willRead === 'Y') { $dot.addClass('read').attr('title','읽음'); $subject.removeClass('subject-unread'); }
      else { $dot.removeClass('read').attr('title','안읽음'); $subject.addClass('subject-unread'); }
      // TODO: /mail/api/markRead 호출
    }); */

    // 전체 선택
    $('#chkAll').on('change', function() {
      $('.row-chk').prop('checked', $(this).prop('checked'));
    });

 // 폴더 전환: mail-folders + mail-trash 모두 처리
    $(document).on('click', '.mail-folders a.list-group-item, .mail-trash a.list-group-item', function(e){
      e.preventDefault();

      // 모든 폴더/휴지통에서 active 제거 후, 클릭한 항목만 active
      $('.mail-folders a.list-group-item, .mail-trash a.list-group-item').removeClass('active');
      $(this).addClass('active');

      // console.log('[email] folder click:', $(this).data('folder'));
	  CURRENT_PAGE = 1;
      // 1페이지부터 다시 로드
      loadMails({ page: 1 });
    });
 // 필터(안읽음/중요/첨부) 단일 선택 토글 - document 위임(더 견고)
    $(document).on('click', '.filter-tabs a.btn', function(e){
      e.preventDefault();

      const $btn = $(this);
      if ($btn.hasClass('disabled')) {
        console.log('[email] filter click ignored (disabled):', $btn.data('filter'));
        return;
      }

      const wasActive = $btn.hasClass('active');
      // 단일 선택: 다른 버튼 모두 해제
      $('.filter-tabs .btn').removeClass('active');

      if (!wasActive) $btn.addClass('active'); // 이미 활성화면 해제
      const nowActive = !wasActive;

      //console.log('[email] filter click:', { filter: $btn.data('filter'), nowActive });
	  CURRENT_PAGE = 1;
      // 필터가 바뀌면 1페이지부터 다시 로드
      loadMails({ page: 1 });
    });

    // 초기 로딩
    loadMails();
  });
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
<script>
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page','mail-list');
  });
</script>
