<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 공통 사이드바 -->
<jsp:include page="/WEB-INF/views/boardContent/boardSideBar.jsp" />

<link rel="stylesheet" href="<%=ctxPath%>/bootstrap-4.6.2-dist/css/bootstrap.min.css" type="text/css" />
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>

<style>
  /* 본문을 사이드바 폭만큼 오른쪽으로 밀기 (네 레이아웃과 일치) */
  .board-content {
    margin-left: 450px;   /* left(220) + middle(400) + 여백 */
    padding: 32px;
    max-width: 1500px;
  }
</style>

<script type="text/javascript">
  $(function () {
   
	    // 등록 버튼 클릭
	    $('#btnWrite').on('click', function () {

	      // 1) 게시판 구분
	      if (!$('#fk_board_category_no').val()) {
	        alert('게시판 구분을 선택하세요');
	        $('#fk_board_category_no').focus();
	        return;
	      }

	      // 2) 제목
	      var title = $.trim($('#board_title').val() || '');
	      if (!title) {
	        alert('제목을 입력하세요');
	        $('#board_title').focus();
	        return;
	      }

	      // 3) 내용 (textarea)
	      var content = $.trim($('#board_content').val() || '');
	      if (!content) {
	        alert('내용을 입력하세요');
	        $('#board_content').focus();
	        return;
	      }

	      $('#addFrm').submit();
	    });
	  
	  
  });
</script>

<div class="board-content">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="h4 m-0">
      <c:choose>
        <c:when test="${empty param.parent_board_no}">글쓰기</c:when>
        <c:otherwise>답변글쓰기</c:otherwise>
      </c:choose>
    </h2>
    <a class="btn btn-outline-secondary btn-sm" href="<%=ctxPath%>/board/list">목록</a>
  </div>

  <!-- 알림/에러 -->
  <c:if test="${not empty msg}">
    <div class="alert alert-info"><c:out value="${msg}"/></div>
  </c:if>
  <c:if test="${not empty errors}">
    <div class="alert alert-danger">
      <c:forEach var="e" items="${errors}">
        <div><c:out value="${e}"/></div>
      </c:forEach>
    </div>
  </c:if>

  <div class="card shadow-sm">
    <div class="card-body">
      <!-- 파일 첨부를 위해 multipart + POST -->
      <form name="addFrm" id="addFrm" method="post" action="<%=ctxPath%>/board/submitPost" enctype="multipart/form-data">
        <!-- 작성자 사번 -->
        <div class="form-group">
          <label class="font-weight-semibold">작성자</label>
          <div class="form-row">
            <div class="col-md-4">
              <input type="hidden" name="fk_emp_no" value="${sessionScope.loginuser.empNo}" />
              <input type="text" name="writer_name" value="${sessionScope.loginuser.name}" class="form-control" readonly />
            </div>
          </div>
        </div>

        <!-- 게시판 구분 (tbl_board_category) -->
        <div class="form-group">
          <label for="fk_board_category_no" class="font-weight-semibold">게시판 구분 <span class="text-danger">*</span></label>
          <select id="fk_board_category_no" name="fk_board_category_no" class="form-control" required>
            <option value="1">선택</option>
            <c:forEach var="cat" items="${requestScope.boardCategories}">
              <option value="${cat.board_category_no}" data-attach="${cat.is_attach_enable}">
                <c:out value="${cat.board_name}"/>
              </option>
            </c:forEach>
          </select>
          <small class="form-text text-muted">예) 전사 공지, 전사 알림, 부서 게시판 등</small>
        </div>

        <!-- 제목 -->
        <div class="form-group">
          <label for="board_title" class="font-weight-semibold">제목 <span class="text-danger">*</span></label>
          <input type="text" id="board_title" name="board_title" class="form-control" maxlength="200"
                 value="<c:out value='${requestScope.board_title}'/>"
                 <c:if test='${not empty param.parent_board_no}'>readonly</c:if> />
          <small class="form-text text-muted"><span id="titleCount">0</span>/200</small>
        </div>

        <!-- 내용 -->
        <div class="form-group">
          <label for="board_content" class="font-weight-semibold">내용 <span class="text-danger">*</span></label>
          <textarea id="board_content" name="board_content" class="form-control" rows="12"></textarea>
        </div>

        <!-- 옵션: 공지 / 상단고정 (토글 스위치) -->
        <div class="form-group">
          <div class="d-flex align-items-center">
            <div class="custom-control custom-switch mr-4">
              <input class="custom-control-input" type="checkbox" id="is_notice" name="is_notice" value="1" />
              <label class="custom-control-label" for="is_notice">공지글 여부</label>
            </div>
            <div class="custom-control custom-switch">
              <input class="custom-control-input" type="checkbox" id="is_pinned" name="is_pinned" value="1" />
              <label class="custom-control-label" for="is_pinned">상단 고정</label>
            </div>
          </div>
        </div>

        <!-- 첨부파일 -->
        <div class="form-group" id="attachRow">
          <label for="attach" class="font-weight-semibold">파일첨부</label>
          <input type="file" id="attach" name="attach" class="form-control-file" />
          <small class="form-text text-muted">필요 시 하나의 파일을 첨부하세요.</small>
        </div>

        <!-- 계층/정렬(필요 시) -->
        <input type="hidden" name="parent_board_no" value="${param.parent_board_no}" />
        <input type="hidden" name="board_priority" value="0" />

        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-light mr-2" onclick="location.href='<%=ctxPath%>/board/list'">취소</button>
          <button type="button" id="btnWrite" class="btn btn-dark">등록</button>
        </div>
      </form>
    </div>
  </div>
</div>
