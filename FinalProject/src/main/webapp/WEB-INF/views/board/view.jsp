<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>



<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 게시판 사이드바 -->
<jsp:include page="/WEB-INF/views/board/boardSideBar.jsp" />

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${b.board_title}</title>
  <link href="${pageContext.request.contextPath}/resources/bootstrap.min.css" rel="stylesheet" />
  <style>
    .sidebar-main { position:fixed; top:70px; left:0; width:180px; }
    .sidebar-sub  { position:fixed; top:70px; left:180px; width:190px; }
    .content      { margin-left:370px; padding:20px; }
  </style>
</head>
<body class="bg-light">
  <div class="sidebar-main"></div>
  <div class="sidebar-sub"></div>
  <div class="content">
    <div class="mb-3">
      <h4 class="mb-1">${fn:escapeXml(b.board_title)}</h4>
      <div class="text-muted small">
        글번호 ${b.board_no} · 작성자 ${b.fk_emp_no} · 등록일 ${b.register_date} · 조회 ${b.view_cnt}
      </div>
    </div>

    <div class="card mb-3">
      <div class="card-body" style="white-space:pre-wrap">${fn:escapeXml(b.board_content)}</div>
    </div>

    <!-- 열람현황 목록(카테고리에서 허용일 때만 표시) -->
<c:if test="${cat.is_read_enabled == 'Y'}">
  <div class="mt-4">
    <button class="btn btn-outline-primary btn-sm"
            type="button"
            data-toggle="collapse"
            data-target="#readersBox"
            aria-expanded="false"
            aria-controls="readersBox">
      열람 현황
      <span class="badge badge-primary ml-1">${readersCnt}</span>
    </button>

    <div class="collapse mt-2" id="readersBox">
      <c:choose>
        <c:when test="${readersCnt > 0}">
          <div class="card shadow-sm">
            <div class="card-body py-2">
              <!-- 이름 뱃지 리스트 -->
              <div class="d-flex flex-wrap">
                <c:forEach var="r" items="${readers}">
                  <span class="badge badge-light border text-dark mr-2 mb-2">
                     ${r['EMP_NAME']}
                  </span>
                </c:forEach>
              </div>
            </div>
          </div>
        </c:when>
        <c:otherwise>
          <div class="text-muted small mt-2">아직 열람자가 없습니다.</div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</c:if>




    <!-- 이전/다음 -->
    <div class="d-flex justify-content-between my-3">
      <div>
        <c:if test="${not empty prev}">
          <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/board/view/${prev.board_no}">← 이전 글</a>
        </c:if>
      </div>
      <div>
        <c:if test="${not empty next}">
          <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/board/view/${next.board_no}">다음 글 →</a>
        </c:if>
      </div>
    </div>

    <!-- 댓글 영역 -->

  <c:if test="${canComment}">
  <!-- 입력폼 -->
  <form class="mb-3" method="post" action="${pageContext.request.contextPath}/board/comment">
    <input type="hidden" name="fk_board_no" value="${b.board_no}">
    <div class="input-group">
      <input type="text" class="form-control" name="comment_content" placeholder="댓글을 입력하세요">
      <button class="btn btn-primary">등록</button>
    </div>
  </form>

  <!-- 댓글 리스트 -->
  <div class="card shadow-sm mb-3">
    <div class="card-header bg-white d-flex align-items-center">
      <strong>댓글</strong>
      <span class="badge badge-primary ml-2">
        <c:out value="${fn:length(comments)}"/>
      </span>
    </div>

    <div class="list-group list-group-flush">
      <c:choose>
        <c:when test="${not empty comments}">
          <c:forEach var="cmt" items="${comments}">
            <div class="list-group-item">
              <div class="d-flex justify-content-between align-items-center">
                <div class="font-weight-bold">
                  <c:out value="${cmt.writer_name}"/>
                </div>
                <small class="text-muted">
                  <c:out value="${cmt.register_date}"/>
                </small>
              </div>
              <div class="mt-1">
                <c:out value="${cmt.comment_content}"/>
              </div>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="list-group-item text-center text-muted">
            첫 댓글을 남겨주세요.
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</c:if>

<c:if test="${not empty files}">
  <div class="card shadow-sm my-3">
    <div class="card-header bg-primary text-white py-2">
      첨부파일
    </div>
    <ul class="list-group list-group-flush">
      <c:forEach var="f" items="${files}">
        <li class="list-group-item d-flex justify-content-between align-items-center">
          <a class="text-body" href="${pageContext.request.contextPath}/board/file/${f.board_file_no}">
            ${f.board_origin_filename}
          </a>
          <small class="text-muted">
            <c:out value="${f.board_filesize}"/> bytes
          </small>
        </li>
      </c:forEach>
    </ul>
  </div>
</c:if>



<c:if test="${not canComment}">
  <div class="alert alert-light border text-muted">
    이 게시판은 댓글이 비활성화되어 있습니다.
  </div>
</c:if>


  <!-- 하단 버튼 -->
<div class="mt-4">
  <a class="btn btn-secondary" href="${pageContext.request.contextPath}/board?category=${b.fk_board_category_no}">목록</a>
</div>

<c:if test="${sessionScope.loginuser != null && sessionScope.loginuser.emp_no == b.fk_emp_no}">
  <form method="post"
        action="${pageContext.request.contextPath}/board/delete/${b.board_no}"
        onsubmit="return confirm('이 글을 삭제하시겠습니까? 댓글/첨부도 함께 삭제됩니다.');"
        class="d-inline-block">
    <c:if test="${not empty _csrf}">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
    </c:if>
    <button type="submit" class="btn btn-primary btn-sm mt-3">글 삭제</button>
  </form>
</c:if>


</div>



</body>
</html>
