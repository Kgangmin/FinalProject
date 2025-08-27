 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!-- 상세 전용 CSS (list.jsp와 동일 레이아웃 변수/클래스 사용) -->
<link rel="stylesheet" href="<%= ctxPath %>/css/draftregister.css" />



<script>
$(function(){
  var CTX = '<%= request.getContextPath() %>';
  var SEARCH_URL = CTX + '/draft/quick';   // GET ?q=... → [{emp_no,emp_name,dept_name,rank_name},...]

  // 디바운스 (간단)
  function debounce(fn, wait){
    var t=null;
    return function(){
      var c=this, a=arguments;
      clearTimeout(t);
      t=setTimeout(function(){ fn.apply(c,a); }, wait||250);
    };
  }

  // 레이어 표시/숨김
  function showLayer($layer){ $layer.show(); }
  function hideLayer($layer){ $layer.hide().empty(); }

  // 렌더링
  function render($layer, list){
    if(!list || !list.length){
      $layer.html('<div class="ac-empty">검색 결과가 없습니다.</div>');
      return showLayer($layer);
    }
    var html = '';
    for(var i=0;i<list.length;i++){
      var e = list[i];
      var right = (e.dept_name||'') + (e.rank_name ? (' / '+e.rank_name) : '');
      html += ''
        + '<div class="ac-item"'
        + ' data-emp-no="'+ (e.emp_no||'') +'"'
        + ' data-name="'+   (e.emp_name||'') +'"'
        + ' data-dept="'+   (e.dept_name||'') +'"'
        + ' data-rank="'+   (e.rank_name||'') +'">'
        +   '<div><strong>'+ (e.emp_name||'') +'</strong></div>'
        +   '<div class="ac-sub">'+ right +'</div>'
        + '</div>';
    }
    $layer.html(html);
    showLayer($layer);
  }

  // 중복 결재자(emp_no)인지 확인
  function isDuplicateEmpNo(targetHidden, empNo){
    var dup = false;
    $('.ef-approver-id').each(function(){
      if (this === targetHidden[0]) return; // 자기 자신 제외
      if ($(this).val() === empNo) { dup = true; return false; }
    });
    return dup;
  }

  // 값 주입(선택 확정)
  function pick($inp, $hidden, $layer, empNo, name){
    // 선택 직후 input 이벤트가 다시 떠서 재검색/재표시되는 것을 막기 위한 플래그
    $inp.data('picking', true);
    $inp.val(name || '');
    $hidden.val(empNo || '');
    hideLayer($layer);
    // 다음 이벤트 루프에서 플래그 해제
    setTimeout(function(){ $inp.removeData('picking'); }, 0);
  }

  // 초기화 (각 결재자 인풋에만 1회)
  function initApproverAC(){
    $('.ef-approver-name').each(function(i){
      var $inp = $(this);

      if ($inp.data('ac-init')) return;        // 중복 초기화 방지
      $inp.data('ac-init', true);

      // placeholder 있으면 세팅(없으면 기본 문구)
      if (!$inp.attr('placeholder')) {
        $inp.attr('placeholder', (i+1)+'차 결재자 이름 또는 부서 입력');
      }
      $inp.attr({'autocomplete':'off','spellcheck':'false'});

      // hidden(emp_no), 래퍼/레이어 구성
      var $hidden = $('<input>', {type:'hidden', name:'approvalLines['+i+'].fk_approval_emp_no', 'class':'ef-approver-id'});
      var $order = $('<input>', { type:'hidden', name:'approvalLines['+i+'].approval_order', value: (i+1)});
      var $wrap   = $('<div class="ac-wrap"></div>');
      var $layer  = $('<div class="ac-layer"></div>');

      $inp.wrap($wrap);
      $inp.after($layer).after($hidden).after($order);

      var xhr = null; // 이 인풋 전용 AJAX 핸들

      // 검색 함수(디바운스)
      var doSearch = debounce(function(){
        if ($inp.data('picking')) return;      // 선택 직후 발생한 input 이벤트 무시
        var q = $.trim($inp.val());
        if (!q){ hideLayer($layer); return; }

        // 진행중이면 취소
        if (xhr && xhr.readyState !== 4) { try{xhr.abort();}catch(e){} }

        $layer.html('<div class="ac-empty">검색 중…</div>').show();

        xhr = $.ajax({
          url: SEARCH_URL,
          type: 'GET',
          data: { q: q },
          dataType: 'json',
          cache: false,
          success: function(list){
            render($layer, Array.isArray(list)?list:[]);
          },
          error: function(_xhr, status){
            if (status === 'abort') return;
            $layer.html('<div class="ac-empty">검색 오류</div>').show();
          }
        });
      }, 200);

      // 타이핑 → 검색 (선택된 emp_no 무효화)
      $inp.on('input', function(){
        if ($inp.data('picking')) return;    // pick()이 넣은 값으로 인한 input 무시
        $hidden.val('');
        doSearch();
      });

      // 항목 클릭(정확히는 mousedown)으로 선택 확정
      $layer.on('mousedown', '.ac-item', function(e){
        e.preventDefault();                  // 포커스 이동/blur 방지
        e.stopPropagation();                 // 문서 바깥클릭 닫기보다 먼저 처리
        var $item = $(this);
        var empNo = String($item.data('emp-no')||'');
        var name  = String($item.data('name')||'');
        if (!empNo) return;

        // 중복 여부 확인
        if (isDuplicateEmpNo($hidden, empNo)) {
          alert('이미 선택된 결재자입니다.');
          hideLayer($layer);
          return;
        }

        // 진행중 요청 취소(늦게 도착한 응답이 레이어를 다시 띄우는 문제 방지)
        if (xhr && xhr.readyState !== 4) { try{xhr.abort();}catch(e){} }

        pick($inp, $hidden, $layer, empNo, name);
      });

      // 래퍼 빈 곳을 누르면 포커스만 주고 아무 것도 안 하도록
      $inp.parent('.ac-wrap').on('mousedown', function(e){
        if (e.target === this) { e.preventDefault(); $inp.focus(); }
      });
    });
  }

  // 문서 바깥 클릭 시 레이어 닫기 (레이어 내부 클릭은 위에서 이미 처리)
  $(document).on('mousedown', function(e){
    if ($(e.target).closest('.ac-wrap').length) return;
    $('.ac-layer').hide().empty();
  });

  // ESC로 닫기(선택)
  $(document).on('keydown', '.ef-approver-name', function(e){
    if (e.key === 'Escape') {
      $(this).siblings('.ac-layer').hide().empty();
    }
  });
 
  $(function(){
	  $('button[name="button_submit"]').on('click', function(){
	    $('#DocsForm').trigger('submit'); 
	  });

	});
  
  // 실행 (조각 JSP가 include되어 렌더 완료된 뒤 한 번만)
  initApproverAC();
  
  // ✅ 여기서 유효성 검사 추가
  $("#DocsForm").on("submit", function(e){
    var $title = $("input[name='draft_title']");
    if($.trim($title.val()) === ""){
      alert("제목을 입력하세요.");
      $title.focus();
      e.preventDefault();
      return false;
    }

    // 최소 1명 결재자 체크
    var hasApprover = false;
    $(".ef-approver-id").each(function(){
      if($.trim($(this).val()) !== ""){
        hasApprover = true;
      }
    });
    if(!hasApprover){
      alert("결재자를 최소 1명 이상 선택하세요.");
      $(".ef-approver-name").eq(0).focus();
      e.preventDefault();
      return false;
    }

    // 내용 체크 (예: 배경 + 제안 내용)
    if($.trim($("textarea[name='background']").val()) === ""){
      alert("배경을 입력하세요.");
      $("textarea[name='background']").focus();
      e.preventDefault();
      return false;
    }

    
    if($.trim($("textarea[name='proposal_content']").val()).length < 1){
      alert("제안 내용은 최소 1자 이상 입력하세요.");
      $("textarea[name='proposal_content']").focus();
      e.preventDefault();
      return false;
    }
    
    if($.trim($("textarea[name='expected_effect']").val()).length < 1){
        alert("기대 효과는 최소 1자 이상 입력하세요.");
        $("textarea[name='expected_effect']").focus();
        e.preventDefault();
        return false;
      }
  });
  
});
</script>








