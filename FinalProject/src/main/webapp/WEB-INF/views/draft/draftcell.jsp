<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!-- 상세 전용 CSS (list.jsp와 동일 레이아웃 변수/클래스 사용) -->
<link rel="stylesheet" href="<%= ctxPath %>/css/draftdetail.css" />
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

	$('button[name="button_submit"]').on('click', function(){
		 
		$('#expenseForm').trigger('submit'); 
	});
});

</script>

<form id="expenseForm" name="expenseForm" action="<%= ctxPath %>/draft/expense" method="post" enctype="multipart/form-data">
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
		      내가 신청한 결제의 상세페이지입니다 내용을 수정하거나 확인 할수 있습니다
		    </div>
		  </div>
		
		  <!-- 오른쪽 버튼 -->
		  <div class="page-actions">
		    <!-- 폼 안에 있으니 type=submit 으로 저장/수정 전송 -->
		    <button type="button" class="btn-action primary" name="button_submit">수정</button>
		    <!-- 목록으로 이동 -->
		    <a href="<%=ctxPath%>/draft/list" class="btn-action secondary">목록</a>
		  </div>
		</div>
	    <!-- 상세 본문 카드: 내부는 기존 내용 유지 -->
	    <div class="detail-section card shadow-sm p-4">
	     <jsp:include page="/WEB-INF/views/draft/${draft_type}.jsp" />
	    </div>
	  </main>
	</div>
</form>
<jsp:include page="/WEB-INF/views/footer/footer.jsp" />

