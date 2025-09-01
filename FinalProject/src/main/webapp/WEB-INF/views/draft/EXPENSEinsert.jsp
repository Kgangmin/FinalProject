<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>
<script type="text/javascript">

$(function(){
	// 1) 행들 전체를 0..N-1로 재인덱싱
	function reindexItems(){
	  $('#tblItems tbody tr').each(function(i){
	    $(this).find('input[name^="items["], select[name^="items["], textarea[name^="items["]').each(function(){
	      // items[무엇이든] 을 items[i] 로 치환 (빈칸도 포함시키기 위해 \d* 사용)
	      this.name = this.name.replace(/items\[\d*\]/, 'items[' + i + ']');
	    });
	  });
	}

	// 2) 행 추가 시: 먼저 재인덱싱 -> 다음 인덱스 = 현재 행 수
	$('#btnAddRow').off('click').on('click', function(){
	  reindexItems();
	  const idx = $('#tblItems tbody tr').length;

	  const html = `
	    <tr>
	      <td>
	      <input type="date" class="ef-input" name="items[\${idx}].expense_date">
	      </td>
	      <td><input type="text" class="ef-input" name="items[\${idx}].payee_name" placeholder="거래처명"></td>
	      <td>
	        <select class="ef-input" name="items[\${idx}].payee_type">
	          <option>개인</option><option>법인</option><option>협력사</option><option>기타</option>
	        </select>
	      </td>
	      <td><input type="text" class="ef-input" name="items[\${idx}].expense_desc" placeholder="지출내역 설명"></td>
	      <td><input type="text" class="ef-input" name="items[\${idx}].payee_bank" placeholder="은행명"></td>
	      <td class="ta-right"><input type="text" class="ef-input" name="items[\${idx}].payee_account" placeholder="계좌번호"></td>
	      <td>
	        <select class="ef-input" name="items[\${idx}].expense_type">
	          <option>교통비</option><option>식대</option><option>출장비</option><option>소모품비</option><option>기타</option>
	        </select>
	      </td>
	      <td class="ta-right">
	        <div class="ef-amount-cell">
	          <input type="text" class="ef-input ef-money js-amount" name="items[\${idx}].expense_amount" placeholder="0">
	        </div>
	      </td>
	      <td class="col-del ta-center">
	        <button type="button" class="ef-icon-btn js-del-row" aria-label="행 삭제">삭제</button>
	      </td>
	    </tr>`;
	  $('#tblItems tbody').append(html);
	});

	// 3) 행 삭제 시 재인덱싱
	$('#tblItems tbody').off('click', '.js-del-row').on('click', '.js-del-row', function(){
	  $(this).closest('tr').remove();
	  reindexItems();
	});
	// 4) 폼 제출 직전에 한 번 더 재인덱싱 (마지막 안전망) 
	$('#expenseForm').off('submit').on('submit', function(){ 
		reindexItems(); 
	});

  	function parseAmount(v) {
	   	 if (v == null) return NaN;
	    	return Number(String(v).replace(/[^\d.-]/g, ''));
	  	}

	  // 완전히 비어있는 행인지 체크
	  function isRowBlank($tr) {
	    var $date   = $tr.find('input[name$=".expense_date"]');
	    var $name   = $tr.find('input[name$=".payee_name"]');
	    var $ptype  = $tr.find('select[name$=".payee_type"]');
	    var $desc   = $tr.find('input[name$=".expense_desc"]');
	    var $bank   = $tr.find('input[name$=".payee_bank"]');
	    var $acct   = $tr.find('input[name$=".payee_account"]');
	    var $etype  = $tr.find('select[name$=".expense_type"]');
	    var $amount = $tr.find('input[name$=".expense_amount"]');

	    var vals = [
	      $.trim($date.val()  || ''),
	      $.trim($name.val()  || ''),
	      $.trim($ptype.val() || ''),
	      $.trim($desc.val()  || ''),
	      $.trim($bank.val()  || ''),
	      $.trim($acct.val()  || ''),
	      $.trim($etype.val() || ''),
	      $.trim($amount.val()|| '')
	    ];
	    return vals.every(function(v){ return v === ''; });
	  }

	  // 한 행 검증(존재하면 전 필수)
	  function validateRow($tr, idx) {
	    function req($el, msg) {
	      if (!$.trim($el.val() || '')) {
	        alert((idx + 1) + '행: ' + msg);
	        $el.focus();
	        return false;
	      }
	      return true;
	    }

	    var $date   = $tr.find('input[name$=".expense_date"]');
	    var $name   = $tr.find('input[name$=".payee_name"]');
	    var $ptype  = $tr.find('select[name$=".payee_type"]');
	    var $desc   = $tr.find('input[name$=".expense_desc"]');
	    var $bank   = $tr.find('input[name$=".payee_bank"]');
	    var $acct   = $tr.find('input[name$=".payee_account"]');
	    var $etype  = $tr.find('select[name$=".expense_type"]');
	    var $amount = $tr.find('input[name$=".expense_amount"]');

	    if (!req($date,  '지출예정일을 입력하세요')) return false;
	    if (!req($name,  '거래처를 입력하세요'))     return false;
	    if (!req($ptype, '대상유형을 선택하세요'))   return false;
	    if (!req($desc,  '지출내역을 입력하세요'))   return false;
	    if (!req($bank,  '은행명을 입력하세요'))     return false;
	    if (!req($acct,  '계좌번호를 입력하세요'))   return false;
	    if (!req($etype, '지출유형을 선택하세요'))   return false;
	    
	    var amt = parseAmount($amount.val());
	    if (!Number.isFinite(amt) || amt <= 0) {
	      alert((idx+1) + '행: 지출금액은 0보다 큰 숫자여야 합니다');
	      $amount.focus();
	      return false;
	    }
	    return true;
	  }

	  // 전체 검증
	  function validateExpenseAll() {
	    var $rows = $('#tblItems tbody tr');
	    if ($rows.length === 0) {
	      alert('지출내역 1행은 필수입니다.');
	      return false;
	    }

	    var ok = true;
	    $rows.each(function (i) {
	      var $tr = $(this);

	      if (isRowBlank($tr)) {
	        alert((i + 1) + '행이 비어 있습니다. 행을 삭제하거나 모든 칸을 입력하세요.');
	        $tr.find('input,select').first().focus();
	        ok = false;
	        return false; // break
	      }

	      if (!validateRow($tr, i)) {
	        ok = false;
	        return false; // break
	      }
	    });

	    return ok;
	  }

	  // 제출 버튼
	 $('button[name="button_submit"]').on("click", function(e){ 

	    // 1) 제목
	    var $title = $('input[name="draft.draft_title"]');
	    if ($.trim($title.val()).length < 1) {
	      alert("제목은 한글자 이상 입력해야합니다");
	      $title.focus();
	      return;
	    }

	    // 2) 결재자 최소 1명
	    var hasApprover = false;
	    $(".ef-approver-id").each(function(){
	      if ($.trim($(this).val()) !== "") {
	        hasApprover = true;
	        return false; // break
	      }
	    });
	    if (!hasApprover) {
	      alert("결재자를 최소 1명 이상 선택하세요.");
	      $(".ef-approver-name").eq(0).focus();
	      return;
	    }

	    // 3) 지출내역 검증
	    if (!validateExpenseAll()) return;

	    // 4) 제출
	    
	    document.DocsForm.submit();
	  });
	
  	
});

