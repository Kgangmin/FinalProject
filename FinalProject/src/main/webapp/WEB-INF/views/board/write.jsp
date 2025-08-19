<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 게시판 사이드바 -->
<jsp:include page="/WEB-INF/views/board/boardSideBar.jsp" />

<style>
  /* 메인(170) + 게시판(200) = 370px만큼 본문 우측으로 */
  .board-content { margin-left: 370px; padding: 24px; max-width: 980px; }
  .card { border-color: rgba(0,0,0,.08); }
  .form-text { color:#6c757d; }
</style>

<!-- 현재 카테고리/기본값 세팅 -->
<c:set var="currentCatNo"   value="${not empty cat ? cat.board_category_no : param.category}" />
<c:set var="currentCatName" value="${not empty cat ? cat.board_category_name : ''}" />
<c:set var="defaultAllowComment" value="${not empty cat ? (cat.is_comment_enabled=='Y') : true}" />
<c:set var="defaultAllowReadList" value="${not empty cat ? (cat.is_read_enabled=='Y') : true}" />

<div class="board-content">
  <!-- 제목 영역 -->
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h2 class="h5 m-0 text-primary">글쓰기</h2>
      <small class="text-muted">
        <c:if test="${not empty currentCatName}">카테고리: <strong>${fn:escapeXml(currentCatName)}</strong></c:if>
      </small>
    </div>
    <div>
      <a class="btn btn-outline-secondary btn-sm"
         href="<%=ctxPath%>/board?category=${currentCatNo}">목록</a>
    </div>
  </div>

  <!-- 작성 폼 -->
  <form method="post" action="<%=ctxPath%>/board/write" enctype="multipart/form-data">
    <!-- 카테고리 선택 -->
    <div class="card shadow-sm mb-3">
      <div class="card-body">
        <div class="form-group">
          <label for="category" class="font-weight-bold">카테고리</label>
          <select class="form-control" id="category" name="fk_board_category_no" required>
            <c:forEach var="c0" items="${categories}">
              <option value="${c0.board_category_no}"
                <c:if test="${currentCatNo == c0.board_category_no}">selected</c:if>>
                <c:out value="${c0.board_category_name}"/>
              </option>
            </c:forEach>
          </select>
          <small class="form-text">
            부서게시판은 본인 부서가 아니면 작성이 제한됩니다. (서버에서 권한 검증)
          </small>
        </div>
      </div>
    </div>

    <!-- 기본 정보 -->
    <div class="card shadow-sm mb-3">
      <div class="card-body">
        <div class="form-group">
          <label for="title" class="font-weight-bold">제목</label>
          <input type="text" class="form-control" id="title" name="board_title"
                 maxlength="100" required placeholder="제목을 입력하세요" />
          <small class="form-text">최대 100자</small>
        </div>

        <div class="form-group mb-0">
          <label for="content" class="font-weight-bold">내용</label>
          <textarea class="form-control" id="content" name="board_content" rows="12"
                    maxlength="1000" required placeholder="내용을 입력하세요"></textarea>
          <small class="form-text">최대 1000자</small>
        </div>
      </div>
    </div>

    <!-- 옵션/첨부 -->
    <div class="card shadow-sm mb-3">
      <div class="card-body">
        <div class="form-row">
          <div class="col-md-6">
            <div class="custom-control custom-checkbox mb-2">
              <input type="checkbox" class="custom-control-input" id="allowComment"
                     name="allow_comment" value="Y"
                     <c:if test="${defaultAllowComment}">checked</c:if> />
              <label class="custom-control-label" for="allowComment">
                댓글 허용
              </label>
            </div>
            <div class="custom-control custom-checkbox mb-2">
              <input type="checkbox" class="custom-control-input" id="allowReadList"
                     name="allow_read_list" value="Y"
                     <c:if test="${defaultAllowReadList}">checked</c:if> />
              <label class="custom-control-label" for="allowReadList">
                읽은 사람 목록 공개
              </label>
            </div>
            <small class="form-text">
              카테고리 정책과 충돌 시 서버 정책이 우선됩니다.
            </small>
          </div>
          <div class="col-md-6">
            <div class="form-group mb-0">
              <label for="files" class="font-weight-bold">첨부파일</label>
              <input type="file" id="files" name="files" class="form-control-file" multiple />
              <small class="form-text">여러 개 선택 가능 • 총 용량 제한은 서버 설정에 따릅니다.</small>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 답글쓰기용(옵션): parent_board_no 파라미터가 있으면 포함 -->
    <c:if test="${not empty param.parent}">
      <input type="hidden" name="parent_board_no" value="${param.parent}" />
    </c:if>

    <!-- 액션 버튼 -->
    <div class="d-flex">
      <button type="submit" class="btn btn-primary mr-2">등록</button>
      <a class="btn btn-outline-secondary"
         href="<%=ctxPath%>/board?category=${currentCatNo}">취소</a>
    </div>
  </form>
</div>
