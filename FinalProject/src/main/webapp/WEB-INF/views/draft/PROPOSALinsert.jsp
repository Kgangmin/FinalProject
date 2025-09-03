<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>    

<%
    String ctxPath = request.getContextPath();
%>

<script>
$(function(){

  /* ========== 공통 유틸 ========== */
  if (typeof window.debounce !== 'function') {
    window.debounce = function(fn, wait){ var t; return function(){ var c=this,a=arguments; clearTimeout(t); t=setTimeout(function(){ fn.apply(c,a); }, wait||200); }; };
  }

  /* ===== 포털 레이어 보조 함수: body에 붙이고 위치 재계산 ===== */
  function ensureLayer($input){
    var $layer = $input.data('ac-layer');
    if(!$layer || !$layer.length){
      $layer = $('<div class="ac-layer" style="position:absolute; z-index:99999; display:none; max-height:280px; overflow:auto;"></div>').appendTo('body');
      $input.data('ac-layer', $layer);
    }
    return $layer;
  }
  function placeLayer($input){
    var $layer = ensureLayer($input);
    var r = $input[0].getBoundingClientRect();
    $layer.css({
      top:  window.scrollY + r.bottom,
      left: window.scrollX + r.left,
      width: r.width
    }).data('for', $input);
    return $layer;
  }

  /* ====== 스크롤/리사이즈 시 위치 재계산 (캡처 모드로 모든 조상 스크롤 감지) ====== */
  (function mountReposition(){
    function recalc(){
      $('.ac-layer:visible').each(function(){
        var $inp = $(this).data('for');
        if ($inp && $inp.length) placeLayer($inp);
      });
    }
    window.addEventListener('scroll', recalc, true);
    window.addEventListener('resize', recalc);
  })();

  // 직원/부서 렌더러
  function renderEmp($layer, list){
    if(!Array.isArray(list)||!list.length){ $layer.html('<div class="ac-empty">검색 결과가 없습니다.</div>').show(); return; }
    var h=''; for(var i=0;i<list.length;i++){ var e=list[i], r=(e.dept_name||'')+(e.rank_name?(' / '+e.rank_name):'');
      h+='<div class="ac-item" data-id="'+(e.emp_no||'')+'" data-label="'+(e.emp_name||'')+'">'
       +  '<div><strong>'+(e.emp_name||'')+'</strong></div><div class="ac-sub">'+r+'</div></div>';
    } $layer.html(h).show();
  }
  function renderDept($layer, list){
    if(!Array.isArray(list)||!list.length){ $layer.html('<div class="ac-empty">검색 결과가 없습니다.</div>').show(); return; }
    var h=''; for(var i=0;i<list.length;i++){ var e=list[i], sub=(e.parent_name||e.org_name||'');
      h+='<div class="ac-item" data-id="'+(e.dept_no||'')+'" data-label="'+(e.dept_name||'')+'">'
       +  '<div><strong>'+(e.dept_name||'')+'</strong></div>'+(sub?'<div class="ac-sub">'+sub+'</div>':'')+'</div>';
    } $layer.html(h).show();
  }

  /* ========== 제출 유효성 ========== */
  $('button[name="button_submit"]').off('click.proposal').on('click.proposal', function(){
    if($('input[name="draft_title"]').val().trim().length < 1){ alert('제목은 한글자 이상 입력해야합니다'); return false; }
    var ok=false; $('.ef-approver-id').each(function(){ if($.trim($(this).val())!=='') ok=true; });
    if(!ok){ alert('결재자를 최소 1명 이상 선택하세요.'); $('.ef-approver-name').eq(0).focus(); return false; }
    if($('textarea[name="background"]').val().trim().length < 1){ alert('추진 배경을 입력하세요(1자 이상).'); return false; }
    if($('textarea[name="proposal_content"]').val().trim().length < 1){ alert('제안 내용을 입력하세요(1자 이상).'); return false; }
    if($('textarea[name="expected_effect"]').val().trim().length < 1){ alert('기대 효과를 입력하세요(1자 이상).'); return false; }
    if($('input[name="task_title"]').length && $('input[name="task_title"]').val().trim().length < 1){ alert('과업 제목을 입력하세요.'); $('input[name="task_title"]').focus(); return false; }
    var s=$('input[name="start_date"]').val(), e2=$('input[name="end_date"]').val();
    if(($('input[name="start_date"]').length||$('input[name="end_date"]').length) && (!s||!e2)){ alert('과업 기간(시작/종료일)을 입력하세요.'); return false; }
    if(s&&e2&&new Date(s)>new Date(e2)){ alert('종료일은 시작일보다 같거나 이후여야 합니다.'); return false; }
    if($('input[name="fk_owner_emp_no"]').length && $('input[name="fk_owner_emp_no"]').val().trim().length < 1){ alert('과업 담당자를 선택하세요.'); $('#ownerName').focus(); return false; }
    var c=0; $('#tblDept tbody select.dept-role').each(function(){ if($(this).val()==='주관') c++; }); if(c<1){ alert('주관 부서는 최소 1개 있어야 합니다.'); $('#tblDept select.dept-role').first().focus(); return false; }

    // ===== 내부 중복 검사(교차 중복은 허용) =====
    // 관련 부서 내부 중복(부서)
    var seenDeptDept={}, dup=false;
    $('#tblDept .dept-no').each(function(){
      var v=$.trim($(this).val()); if(!v) return;
      if(seenDeptDept[v]){ dup=true; return false; }
      seenDeptDept[v]=true;
    });
    if(dup){ alert('관련 부서에 동일 부서가 중복되었습니다.'); return false; }

    // 접근 권한 내부 중복(부서/사원 각각)
    var seenDeptAcc={}, seenEmpAcc={}, dupAcc=false;
    $('#tblAccess tbody tr').each(function(){
      var t=$(this).find('.acc-type').val();
      var v=$.trim($(this).find('.acc-target-no').val()); if(!v) return;
      if(t==='dept'){ if(seenDeptAcc[v]){ dupAcc=true; return false; } seenDeptAcc[v]=true; }
      if(t==='emp'){  if(seenEmpAcc[v]) { dupAcc=true; return false; } seenEmpAcc[v]=true; }
    });
    if(dupAcc){ alert('접근 권한에서 동일 대상이 중복되었습니다.'); return false; }

    // 접근 권한: 이름만 입력하고 선택 안 한 경우
    var bad=false; $('#tblAccess tbody tr').each(function(){
      if($(this).find('.acc-target-name').val().trim() && !$(this).find('.acc-target-no').val().trim()){
        alert('공유 대상을 검색해 목록에서 선택해 주세요.'); $(this).find('.acc-target-name').focus(); bad=true; return false;
      }
    }); if(bad) return false;

    document.DocsForm.submit();
  });

  /* ========== 관련 부서 (추가/역할/삭제) ========== */
  $('#btnAddDept').off('click.proposal').on('click.proposal', function(){
    $('#tblDept tbody').append(
      '<tr>'
      + '<td><input type="text" class="ef-input dept-name" placeholder="부서명 검색 후 선택"><input type="hidden" name="dept_no[]" class="dept-no"></td>'
      + '<td><select name="task_dept_role[]" class="ef-input dept-role"><option value="주관">주관</option><option value="협력" selected>협력</option></select></td>'
      + '<td class="txt-right"><button type="button" class="ef-btn ef-btn-ghost btnDelRow">삭제</button></td>'
      + '</tr>'
    );
  });
  $(document).off('change.proposal', '#tblDept tbody select.dept-role')
             .on('change.proposal',  '#tblDept tbody select.dept-role', function(){
               if($(this).val()==='협력'){ setTimeout(function(){ var c=0; $('#tblDept tbody select.dept-role').each(function(){ if($(this).val()==='주관') c++; }); if(c===0){ alert('주관 부서는 최소 1개 있어야 합니다.'); $('#tblDept tbody select.dept-role').first().val('주관'); } },0); }
             });
  $(document).off('click.proposal', '#tblDept .btnDelRow')
             .on('click.proposal',  '#tblDept .btnDelRow', function(){
               if($(this).closest('tr').data('fixed-main')===true){ alert('기본 주관 부서는 삭제할 수 없습니다.'); return; }
               if($(this).closest('tr').find('select.dept-role').val()==='주관'){
                 var c=0; $('#tblDept tbody select.dept-role').each(function(){ if($(this).val()==='주관') c++; }); if(c<=1){ alert('주관 부서는 최소 1개 있어야 합니다.'); return; }
               }
               $(this).closest('tr').remove();
             });

  /* ========== 관련 부서 오토컴플리트(부서) ========== */
  $(document).off('input.deptac focus.deptac', '#tblDept .dept-name')
    .on('input.deptac', '#tblDept .dept-name', debounce(function(){
      if($(this).data('picking')) return;
      var q=$.trim($(this).val()); if(!q){ ensureLayer($(this)).hide(); return; }
      var xhr=$(this).data('xhr'); if(xhr && xhr.readyState!==4){ try{xhr.abort();}catch(e){} }
      placeLayer($(this)).html('<div class="ac-empty">검색 중…</div>').show();
      xhr=$.ajax({
        url: '<%=ctxPath%>/draft/deptquick', type:'GET', data:{q:q}, dataType:'json', cache:false
      }).done((list)=>{ renderDept(ensureLayer($(this)), Array.isArray(list)?list:[]); })
        .fail((_x,s)=>{ if(s!=='abort') ensureLayer($(this)).html('<div class="ac-empty">검색 오류</div>').show(); });
      $(this).data('xhr', xhr);
    },200))
    .on('focus.deptac', '#tblDept .dept-name', function(){ if($.trim($(this).val())) $(this).trigger('input'); });

  /* ========== 접근 권한: 행 추가/삭제/타입 변경 ========== */
  $('#btnAddAccess').off('click.proposal').on('click.proposal', function(){
    $('#tblAccess tbody').append(
      '<tr>'
      + '  <td><select name="target_type[]" class="ef-input acc-type"><option value="dept">부서</option><option value="emp">사원</option></select></td>'
      + '  <td><input type="text" class="ef-input acc-target-name" placeholder="부서명 검색 후 선택"><input type="hidden" name="target_no[]" class="acc-target-no"></td>'
      + '  <td class="txt-right"><button type="button" class="ef-btn ef-btn-ghost btnDelAccess">삭제</button></td>'
      + '</tr>'
    );
  });
  $(document).off('click.proposal', '#tblAccess .btnDelAccess')
             .on('click.proposal',  '#tblAccess .btnDelAccess', function(){
               if($('#tblAccess tbody tr').length<=1){ alert('접근 권한은 최소 1행이 필요합니다.'); return; }
               $(this).closest('tr').remove();
             });
  $(document).off('change.proposal', '#tblAccess .acc-type')
             .on('change.proposal',  '#tblAccess .acc-type', function(){
               $(this).closest('tr').find('.acc-target-name').val('')
                                     .attr('placeholder', $(this).val()==='emp' ? '사원 검색 후 선택' : '부서명 검색 후 선택');
               $(this).closest('tr').find('.acc-target-no').val('');
               var $inp = $(this).closest('tr').find('.acc-target-name');
               if($inp.length) ensureLayer($inp).hide().empty();
             });

  /* ========== Owner 오토컴플리트 ========== */
  if($('#ownerName').length){
    if($('input[name="fk_owner_emp_no"]').val().trim()==='' && '${emp.emp_no}') { $('input[name="fk_owner_emp_no"]').val('${emp.emp_no}'); if(!$('#ownerName').val().trim()) $('#ownerName').val('${emp.emp_name}'); }

    $('#ownerName').off('input.proposal focus.proposal')
      .on('input.proposal', debounce(function(){
        if($('#ownerName').data('picking')) return;
        var q=$.trim($('#ownerName').val()); if(!q){ ensureLayer($('#ownerName')).hide(); return; }
        var xhr=$('#ownerName').data('xhr'); if(xhr && xhr.readyState!==4){ try{xhr.abort();}catch(e){} }
        placeLayer($('#ownerName')).html('<div class="ac-empty">검색 중…</div>').show();
        xhr=$.ajax({ url:'<%=ctxPath%>/draft/quick', type:'GET', data:{q:q}, dataType:'json', cache:false })
          .done(function(list){ renderEmp(ensureLayer($('#ownerName')), Array.isArray(list)?list:[]); })
          .fail(function(_x,s){ if(s!=='abort') ensureLayer($('#ownerName')).html('<div class="ac-empty">검색 오류</div>').show(); });
        $('#ownerName').data('xhr', xhr);
      },200))
      .on('focus.proposal', function(){ if($.trim($('#ownerName').val())) $('#ownerName').trigger('input'); });
  }

  /* ========== 접근 권한 오토컴플리트(행별) ========== */
  $(document).off('input.proposal focus.proposal', '#tblAccess .acc-target-name')
    .on('input.proposal', '#tblAccess .acc-target-name', debounce(function(){
      var q=$.trim($(this).val()); if(!q){ ensureLayer($(this)).hide(); return; }
      var mode=$(this).closest('tr').find('.acc-type').val();
      var xhr=$(this).data('xhr'); if(xhr && xhr.readyState!==4){ try{xhr.abort();}catch(e){} }
      placeLayer($(this)).html('<div class="ac-empty">검색 중…</div>').show();
      xhr=$.ajax({
        url: (mode==='emp'? '<%=ctxPath%>/draft/quick' : '<%=ctxPath%>/draft/deptquick'),
        type:'GET', data:{q:q}, dataType:'json', cache:false
      }).done((list)=>{ (mode==='emp'?renderEmp:renderDept)(ensureLayer($(this)), Array.isArray(list)?list:[]); })
        .fail((_x,s)=>{ if(s!=='abort') ensureLayer($(this)).html('<div class="ac-empty">검색 오류</div>').show(); });
      $(this).data('xhr', xhr);
    },200))
    .on('focus.proposal', '#tblAccess .acc-target-name', function(){ if($.trim($(this).val())) $(this).trigger('input'); });

  /* ========== 공통: 아이템 선택 / 외부 클릭 닫기 / 스크롤 위치 보정 / 키보드 ========== */
  // 기존 핸들러 교체(중복 검사 포함)
  $(document).off('mousedown.proposal', '.ac-layer .ac-item')
    .on('mousedown.proposal', '.ac-layer .ac-item', function(e){
      e.preventDefault(); e.stopPropagation();
      var $layer=$(this).closest('.ac-layer');
      var $inp=$layer.data('for'); if(!$inp||!$inp.length) return;
      var id=$(this).data('id')||'', label=$(this).data('label')||'';

      // 선택 컨텍스트에 따른 주입 + 내부 중복 차단
      if($inp.closest('#tblDept').length){
        // 관련 부서: 내부 중복 차단
        var duplicated=false;
        $('#tblDept .dept-no').each(function(){
          if($(this).closest('tr')[0] === $inp.closest('tr')[0]) return;
          if($.trim($(this).val()) === id){ duplicated=true; return false; }
        });
        if(duplicated){ alert('관련 부서에 이미 같은 부서가 있습니다.'); return; }
        $inp.data('picking', true).val(label);
        $inp.closest('td').find('.dept-no').val(id);
        $layer.hide(); setTimeout(function(){ $inp.removeData('picking'); },0);
        return;
      }

      if($inp.closest('#tblAccess').length){
        var $row = $inp.closest('tr');
        var t = $row.find('.acc-type').val();

        if(t==='dept'){
          // 접근 권한(부서): 내부 중복 차단
          var dupDept=false;
          $('#tblAccess tbody tr').each(function(){
            if(this === $row[0]) return;
            if($(this).find('.acc-type').val()!=='dept') return;
            if($.trim($(this).find('.acc-target-no').val()) === id){ dupDept=true; return false; }
          });
          if(dupDept){ alert('접근 권한(부서)에 이미 같은 부서가 있습니다.'); return; }
        } else { // emp
          // 접근 권한(사원): 내부 중복 차단
          var dupEmp=false;
          $('#tblAccess tbody tr').each(function(){
            if(this === $row[0]) return;
            if($(this).find('.acc-type').val()!=='emp') return;
            if($.trim($(this).find('.acc-target-no').val()) === id){ dupEmp=true; return false; }
          });
          if(dupEmp){ alert('접근 권한(사원)에 이미 같은 사람이 있습니다.'); return; }
        }

        $inp.data('picking', true).val(label);
        $row.find('.acc-target-no').val(id);
        $layer.hide(); setTimeout(function(){ $inp.removeData('picking'); },0);
        return;
      }

      if($inp.is('#ownerName')){
        $inp.data('picking', true).val(label);
        $('input[name="fk_owner_emp_no"]').val(id);
        $layer.hide(); setTimeout(function(){ $inp.removeData('picking'); },0);
        return;
      }
    });

  $(document).off('mousedown.proposal.outside').on('mousedown.proposal.outside', function(e){
    if($(e.target).closest('.ac-layer').length===0 && $(e.target).closest('.ac-wrap').length===0){ $('.ac-layer').hide(); }
  });

  $(window).off('scroll.proposal resize.proposal').on('scroll.proposal resize.proposal', function(){
    $('.ac-layer:visible').each(function(){
      var $inp=$(this).data('for'); if($inp&&$inp.length) placeLayer($inp);
    });
  });

  $(document).off('keydown.proposal', '.ac-wrap input[type="text"], #ownerName, #tblAccess .acc-target-name, #tblDept .dept-name')
    .on('keydown.proposal', '.ac-wrap input[type="text"], #ownerName, #tblAccess .acc-target-name, #tblDept .dept-name', function(e){
      var $layer = ensureLayer($(this)); if(!$layer.is(':visible')) return;
      var $items = $layer.find('.ac-item'); if(!$items.length) return;
      var $cur = $items.filter('.is-active'); var idx = $items.index($cur);
      if(e.key==='ArrowDown'){ idx=(idx+1)%$items.length; $items.removeClass('is-active').eq(idx).addClass('is-active'); e.preventDefault(); }
      if(e.key==='ArrowUp'){   idx=(idx<=0?$items.length:idx)-1; $items.removeClass('is-active').eq(idx).addClass('is-active'); e.preventDefault(); }
      if(e.key==='Enter'){ if(idx>=0){ $items.eq(idx).trigger('mousedown'); e.preventDefault(); } }
      if(e.key==='Escape'){ $layer.hide(); }
    });

});
</script>