<form id="DocsForm" name="DocsForm" action="<%= ctxPath %>/draft/${draft_type}/insert" method="post" enctype="multipart/form-data">
	<div class="container-fluid">
	  <!-- 2차 사이드바 -->
	  <jsp:include page="/WEB-INF/views/draft/draftSidebar.jsp" />
	
	  <!-- 본문 -->
	  <main class="main-with-sub p-4">
	 <div class="page-head mb-3 page-head--with-actions">
		  <div class="page-head-left">
		    <h4 class="font-weight-bold mb-1">${draft_type=='EXPENSE' ? '지출결의서' :
	                                           draft_type=='PROPOSAL' ? '업무기안서' :
	                                           draft_type=='LEAVE' ? '휴가신청서' : '' }</h4>
		    <div class="text-muted small">
		      결제 신청 페이지입니다 내용을 작성하고 등록 할수 있습니다
		    </div>
		  </div>
		
		  <!-- 오른쪽 버튼 -->
		  <div class="page-actions">
		    <!-- 폼 안에 있으니 type=submit 으로 저장/수정 전송 -->
		    <button type="button" class="btn-action primary" name="button_submit">저장</button>
		    <!-- 목록으로 이동 -->
		    <a href="<%=ctxPath%>/draft/list" class="btn-action secondary">취소</a>
		  </div>
		</div>
	    <!-- 상세 본문 카드: 내부는 기존 내용 유지 -->
	    <div class="detail-section card shadow-sm p-4">
	     <jsp:include page="/WEB-INF/views/draft/${draft_type}insert.jsp" />
	    </div>
	  </main>
	</div>
</form>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />

