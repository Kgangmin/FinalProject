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


  // 행 추가
  $('#btnAddRow').on('click', function(){
    const $tr = addRow();
    // UX: 새 행의 첫 입력칸에 포커스 (거래처로 이동하고 싶으면 셀렉터 바꿔도 됨)
    $tr.find('input, select').first().focus();
  });

  // 행 삭제 (이벤트 위임: 기존 + 동적 추가 모두 커버)
  $('#tblItems tbody').on('click', '.js-del-row', function(){
    const $tbody = $('#tblItems tbody');
    $(this).closest('tr').remove();
    // 최소 1행 유지하고 싶으면 아래 주석 해제
    // if ($tbody.children('tr').length === 0) addRow();
  });
  
});


 // 현재 테이블에서 가장 큰 items[index]의 index를 찾아 +1 반환
 function getNextItemIndex(){
   let maxIdx = -1;
   $('#tblItems tbody')
     .find('input[name^="items["], select[name^="items["], textarea[name^="items["]')
     .each(function(){	
       const m = this.name.match(/^items\[(\d+)\]\./);
       if (m) {
         const n = parseInt(m[1], 10);
         if (!Number.isNaN(n) && n > maxIdx) maxIdx = n;
       }
     });
   return maxIdx + 1; // 아무것도 없으면 0부터 시작
 }

 // 새 행 추가 (현재 JSP 열 구성에 맞춤)
 function addRow(){
   const idx = getNextItemIndex();
   const html = `
     <tr>
       <!-- 지출예정일 -->
       <td>
         <input type="date" class="ef-input" name="items[${idx}].plannedDate">
       </td>

       <!-- 거래처 -->
       <td>
         <input type="text" class="ef-input" name="items[${idx}].vendorName" placeholder="거래처명">
       </td>

       <!-- 대상유형 -->
       <td>
         <select class="ef-input" name="items[${idx}].targetType">
           <option>사내</option>
           <option>임직원</option>
           <option>거래처</option>
           <option>기타</option>
         </select>
       </td>

       <!-- 지출내역설명 -->
       <td>
         <input type="text" class="ef-input" name="items[${idx}].description" placeholder="지출내역 설명">
       </td>

       <!-- 은행명 -->
       <td>
         <input type="text" class="ef-input" name="items[${idx}].bankName" placeholder="은행명">
       </td>

       <!-- 대상계좌 -->
       <td class="ta-right">
         <input type="text" class="ef-input" name="items[${idx}].accountNo" placeholder="계좌번호">
       </td>

       <!-- 지출유형 -->
       <td>
         <select class="ef-input" name="items[${idx}].expenseType">
           <option>일반비용</option>
           <option>식대</option>
           <option>교통비</option>
           <option>소모품</option>
           <option>기타</option>
         </select>
       </td>

       <!-- 지출금액 -->
       <td class="ta-right">
         <div class="ef-amount-cell">
           <input type="text" class="ef-input ef-money js-amount" name="items[${idx}].amount" placeholder="0">
         </div>
       </td>

       <!-- 삭제 버튼 -->
       <td class="col-del ta-center">
         <button type="button" class="ef-icon-btn js-del-row" aria-label="행 삭제">삭제</button>
       </td>
     </tr>`;

   const $tr = $(html).appendTo('#tblItems tbody');
 }


</script>

