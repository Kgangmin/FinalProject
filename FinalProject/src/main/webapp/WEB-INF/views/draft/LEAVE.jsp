<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String ctxPath = request.getContextPath();
%>
<!-- 날짜/일수 계산 스크립트 -->
<script>
$(function(){

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




(function(){
  function parseYMD(s){
    if(!s) return null;
    const [y,m,d] = s.split('-').map(Number);
    if(!y||!m||!d) return null;
    return new Date(y, m-1, d);
  }

  function businessDaysInclusive(start, end, excludeWeekend){
    if(!start || !end) return 0;
    if(end < start) return 0;

    // 기본: 달력일(포함계산)
    if(!excludeWeekend){
      const diff = (end - start) / (1000*60*60*24);
      return diff + 1; // inclusive
    }

    // 주말 제외 (토/일 제외)
    let count = 0;
    const cur = new Date(start.getFullYear(), start.getMonth(), start.getDate());
    const last = new Date(end.getFullYear(), end.getMonth(), end.getDate());
    while(cur <= last){
      const day = cur.getDay(); // 0:일, 6:토
      if(day !== 0 && day !== 6) count++;
      cur.setDate(cur.getDate() + 1);
    }
    return count;
  }

  const $start = document.getElementById('leaveStart');
  const $end   = document.getElementById('leaveEnd');
  const $days  = document.getElementById('leaveDays');
  const $chkWk = document.getElementById('chkExcludeWeekend');

  function syncMinEnd(){
    if($start && $start.value){
      $end && ($end.min = $start.value);
    }
  }

  function recalc(){
    const s = parseYMD($start?.value);
    const e = parseYMD($end?.value);
    const excludeWeekend = !!$chkWk?.checked;
    const n = businessDaysInclusive(s, e, excludeWeekend);
    if($days){
      $days.value = n || 0;
    }
  }

  [$start, $end, $chkWk].forEach(el=>{
    el && el.addEventListener('change', ()=>{ syncMinEnd(); recalc(); });
    el && el.addEventListener('input',  ()=>{ syncMinEnd(); recalc(); });
  });

  // 초기 계산
  syncMinEnd();
  recalc();
})();
</script>
<!-- ===== 여기부터 '휴가신청서 화면용 폼'(leave-form) ===== -->
<div class="leave-form doc-form">
  <!-- 본문 그리드 -->
  <div class="ef-grid">
    <!-- 좌측: 입력 섹션 -->
    <div class="ef-main">

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
              <c:if test="${not empty line.approval_comment}">
                <div class="ef-approval-comment-inline">${line.approval_comment}</div>
              </c:if>
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
            <input class="ef-input" name="drafterName" value="${draft.emp_name}" readonly="readonly">
          </label>
          <label class="ef-field">
            <span class="ef-label">부서</span>
            <input class="ef-input" name="drafterDept" value="${draft.dept_name}" readonly="readonly">
          </label>
          <label class="ef-field">
            <span class="ef-label">연락처</span>
            <input class="ef-input" name="contact" value="${draft.phone_num}" readonly="readonly">
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
          <label class="ef-field">
            <span class="ef-label">휴가유형</span>
            <select class="ef-input" name="leave.fk_leave_type_no" id="leaveType">
              <c:forEach var="t" items="${Leave_type}">
                <option value="${t.leave_type_no}"
                  ${Leave.fk_leave_type_no == t.leave_type_no ? 'selected' : ''}>
                  ${t.leave_type_name}
                </option>
              </c:forEach>
            </select>
          </label>
  		  <!-- 휴가일수 (자동 계산, 수정 필요 시 readonly 제거) -->
          <label class="ef-field">
            <span class="ef-label">휴가일수</span>
            <input type="number" class="ef-input" id="leaveDays"
                   name="leave.leave_days"
                   value="${Leave.leave_days}"
                   min="0" step="0.5" readonly="readonly" />
          </label>
          <!-- 시작일 -->
          <label class="ef-field">
            <span class="ef-label">시작일</span>
            <input type="date" class="ef-input" id="leaveStart"
                   name="leave.start_date"
                   value="${fn:substring(Leave.start_date,0,10)}" />
          </label>

          <!-- 종료일 -->
          <label class="ef-field">
            <span class="ef-label">종료일</span>
            <input type="date" class="ef-input" id="leaveEnd"
                   name="leave.end_date"
                   value="${fn:substring(Leave.end_date,0,10)}" />
          </label>

      

          <!-- 비고 -->
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">비고</span>
            <textarea class="ef-input" name="leave.leave_remark"
                      rows="3" placeholder="사유 등 메모를 입력하세요.">${Leave.leave_remark}</textarea>
          </label>
        </div>
       
      </section>

      <!-- 첨부파일 섹션은 공통 껍데기에서 그대로 사용 -->
		<section class="ef-card">
			  <div class="ef-card-title">첨부파일</div>
			
			  <div class="ef-filebox">
			    <input type="file" id="efFiles" name="files" class="ef-input" multiple>
			    <div id="delFilesBox"></div>
			    <div id="efFileSelected" class="ef-file-selected">    
					  <ul class="ef-file-list" id="efFileList">
					    <!-- 서버에 이미 저장된 파일 -->
					    <c:forEach var="f" items="${fileList}">
					      <li class="ef-file-item">
					      	<input type="hidden" name="draft_file_no" value="${f.draft_file_no}">
					        <a class="ef-file-link" href="<%=ctxPath%>/draft/file/download?fileNo=${f.draft_file_no}">
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


    