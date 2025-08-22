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
  :root {
    --header-h: 70px;          /* 헤더 높이(상황 맞게 조정) */
    --sidebar-w: 370px;        /* 사이드바 합계(메인+서브) */
    --list: 540px;           /* 게시글 리스트 고정 높이 */
  }

  /* 본문은 사이드바 폭만큼 오른쪽으로, 세로는 화면 높이에 맞춰 최소 확보 */
  .board-content {
    margin-left: var(--sidebar-w);
    padding: 24px;
    max-width: 1200px;
    min-height: calc(100vh - var(--header-h));
    display: flex;
    flex-direction: column;
  }

  /* 리스트 카드 자체는 고정 높이 */
  .list-frame {
    height: var(--list);
    display: flex;
    flex-direction: column;
    border-color: rgba(0,0,0,.08);
  }
  /* 표 스크롤 영역 */
  .list-scroll {
    flex: 1 1 auto;
    overflow: auto;
  }
  /* 헤더 고정(스크롤 시 thead가 따라다님) */
  .table thead th {
    position: sticky; top: 0; z-index: 2;
    background: #0d6efd; color: #fff; /* 네가 쓰는 bg-primary 컬러와 일치 */
  }
  .table-hover tbody tr:hover { background: #f8fbff; }

  /* 사이드바( boardSideBar.jsp 에서 쓰는 클래스명이 같다면 여기로 강제 적용 ) */
  .sidebar-main, .sidebar-sub {
    position: fixed;
    top: var(--header-h);
    bottom: 0;                 /* 화면 하단에 고정 */
    overflow-y: auto;          /* 긴 경우 자체 스크롤 */
  }

 .badge.badge-primary.badge-pill { font-size: .75rem; }
  
</style>


<!-- 호환: 파라미터/모델 값 기본셋 -->
<c:set var="currentCatNo"   value="${not empty cat ? cat.board_category_no : param.category}" />
<c:set var="currentCatName" value="${not empty cat ? cat.board_category_name : ''}" />
<c:set var="pageNum"        value="${empty page ? (empty param.page ? 1 : param.page) : page}" />
<c:set var="pageSize"       value="${empty size ? (empty param.size ? 10 : param.size) : size}" />
<c:set var="sortVal"        value="${empty sort ? (empty param.sort ? 'latest' : param.sort) : sort}" />
<c:set var="searchTypeVal"  value="${empty searchType ? param.searchType : searchType}" />
<c:set var="searchKeyVal"   value="${empty searchKeyword ? param.searchKeyword : searchKeyword}" />

<c:if test="${not empty msg}">
  <div class="alert alert-warning alert-dismissible fade show py-2 px-3" role="alert" style="margin-top:8px; margin-left:400px; ">
    ${msg}
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
</c:if>


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
  <div class="card shadow-sm list-frame"><!-- 👈 list-frame 추가 -->
  <div class="card-body p-0 list-scroll"><!-- 👈 list-scroll 추가 -->
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
             
						<c:if test="${not empty post.comment_cnt && post.comment_cnt ne '0'}">
						  <span class="badge badge-primary badge-pill ml-1 align-text-middle" title="댓글 수">
						    ${post.comment_cnt}
						  </span>
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

  <!-- 페이징 바 -->
<div class="d-flex justify-content-center my-3">
  <ul class="pagination mb-0">

    <!-- ◀ 이전 or ◀ 이전 10 -->
    <c:choose>
      <c:when test="${hasPrevNav}">
        <c:url var="prevUrl" value="/board">
          <c:param name="category" value="${cat.board_category_no}" />
          <c:param name="page" value="${prevNavPage}" />
          <c:param name="size" value="${size}" />
          <c:param name="searchType" value="${searchType}" />
          <c:param name="searchKeyword" value="${searchKeyword}" />
          <c:param name="sort" value="${sort}" />
        </c:url>
        <li class="page-item">
          <a class="page-link text-primary" href="${prevUrl}">${prevLabel}</a>
        </li>
      </c:when>
      <c:otherwise>
        <li class="page-item disabled">
          <span class="page-link">${prevLabel}</span>
        </li>
      </c:otherwise>
    </c:choose>

    <!-- 페이지 번호들 (항상 blockStartPage ~ blockEndPage 범위) -->
    <c:forEach var="p" begin="${blockStartPage}" end="${blockEndPage}">
      <c:url var="pageUrl" value="/board">
        <c:param name="category" value="${cat.board_category_no}" />
        <c:param name="page" value="${p}" />
        <c:param name="size" value="${size}" />
        <c:param name="searchType" value="${searchType}" />
        <c:param name="searchKeyword" value="${searchKeyword}" />
        <c:param name="sort" value="${sort}" />
      </c:url>
      <li class="page-item ${p == page ? 'active' : ''}">
        <a class="page-link" href="${pageUrl}">${p}</a>
      </li>
    </c:forEach>

    <!-- 다음 ▶ or 다음 10 ▶ -->
    <c:choose>
      <c:when test="${hasNextNav}">
        <c:url var="nextUrl" value="/board">
          <c:param name="category" value="${cat.board_category_no}" />
          <c:param name="page" value="${nextNavPage}" />
          <c:param name="size" value="${size}" />
          <c:param name="searchType" value="${searchType}" />
          <c:param name="searchKeyword" value="${searchKeyword}" />
          <c:param name="sort" value="${sort}" />
        </c:url>
        <li class="page-item">
          <a class="page-link text-primary" href="${nextUrl}">${nextLabel}</a>
        </li>
      </c:when>
      <c:otherwise>
        <li class="page-item disabled">
          <span class="page-link">${nextLabel}</span>
        </li>
      </c:otherwise>
    </c:choose>

  </ul>
</div>


</div>
