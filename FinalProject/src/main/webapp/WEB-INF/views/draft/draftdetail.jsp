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
                  <input type="text" class="ef-input" name="docNo" value="${expense.docNo}" placeholder="자동생성 또는 수기 입력">
                </label>
                <label class="ef-field">
                  <span class="ef-label">기안일</span>
                  <input type="date" class="ef-input" name="draftDate" value="<fmt:formatDate value='${expense.draftDate}' pattern='yyyy-MM-dd'/>">
                </label>
                <label class="ef-field ef-colspan-2">
                  <span class="ef-label">용도(제목)</span>
                  <input type="text" class="ef-input" name="title" value="${expense.title}" placeholder="예) 팀 회의 다과 구입비">
                </label>
              </div>
            </section>

            <!-- 결재선(간단 입력형) -->
            <section class="ef-card">
              <div class="ef-card-title">결재라인</div>
              <div class="ef-approvals">
                <c:forEach var="line" items="${expense.lines}" varStatus="st">
                  <div class="ef-approver">
                    <div class="ef-approver-role">
                      <select class="ef-input" name="lines[${st.index}].role">
                        <option ${line.role=='기안'?'selected':''}>기안</option>
                        <option ${line.role=='검토'?'selected':''}>검토</option>
                        <option ${line.role=='승인'?'selected':''}>승인</option>
                        <option ${line.role=='전결'?'selected':''}>전결</option>
                      </select>
                    </div>
                    <input class="ef-input" type="text" name="lines[${st.index}].name" value="${line.name}" placeholder="이름">
                  </div>
                </c:forEach>
               	<label class="ef-field">
                  <span class="ef-label">결제자1</span>
                  <input class="ef-input" name="drafterName1" value="${expense.drafterName}" placeholder="홍길동">
                </label>
                <label class="ef-field">
                  <span class="ef-label">결제자2</span>
                  <input class="ef-input" name="drafterName2" value="${expense.drafterName}" placeholder="홍길동">
                </label>
                <label class="ef-field">
                  <span class="ef-label">결제자3</span>
                  <input class="ef-input" name="drafterName3" value="${expense.drafterName}" placeholder="홍길동">
                </label>
              </div>
            </section>

            <!-- 기본정보 -->
            <section class="ef-card">
              <div class="ef-card-title">기본정보</div>
              <div class="ef-form-grid ef-2col">
                <label class="ef-field">
                  <span class="ef-label">기안자</span>
                  <input class="ef-input" name="drafterName" value="${expense.drafterName}" placeholder="홍길동">
                </label>
                <label class="ef-field">
                  <span class="ef-label">부서</span>
                  <input class="ef-input" name="drafterDept" value="${expense.drafterDept}" placeholder="경영지원팀">
                </label>
                <label class="ef-field">
                  <span class="ef-label">연락처</span>
                  <input class="ef-input" name="contact" value="${expense.contact}" placeholder="010-0000-0000">
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
					  <c:forEach var="row" items="${expense.items}" varStatus="st">
					    <tr>
					      <!-- 지출예정일 -->
					      <td>
					        <input type="date" class="ef-input"
					               name="items[${st.index}].plannedDate"
					               value="<fmt:formatDate value='${row.plannedDate}' pattern='yyyy-MM-dd'/>">
					      </td>
					
					      <!-- 거래처 -->
					      <td>
					        <input type="text" class="ef-input"
					               name="items[${st.index}].vendorName"
					               value="${row.vendorName}" placeholder="예: ㈜ABC상사">
					      </td>
					
					      <!-- 대상유형 -->
					      <td>
					        <select class="ef-input" name="items[${st.index}].targetType">
					          <option value="사내"   ${row.targetType=='사내'   ? 'selected' : ''}>사내</option>
					          <option value="임직원" ${row.targetType=='임직원' ? 'selected' : ''}>임직원</option>
					          <option value="거래처" ${row.targetType=='거래처' ? 'selected' : ''}>거래처</option>
					          <option value="기타"   ${row.targetType=='기타'   ? 'selected' : ''}>기타</option>
					        </select>
					      </td>
					
					      <!-- 지출내역설명 -->
					      <td>
					        <input type="text" class="ef-input"
					               name="items[${st.index}].description"
					               value="${row.description}" placeholder="예: 회의 다과 구입">
					      </td>
					
					      <!-- 은행명 -->
					      <td>
					        <input type="text" class="ef-input"
					               name="items[${st.index}].bankName"
					               value="${row.bankName}" placeholder="예: 우리은행">
					      </td>
					
					      <!-- 대상계좌 -->
					      <td class="ta-right">
					        <input type="text" class="ef-input"
					               name="items[${st.index}].accountNo"
					               value="${row.accountNo}" placeholder="예: 1002-***-****">
					      </td>
					
					      <!-- 지출유형 -->
					      <td>
					        <select class="ef-input" name="items[${st.index}].expenseType">
					          <option value="일반비용" ${row.expenseType=='일반비용' ? 'selected' : ''}>일반비용</option>
					          <option value="식대"     ${row.expenseType=='식대'     ? 'selected' : ''}>식대</option>
					          <option value="교통비"   ${row.expenseType=='교통비'   ? 'selected' : ''}>교통비</option>
					          <option value="소모품"   ${row.expenseType=='소모품'   ? 'selected' : ''}>소모품</option>
					          <option value="기타"     ${row.expenseType=='기타'     ? 'selected' : ''}>기타</option>
					        </select>
					      </td>
					
					      <!-- 지출금액 + (행삭제 버튼은 이 칸 안에) -->
					      <td class="ta-right">
					        <div class="ef-amount-cell">
					          <input type="text" class="ef-input ef-money js-amount"
					                 name="items[${st.index}].amount"
					                 value="<fmt:formatNumber value='${row.amount}' pattern='#,##0'/>"
					                 placeholder="0">
					          
					        </div>
					      </td>
					  	    <td class="col-del ta-center">
						        <button type="button" class="ef-icon-btn js-del-row" aria-label="행 삭제">삭제</button>
						    </td>
					    </tr>
					  </c:forEach>
					
					  <!-- 목록 없을 때 기본 1행 -->
					  <c:if test="${empty expense.items}">
					    <tr>
					      <td><input type="date" class="ef-input" name="items[0].plannedDate"></td>
					      <td><input type="text" class="ef-input" name="items[0].vendorName" placeholder="거래처명"></td>
					      <td>
					        <select class="ef-input" name="items[0].targetType">
					          <option>사내</option><option>임직원</option><option>거래처</option><option>기타</option>
					        </select>
					      </td>
					      <td><input type="text" class="ef-input" name="items[0].description" placeholder="지출내역 설명"></td>
					      <td><input type="text" class="ef-input" name="items[0].bankName" placeholder="은행명"></td>
					      <td class="ta-right"><input type="text" class="ef-input" name="items[0].accountNo" placeholder="계좌번호"></td>
					      <td>
					        <select class="ef-input" name="items[0].expenseType">
					          <option>일반비용</option><option>식대</option><option>교통비</option><option>소모품</option><option>기타</option>
					        </select>
					      </td>
					      <td class="ta-right">
					        <div class="ef-amount-cell">
					          <input type="text" class="ef-input ef-money js-amount" name="items[0].amount" placeholder="0">
					        </div>
					      </td>
					        <td class="col-del ta-center">
						        <button type="button" class="ef-icon-btn js-del-row" aria-label="행 삭제">삭제</button>
						    </td>
					    </tr>
					  </c:if>
					</tbody>
                </table>
              </div>
            </section>

            <!-- 비고 / 첨부 -->
            <section class="ef-card">
              <div class="ef-form-grid ef-1col">
                <label class="ef-field">
                  <span class="ef-label">첨부파일</span>
                  <input type="file" class="ef-input" multiple>
                  <small class="ef-help">영수증/세금계산서 이미지 또는 PDF 업로드</small>
                </label>
              </div>
            </section>
          </div>


        </div>
      </div>
      <!-- ===== 지출결의서 폼 끝 ===== -->
    </div>
  </main>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />

