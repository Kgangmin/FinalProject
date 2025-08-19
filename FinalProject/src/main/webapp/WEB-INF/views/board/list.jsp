<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 게시판 사이드바 -->
<jsp:include page="/WEB-INF/views/board/boardSideBar.jsp" />

<style>
  /* 메인(170) + 게시판(200) = 370px 만큼 본문을 오른쪽으로 */
  .board-content { margin-left: 370px; padding: 24px; max-width: 1200px; }
  .table thead th { border-color: rgba(0,0,0,.08); }
  .table-hover tbody tr:hover { background: #f8fbff; } /* 은은한 파랑 하이라이트 */
</style>

<!-- 호환: 파라미터/모델 값 기본셋 -->
<c:set var="currentCatNo"   value="${not empty cat ? cat.board_category_no : param.category}" />
<c:set var="currentCatName" value="${not empty cat ? cat.board_category_name : ''}" />
<c:set var="pageNum"        value="${empty page ? (empty param.page ? 1 : param.page) : page}" />
<c:set var="pageSize"       value="${empty size ? (empty param.size ? 10 : param.size) : size}" />
<c:set var="sortVal"        value="${empty sort ? (empty param.sort ? 'latest' : param.sort) : sort}" />
<c:set var="searchTypeVal"  value="${empty searchType ? param.searchType : searchType}" />
<c:set var="searchKeyVal"   value="${empty searchKeyword ? param.searchKeyword : searchKeyword}" />

<div class="board-content">
  <!-- 타이틀 -->
  <div class="d-flex align-items-center justify-content-between mb-2">
    <div>
      <h2 class="h5 m-0 text-primary">
        <c:choose>
          <c:when test="${not empty currentCatName}">${fn:escapeXml(currentCatName)}</c:when>
          <c:otherwise>게시판</c:otherwise>
        </c:choose>
      </h2>
      <small class="text-muted">
        <c:if test="${totalCnt gt 0}">총 <strong>${totalCnt}</strong>건</c:if>
        <c:if test="${totalCnt == 0}">등록된 글이 없습니다</c:if>
      </small>
    </div>
  </div>

  <!-- 검색/정렬 (간단 버전) -->
  <form class="form-row align-items-center mb-3" method="get" action="<%=ctxPath%>/board">
    <input type="hidden" name="category" value="${currentCatNo}" />
    <div class="col-auto">
      <select class="form-control form-control-sm" name="searchType">
        <option value=""        ${empty searchTypeVal ? 'selected':''}>검색항목</option>
        <option value="title"   ${searchTypeVal=='title'  ? 'selected':''}>제목</option>
        <option value="writer"  ${searchTypeVal=='writer' ? 'selected':''}>작성자</option>
      </select>
    </div>
    <div class="col-auto">
      <input type="text" class="form-control form-control-sm" name="searchKeyword"
             value="${fn:escapeXml(searchKeyVal)}" placeholder="검색어" />
    </div>
    <div class="col-auto">
      <select class="form-control form-control-sm" name="sort">
        <option value="latest" ${sortVal=='latest' ? 'selected':''}>최신순</option>
        <option value="views"  ${sortVal=='views'  ? 'selected':''}>조회수순</option>
      </select>
    </div>
    <div class="col-auto">
      <button class="btn btn-outline-primary btn-sm">검색</button>
    </div>
  </form>

  <!-- 게시글 리스트 -->
  <div class="card shadow-sm">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table mb-0 table-hover">
          <thead class="bg-primary text-white">
            <tr class="text-center">
              <th style="width:90px;">글번호</th>
              <th class="text-left">제목</th>
              <th style="width:160px;">작성자</th>
              <th style="width:160px;">작성일</th>
              <th style="width:110px;">조회수</th>
            </tr>
          </thead>
          <tbody>
            <c:if test="${not empty list}">
              <c:forEach var="post" items="${list}">
                <tr>
                  <td class="text-center">${post.board_no}</td>
                  <td class="text-left">
                    <c:if test="${post.is_pinned=='Y'}">
                      <span class="badge badge-warning text-dark mr-1">공지</span>
                    </c:if>
                    <c:if test="${not empty post.parent_board_no}">
                      <span class="mr-1">↪</span>
                    </c:if>
                    <a class="text-body" href="<%=ctxPath%>/board/view/${post.board_no}">
                      <c:out value="${post.board_title}"/>
                    </a>
                    <c:if test="${post.is_attached=='Y'}">
                      <span title="첨부파일 있음">💾</span>
                    </c:if>
                  </td>
                  <td class="text-center">
                    <!-- writer_name을 조인해서 넘기면 우선 사용, 아니면 사번 표시 -->
                    <c:choose>
                      <c:when test="${not empty post.writer_name}">
                        <c:out value="${post.writer_name}"/>
                      </c:when>
                      <c:otherwise>${post.fk_emp_no}</c:otherwise>
                    </c:choose>
                  </td>
                  <td class="text-center">${post.register_date}</td>
                  <td class="text-center">${post.view_cnt}</td>
                </tr>
              </c:forEach>
            </c:if>

            <c:if test="${empty list}">
              <tr>
                <td class="text-center text-muted" colspan="5">게시글이 없습니다.</td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- 페이징 -->
  <c:if test="${totalPage gt 1}">
    <nav class="my-3">
      <ul class="pagination justify-content-center">
        <c:forEach var="p" begin="1" end="${totalPage}">
          <li class="page-item ${p==pageNum?'active':''}">
            <a class="page-link"
               href="<%=ctxPath%>/board?category=${currentCatNo}&page=${p}&size=${pageSize}&searchType=${searchTypeVal}&searchKeyword=${fn:escapeXml(searchKeyVal)}&sort=${sortVal}">
              ${p}
            </a>
          </li>
        </c:forEach>
      </ul>
    </nav>
  </c:if>
</div>
