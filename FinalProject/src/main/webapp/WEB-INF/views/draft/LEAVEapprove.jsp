
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
  
  $('button[name="button_submit"]').on('click', function(){
		 
		$('#DocsForm').trigger('submit'); 
	});
  
//(한 줄설명) 기존 첨부파일: 삭제 버튼 클릭 시 li 제거 + deleteFileNos hidden 추가.
$('#efFileList').on('click', '.js-del-file', function(){
  const $li = $(this).parents('.ef-file-item');
  // li의 data-file-no 또는 내부 hidden(draft_file_no)에서 번호를 찾는다.
  const del_draft_file_no = $li.find('input[name="draft_file_no"]').val();
  
 
  $li.remove();
  const $box = $('#delFilesBox');
  
  $('<input>', { type:'hidden', name:'del_draft_file_no', value:del_draft_file_no }).appendTo($box);
  
  if ($('#efFileList .ef-file-item').length === 0) {
      $('#efFileList').append('<li class="ef-file-item text-muted js-empty">첨부파일 없음</li>');
    }
  });
 
});
</script>





<!-- ===== 여기부터 '휴가신청서 화면용 폼'(leave-form) ===== -->
<div class="leave-form doc-form">
  <!-- 본문 그리드 -->
  <div class="ef-grid">
    <!-- 좌측: 입력 섹션 -->
    <div class="ef-main">
	  	<!-- 문서 메타 -->
		<section class="ef-card">
	         <div class="ef-card-title">문서 정보</div>
	         <div class="ef-form-grid ef-2col">
	           <label class="ef-field">
	             <span class="ef-label">문서번호</span>
	             <input type="text" class="ef-input" name="draft.draft_no" value="${draft.draft_no}" placeholder="자동생성 또는 수기 입력" readonly="readonly">
	           </label>
	           <label class="ef-field">
	             <span class="ef-label">기안일</span>
	             <input type="date" class="ef-input" name="draft.draft_date" value="${fn:substring(draft.draft_date, 0, 10)}" readonly="readonly">
	           </label>
	           <label class="ef-field ef-colspan-2">
	             <span class="ef-label">용도(제목)</span>
	             <input type="text" class="ef-input" name="draft.draft_title" value="${draft.draft_title}" placeholder="예) 팀 회의 다과 구입비" readonly="readonly">
	           </label>
	         </div>
	      </section>
	      <!-- 결재선(공통) -->
	      <section class="ef-card">
	        <div class="ef-card-title">결재라인</div>
	        <div class="ef-approvals">
	          <c:forEach var="line" items="${approvalLine}" varStatus="st">
	            <div class="ef-approval-item">
	              <label class="ef-field ef-colspan-2">
	                <span class="ef-label">결재자 ${st.index + 1}</span>
	                <input type="text" class="ef-input ef-approver-name"
	                       name="approvalLine_name" value="${line.emp_name}" readonly="readonly">
	              </label>
	              <span class="status-badge ${line.approval_status eq '승인' ? 'status-approve' :
	                                         (line.approval_status eq '반려' ? 'status-reject' : 'status-wait')}">
	                ${line.approval_status}
	              </span>
	              	<c:set var="isMyLine" value="${line.fk_approval_emp_no == loginEmp.emp_no}" />
					<c:set var="isPending" value="${empty line.approval_status or line.approval_status eq '대기'}" />
					<c:set var="isMyTurn" value="${line.approval_order == nextOrder}" />
						
					  <c:choose>
					  <c:when test="${isMyLine and isPending and isMyTurn}">
						  <form id="ApproveForm_${st.index}" class="ef-approve-row">
						    <input type="hidden" name="draft_no" value="${draft.draft_no}">
						    <input type="hidden" name="approval_line_no" value="${line.approval_line_no}">
						    <input type="hidden" name="approver_emp_no" value="${loginEmp.emp_no}">
						    <input type="hidden" name="draft_type" value="${draft.draft_type}">
						    <input type="hidden" name="approval_status" value="">
						    <div class="ef-comment-col ef-field">
						      <span class="ef-label">결재 의견</span>
						      <textarea class="ef-approval-comment-textarea" name="approval_comment" placeholder="결재 의견을 입력하세요.">${line.approval_comment}</textarea>
						    </div>
						    <div class="ef-actions-col">
						      <button type="button" class="ef-btn ef-btn-approve" data-form="ApproveForm_${st.index}" data-result="승인">승인</button>
						      <button type="button" class="ef-btn ef-btn-reject"  data-form="ApproveForm_${st.index}" data-result="반려">반려</button>
						    </div>
						  </form>
						</c:when>
						<c:otherwise>
							<c:if test="${not empty line.approval_comment}">
							    <div class="ef-approval-comment-inline">${line.approval_comment}</div>
							</c:if>
						</c:otherwise>
					  </c:choose>
	            </div>
	          </c:forEach>
	        </div>
	      </section>

	      <!-- 기본정보(공통) -->
	      <section class="ef-card">
	        <div class="ef-card-title">기본정보</div>
	        <div class="ef-form-grid ef-2col">
	          <label class="ef-field">
	            <span class="ef-label">기안자</span>
	            <input class="ef-input" name="draft.emp_name" value="${draft.emp_name}" readonly="readonly">
	            <input type="hidden" class="ef-input" name="fk_draft_emp_no" value="${draft.fk_draft_emp_no}" readonly="readonly">
	          </label>
	          <label class="ef-field">
	            <span class="ef-label">부서</span>
	            <input class="ef-input" name="draft.dept_name" value="${draft.dept_name}" readonly="readonly">
	          </label>
	          <label class="ef-field">
	            <span class="ef-label">연락처</span>
	            <input class="ef-input" name="draft.phone_num" value="${draft.phone_num}" readonly="readonly">
	          </label>
	        </div>
	      </section>

      <!-- 휴가 정보 -->
	      <section class="ef-card">
	        <div class="ef-card-title">휴가 정보</div>
	
	        <!-- FK_DRAFT_NO는 서버에서도 알지만, 안전하게 함께 전송 -->
	        <input type="hidden" name="leave.fk_draft_no" value="${draft.draft_no}"/>
	
	        <div class="ef-form-grid ef-2col">
	          <!-- 휴가유형 -->
	          <label class="ef-field ">
	            <span class="ef-label">휴가유형</span>
	            <select class="ef-input" name="leave.Fk_leave_type_no" id="leaveType" disabled="disabled">
	              <c:forEach var="t" items="${Leave_type}">
	                <option value="${t.leave_type_no}"
	                  ${Leave.fk_leave_type_no == t.leave_type_no ? 'selected' : ''}>
	                  ${t.leave_type_name}
	                </option>
	              </c:forEach>
	            </select>
	            <input type="hidden" name="fk_leave_type_no" value="${Leave.fk_leave_type_no}">
	          </label>
	  		  <!-- 휴가일수 (자동 계산, 수정 필요 시 readonly 제거) -->
	          <label class="ef-field ">
	            <span class="ef-label">휴가일수</span>
	            <input type="number" class="ef-input" id="leaveDays"
	                   name="leave_days"
	                   
	                   min="0" step="0.5" readonly="readonly" />
	          </label>
	        <fmt:formatDate value="${Leave.start_date}" pattern="yyyy-MM-dd" var="startD"/>
			<fmt:formatDate value="${Leave.start_date}" pattern="HH"        var="startH"/>
	        <label class="ef-field ">
				
				<span class="ef-label  ">시작 일시</span>
				<!-- 날짜 -->
				<input type="date" id="startDate" class="ef-input" value="${startD != null ? startD : ''}" readonly="readonly"/>
				
				<!-- 시작 시간: 09시 / 14시만 -->
				<select id="startHour" class="ef-input" disabled="disabled">
				  <option value="09" ${startH == '09' ? 'selected' : ''}>09시</option>
				  <option value="14" ${startH == '14' ? 'selected' : ''}>14시</option>
				</select>
				
				<!-- 서버로 보낼 실제 ISO 값 -->
				<input type="hidden" name="start_date" id="startHidden"/>
			</label>
				
			<fmt:formatDate value="${Leave.end_date}" pattern="yyyy-MM-dd" var="endD"/>
			<fmt:formatDate value="${Leave.end_date}" pattern="HH"        var="endH"/>
				<!-- 휴가 종료일시 -->
			<label class="ef-field ">
				   <span class="ef-label ef-inline">종료 일시</span>
	
				  <!-- 날짜 -->
				  <input type="date" class="ef-input" id="endDate"
				         value="${endD != null ? endD : ''}" readonly="readonly"/>
				
				  <!-- 시간: 13시 / 18시만 -->
				  <select id="endHour" class="ef-input" disabled="disabled">
				    <option value="13" ${endH == '13' ? 'selected' : ''}>13시</option>
				    <option value="18" ${endH == '18' ? 'selected' : ''}>18시</option>
				  </select>
				
				  <!-- 서버로 보낼 실제 값 -->
				  <input type="hidden" name="end_date" id="endHidden"/>
			</label>
	
	      
	
	          <!-- 비고 -->
	          <label class="ef-field ef-colspan-2">
	            <span class="ef-label">비고</span>
	            <textarea class="ef-input" name="leave_remark"
	                      rows="3" placeholder="사유 등 메모를 입력하세요." readonly="readonly">${Leave.leave_remark}</textarea>
	          </label>
	        </div>
	       
	      </section>
	
	      <!-- 첨부파일 섹션은 공통 껍데기에서 그대로 사용 -->
			<section class="ef-card">
				  <div class="ef-card-title">첨부파일</div>
				
				  <div class="ef-filebox">
				    <div id="efFileSelected" class="ef-file-selected">    
						  <ul class="ef-file-list" id="efFileList">
						    <!-- 서버에 이미 저장된 파일 -->
						    <c:forEach var="f" items="${fileList}">
						      <li class="ef-file-item">
						      	<input type="hidden" name="draft_file_no" value="${f.draft_file_no}">
						        <a class="ef-file-link" href="<%=ctxPath%>/draft/file/download?draft_file_no=${f.draft_file_no}">
						          <span class="ef-file-name">${f.draft_origin_filename}</span>
						          <span class="ef-file-size"><fmt:formatNumber value="${f.draft_filesize/1024}" pattern="#,##0"/> KB</span>
						        </a>
						        <!-- 삭제 버튼 추가 -->
	     						<button type="button" class="ef-icon-btn js-del-file" aria-label="첨부 삭제" style="height: 30px; " >X</button>
						      </li>
						    </c:forEach>
						
						    <c:if test="${empty fileList}">
						      <li class="ef-file-item text-muted">첨부파일 없음</li>
						    </c:if>
						  </ul>
				    </div>
				  </div>
				
				  <small class="ef-help">영수증/세금계산서 이미지 또는 PDF 업로드</small>
					
					  
			 </section>
    </div>
  </div>
</div>
<!-- ===== 휴가신청서 폼 끝 ===== -->


    