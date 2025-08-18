<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>

<jsp:include page="../header/header.jsp" />

<!-- FullCalendar 5.10.1 -->
<link rel="stylesheet" href="<%= ctxPath %>/fullcalendar_5.10.1/main.min.css">
<script src="<%= ctxPath %>/fullcalendar_5.10.1/main.min.js"></script>


<!-- 페이지 전용 CSS -->
<link rel="stylesheet" href="<%= ctxPath %>/css/schedule.css">

<!-- ===== 캘린더 전용 사이드바 (menu.jsp 오른쪽에 공백 없이 붙음) ===== -->
<aside id="scheduleSidebar" class="schedule-sidebar">
    <div class="sidebar-section">
        <div class="section-title">일정</div>        
    </div>
	<button id="btnCreate" class="btn btn-primary btn-block mb-2">+ 새 일정</button>
    <div class="sidebar-section">
        <div class="section-title">필터</div>
        <div class="custom-control custom-checkbox">
            <input type="checkbox" class="custom-control-input fc-filter" id="chkMy" data-type="MY" checked>
            <label class="custom-control-label" for="chkMy">내 일정</label>
        </div>
        <div class="custom-control custom-checkbox">
            <input type="checkbox" class="custom-control-input fc-filter" id="chkDept" data-type="DEPT" checked>
            <label class="custom-control-label" for="chkDept">부서 일정</label>
        </div>
        <div class="custom-control custom-checkbox">
            <input type="checkbox" class="custom-control-input fc-filter" id="chkCompany" data-type="COMP" checked>
            <label class="custom-control-label" for="chkCompany">회사 일정</label>
        </div>
    </div>

    <div class="sidebar-section">
        <div class="section-title">빠른 검색</div>
        <div class="input-group">
            <input type="text" id="q" class="form-control" placeholder="제목/메모 검색">
            <div class="input-group-append">
                <button id="btnSearch" class="btn btn-outline-secondary">검색</button>
            </div>
        </div>
    </div>
    <!-- ===== 검색결과 패널 ===== -->
	<div id="searchPanel" class="sidebar-section" style="display:none;">
	  <div class="section-title d-flex align-items-center justify-content-between">
	    <span>검색 결과 <small id="searchCount" class="text-muted">(0)</small></span>
	    <button type="button" id="btnSearchClear" class="btn btn-sm btn-outline-secondary">초기화</button>
	  </div>
	  <ul id="searchList" class="list-group small"></ul>
	</div>
</aside>

<!-- ===== 본문: 캘린더 영역 ===== -->
<div id="calendarWrapper" class="calendar-wrapper">
    <div id="calendar"></div>
</div>

<!-- ===== 일정 등록/수정 모달 ===== -->
<div class="modal fade" id="eventModal" tabindex="-1" role="dialog" aria-labelledby="eventModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 id="eventModalLabel" class="modal-title">일정 등록</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <form id="eventForm">
          <input type="hidden" id="eventId">
          <div class="form-group">
            <label for="eventTitle">제목</label>
            <input type="text" class="form-control" id="eventTitle" required>
          </div>
          <div class="form-group">
            <label for="eventType">구분</label>
            <select id="eventType" class="form-control">
              <option value="MY">내 일정</option>
            </select>
          </div>
          <div class="form-group">
            <label>기간</label>
            <div class="form-row">
              <div class="col">
                <input type="datetime-local" id="eventStart" class="form-control" required>
              </div>
              <div class="col">
                <input type="datetime-local" id="eventEnd" class="form-control">
              </div>
            </div>
            
          </div>
          <div class="form-group">
            <label for="loc">장소</label>
            <input type="text" id="loc" class="form-control">
          </div>
          <div class="form-group">
            <label for="eventMemo">메모</label>
            <textarea id="eventMemo" class="form-control" rows="3"></textarea>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" id="btnDelete" class="btn btn-outline-danger d-none">삭제</button>
        <button type="button" id="btnSave" class="btn btn-primary">저장</button>
      </div>
    </div>
  </div>
