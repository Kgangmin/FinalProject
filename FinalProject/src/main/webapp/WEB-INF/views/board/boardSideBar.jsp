<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%
  String ctxPath = request.getContextPath(); 
%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  /* 메인 사이드바(180px) 옆에 붙는 보드 사이드바(190px) */
  .board-panel {
    position: fixed; top: 70px; left: 180px; width: 190px;
    height: calc(100vh - 70px);
    background: #fff;
    border-right: 1px solid rgba(0,0,0,.08);
    padding: 16px 12px;
    overflow-y: auto;
    z-index: 1020;
  }
  .board-title { font-weight: 700; color: #0d6efd; } /* 파랑 포인트 */
  .list-group-item.active {
    background-color: #0d6efd; border-color: #0d6efd;
  }
</style>

<!-- 컨트롤러에서 내려보내는 값 기준:
     - categories : List<CategoryDTO>
     - cat        : 현재 선택된 카테고리(CategoryDTO) (list/view 모두 제공됨)
     - 만약 cat이 없으면 param.category 사용 -->
<c:set var="currentCatNo" value="${not empty cat ? cat.board_category_no : param.category}" />

<!-- 자유게시판 번호(글쓰기 기본용) 찾기 -->
<c:set var="freeCatNo" value="" />
<c:forEach var="c0" items="${categories}">
  <c:if test="${c0.board_category_name == '자유게시판' && empty freeCatNo}">
    <c:set var="freeCatNo" value="${c0.board_category_no}" />
  </c:if>
</c:forEach>

<!-- 글쓰기 버튼이 눌렸을 때 사용할 카테고리: 현재 선택 > 자유게시판 -->
<c:set var="writeCatNo" value="${not empty currentCatNo ? currentCatNo : freeCatNo}" />

<div class="board-panel">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div class="board-title">게시판</div>
  </div>

  <!-- 글쓰기 -->
  <div class="mb-3">
    <a class="btn btn-primary btn-sm w-100"
       href="<%=ctxPath%>/board/write?category=${writeCatNo}"
       role="button">글쓰기</a>
  </div>

  <!-- 전사게시판 -->
  <div class="mb-3">
    <div class="text-secondary small mb-1">전사게시판</div>
    <div class="list-group">
      <c:forEach var="c0" items="${categories}">
        <c:if test="${c0.board_category_name == '전사공지'
                     || c0.board_category_name == '전사알림'
                     || c0.board_category_name == '자유게시판'}">
          <a class="list-group-item list-group-item-action
                    ${currentCatNo == c0.board_category_no ? 'active' : ''}"
             href="<%=ctxPath%>/board?category=${c0.board_category_no}">
            <c:out value="${c0.board_category_name}"/>
          </a>
        </c:if>
      </c:forEach>
    </div>
  </div>

  <!-- 부서게시판 -->
  <div class="mb-2">
    <div class="text-secondary small mb-1">부서게시판</div>
    <div class="list-group">
      <c:set var="deptCount" value="0" />
      <c:forEach var="c0" items="${categories}">
        <c:if test="${c0.board_category_name != '전사공지'
                     && c0.board_category_name != '전사알림'
                     && c0.board_category_name != '자유게시판'}">
          <c:set var="deptCount" value="${deptCount + 1}" />
          <a class="list-group-item list-group-item-action
                    ${currentCatNo == c0.board_category_no ? 'active' : ''}"
             href="<%=ctxPath%>/board?category=${c0.board_category_no}">
            <c:out value="${c0.board_category_name}"/>
          </a>
        </c:if>
      </c:forEach>
      <c:if test="${deptCount == 0}">
        <div class="list-group-item text-muted">등록된 부서게시판이 없습니다.</div>
      </c:if>
    </div>
  </div>
</div>
