<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
  .board-panel {
    position: fixed; top: 70px; left: 170px; width: 200px;
    height: calc(100vh - 70px);
    background: #fff; border-right: 1px solid rgba(0,0,0,.08);
    padding: 16px 12px; overflow-y: auto; z-index: 1020;
  }
  .board-title { font-weight: 700; color: #0d6efd; }
  .list-group-item.active { background-color: #0d6efd; border-color: #0d6efd; }
</style>

<%-- ===== 로그인 정보 (프로젝트 상황에 맞게 하나만 쓰면 됨) ===== --%>
<c:set var="empNo"
       value="${not empty sessionScope.loginuser ? sessionScope.loginuser.emp_no
               : (not empty sessionScope.loginEmp ? sessionScope.loginEmp.empNo : '')}" />
<c:set var="deptNo"
       value="${not empty sessionScope.loginuser ? sessionScope.loginuser.fk_dept_no
               : (not empty sessionScope.loginEmp ? sessionScope.loginEmp.fkDeptNo : '')}" />

<%-- 현재 스코프 (CORP/DEPT/EMP) --%>
<c:set var="currentScope0" value="${not empty param.scope ? param.scope : 'CORP'}" />
<c:set var="currentScope"  value="${fn:toUpperCase(fn:trim(currentScope0))}" />

<div class="board-panel">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div class="board-title">자료실</div>
  </div>

  <!-- 전사 자료실 -->
  <div class="mb-3">
    <div class="text-secondary small mb-1">전사자료실</div>
    <div class="list-group">
      <a class="list-group-item ${currentScope eq 'CORP' ? 'active' : ''}"
   href="${pageContext.request.contextPath}/drive/list?scope=CORP">전사 자료실</a>
    </div>
  </div>

  <!-- 부서 자료실: 내 부서만 접근하도록 deptNo 포함 -->
  <div class="mb-3">
    <div class="text-secondary small mb-1">부서자료실</div>
    <div class="list-group">
      <c:choose>
        <c:when test="${not empty deptNo}">
          <a class="list-group-item ${currentScope eq 'DEPT' ? 'active' : ''}"
   href="${pageContext.request.contextPath}/drive/list?scope=DEPT">내 부서 자료실</a>
        </c:when>
        <c:otherwise>
          <div class="list-group-item text-muted">부서 정보가 없습니다.</div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

  <!-- 개인 자료실: 본인만 접근하도록 empNo 포함 -->
  <div class="mb-2">
    <div class="text-secondary small mb-1">개인자료실</div>
    <div class="list-group">
      <c:choose>
        <c:when test="${not empty empNo}">
         <a class="list-group-item ${currentScope eq 'EMP' ? 'active' : ''}"
   href="${pageContext.request.contextPath}/drive/list?scope=EMP">내 개인 자료실</a>
        </c:when>
        <c:otherwise>
          <div class="list-group-item text-muted">로그인 정보가 없습니다.</div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

  <%-- (선택) 관리자 도구: 필요시 조건/링크만 맞춰서 사용
  <c:if test="${sessionScope.loginuser != null && sessionScope.loginuser.fk_dept_no == '01'}">
    <button type="button" class="btn btn-primary btn-sm w-100 mt-3"
            onclick="location.href='${pageContext.request.contextPath}/drive/admin'">
      자료실 관리
    </button>
  </c:if>
  --%>

</div>
