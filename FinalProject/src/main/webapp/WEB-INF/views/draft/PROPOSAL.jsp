<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>    
    
<%
    String ctxPath = request.getContextPath();
%>
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


 
 
   </div>

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
