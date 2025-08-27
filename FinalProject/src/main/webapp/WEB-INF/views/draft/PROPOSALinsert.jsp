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
              </label>       
            </div>
          	<div class="ef-approval-item">
              <label class="ef-field ef-colspan-2">
                <span class="ef-label">결재자 2&nbsp;<small>(선택)</small></span>
                <input type="text" class="ef-input ef-approver-name"
                       name="approvalLine_name" placeholder="이름 /부서 / 직급 입력 후 목록에서 선택">
              </label>       
            </div>
             <div class="ef-approval-item">
              <label class="ef-field ef-colspan-2">
                <span class="ef-label">결재자 3&nbsp;<small>(선택)</small></span>
                <input type="text" class="ef-input ef-approver-name"
                       name="approvalLine_name" placeholder="이름 / 부서 / 직급 입력 후 목록에서 선택">
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

      <!-- 업무기안 정보 -->
      <section class="ef-card">
        
        <div class="ef-card-title">업무기안 내용</div>
        <div class="ef-form-grid ef-2col">
          <!-- 배경 -->
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">배경</span>
            <textarea class="ef-input" name="background" rows="3" placeholder="해당 기안이 필요한 배경을 입력하세요."></textarea>
          </label>
          <!-- 제안 내용 -->
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">제안 내용</span>
            <textarea class="ef-input" name="proposal_content" rows="5" placeholder="구체적인 제안 내용을 입력하세요."></textarea>
          </label>
          <!-- 기대 효과 -->
          <label class="ef-field ef-colspan-2">
            <span class="ef-label">기대 효과</span>
            <textarea class="ef-input" name="expected_effect" rows="5" placeholder="업무기안 실행 시 예상되는 효과를 입력하세요."></textarea>
          </label>
        </div>
      </section>

      <!-- 첨부파일 섹션 (공통) -->
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
