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
      <div class="mail-list-toolbar">
        <div class="text-muted small">전체메일함</div>
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
    </div>
  </section>
</div>

<script>

	const CTX = '<%=ctxPath%>';

	$(function() {
	  function folderLabel(folder){
	      if(folder === 'tome')   return '내게쓴메일함';
	      if(folder === 'sent')   return '보낸메일함';
	      if(folder === 'inbox')  return '받은메일함';
	      if(folder === 'trash')  return '휴지통';
	      return '전체메일함';
	    }

  	function currentFilter() {
      // 활성화된 필터 탭 1개만 사용 (없으면 null)
      return $('.filter-tabs .btn.active').data('filter') || null;
    }  
	  
    function loadMails(params) {
      const activeFolder = $('.mail-folders .active').data('folder') || 'all';
      const activeFilter = currentFilter();
      const defaults = {
    	        folder: activeFolder,
    	        unread: (activeFilter === 'unread' ? 'Y' : 'N'),
    	        star:   (activeFilter === 'star'   ? 'Y' : 'N'),
    	        attach: (activeFilter === 'attach' ? 'Y' : 'N'),
    	        page: 1,
    	        size: 20
    	      };
      const query = $.extend({}, defaults, params || {});
      // 헤더의 열 제목 바꾸기
      if (query.folder === 'sent') {
        $('.mail-table thead th.col-from').text('받는사람');
      } else {
        $('.mail-table thead th.col-from').text('보낸사람');
      }
      // 상단 툴바 타이틀도 업데이트
      $('.mail-list-toolbar .text-muted.small').text(folderLabel(query.folder));

      $.ajax({
        url: '<%=ctxPath%>/mail/list',
        type: 'GET',
        data: query,
        dataType: 'json',
        success: function(res) {
          // ✅ folder 넘겨주기
          renderRows(res.list || [], query.folder);
        },
        error: function() {
          $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">목록을 불러오지 못했습니다.</td></tr>');
        }
      });
    }

    function renderRows(rows, folder){
      if(!rows.length){
        $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">메일이 없습니다.</td></tr>');
        return;
      }
      const html = rows.map(function(m){
        const starActive = m.isImportant === 'Y';
        const unread = m.isRead === 'N';
        const hasAttach = m.hasAttach === 'Y';

        // ✅ 보낸메일(sent)은 받는사람(toNames), 나머지는 보낸사람(fromName)
        const nameForList = (folder === 'sent') ? (m.toNames || '') : (m.fromName || '');

        const detailUrl = CTX + '/mail/detail?emailNo=' + encodeURIComponent(m.emailNo);
        
        // sent 폴더는 수신행이 없어 중요표시 대상 아님 → UI 비활성화
        const canStar = (folder !== 'sent');
        
        return `
          <tr data-id="\${m.emailNo}" data-unread="\${unread}" data-attach="\${hasAttach}">
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

 	// 폴더 변경
    $('.mail-folders').on('click', 'a.list-group-item', function(e){
      e.preventDefault();
      $('.mail-folders a').removeClass('active');
      $(this).addClass('active');
      loadMails({ page: 1 });
    });

    // ✅ 필터 탭 클릭(단일 선택 토글)
    $('.filter-tabs').on('click', 'a.btn', function(e){
      e.preventDefault();
      const $btn = $(this);
      if ($btn.hasClass('active')) {
        // 한 번 더 누르면 해제(=필터 없음)
        $btn.removeClass('active');
      } else {
        // 단일 선택: 다른 버튼 해제
        $('.filter-tabs .btn').removeClass('active');
        $btn.addClass('active');
      }
      loadMails({ page: 1 });
    });

    // 초기 로딩
    loadMails();
  });
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
<script>
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page');
  });
</script>