</script>

<!-- ===== 지출결의서 신청 폼(fragment) ===== -->
<div class="expense-form doc-form">
  <div class="ef-grid">
    <div class="ef-main">

      <!-- 문서 메타 (업무기안 구조 동일) -->
      <section class="ef-card">
        <div class="ef-card-title">문서 정보</div>
        <div class="ef-form-grid ef-2col">
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">용도(제목)</span>
            <input type="text" class="ef-input" name="draft.draft_title" placeholder="예) 팀 회의 다과 구입비">
            <input type="hidden" name="draft.fk_draft_emp_no" value="${emp.emp_no}">
            <input type="hidden" name="draft.draft_type" value="${draft_type}">
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
              <span class="ef-label">결재자 2 <small>(선택)</small></span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
            </label>
          </div>
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 3 <small>(선택)</small></span>
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

      <!-- 지출내역 (신청용: 빈 테이블 + 행 추가) -->
      <section class="ef-card">
        <div class="ef-card-title-wrap">
          <div class="ef-card-title">지출내역</div>
          <div class="ef-right">
            <button type="button" class="ef-btn ef-btn-ghost" id="btnAddRow">+ 항목 추가</button>
          </div>
        </div>

        <div class="ef-table-wrap">
          <table class="ef-table" id="tblItems">
            <thead style="text-align:center;">
              <tr>
                <th>지출예정일</th>
                <th>거래처</th>
                <th style="width:120px;">대상유형</th>
                <th style="width:300px;">지출내역설명</th>
                <th>은행명</th>
                <th>대상계좌</th>
                <th style="width:120px;">지출유형</th>
                <th>지출금액</th>
                <th style="width:67px;"></th>
              </tr>
            </thead>
            <tbody>
              <!-- 최초 1행 기본 제공 -->
              <tr>
                <td>
                  <input type="date" class="ef-input" name="items[0].expense_date">
                </td>
                <td>
                  <input type="text" class="ef-input" name="items[0].payee_name" placeholder="예: ㈜ABC상사">
                </td>
                <td>
                  <select class="ef-input" name="items[0].payee_type">
                  	<option value="">선택</option>
                    <option value="개인">개인</option>
                    <option value="법인">법인</option>
                    <option value="협력사">협력사</option>
                    <option value="기타">기타</option>
                  </select>
                </td>
                <td>
                  <input type="text" class="ef-input" name="items[0].expense_desc" placeholder="예: 회의 다과 구입">
                </td>
                <td>
                  <input type="text" class="ef-input" name="items[0].payee_bank" placeholder="예: 우리은행">
                </td>
                <td class="ta-right">
                  <input type="text" class="ef-input" name="items[0].payee_account" placeholder="예: 1002-***-****">
                </td>
                <td>
                  <select class="ef-input" name="items[0].expense_type">
                    <option value="교통비">교통비</option>
                    <option value="식대">식대</option>
                    <option value="출장비">출장비</option>
                    <option value="소모품비">소모품비</option>
                    <option value="기타">기타</option>
                  </select>
                </td>
                <td class="ta-right">
                  <div class="ef-amount-cell">
                    <input type="text" class="ef-input ef-money js-amount" name="items[0].expense_amount" placeholder="0">
                  </div>
                </td>
                <td class="col-del ta-center">
                  <button type="button" class="ef-icon-btn js-del-row" aria-label="행 삭제">삭제</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- 첨부파일 (업무기안과 동일 껍데기) -->
      <section class="ef-card">
        <div class="ef-card-title">첨부파일</div>
        <div class="ef-filebox">
          <input type="file" id="efFiles" name="files" class="ef-input" multiple>
        </div>
        <small class="ef-help">영수증/세금계산서 이미지 또는 PDF 업로드</small>
      </section>

    </div>
  </div>
</div>