<div class="container-fluid">
  <!-- 2차 사이드바 -->
  <jsp:include page="/WEB-INF/views/draft/draftSidebar.jsp" />

  <!-- 본문 -->
  <main class="main-with-sub p-4">
    <!-- 페이지 제목/설명 (리스트 페이지 상단 톤과 동일) -->
    <div class="page-head mb-3">
      <h4 class="font-weight-bold mb-1">지출결의서</h4>
      <div class="text-muted small">내가 신청한 결제의 상세페이지입니다 내용을 수정하거나 확인 할수 있습니다</div>
    </div>

    <!-- 상세 본문 카드: 내부는 기존 내용 유지 -->
    <div class="detail-section card shadow-sm p-4">
      <!-- ===== 여기부터 '지출결의서 화면용 폼'(expense-form) ===== -->
      <div class="expense-form">
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
                  <input type="text" class="ef-input" name="docNo" value="${draft.draft_no}" placeholder="자동생성 또는 수기 입력" readonly="readonly">
                </label>
                <label class="ef-field">
                  <span class="ef-label">기안일</span>
                  <input type="date" class="ef-input" name="draftDate" value="${fn:substring(draft.draft_date, 0, 10)}" readonly="readonly">
                </label>
                <label class="ef-field ef-colspan-2">
                  <span class="ef-label">용도(제목)</span>
                  <input type="text" class="ef-input" name="title" value="${draft.draft_title}" placeholder="예) 팀 회의 다과 구입비" >
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
					        <input type="date" class="ef-input"
					               name="items[${st.index}].plannedDate"
					               value="${fn:substring(row.expense_date, 0, 10)}">
					      </td>
					
					      <!-- 거래처 -->
					      <td>
					        <input type="text" class="ef-input"
					               name="items[${st.index}].vendorName"
					               value="${row.payee_name}" placeholder="예: ㈜ABC상사">
					      </td>
					
					      <!-- 대상유형 -->
					      <td>
					        <select class="ef-input" name="items[${st.index}].targetType">
					          <option value="사내"   ${row.payee_type=='사내'   ? 'selected' : ''}>사내</option>
					          <option value="임직원" ${row.payee_type=='임직원' ? 'selected' : ''}>임직원</option>
					          <option value="거래처" ${row.payee_type=='거래처' ? 'selected' : ''}>거래처</option>
					          <option value="개인"   ${row.payee_type=='개인'   ? 'selected' : ''}>개인</option>
					        </select>
					      </td>
					
					      <!-- 지출내역설명 -->
					      <td>
					        <input type="text" class="ef-input"
					               name="items[${st.index}].description"
					               value="${row.expense_desc}" placeholder="예: 회의 다과 구입">
					      </td>
					
					      <!-- 은행명 -->
					      <td>
					        <input type="text" class="ef-input"
					               name="items[${st.index}].bankName"
					               value="${row.payee_bank}" placeholder="예: 우리은행">
					      </td>
					
					      <!-- 대상계좌 -->
					      <td class="ta-right">
					        <input type="text" class="ef-input"
					               name="items[${st.index}].accountNo"
					               value="${row.payee_account}" placeholder="예: 1002-***-****">
					      </td>
					
					      <!-- 지출유형 -->
					      <td>
					        <select class="ef-input" name="items[${st.index}].expenseType">
					          <option value="일반비용" ${row.expense_type=='일반비용' ? 'selected' : ''}>일반비용</option>
					          <option value="식대"     ${row.expense_type=='식대'     ? 'selected' : ''}>식대</option>
					          <option value="교통비"   ${row.expense_type=='교통비'   ? 'selected' : ''}>교통비</option>
					          <option value="소모품"   ${row.expense_type=='소모품'   ? 'selected' : ''}>소모품</option>
					          <option value="기타"     ${row.expense_type=='기타'     ? 'selected' : ''}>기타</option>
					        </select>
					      </td>
					
					      <!-- 지출금액 + (행삭제 버튼은 이 칸 안에) -->
					      <td class="ta-right">
					        <div class="ef-amount-cell">
					          <input type="text" class="ef-input ef-money js-amount"
					                 name="items[${st.index}].amount"
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
			    <div id="efFileSelected" class="ef-file-selected">    
					  <ul class="ef-file-list" id="efFileList">
					    <!-- 서버에 이미 저장된 파일 -->
					    <c:forEach var="f" items="${fileList}">
					      <li class="ef-file-item">
					        <a class="ef-file-link" href="<%=ctxPath%>/draft/file/download?fileNo=${f.draft_file_no}">
					          <span class="ef-file-name">${f.draft_origin_filename}</span>
					          <span class="ef-file-size"><fmt:formatNumber value="${f.draft_filesize/1024}" pattern="#,##0"/> KB</span>
					        </a>
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
      <!-- ===== 지출결의서 폼 끝 ===== -->
    </div>
  </main>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />

