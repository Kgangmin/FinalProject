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

<%-- 현재 선택된 카테고리 --%>
<c:set var="currentCatNo" value="${not empty cat ? cat.board_category_no : param.category}" />

<%-- 전사 카테고리 이름 세트 --%>
<c:set var="corp1" value="전사공지" />
<c:set var="corp2" value="전사알림" />
<c:set var="corp3" value="자유게시판" />

<%-- 글쓰기 이동용 기본 카테고리 결정:
     1) 현재 선택값이 있으면 그걸 사용
     2) 없으면 '자유게시판'이 보이면 자유게시판
     3) 그래도 없으면 categories의 첫 번째 --%>
<c:set var="writeCatNo" value="${currentCatNo}" />
<c:if test="${empty writeCatNo}">
  <c:forEach var="c0" items="${categories}">
    <c:if test="${c0.board_category_name == corp3}">
      <c:set var="writeCatNo" value="${c0.board_category_no}" />
    </c:if>
  </c:forEach>
</c:if>
<c:if test="${empty writeCatNo}">
  <c:forEach var="c0" items="${categories}" varStatus="st">
    <c:if test="${st.first}">
      <c:set var="writeCatNo" value="${c0.board_category_no}" />
    </c:if>
  </c:forEach>
</c:if>

<div class="board-panel">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div class="board-title">게시판</div>
  </div>

  <!-- 글쓰기 버튼 -->
  <div class="mb-3">
    <a class="btn btn-primary btn-sm w-100"
       href="${pageContext.request.contextPath}/board/write?category=${writeCatNo}"
       role="button">글쓰기</a>
  </div>

  <!-- 전사게시판: 항상 노출 (이미 서버에서 필터됨) -->
  <div class="mb-3">
    <div class="text-secondary small mb-1">전사게시판</div>
    <div class="list-group">
      <c:forEach var="c0" items="${categories}">
        <c:if test="${c0.board_category_name == corp1
                     || c0.board_category_name == corp2
                     || c0.board_category_name == corp3}">
          <a class="list-group-item list-group-item-action
                    ${currentCatNo == c0.board_category_no ? 'active' : ''}"
             href="${pageContext.request.contextPath}/board?category=${c0.board_category_no}">
            <c:out value="${c0.board_category_name}" />
          </a>
        </c:if>
      </c:forEach>
    </div>
  </div>

  <!-- 부서게시판: 서버에서 이미 '내 부서 것만' 내려옴 -->
  <div class="mb-2">
    <div class="text-secondary small mb-1">부서게시판</div>
    <div class="list-group">
      <c:set var="deptCount" value="0" />
      <c:forEach var="c0" items="${categories}">
        <c:if test="${c0.board_category_name != corp1
                     && c0.board_category_name != corp2
                     && c0.board_category_name != corp3}">
          <c:set var="deptCount" value="${deptCount + 1}" />
          <a class="list-group-item list-group-item-action
                    ${currentCatNo == c0.board_category_no ? 'active' : ''}"
             href="${pageContext.request.contextPath}/board?category=${c0.board_category_no}">
            <c:out value="${c0.board_category_name}" />
          </a>
        </c:if>
      </c:forEach>
      <c:if test="${deptCount == 0}">
        <div class="list-group-item text-muted">내 부서 게시판이 없습니다.</div>
      </c:if>
    </div>
  </div>

  <%-- 관리자(부서 01) 도구 (원하면 유지) --%>
  <c:if test="${sessionScope.loginuser != null && sessionScope.loginuser.fk_dept_no == '01'}">
    <button type="button"
            class="btn btn-primary btn-sm w-100 mb-4"
            onclick="location.href='${pageContext.request.contextPath}/board/admin/category/form'">
      + 게시판 추가
    </button>
  </c:if>
  
  
</div>
