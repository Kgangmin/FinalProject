<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String ctxPath = request.getContextPath();
%>
<meta name="google-api-key" content="${googleApiKey}">

<script>
$(function () {
  // --- 설정/상태 ---
  var GOOGLE_API_KEY = (document.querySelector('meta[name="google-api-key"]') || {}).content || '';
  var HOL_CAL_ID = 'ko.south_korea#holiday@group.v.calendar.google.com';
  var holidays = new Set();       // 'YYYY-MM-DD'
  var loadedYears = new Set();

  // --- 유틸 ---
  function fmtYMDLocal(d) {
    var y = d.getFullYear();
    var m = ('0' + (d.getMonth() + 1)).slice(-2);
    var da = ('0' + d.getDate()).slice(-2);
    return y + '-' + m + '-' + da;
  }
  function isWeekday(d) { var w = d.getDay(); return w !== 0 && w !== 6; }

  // --- 공휴일 로드(연도) ---
  async function loadHolidaysForYear(year) {
    if (loadedYears.has(year)) return;
    if (!GOOGLE_API_KEY) { console.warn('[Holiday] GOOGLE_API_KEY empty'); return; }

    // UTC ISO 사용 (JSP-EL 피하려고 문자열 더하기만 사용)
    var timeMin = new Date(Date.UTC(year, 0, 1, 0, 0, 0)).toISOString();
    var timeMax = new Date(Date.UTC(year + 1, 0, 1, 0, 0, 0)).toISOString();

    var base = 'https://www.googleapis.com/calendar/v3/calendars/'
             + encodeURIComponent(HOL_CAL_ID)
             + '/events';

    var params = new URLSearchParams({
      singleEvents: 'true',
      orderBy: 'startTime',
      timeMin: timeMin,
      timeMax: timeMax,
      maxResults: '2500',
      key: GOOGLE_API_KEY
    }).toString();

    var url = base + '?' + params;

    // 디버그
    //console.log('[Holiday] key.len =', (GOOGLE_API_KEY || '').length);
    //console.log('[Holiday] url =', url);

    try {
      var res = await fetch(url);
      if (!res.ok) {
        var txt = await res.text();
        console.error('[Holiday] API error', res.status, txt);
        return; // 실패 시에도 페이지 동작은 계속 (주말만 제외하여 계산)
      }
      var data = await res.json();
      (data.items || []).forEach(function(ev){
        if (ev && ev.start && ev.start.date) {
          holidays.add(ev.start.date); // 종일 이벤트
        } else if (ev && ev.start && ev.start.dateTime) {
          holidays.add(fmtYMDLocal(new Date(ev.start.dateTime)));
        }
      });
      loadedYears.add(year);
      //console.log('[Holiday] loaded year', year, 'total=', holidays.size);
    } catch (e) {
      console.error('[Holiday] fetch failed', e);
    }
  }

  // --- 기간에 걸친 연도 공휴일 ensure ---
  async function ensureHolidaysBetween(sdStr, edStr) {
    if (!sdStr || !edStr) return;
    var sYear = parseInt(sdStr.slice(0,4), 10);
    var eYear = parseInt(edStr.slice(0,4), 10);
    var jobs = [];
    for (var y = sYear; y <= eYear; y++) jobs.push(loadHolidaysForYear(y));
    await Promise.all(jobs);
  }

  // --- hidden 값/제약 ---
  function syncMinEndDate() {
    var sd = $('#startDate').val();
    if (sd) $('#endDate').attr('min', sd);
    else $('#endDate').removeAttr('min');
  }
  function enforceHourRule() {
    var sd = $('#startDate').val();
    var ed = $('#endDate').val();
    var sh = $('#startHour').val();
    var $endHour = $('#endHour');
    var $opt13 = $endHour.find('option[value="13"]');
    if (sd && ed && sd === ed && sh === '14') {
      $opt13.prop('disabled', true);
      if ($endHour.val() === '13') $endHour.val('18');
    } else {
      $opt13.prop('disabled', false);
    }
  }
  function syncHidden() {
    var sd = $('#startDate').val();
    var sh = $('#startHour').val();
    var ed = $('#endDate').val();
    var eh = $('#endHour').val();
    // 템플릿리터럴 금지 -> 문자열 더하기
    $('#startHidden').val(sd && sh ? (sd + 'T' + sh + ':00') : '');
    $('#endHidden').val(ed && eh ? (ed + 'T' + eh + ':00') : '');
  }
  function syncAll() { syncMinEndDate(); enforceHourRule(); syncHidden(); }

  // --- 휴가일수 계산 ---
  async function computeLeaveDays() {
    var sd = $('#startDate').val();
    var sh = $('#startHour').val();
    var ed = $('#endDate').val();
    var eh = $('#endHour').val();
    if (!sd || !sh || !ed || !eh) { $('#leaveDays').val(0); return; }

    await ensureHolidaysBetween(sd, ed);

    var sDate = new Date(sd + 'T00:00:00');
    var eDate = new Date(ed + 'T00:00:00');
    if (eDate < sDate) { $('#leaveDays').val(0); return; }

    var days = 0;
    var cur = new Date(sDate);
    while (cur <= eDate) {
      var ymd = fmtYMDLocal(cur);
      var isHoliday = holidays.size > 0 ? holidays.has(ymd) : false; // 실패시 공휴일 미적용
      if (isWeekday(cur) && !isHoliday) days++;
      cur.setDate(cur.getDate() + 1);
    }

    var slots = days * 2;
    var sHoliday = holidays.size > 0 ? holidays.has(fmtYMDLocal(sDate)) : false;
    var eHoliday = holidays.size > 0 ? holidays.has(fmtYMDLocal(eDate)) : false;

    if (isWeekday(sDate) && !sHoliday && sh === '14') slots -= 1;  // 시작이 오후면 -0.5
    if (isWeekday(eDate) && !eHoliday && eh === '13') slots -= 1;  // 종료가 13시면 -0.5
    if (slots < 0) slots = 0;

    var leaveDays = slots * 0.5;
    // 소수 .0 제거
    var txt = (Math.round(leaveDays * 10) / 10).toString().replace(/\.0$/, '');
    $('#leaveDays').val(txt);
  }

  // --- 이벤트 바인딩 & 초기화 ---
  $('#startDate, #startHour, #endDate, #endHour').on('change input', function () {
    syncAll(); 
    // 비동기 계산 (await 안 걸어도 됨)
    computeLeaveDays();
  });

  // 초기에 올해 공휴일 프리페치 후 1회 계산
  var thisYear = (new Date()).getFullYear();
  loadHolidaysForYear(thisYear).then(function(){
    syncAll();
    computeLeaveDays();
  });  

  
  $('button[name="button_submit"]').on("click", function(e){
  
		if($('input[name="draft_title"]').val().length < 1){
			  alert("제목은 한글자 이상 입력해야합니다");
			  return false;
		}
		var hasApprover = false;
		$(".ef-approver-id").each(function(){
		  if ($.trim($(this).val()) !== "") {
		    hasApprover = true;
		  }
		});
		if (!hasApprover) {
		  alert("결재자를 최소 1명 이상 선택하세요.");
		  $(".ef-approver-name").eq(0).focus();
		  return false;
		}
		
		
		if($('select[name="fk_leave_type_no"]').val() == ""){
			alert("휴가유형을 선택하세요");
			return false;
		}
		if($('input#startDate').val() == ""){
			alert("시작날짜를 선택하세요");
			return false;
		}
		if($('select#startHour').val() == ""){
			alert("시작시간을 선택하세요");
			return false;
		}
		if($('input#endDate').val() == ""){
			alert("종료날자를 선택하세요");
			return false;
		}
		if($('select#endHour').val() == ""){
			alert("종료시간을 선택하세요");
			return false;
		}
		if($('textarea[name="leave_remark"]').val().length < 1){
			alert("비고를 입력하세요");
			return false;
		
		}
		document.DocsForm.submit();
  });
});
</script>