</div>

<script>
(function() {
    const TOPBAR_H = 70;

    // 폼 기본 제출 방지(Enter로 인한 GET 405 예방)
    $('#eventForm').on('submit', function(e){ e.preventDefault(); return false; });

    const calendarEl = document.getElementById('calendar');
    const calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'ko',
        timeZone: 'local',
        height: '100%',            
        contentHeight: 'auto',
        expandRows: true,

        // 주/일 뷰 UX
        nowIndicator: true,
        slotMinTime: '06:00:00',
        slotMaxTime: '23:00:00',
        scrollTime: '09:00:00',

        // 공휴일(구글 캘린더)
        googleCalendarApiKey: 'AIzaSyDRDmUug03H1acKAGbAQEBGNSaoPE4MPk0',
        eventSources: [
            {
                googleCalendarId: 'ko.south_korea#holiday@group.v.calendar.google.com',
                color: '#ff6b6b',
                textColor: '#ffffff'
            }
        ],
        initialView: 'dayGridMonth',
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
        },
        buttonText: {
            today: '오늘',
            month: '월',
            week: '주',
            day: '일',
            list: '목록'   // listWeek 버튼에 사용됨
          },

        // List 뷰에서 상세 표시
        eventContent: function(arg) {
            if (!arg.view.type.startsWith('list')) return;
            const ev = arg.event;
            const ex = ev.extendedProps || {};
            const start = formatDateTime(ev.start);
            const end   = ev.end ? formatDateTime(ev.end) : '';
            const detail = ex.detail ? escapeHtml(ex.detail) : '';
            const loc    = ex.loc ? escapeHtml(ex.loc) : '';

            const root = document.createElement('div');
            root.className = 'fc-list-custom';
            root.innerHTML =
                '<div class="fc-list-title font-weight-bold">' + escapeHtml(ev.title) + '</div>' +
                '<div class="fc-list-meta text-muted" style="font-size:12px;">' +
                    (start ? start : '') + (end ? ' ~ ' + end : '') +
                '</div>' +
                (detail ? '<div class="fc-list-detail" style="margin-top:2px;">메모: ' + detail + '</div>' : '') +
                (loc ?    '<div class="fc-list-loc text-muted" style="font-size:12px;">장소: ' + loc + '</div>' : '');

            return { domNodes: [root] };
        },

        windowResize: function() { adjustCalendarHeight(); },

        selectable: true,
        selectMirror: true,
        select: function(info) {
            openModal({
                id: '',
                title: '',
                type: 'MY',
                start: info.startStr,
                end: info.endStr,
                loc: '',
                memo: ''
            });
        },

        eventClick: function(info) {
            const ev = info.event;
            openModal({
                id: ev.id,
                title: ev.title,
                type: ev.extendedProps.type,
                start: ev.start,
                end: ev.end,
                loc: ev.extendedProps.loc || '',
                memo: ev.extendedProps.detail || ''
            }, true);
        },

        // 서버에서 JSON 로드
        events: function(fetchInfo, successCallback, failureCallback) {
            const types = $('.fc-filter:checked').map(function(){return $(this).data('type');}).get();
            const keyword = $('#q').val() || '';
            
            // 내 일정 체크박스에 체크를 해제했을 경우
            if (!types.includes('MY')) {
                successCallback([]);          // 개인 일정은 비워서 반환
                return;                       // 서버 호출 자체를 생략
            }

            $.ajax({
                url: '<%= ctxPath %>/schedule/events',
                type: 'GET',
                dataType: 'json',
                data: {
                    start: fetchInfo.startStr,
                    end:   fetchInfo.endStr,
                    types: types.join(','),
                }
            }).done(function(list){
                const events = list.map(function(e){
                    const colorMap = { 'MY':'#2d87f3', 'DEPT':'#28a745', 'COMP':'#6f42c1' };
                    return {
                        id: e.id,
                        title: e.title,
                        start: e.start,
                        end: e.end,
                        backgroundColor: colorMap[e.type] || '#2d87f3',
                        borderColor: colorMap[e.type] || '#2d87f3',
                        extendedProps: {
                            type: e.type,
                            detail: e.detail,
                            loc: e.loc
                        }
                    };
                });
                successCallback(events);
            }).fail(function(xhr){
            	  if (xhr.status === 401) {
            		    alert('로그인이 필요합니다.');
            		    location.href = '<%= ctxPath %>/login/loginStart';
            		    return;
            		  }
            		  console.error(xhr.responseText || xhr.statusText);
            		  failureCallback(xhr);
          		});
        }
    });

    calendar.render();
    adjustCalendarHeight();

    // ===== 유틸 =====
    function pad(n){ return n < 10 ? '0'+n : ''+n; }
    function formatDateTime(d){
        const dt = (d instanceof Date) ? d : new Date(d);
        return dt.getFullYear() + '-' + pad(dt.getMonth()+1) + '-' + pad(dt.getDate())
            + ' ' + pad(dt.getHours()) + ':' + pad(dt.getMinutes());
    }
    function escapeHtml(s){
        return String(s).replace(/[&<>"']/g, function(m){
            return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]);
        });
    }

    // ===== 버튼/검색/필터 =====
    $('input[name="view"]').on('change', function(){ calendar.changeView(this.value); });
    $('#btnSearch').on('click', function(){ calendar.refetchEvents(); });
    $('#q').on('keypress', function(e){ if(e.which === 13) calendar.refetchEvents(); });
    $('.fc-filter').on('change', function(){ calendar.refetchEvents(); });
    $('#btnCreate').on('click', function(){
        openModal({ id:'', title:'', type:'MY', start:new Date(), end:'', loc:'', memo:'' });
    });

    // ===== 모달 핸들러 =====
    function openModal(data, isEdit) {
        $('#eventId').val(data.id || '');
        $('#eventTitle').val(data.title || '');
        $('#eventType').val(data.type || 'MY');
        setDateTimeLocal('#eventStart', data.start);
        setDateTimeLocal('#eventEnd', data.end);
        $('#eventMemo').val(data.memo || '');
        $('#loc').val(data.loc || '');
        $('#btnDelete').toggleClass('d-none', !isEdit);
        $('#eventModalLabel').text(isEdit ? '일정 수정' : '일정 등록');
        $('#eventModal').modal('show');
    }
    function setDateTimeLocal(selector, value) {
        if(!value) { $(selector).val(''); return; }
        const d = (value instanceof Date) ? value : new Date(value);
        const local = new Date(d.getTime() - (d.getTimezoneOffset()*60000));
        $(selector).val(local.toISOString().slice(0,16));
    }

    // 일정 등록 모달에서 '저장'
    $('#btnSave').on('click', function(){
        const $btn = $(this).prop('disabled', true);
        const id = $('#eventId').val();
        const isUpdate = !!id; // id 값을 불리언(Boolean)으로 바꾸는 것이다. 값이 있으면 true, 없으면 false
        const payload = {
            id: id || null,
            title: $('#eventTitle').val().trim(),
            type: $('#eventType').val(),
            start: $('#eventStart').val(),
            end: $('#eventEnd').val() || null,
            loc: $('#loc').val() || '',
            memo: $('#eventMemo').val()
        };

        const title = payload.title;
        if (!title) {
            alert('제목을 입력하세요.');
            $('#eventTitle').focus();
            return $btn.prop('disabled', false);
        }

        const start = payload.start;
        const end   = $('#eventEnd').val();
        if (end && new Date(start) > new Date(end)) {
            alert('종료일시는 시작일시 이후여야 합니다.');
            $('#eventEnd').focus();
            return $btn.prop('disabled', false);
        }

        $.ajax({
            url: '<%= ctxPath %>/schedule/save',
            type: 'POST',
            contentType: 'application/json; charset=UTF-8',
            data: JSON.stringify(payload),
            dataType: 'json'
        }).done(function(res){
        	alert(isUpdate ? '일정 수정이 완료되었습니다.' : '일정 등록이 완료되었습니다.');
            $('#eventModal').modal('hide');
            calendar.refetchEvents();
        }).fail(function(xhr){
            alert('저장 실패: ' + (xhr.responseText || xhr.statusText));
        }).always(function(){
            $btn.prop('disabled', false);
        });
    });// $('#btnSave').on('click', function(){})----------------------------
    
    
	// 일정 삭제
    $('#btnDelete').on('click', function(){
        const id = $('#eventId').val();
        if(!id) return;
        if(!confirm('삭제하시겠습니까?')) return;

        $.ajax({
            url: '<%= ctxPath %>/schedule/delete/' + encodeURIComponent(id),
            type: 'DELETE',
            dataType: 'json'
        }).done(function(res){
            $('#eventModal').modal('hide');
            calendar.refetchEvents();
        }).fail(function(xhr){
            alert('삭제 실패: ' + (xhr.responseText || xhr.statusText));
        });
    });
    
    
 // ===== 검색결과 Ajax =====
    function doSearchList() {
      const keyword = ($('#q').val() || '').trim();
      if (!keyword) {
        // 키워드 없으면 패널 접고 종료
        $('#searchPanel').hide();
        $('#searchList').empty();
        $('#searchCount').text('(0)');
        return;
      }

      $.ajax({
        url: '<%= ctxPath %>/schedule/search',
        type: 'GET',
        dataType: 'json',
        data: {
          q: keyword,
          limit: 100  // 필요 시 조정
          // from: '2025-01-01', to: '2025-12-31' 처럼 기간 파라미터도 보낼 수 있음
        }
      }).done(function(items){
        renderSearchList(items || []);
      }).fail(function(xhr){
        if (xhr.status === 401) {
          alert('로그인이 필요합니다.');
          location.href = '<%= ctxPath %>/login/loginStart';
          return;
        }
        alert('검색 실패: ' + (xhr.responseText || xhr.statusText));
      });
    }

    function renderSearchList(items) {
    	  const $list = $('#searchList').empty();
    	  $('#searchCount').text('(' + items.length + ')');
    	  $('#searchPanel').toggle(items.length > 0);

    	  if (!items.length) return;

    	  items.forEach(function(it){
    	    const startStr = it.start ? it.start.replace('T', ' ').substring(0,16) : '';
    	    const endStr   = it.end   ? it.end.replace('T', ' ').substring(0,16)   : '';

    	    var html = ''
    	      + '<li class="list-group-item list-group-item-action" style="cursor:pointer;">'
    	      +   '<div class="d-flex justify-content-between">'
    	      +     '<div class="font-weight-bold">' + escapeHtml(it.title || '') + '</div>'
    	      +     '<small class="text-muted">' + escapeHtml(it.loc || '') + '</small>'
    	      +   '</div>'
    	      +   '<div class="text-muted">' + startStr + (endStr ? ' ~ ' + endStr : '') + '</div>';

    	    if (it.detail) {
    	      html += '<div class="mt-1">메모: ' + escapeHtml(it.detail) + '</div>';
    	    }

    	    html += '</li>';

    	    const $li = $(html);

    	    // 날짜 이동 + 모달 열기
    	    $li.on('click', function(){
    	      if (it.start) {
    	        calendar.gotoDate(it.start);
    	      }
    	    });
    	    $list.append($li);
    	  });
    	}
    

    // 검색 버튼/엔터 → 리스트 검색
    $('#btnSearch').off('click').on('click', doSearchList);
    $('#q').off('keypress').on('keypress', function(e){
      if (e.which === 13) doSearchList();
    });
    // 검색 초기화
    $('#btnSearchClear').on('click', function(){
      $('#q').val('');
      doSearchList(); // 빈값이면 내부에서 패널 숨김
    });
    
  
    // ===== 레이아웃 보정 =====
    function adjustCalendarHeight() {
        const h = window.innerHeight - TOPBAR_H;
        $('#calendarWrapper').css('height', h + 'px');
    }
    $('#mycontent').addClass('schedule-page-active');

})();
</script>