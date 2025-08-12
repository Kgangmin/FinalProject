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
  $(function() {
    // ===== 목록 호출 (필요시 컨트롤러/서비스 완료 후 활성화)
    function loadMails(params) {
      const defaults = {
        folder: $('.mail-folders .active').data('folder') || 'all',
        unread: $('#filterUnread').prop('checked') ? 'Y' : 'N',
        star:   $('#filterStar').prop('checked')   ? 'Y' : 'N',
        attach: $('#filterAttach').prop('checked') ? 'Y' : 'N',
        page: 1, size: 20
      };
      const query = $.extend({}, defaults, params || {});
      $.ajax({
        url: '<%=ctxPath%>/mail/api/list',
        type: 'GET',
        data: query,
        dataType: 'json',
        success: function(res) { renderRows(res.list || []); },
        error: function() {
          $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">목록을 불러오지 못했습니다.</td></tr>');
        }
      });
    }

    function renderRows(rows){
      if(!rows.length){
        $('#mailTbody').html('<tr><td colspan="6" class="text-center text-muted">메일이 없습니다.</td></tr>');
        return;
      }
      const html = rows.map(function(m){
        const starActive = m.isStar === 'Y';
        const unread = m.isRead === 'N';
        const hasAttach = m.hasAttach === 'Y';
        return `
          <tr data-id="${m.mailId}" data-unread="${unread}" data-attach="${hasAttach}">
            <td class="col-chk">
              <div class="custom-control custom-checkbox">
                <input type="checkbox" class="custom-control-input row-chk" id="row${m.mailId}">
                <label class="custom-control-label" for="row${m.mailId}"></label>
              </div>
            </td>
            <td class="col-star">
              <button type="button" class="btn-star ${starActive ? 'active':''}" aria-label="중요 표시">
                ${starActive ? '★' : '☆'}
              </button>
            </td>
            <td class="col-read">
              <span class="read-dot ${unread ? '' : 'read'}" title="${unread ? '안읽음':'읽음'}"></span>
            </td>
            <td class="col-from">${m.fromName || ''}</td>
            <td class="col-subject">
              <span class="${unread ? 'subject-unread':''}">${(m.subject || '(제목없음)')}</span>
            </td>
            <td class="col-date">${m.sentAt || ''}</td>
          </tr>`;
      }).join('');
      $('#mailTbody').html(html);
    }

    // 중요표시 토글
    $(document).on('click', '.btn-star', function(e) {
      e.stopPropagation();
      const $btn = $(this);
      const $tr = $btn.closest('tr');
      const mailId = $tr.data('id');
      const toStar = !$btn.hasClass('active');

      // Optimistic UI
      $btn.toggleClass('active').text(toStar ? '★' : '☆');

      $.ajax({
        url: '<%=ctxPath%>/mail/api/toggleStar',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ mailId: mailId, toStar: toStar }),
        error: function(){
          // 롤백
          $btn.toggleClass('active').text(toStar ? '☆' : '★');
          alert('중요표시 변경 실패');
        }
      });
    });

    // 읽음 토글 (행 클릭)
    $('#mailTbody').on('click', 'tr', function(e) {
      if ($(e.target).closest('.custom-control, .btn-star').length) return;

      const $tr = $(this);
      const $dot = $tr.find('.read-dot');
      const $subject = $tr.find('.col-subject span');
      const mailId = $tr.data('id');
      const willRead = $dot.hasClass('read') ? 'N' : 'Y';

      // Optimistic UI
      if (willRead === 'Y') { $dot.addClass('read').attr('title','읽음'); $subject.removeClass('subject-unread'); }
      else { $dot.removeClass('read').attr('title','안읽음'); $subject.addClass('subject-unread'); }

      $.ajax({
        url: '<%=ctxPath%>/mail/api/markRead',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ mailId: mailId, isRead: willRead }),
        error: function(){
          // 롤백
          if (willRead === 'Y') { $dot.removeClass('read').attr('title','안읽음'); $subject.addClass('subject-unread'); }
          else { $dot.addClass('read').attr('title','읽음'); $subject.removeClass('subject-unread'); }
          alert('읽음 변경 실패');
        }
      });
    });

    // 전체 선택
    $('#chkAll').on('change', function() {
      $('.row-chk').prop('checked', $(this).prop('checked'));
    });

    // 필터/폴더 변경 시 목록 갱신
    $('#filterUnread, #filterStar, #filterAttach').on('change', function(){ loadMails(); });
    $('.mail-folders').on('click', 'a.list-group-item', function(e){
      e.preventDefault();
      $('.mail-folders a').removeClass('active');
      $(this).addClass('active');
      loadMails();
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