<!-- ===== 업무기안서 화면용 폼 ===== -->
<div class="proposal-form doc-form">
  <div class="ef-grid">
    <div class="ef-main">

      <!-- 문서 메타 -->
      <section class="ef-card">
        <div class="ef-card-title">문서 정보</div>
        <div class="ef-form-grid ef-2col">
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">용도(제목)</span>
            <input type="text" class="ef-input" name="draft_title" placeholder="예) 신규 프로젝트 추진 기안">
            <input type="hidden" name="fk_draft_emp_no" value="${emp.emp_no}">
            <input type="hidden" name="draft_type" value="${draft_type}">
          </label>
        </div>
      </section>

      <!-- 결재선(공통) -->
      <section class="ef-card">
        <div class="ef-card-title">결재라인</div>
        <div class="ef-approvals">
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 1</span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
              <input type="hidden" class="ef-approver-id" name="approvalLine_id">
            </label>
          </div>
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 2 <small>(선택)</small></span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 /부서 / 직급 입력 후 목록에서 선택">
              <input type="hidden" class="ef-approver-id" name="approvalLine_id">
            </label>
          </div>
          <div class="ef-approval-item">
            <label class="ef-field ef-colspan-2">
              <span class="ef-label">결재자 3 <small>(선택)</small></span>
              <input type="text" class="ef-input ef-approver-name"
                     name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
              <input type="hidden" class="ef-approver-id" name="approvalLine_id">
            </label>
          </div>
        </div>
      </section>

      <!-- 기본정보(공통) -->
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

      <!-- 업무기안 내용 -->
      <section class="ef-card">
        <div class="ef-card-title">업무기안 내용</div>
        <div class="ef-form-grid ef-2col">
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">배경</span>
            <textarea class="ef-input" name="background" rows="3" placeholder="해당 기안이 필요한 배경을 입력하세요."></textarea>
          </label>
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">제안 내용</span>
            <textarea class="ef-input" name="proposal_content" rows="5" placeholder="구체적인 제안 내용을 입력하세요."></textarea>
          </label>
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">기대 효과</span>
            <textarea class="ef-input" name="expected_effect" rows="5" placeholder="업무기안 실행 시 예상되는 효과를 입력하세요."></textarea>
          </label>
        </div>
      </section>
	  <section class="ef-card">
	    <div class="ef-card-title">과업 설정</div>
	    <div class="ef-form-grid ef-2col">
	      <label class="ef-field ef-colspan-2">
	        <span class="ef-label">과업 제목</span>
	        <input type="text" class="ef-input" name="task_title" placeholder="예) 신규 프로젝트 PoC 수행">
	      </label>
	      <label class="ef-field">
	        <span class="ef-label">시작일</span>
	        <input type="date" class="ef-input date" name="start_date" id="start_date">
	      </label>
	      <label class="ef-field">
	        <span class="ef-label">종료일</span>
	        <input type="date" class="ef-input date" name="end_date" id="end_date">
	      </label>
	      <label class="ef-field">
	        <span class="ef-label">담당자(Owner)</span>
	        <input type="text" id="ownerName" class="ef-input" placeholder="담당자 이름 검색 후 선택(기본: 기안자)">
	        <input type="hidden" id="fkOwnerEmpNo" name="fk_owner_emp_no">
	      </label>
	    </div>
	    <small class="ef-help">담당자는 기본적으로 기안자로 세팅됩니다. 필요 시 검색/변경하세요.</small>
	  </section>
      <section class="ef-card">
        <div class="ef-card-title-wrap">
          <div class="ef-card-title">접근 권한(공유 대상)</div>
          <div class="ef-right">
            <button type="button" class="ef-btn ef-btn-ghost" id="btnAddAccess">+ 대상 추가</button>
          </div>
        </div>

        <div class="ef-table-wrap">
          <table class="ef-table" id="tblAccess">
            <thead>
              <tr>
                <th style="width:140px">대상 유형</th>
                <th>대상</th>
                <th style="width:90px"></th>
              </tr>
            </thead>
            <tbody>
              <!-- 기본 1행: 마지막 1행은 삭제 불가 -->
              <tr>
                <td>
                  <select name="target_type[]" class="ef-input acc-type">
                    <option value="dept">부서</option>
                    <option value="emp">사원</option>
                  </select>
                </td>
                <td>
                  <input type="text" class="ef-input acc-target-name" placeholder="대상 검색 후 선택">
                  <input type="hidden" name="target_no[]" class="acc-target-no">
                </td>
                <td class="txt-right">
                  <button type="button" class="ef-btn ef-btn-ghost btnDelAccess">삭제</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <small class="ef-help">부서/사원 단위로 열람 권한을 줄 수 있습니다. 최소 1행은 유지됩니다.</small>
      </section>
      <!-- ✅ 추가 섹션 2: 관련 부서(주관/협력) → tbl_proposal_department -->
      <section class="ef-card">
        <div class="ef-card-title-wrap">
          <div class="ef-card-title">관련 부서</div>
          <div class="ef-right">
            <button type="button" class="ef-btn ef-btn-ghost" id="btnAddDept">+ 부서 추가</button>
          </div>
        </div>

        <div class="ef-table-wrap">
          <table class="ef-table" id="tblDept">
            <thead>
              <tr>
                <th>부서</th>
                <th style="width:120px">역할</th>
                <th style="width:90px"></th>
              </tr>
            </thead>
            <tbody>
              <!-- 기본 1행(주관) : 삭제 불가 -->
              <tr data-fixed-main="true">
                <td>
                  <input type="text" class="ef-input dept-name" placeholder="부서명 검색 후 선택">
                  <input type="hidden" name="dept_no[]" class="dept-no">
                </td>
                <td>
                  <select name="task_dept_role[]" class="ef-input dept-role">
                    <option value="주관" selected>주관</option>
                    <option value="협력">협력</option>
                  </select>
                </td>
                <td class="txt-right">
                  <button type="button" class="ef-btn ef-btn-ghost btnDelRow" disabled title="주관 부서는 최소 1개 필요합니다.">삭제</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <small class="ef-help">주관/협력 부서를 지정하세요. 주관 부서는 최소 1개가 유지되어야 합니다.</small>
      </section>

      <!-- 첨부파일 -->
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
