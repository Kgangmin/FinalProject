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

      <!-- 페이지네이션 -->
      <nav aria-label="메일 목록 페이지" class="mt-2">
        <ul id="mailPager" class="pagination pagination-sm justify-content-center mb-0"><!-- JS로 렌더 --></ul>
      </nav>
    </div>
  </section>
</div>

<script>
  const CTX = '<%=ctxPath%>';

  // ===== 서버 필터 구현 여부 토글 =====
  // 서버가 /mail/list에서 unread/star/attach를 WHERE에 반영하면 true로 변경
  const SERVER_FILTERS_MAILS = false;

  // 로그인 사용자 번호(숨김 목록을 사용자별로 분리)
  const LOGIN_EMP_NO = '${sessionScope.loginuser.emp_no}';
  const HIDDEN_KEY = 'mailHidden:' + LOGIN_EMP_NO;

  const PAGE_SIZE = 10;
  let CURRENT_PAGE = 1;

  // 클라이언트 집계 모드 상태
  let CLIENT_MODE = false;        // true면 서버 호출 대신 메모리 데이터로 페이지 이동
  let CLIENT_DATASET = [];        // 필터 후 전체 rows
  let CLIENT_FOLDER = 'all';      // 현재 폴더(렌더용)
  let CLIENT_FILTER = null;       // 현재 필터(unread|star|attach|null)

  $(function () {
    function folderLabel(folder) {
      if (folder === 'tome') return '내게쓴메일함';
      if (folder === 'sent') return '보낸메일함';
      if (folder === 'inbox') return '받은메일함';
      if (folder === 'trash') return '휴지통';
      return '전체메일함';
    }
    function filterLabel(filter) {
      if (filter === 'unread') return ' · 안읽음';
      if (filter === 'star') return ' · 중요';
      if (filter === 'attach') return ' · 첨부';
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
    function getActiveFolder() {
      return $('.mail-folders .active').data('folder')
        || $('.mail-trash .active').data('folder')
        || 'all';
    }
    function currentFilter() {
      return $('.filter-tabs .btn.active').data('filter') || null;
    }
    function updateFilterControls(folder) {
      const $unread = $('.filter-tabs .btn[data-filter="unread"]');
      const $star   = $('.filter-tabs .btn[data-filter="star"]');
      // sent/trash에서는 안읽음/중요 비활성, 첨부는 허용
      const disable = (folder === 'sent' || folder === 'trash');
      if (disable) {
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
    function renderPager(total, page, size) {
      const $pager = $('#mailPager');
      $pager.empty();

      const totalPages = Math.max(1, Math.ceil((total || 0) / size));
      const cur = Math.min(Math.max(1, page), totalPages);
      const BLOCK = 5;
      const blockIndex = Math.floor((cur - 1) / BLOCK);
      const start = blockIndex * BLOCK + 1;
      const end = Math.min(start + BLOCK - 1, totalPages);

      const li = (label, targetPage, state) => {
        const $li = $('<li class="page-item"></li>');
        if (state === 'disabled') $li.addClass('disabled');
        if (state === 'active')   $li.addClass('active');
        const $a = $('<a class="page-link" href="#"></a>').text(label);
        if (targetPage) $a.attr('data-page', targetPage);
        $li.append($a);
        return $li;
      };

      $pager.append(li('맨처음', 1, cur === 1 ? 'disabled' : ''));
      $pager.append(li('이전', Math.max(1, cur - 1), cur === 1 ? 'disabled' : ''));
      for (let p = start; p <= end; p++) $pager.append(li(String(p), p, p === cur ? 'active' : ''));
      $pager.append(li('다음', Math.min(totalPages, cur + 1), cur === totalPages ? 'disabled' : ''));
      $pager.append(li('마지막', totalPages, cur === totalPages ? 'disabled' : ''));
    }

    // URL folder 초기화
    const params = new URLSearchParams(location.search);
    const urlFolder = params.get('folder');
    if (urlFolder) {
      $('.mail-folders a.list-group-item, .mail-trash a.list-group-item').removeClass('active');
      const $link = $('.mail-folders a.list-group-item[data-folder="' + urlFolder + '"], .mail-trash a.list-group-item[data-folder="' + urlFolder + '"]');
      if ($link.length) $link.addClass('active');
    }

    // 초기 로딩
    CURRENT_PAGE = 1;
    loadMails({ page: 1, folder: urlFolder || 'all' });

    // ===== 공통 유틸 =====
    function loadHiddenSet() {
      try {
        const raw = localStorage.getItem(HIDDEN_KEY);
        const arr = raw ? JSON.parse(raw) : [];
        return new Set((arr || []).map(String));
      } catch (e) { return new Set(); }
    }
    function saveHiddenSet(set) {
      try { localStorage.setItem(HIDDEN_KEY, JSON.stringify(Array.from(set))); } catch (e) {}
    }
    function addHidden(ids) {
      const set = loadHiddenSet();
      (ids || []).forEach(id => set.add(String(id)));
      saveHiddenSet(set);
    }
    function removeHidden(ids) {
      const set = loadHiddenSet();
      (ids || []).forEach(id => set.delete(String(id)));
      saveHiddenSet(set);
    }

    function renderRows(rows, folder) {
      // 영구숨김 적용
      const hiddenSet = loadHiddenSet();
      const displayRows = (rows || []).filter(m => !hiddenSet.has(String(m.emailNo)));

      if (!displayRows.length) {
        $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">메일이 없습니다.</td></tr>');
        return;
      }

      const html = displayRows.map(function (m) {
        const starActive = m.isImportant === 'Y';
        const unread = m.isRead === 'N';
        const hasAttach = m.hasAttach === 'Y';

        const owner = (folder === 'trash')
          ? (m.ownerType || (m.isRead == null ? 'S' : 'R'))
          : null;
        const nameForList =
          (folder === 'sent') ? (m.toNames || '') :
          (folder === 'trash' && owner === 'S') ? (m.toNames || '') :
          (m.fromName || '');

        const detailUrl = CTX + '/mail/detail?emailNo=' + encodeURIComponent(m.emailNo);
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
                      class="btn-star \${starActive ? 'active' : ''} \${canStar ? '' : 'disabled'}"
                      data-emailno="\${m.emailNo}"
                      data-canstar="\${canStar ? 'Y' : 'N'}"
                      aria-label="중요 표시"
                      \${canStar ? '' : 'title="보낸메일함 또는 휴지통에서는 중요표시를 사용할 수 없습니다."'}
              >
                \${starActive ? '★' : '☆'}
              </button>
            </td>
            <td class="col-read">
              <span class="read-dot \${unread ? '' : 'read'}" title="\${unread ? '안읽음' : '읽음'}"></span>
            </td>
            <td class="col-from">\${nameForList}</td>
            <td class="col-subject">
              <a class="subject-link \${unread ? 'subject-unread' : ''}" href="\${detailUrl}">
                \${(m.emailTitle || '(제목없음)')}
              </a>
              \${hasAttach ? ' <span class="text-muted">📎</span>' : ''}
            </td>
            <td class="col-date">${m.sentAt || ''}</td>
          </tr>`;
      }).join('');

      $('#mailTbody').html(html);
    }

    // ===== 서버 통신 =====
    function fetchPage(query) {
      // 공통 GET
      return $.ajax({
        url: '<%=ctxPath%>/mail/list',
        type: 'GET',
        data: query,
        dataType: 'json'
      });
    }

    async function loadMails(params) {
      const folder = getActiveFolder();
      const filter = currentFilter();

      updateFilterControls(folder);
      updateToolbarActions(folder);

      // 헤더 텍스트
      if (folder === 'sent') $('.mail-table thead th.col-from').text('받는사람');
      else $('.mail-table thead th.col-from').text('보낸사람');
      $('.mail-list-toolbar .text-muted.small').text(folderLabel(folder) + filterLabel(filter));

      // 기본 쿼리
      const base = {
        folder: folder,
        unread: (filter === 'unread' ? 'Y' : 'N'),
        star:   (filter === 'star'   ? 'Y' : 'N'),
        attach: (filter === 'attach' ? 'Y' : 'N'),
        page: CURRENT_PAGE,
        size: PAGE_SIZE
      };
      const query = $.extend({}, base, params || {});

      // === 클라이언트 집계 모드 진입 조건 ===
      // 서버 필터 비활성 + 필터가 존재하면, 모든 페이지를 수집해 프론트에서 필터/페이징
      if (!SERVER_FILTERS_MAILS && filter) {
        await enterClientAggregateMode(folder, filter);
        return;
      }

      // === 서버 페이징 모드 ===
      CLIENT_MODE = false;
      CLIENT_DATASET = [];
      CLIENT_FOLDER = folder;
      CLIENT_FILTER = filter;

      try {
        const res = await fetchPage(query);
        renderRows(res.list || [], folder);

        // 휴지통 + 숨김 모두 제거되어 보이는 특수케이스 보정
        const visibleRows = $('#mailTbody tr').length;
        const effectiveTotal = (folder === 'trash' && (res.list || []).length > 0 && visibleRows === 0)
          ? 0
          : (res.total || 0);

        renderPager(effectiveTotal, query.page || 1, query.size || PAGE_SIZE);
      } catch (e) {
        console.error('[email] /mail/list error', e);
        $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">목록을 불러오지 못했습니다.</td></tr>');
      }
    }

    // ===== 클라이언트 집계 모드 =====
    function applyClientFilter(rows, filter, folder) {
      if (!filter) return rows || [];
      let out = rows || [];
      if (filter === 'unread' && folder !== 'sent') {
        out = out.filter(r => r.isRead === 'N');
      } else if (filter === 'star' && folder !== 'sent') {
        out = out.filter(r => r.isImportant === 'Y');
      } else if (filter === 'attach') {
        out = out.filter(r => r.hasAttach === 'Y');
      }
      return out;
    }

    async function enterClientAggregateMode(folder, filter) {
      // 서버가 필터를 적용하지 않는다고 가정하고,
      // 전체 페이지를 순회 수집 후 프론트에서 필터링
      CLIENT_MODE   = true;
      CLIENT_FOLDER = folder;
      CLIENT_FILTER = filter;

      // 1) 첫 페이지로 total 파악
      const first = await fetchPage({
        folder, unread: 'N', star: 'N', attach: 'N',
        page: 1, size: 200   // 한번에 많이
      });

      let all = first.list || [];
      const total = first.total || all.length;
      const perPage = 200;
      const maxPage = Math.max(1, Math.ceil(total / perPage));

      // 2) 나머지 페이지 순회
      for (let p = 2; p <= maxPage; p++) {
        /* eslint-disable no-await-in-loop */
        const res = await fetchPage({
          folder, unread: 'N', star: 'N', attach: 'N',
          page: p, size: perPage
        });
        all = all.concat(res.list || []);
      }

      // 3) 프론트 필터 → 숨김 적용
      const filtered = applyClientFilter(all, filter, folder);
      CLIENT_DATASET = filtered;

      // 4) 1페이지부터 렌더
      CURRENT_PAGE = 1;
      renderClientPage();  // 페이저 + 슬라이스 + 렌더
    }

    function renderClientPage() {
      const total = CLIENT_DATASET.length;
      renderPager(total, CURRENT_PAGE, PAGE_SIZE);

      const start = (CURRENT_PAGE - 1) * PAGE_SIZE;
      const end   = start + PAGE_SIZE;
      const slice = CLIENT_DATASET.slice(start, end);

      renderRows(slice, CLIENT_FOLDER);
    }

    // ===== 이벤트 바인딩 =====
    // 페이지 클릭
    $(document).on('click', '#mailPager .page-link', function (e) {
      e.preventDefault();
      const $li = $(this).closest('.page-item');
      if ($li.hasClass('disabled') || $li.hasClass('active')) return;

      const target = parseInt($(this).data('page'), 10);
      if (!target || isNaN(target)) return;

      CURRENT_PAGE = target;

      if (CLIENT_MODE) {
        renderClientPage(); // 서버 호출 없이 메모리에서 페이징
      } else {
        loadMails({ page: CURRENT_PAGE });
      }
    });

    // 전체 선택
    $('#chkAll').on('change', function () {
      $('.row-chk').prop('checked', $(this).prop('checked'));
    });

    // 폴더 전환
    $(document).on('click', '.mail-folders a.list-group-item, .mail-trash a.list-group-item', function (e) {
      e.preventDefault();
      $('.mail-folders a.list-group-item, .mail-trash a.list-group-item').removeClass('active');
      $(this).addClass('active');

      // 폴더 바뀌면 항상 서버/클라 상태 초기화
      CLIENT_MODE = false;
      CLIENT_DATASET = [];
      CURRENT_PAGE = 1;
      loadMails({ page: 1 });
    });

    // 필터(안읽음/중요/첨부) 단일 선택 토글
    $(document).on('click', '.filter-tabs a.btn', function (e) {
      e.preventDefault();

      const $btn = $(this);
      if ($btn.hasClass('disabled')) return;

      const wasActive = $btn.hasClass('active');
      $('.filter-tabs .btn').removeClass('active');
      if (!wasActive) $btn.addClass('active'); // 이미 활성화면 해제

      // 필터 바뀌면 항상 1페이지부터
      CURRENT_PAGE = 1;

      // 클라 집계 모드도 필터 변경에 따라 재계산
      CLIENT_MODE = false;
      CLIENT_DATASET = [];
      loadMails({ page: 1 });
    });

    // 삭제
    $('#btnDelete').on('click', function () {
      const ids = [];
      $('#mailTbody .row-chk:checked').each(function () {
        ids.push(String($(this).closest('tr').data('id')));
      });
      if (!ids.length) { alert('삭제할 메일을 선택하세요.'); return; }

      const activeFolder = getActiveFolder();
      if (!confirm('선택한 메일을 휴지통으로 이동하시겠습니까?')) return;

      $.ajax({
        url: CTX + '/mail/api/delete',
        method: 'POST',
        traditional: true,
        data: { folder: activeFolder, emailNos: ids },
        success: function (res) {
          if (res && res.ok) {
            alert('휴지통으로 이동했습니다.');
            CURRENT_PAGE = 1;
            // 집계 모드라면 메모리에서 제거 후 재렌더
            if (CLIENT_MODE) {
              CLIENT_DATASET = CLIENT_DATASET.filter(m => !ids.includes(String(m.emailNo)));
              renderClientPage();
            } else {
              loadMails({ page: 1 });
            }
          } else {
            alert('삭제에 실패했습니다.');
          }
        },
        error: function () {
          alert('서버 오류로 삭제에 실패했습니다.');
        }
      });
    });

    // 복원
    function getSelectedIdsByOwner() {
      const recvs = [], sents = [];
      $('#mailTbody .row-chk:checked').each(function(){
        const $tr = $(this).closest('tr');
        const id = $tr.data('id');
        const owner = ($tr.data('owner') || 'R');
        if (owner === 'S') sents.push(id); else recvs.push(id);
      });
      return { recvs, sents };
    }
    $('#btnRestore').on('click', function () {
      const picked = getSelectedIdsByOwner();
      if (!picked.recvs.length && !picked.sents.length) {
        alert('복원할 메일을 선택하세요.');
        return;
      }
      if (!confirm('선택한 메일을 복원하시겠습니까?')) return;

      $.ajax({
        url: CTX + '/mail/api/restore',
        method: 'POST',
        data: { recvs: picked.recvs.join(','), sents: picked.sents.join(',') },
        success: function (res) {
          if (res && res.ok) {
            const ids = [];
            $('#mailTbody .row-chk:checked').each(function () {
              ids.push(String($(this).closest('tr').data('id')));
            });
            removeHidden(ids);

            alert('복원되었습니다.');
            CURRENT_PAGE = 1;
            if (CLIENT_MODE) {
              CLIENT_DATASET = CLIENT_DATASET.filter(m => !ids.includes(String(m.emailNo)));
              renderClientPage();
            } else {
              loadMails({ page: 1 });
            }
          } else {
            alert('복원에 실패했습니다.');
          }
        },
        error: function () {
          alert('서버 오류로 복원에 실패했습니다.');
        }
      });
    });

    // 휴지통: 선택 영구삭제(프론트 숨김)
    $('#btnPurge').on('click', function () {
      const ids = [];
      $('#mailTbody .row-chk:checked').each(function () {
        ids.push(String($(this).closest('tr').data('id')));
      });
      if (!ids.length) { alert('영구삭제할 메일을 선택하세요.'); return; }
      if (!confirm('선택한 메일을 영구삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;

      addHidden(ids);
      alert('영구삭제 되었습니다.');
      CURRENT_PAGE = 1;
      if (CLIENT_MODE) {
        CLIENT_DATASET = CLIENT_DATASET.filter(m => !ids.includes(String(m.emailNo)));
        renderClientPage();
      } else {
        loadMails({ page: 1 });
      }
    });

    // 중요표시 토글
    $(document).on('click', '.btn-star', function (e) {
      e.stopPropagation();
      const $btn = $(this);
      if ($btn.data('canstar') !== 'Y' || $btn.hasClass('disabled')) return;

      const emailNo = $btn.data('emailno');
      const toStar = !$btn.hasClass('active');
      const nextValue = toStar ? 'Y' : 'N';

      const prevText = $btn.text();
      $btn.toggleClass('active').text(toStar ? '★' : '☆').prop('disabled', true);

      $.ajax({
        url: CTX + '/mail/api/important',
        method: 'POST',
        data: { emailNo: emailNo, value: nextValue },
        success: function (res) {
          if (!res || res.ok !== true) {
            $btn.toggleClass('active').text(prevText);
            alert('중요표시 변경에 실패했습니다.');
          } else if (CLIENT_MODE) {
            // 메모리 데이터 동기화
            CLIENT_DATASET = CLIENT_DATASET.map(m =>
              String(m.emailNo) === String(emailNo)
                ? Object.assign({}, m, { isImportant: nextValue })
                : m
            );
          }
        },
        error: function () {
          $btn.toggleClass('active').text(prevText);
          alert('네트워크 오류 또는 서버 오류입니다.');
        },
        complete: function () { $btn.prop('disabled', false); }
      });
    });

    // 휴지통 전체 비우기(사이드바 이벤트)
    $(document).on('mail.emptyTrashAll', async function () {
      if (!confirm('휴지통에 있는 모든 메일을 영구삭제 하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;

      // trash 전부 수집 → 숨김 등록
      try {
        // 큰 size로 반복 수집
        const first = await fetchPage({ folder: 'trash', unread:'N', star:'N', attach:'N', page:1, size:300 });
        let all = first.list || [];
        const total = first.total || all.length;
        const perPage = 300;
        const maxPage = Math.max(1, Math.ceil(total / perPage));
        for (let p=2; p<=maxPage; p++) {
          /* eslint-disable no-await-in-loop */
          const res = await fetchPage({ folder:'trash', unread:'N', star:'N', attach:'N', page:p, size:perPage });
          all = all.concat(res.list || []);
        }

        addHidden(all.map(m => String(m.emailNo)));
        alert('휴지통을 모두 비웠습니다.');

        // 뷰 갱신
        $('.mail-folders a.list-group-item, .mail-trash a.list-group-item').removeClass('active');
        $('.mail-trash a.list-group-item[data-folder="trash"]').addClass('active');
        CURRENT_PAGE = 1;
        if (CLIENT_MODE) {
          // 집계 모드였다면 초기화 후 재로드
          CLIENT_MODE = false;
          CLIENT_DATASET = [];
        }
        loadMails({ page: 1 });
      } catch (e) {
        console.error('[email] emptyTrashAll error', e);
        alert('휴지통 비우기 중 오류가 발생했습니다.');
      }
    });
  });
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
<script>
  document.addEventListener('DOMContentLoaded', function () {
    document.body.classList.add('mail-page', 'mail-list');
  });
</script>
