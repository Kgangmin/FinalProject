	<%@ page language="java" contentType="text/html; charset=UTF-8"
	    pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
	<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
	<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>    
	    
	<%
	    String ctxPath = request.getContextPath();
	%>
<script type="text/javascript">

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
						    <input type="hidden" name="draft_type" value="${draft.draft_type}">
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
		        <input type="hidden" name="fk_draft_no" value="${draft.draft_no}"/>
		        <div class="ef-card-title">업무기안 내용</div>
		        <div class="ef-form-grid ef-2col">
		          <!-- 배경 -->
		          <label class="ef-field ef-colspan-2">
		            <span class="ef-label">배경</span>
		            <textarea class="ef-input" name="background" rows="3" placeholder="해당 기안이 필요한 배경을 입력하세요." readonly="readonly">${proposal.background}</textarea>
		          </label>
		          <!-- 제안 내용 -->
		          <label class="ef-field ef-colspan-2">
		            <span class="ef-label">제안 내용</span>
		            <textarea class="ef-input" name="proposal_content" rows="5" placeholder="구체적인 제안 내용을 입력하세요." readonly="readonly">${proposal.proposal_content}</textarea>
		          </label>
		          <!-- 기대 효과 -->
		          <label class="ef-field ef-colspan-2">
		            <span class="ef-label">기대 효과</span>
		            <textarea class="ef-input" name="expected_effect" rows="5" placeholder="업무기안 실행 시 예상되는 효과를 입력하세요." readonly="readonly">${proposal.expected_effect}</textarea>
		          </label>
		        </div>
		      </section>
						<!-- 과업 설정 (읽기전용) -->
			  <section class="ef-card">
				  <div class="ef-card-title">과업 설정</div>
				  <div class="ef-form-grid ef-2col">
				    <label class="ef-field ef-colspan-2">
				      <span class="ef-label">과업 제목</span>
				      <input type="text" class="ef-input" name="task_title"
				             value="${proposal.task_title}" placeholder="예) 신규 프로젝트 PoC 수행"
				             readonly="readonly">
				    </label>
				
				    <fmt:formatDate value="${proposal.start_date}" pattern="yyyy-MM-dd" var="startStr"/>
				    <fmt:formatDate value="${proposal.end_date}"   pattern="yyyy-MM-dd" var="endStr"/>
				
				    <label class="ef-field">
				      <span class="ef-label">시작일</span>
				      <input type="date" class="ef-input date"
				             name="start_date" id="start_date"
				             value="${startStr}" readonly="readonly">
				    </label>
				
				    <label class="ef-field">
				      <span class="ef-label">종료일</span>
				      <input type="date" class="ef-input date"
				             name="end_date" id="end_date"
				             value="${endStr}" readonly="readonly">
				    </label>
				
				    <label class="ef-field">
				      <span class="ef-label">담당자(Owner)</span>
				      <input type="text" id="ownerName" class="ef-input"
				             value="${proposal.owner_emp_name}" placeholder="담당자" readonly="readonly">
				      <input type="hidden" name="fk_owner_emp_no" value="${proposal.fk_owner_emp_no}">
				    </label>
				  </div>
				</section>
									<!-- 접근 권한 (읽기전용) -->
				<section class="ef-card">
				  <div class="ef-card-title">접근 권한(공유 대상)</div>
				
				  <div class="ef-table-wrap">
				    <table class="ef-table" id="tblAccess">
				      <thead>
				        <tr>
				          <th style="width:140px">대상 유형</th>
				          <th>대상</th>
				        </tr>
				      </thead>
				      <tbody>
				        <c:choose>
				          <c:when test="${not empty proposalAccesses}">
				            <c:forEach var="a" items="${proposalAccesses}">
				              <tr>
				                <td>
				                  <!-- select은 disabled + hidden으로 값 보존 -->
				                  <select class="ef-input acc-type" disabled>
				                    <option value="dept" ${a.target_type eq 'dept' ? 'selected' : ''}>부서</option>
				                    <option value="emp"  ${a.target_type eq 'emp'  ? 'selected' : ''}>사원</option>
				                  </select>
				                  <input type="hidden" name="target_type[]" value="${a.target_type}">
				                </td>
				                <td>
				                  <input type="text" class="ef-input acc-target-name"
				                         value="${a.target_type eq 'dept' ? a.dept_name : a.emp_name}"
				                         readonly="readonly">
				                  <input type="hidden" name="target_no[]" class="acc-target-no" value="${a.target_no}">
				                </td>
				              </tr>
				            </c:forEach>
				          </c:when>
				          <c:otherwise>
				            <tr>
				              <td>
				                <select class="ef-input" disabled>
				                  <option>부서</option><option>사원</option>
				                </select>
				              </td>
				              <td>
				                <input type="text" class="ef-input" value="(대상 없음)" readonly="readonly">
				              </td>
				            </tr>
				          </c:otherwise>
				        </c:choose>
				      </tbody>
				    </table>
				  </div>
				</section>
				<!-- 관련 부서 (읽기전용) -->
				<section class="ef-card">
				  <div class="ef-card-title">관련 부서</div>
				
				  <div class="ef-table-wrap">
				    <table class="ef-table" id="tblDept">
				      <thead>
				        <tr>
				          <th>부서</th>
				          <th style="width:120px">역할</th>
				        </tr>
				      </thead>
				      <tbody>
				        <c:choose>
				          <c:when test="${not empty proposalDepartments}">
				            <c:forEach var="d" items="${proposalDepartments}">
				              <tr>
				                <td>
				                  <input type="text" class="ef-input dept-name"
				                         value="${d.dept_name}" readonly="readonly">
				                  <input type="hidden" name="dept_no[]" class="dept-no" value="${d.fk_dept_no}">
				                </td>
				                <td>
				                  <!-- select은 disabled + hidden으로 값 보존 -->
				                  <select class="ef-input dept-role" disabled>
				                    <option value="주관" ${d.task_dept_role eq '주관' ? 'selected' : ''}>주관</option>
				                    <option value="협력" ${d.task_dept_role eq '협력' ? 'selected' : ''}>협력</option>
				                  </select>
				                  <input type="hidden" name="task_dept_role[]" value="${d.task_dept_role}">
				                </td>
				              </tr>
				            </c:forEach>
				          </c:when>
				          <c:otherwise>
				            <tr>
				              <td><input type="text" class="ef-input" value="(부서 없음)" readonly="readonly"></td>
				              <td>
				                <select class="ef-input" disabled>
				                  <option>주관</option><option>협력</option>
				                </select>
				              </td>
				            </tr>
				          </c:otherwise>
				        </c:choose>
				      </tbody>
				    </table>
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
					  <small class="ef-help">관련 자료(PDF, 이미지 등) 업로드</small>
				 </section>
	    </div>
	  </div>
	</div>