<!-- ===== 휴가신청 폼(fragment) ===== -->
<div class="proposal-form doc-form">
  <div class="ef-grid">
    <div class="ef-main">

      <!-- 문서 메타 (업무기안 구조 동일) -->
      <section class="ef-card">
        <div class="ef-card-title">문서 정보</div>
        <div class="ef-form-grid ef-2col">
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">용도(제목)</span>
            <input type="text" class="ef-input" name="draft_title" placeholder="예) 여름 휴가 신청">
            <input type="hidden" name="fk_draft_emp_no" value="${emp.emp_no}">
            <input type="hidden" name="draft_type" value="${draft_type}">
          </label>
        </div>
      </section>

      <!-- 결재선(업무기안과 동일 구조/네이밍) -->
      <section class="ef-card">
        <div class="ef-card-title">결재라인</div>
        <div class="ef-approvals">
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 1</span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
            </label>
          </div>
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 2&nbsp;<small>(선택)</small></span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
            </label>
          </div>
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 3&nbsp;<small>(선택)</small></span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
            </label>
          </div>
        </div>
      </section>

      <!-- 기본정보(업무기안과 동일) -->
      <section class="ef-card">
        <div class="ef-card-title">기본정보</div>
        <div class="ef-form-grid ef-2col">
          <label class="ef-field">
            <span class="ef-label">기안자</span>
            <input class="ef-input" name="emp_name" value="${emp.emp_name}" readonly="readonly">
          </label>
          <label class="ef-field">
            <span class="ef-label">부서</span>
            <input class="ef-input" name="dept_name" value="${emp.team_name}" readonly="readonly">
          </label>
          <label class="ef-field">
            <span class="ef-label">연락처</span>
            <input class="ef-input" name="phone_num" value="${emp.phone_num}" readonly="readonly">
          </label>
        </div>
      </section>

      <!-- ✅ 여기만 '업무기안 내용' 대신 '휴가신청 정보'로 대체 -->
      <section class="ef-card">
        <div class="ef-card-title">휴가신청 정보</div>
        <div class="ef-form-grid ef-2col">

          <!-- 휴가유형 -->
          <label class="ef-field">
            <span class="ef-label">휴가유형</span>
            <select class="ef-input" name="fk_leave_type_no" id="leaveType">
               <option value="">휴가유형 선택</option>
               <option value="1">연가</option>
               <option value="2">병가</option>
               <option value="3">경조사</option>
            </select>
          </label>

          <!-- 휴가일수(자동계산 대상: readonly, id 유지) -->
          <label class="ef-field">
            <span class="ef-label">휴가일수</span>
            <input type="number" class="ef-input" id="leaveDays"
                   name="leave_days" min="0" step="0.5" readonly="readonly" value="0">
          </label>

          <!-- 시작 일시 -->
          <label class="ef-field">
            <span class="ef-label">시작 일시</span>
            <input type="date" id="startDate" class="ef-input">
            <select id="startHour" class="ef-input">
              <option value="">시간선택</option>
              <option value="09">09시</option>
              <option value="14">14시</option>
            </select>
            <input type="hidden" name="start_date" id="startHidden">
          </label>

          <!-- 종료 일시 -->
          <label class="ef-field">
            <span class="ef-label">종료 일시</span>
            <input type="date" id="endDate" class="ef-input">
            <select id="endHour" class="ef-input">
              <option value="">시간선택</option>
              <option value="13">13시</option>
              <option value="18">18시</option>
            </select>
            <input type="hidden" name="end_date" id="endHidden">
          </label>

          <!-- 비고 -->
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">비고</span>
            <textarea class="ef-input" name="leave_remark" rows="3" placeholder="사유 등 메모를 입력하세요."></textarea>
          </label>
        </div>
      </section>

      <!-- 첨부파일 섹션 (업무기안과 동일 껍데기) -->
      <section class="ef-card">
        <div class="ef-card-title">첨부파일</div>
        <div class="ef-filebox">
          <input type="file" id="efFiles" name="files" class="ef-input" multiple>
        </div>
        <small class="ef-help">관련 자료(PDF, 이미지 등) 업로드</small>
      </section>

    </div>
  </div>
</div>

