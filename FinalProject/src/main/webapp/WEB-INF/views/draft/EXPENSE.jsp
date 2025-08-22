<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!-- 상세 전용 CSS (list.jsp와 동일 레이아웃 변수/클래스 사용) -->

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



<!-- ===== 여기부터 '지출결의서 화면용 폼'(expense-form) ===== -->
	      <div class="expense-form doc-form">
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
	                  <input type="text" class="ef-input" name="draft.draft_title" value="${draft.draft_title}" placeholder="예) 팀 회의 다과 구입비" >
	                </label>
	              </div>
	            </section>
	
	            <!-- 결재선(간단 입력형) -->
	            <section class="ef-card">
				  <div class="ef-card-title">결재라인</div>
				  <div class="ef-approvals">
				
				    <c:forEach var="line" items="${approvalLine}" varStatus="st">
					  <div class="ef-approval-item">
					    <!-- 이름 -->
						<label class="ef-field ef-colspan-2">   
							<span class="ef-label">결제자${st.index +1} </span> 
						    <input type="text" class="ef-input ef-approver-name"
						           name="approvalLine_name"	
						           value="${line.emp_name}" readonly="readonly">
						</label>
					    <!-- 상태 뱃지 -->
					    <span class="status-badge ${line.approval_status eq '승인' ? 'status-approve' :
					                               (line.approval_status eq '반려' ? 'status-reject' : 'status-wait')}">
					      ${line.approval_status}
					    </span>
					
					    <!-- 코멘트 -->
					    <c:if test="${not empty line.approval_comment}">
					      <div class="ef-approval-comment-inline">${line.approval_comment}</div>
					    </c:if>
					  </div>
					</c:forEach>
				
				  </div>
				</section>
	
	            <!-- 기본정보 -->
	            <section class="ef-card">
	              <div class="ef-card-title">기본정보</div>
	              <div class="ef-form-grid ef-2col">
	                <label class="ef-field">
	                  <span class="ef-label">기안자</span>
	                  <input class="ef-input" name="drafterName" value="${draft.emp_name}" placeholder="홍길동" readonly="readonly">
	                </label>
	                <label class="ef-field">
	                  <span class="ef-label">부서</span>
	                  <input class="ef-input" name="drafterDept" value="${draft.dept_name}" placeholder="경영지원팀" readonly="readonly">
	                </label>
	                <label class="ef-field">
	                  <span class="ef-label">연락처</span>
	                  <input class="ef-input" name="contact" value="${draft.phone_num}" placeholder="010-0000-0000" readonly="readonly">
	                </label>
	            
	              </div>
	            </section>
	
	            <!-- 지출내역 테이블 -->
	            <section class="ef-card">
	              <div class="ef-card-title-wrap">
	                <div class="ef-card-title">지출내역</div>
	                <div class="ef-right">
	                  <button type="button" class="ef-btn ef-btn-ghost" id="btnAddRow">+ 항목 추가</button>
	                </div>
	              </div>
	
	              <div class="ef-table-wrap">
	                <table class="ef-table" id="tblItems" >
	                  <thead style="text-align: center;">
	                    <tr>
	                      <th>지출예정일</th>
	                      <th>거래처</th>
	                      <th style="width: 120px;">대상유형</th>
	                      <th style="width: 300px;">지출내역설명</th>
	                      <th>은행명</th>
	                      <th>대상계좌</th>
	                      <th style="width: 120px;">지출유형</th>
	                      <th>지출금액</th>
	                      <th style="width: 67px;"></th>
	                    </tr>
	                  </thead>
	                  <tbody>
						  <!-- 목록 있을 때 -->
						  <c:forEach var="row" items="${expenseList}" varStatus="st">
						    <tr>
						    	
						      <!-- 지출예정일 -->
						      <td>
						      	<input type="hidden" name="items[${st.index}].expense_no" value="${row.expense_no}">
						        <input type="date" class="ef-input"
						               name="items[${st.index}].expense_date"
						               value="${fn:substring(row.expense_date, 0, 10)}">
						      </td>
						
						      <!-- 거래처 -->
						      <td>
						        <input type="text" class="ef-input"
						               name="items[${st.index}].payee_name"
						               value="${row.payee_name}" placeholder="예: ㈜ABC상사">
						      </td>
						
						      <!-- 대상유형 -->
						      <td>
						        <select class="ef-input" name="items[${st.index}].payee_type">
						          <option value="개인"   ${row.payee_type=='개인'   ? 'selected' : ''}>개인</option>
						          <option value="법인" ${row.payee_type=='법인' ? 'selected' : ''}>법인</option>
						          <option value="협력사" ${row.payee_type=='협력사' ? 'selected' : ''}>협력사</option>
						          <option value="기타"   ${row.payee_type=='기타'   ? 'selected' : ''}>기타</option>
						        </select>
						      </td>
						
						      <!-- 지출내역설명 -->
						      <td>
						        <input type="text" class="ef-input"
						               name="items[${st.index}].expense_desc"
						               value="${row.expense_desc}" placeholder="예: 회의 다과 구입">
						      </td>
						
						      <!-- 은행명 -->
						      <td>
						        <input type="text" class="ef-input"
						               name="items[${st.index}].payee_bank"
						               value="${row.payee_bank}" placeholder="예: 우리은행">
						      </td>
						
						      <!-- 대상계좌 -->
						      <td class="ta-right">
						        <input type="text" class="ef-input"
						               name="items[${st.index}].payee_account"
						               value="${row.payee_account}" placeholder="예: 1002-***-****">
						      </td>
						
						      <!-- 지출유형 -->
						      <td>
						        <select class="ef-input" name="items[${st.index}].expense_type">
						          <option value="교통비" ${row.expense_type=='교통비' ? 'selected' : ''}>교통비</option>
						          <option value="식대"     ${row.expense_type=='식대'     ? 'selected' : ''}>식대</option>
						          <option value="출장비"   ${row.expense_type=='출장비'   ? 'selected' : ''}>출장비</option>
						          <option value="소모품비"   ${row.expense_type=='소모품비'   ? 'selected' : ''}>소모품비</option>
						          <option value="기타"     ${row.expense_type=='기타'     ? 'selected' : ''}>기타</option>
						        </select>
						      </td>
						
						      <!-- 지출금액 + (행삭제 버튼은 이 칸 안에) -->
						      <td class="ta-right">
						        <div class="ef-amount-cell">
						          <input type="text" class="ef-input ef-money js-amount"
						                 name="items[${st.index}].expense_amount"
						                 value="${row.expense_amount}"
						                 placeholder="0">
						          
						        </div>
						      </td>
						  	    <td class="col-del ta-center">
							        <button type="button" class="ef-icon-btn js-del-row" aria-label="행 삭제">삭제</button>
							    </td>
						    </tr>
						  </c:forEach>
						</tbody>
	                </table>
	              </div>
	            </section>
	
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
