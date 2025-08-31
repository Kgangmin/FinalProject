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
		
	 	 $(document).on('click', '.ef-btn-approve, .ef-btn-reject', function(){
		    const $btn   = $(this);
		    const result = $btn.data('result');

		    const $form = $('#DocsForm');                               // 항상 바깥 폼만 사용
		    $form.attr('action', '<%=ctxPath%>/draft/approve');         // ✅ 목적지 강제 변경
		    $form.find('input[name="approval_status"]').val(result);    // ✅ 이름 일치

		    $form.get(0).submit();       
		});
	});
	
	</script>
	
	 <!-- ===== 여기부터 '업무기안서 화면용 폼'(proposal-form) ===== -->
	<div class="proposal-form doc-form">
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
		             <input type="text" class="ef-input" name="draft.draft_no" value="${draft.draft_no}" readonly="readonly">
		           </label>
		           <label class="ef-field">
		             <span class="ef-label">기안일</span>
		             <input type="date" class="ef-input" name="draft.draft_date" value="${fn:substring(draft.draft_date, 0, 10)}" readonly="readonly">
		           </label>
		           <label class="ef-field ef-colspan-2">
		             <span class="ef-label">용도(제목)</span>
		             <input type="text" class="ef-input" name="draft.draft_title" value="${draft.draft_title}" placeholder="예) 신규 프로젝트 추진 기안" readonly="readonly">
		           </label>
		         </div>
		      </section>
		      
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
	
		      <!-- 업무기안 정보 -->
		      <section class="ef-card">
		        <input type="hidden" name="proposal.fk_draft_no" value="${draft.draft_no}"/>
		        <div class="ef-card-title">업무기안 내용</div>
		        <div class="ef-form-grid ef-2col">
		          <!-- 배경 -->
		          <label class="ef-field ef-colspan-2">
		            <span class="ef-label">배경</span>
		            <textarea class="ef-input" name="proposal.background" rows="3" placeholder="해당 기안이 필요한 배경을 입력하세요." readonly="readonly">${proposal.background}</textarea>
		          </label>
		          <!-- 제안 내용 -->
		          <label class="ef-field ef-colspan-2">
		            <span class="ef-label">제안 내용</span>
		            <textarea class="ef-input" name="proposal.proposal_content" rows="5" placeholder="구체적인 제안 내용을 입력하세요." readonly="readonly">${proposal.proposal_content}</textarea>
		          </label>
		          <!-- 기대 효과 -->
		          <label class="ef-field ef-colspan-2">
		            <span class="ef-label">기대 효과</span>
		            <textarea class="ef-input" name="proposal.expected_effect" rows="5" placeholder="업무기안 실행 시 예상되는 효과를 입력하세요." readonly="readonly">${proposal.expected_effect}</textarea>
		          </label>
		        </div>
		      </section>
		
		      <!-- 첨부파일 섹션 (공통) -->
				<section class="ef-card">
					  <div class="ef-card-title">첨부파일</div>
					  <div class="ef-filebox">
					    <div id="efFileSelected" class="ef-file-selected">    
							  <ul class="ef-file-list" id="efFileList">
							    <c:forEach var="f" items="${fileList}">
							      <li class="ef-file-item">
							      	<input type="hidden" name="draft_file_no" value="${f.draft_file_no}">
							        <a class="ef-file-link" href="<%=ctxPath%>/draft/file/download?draft_file_no=${f.draft_file_no}">
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
					  
				 </section>
	    </div>
	  </div>
	</div>
