<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
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

    <!-- 읽은 사람 (카테고리 허용일 때만 노출) -->
    <c:if test="${cat.is_read_enabled=='Y'}">
      <div class="mb-3">
        <strong>읽은 사람</strong>
        <span class="text-muted">(${readersCnt}명)</span>
        <div class="mt-1">
          <c:forEach var="r" items="${readers}">
            <span class="badge bg-secondary me-1">${r.emp_name}(${r.emp_no})</span>
          </c:forEach>
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

    <!-- 댓글 (카테고리 허용일 때만 입력창 노출) -->
    <c:if test="${cat.is_comment_enabled=='Y'}">
      <form class="mb-3" method="post" action="${pageContext.request.contextPath}/board/comment">
        <input type="hidden" name="fk_board_no" value="${b.board_no}">
        <div class="input-group">
          <input type="text" class="form-control" name="comment_content" placeholder="댓글을 입력하세요">
          <button class="btn btn-primary">등록</button>
        </div>
      </form>
    </c:if>

    <!-- 댓글 목록(5개 페이징은 Ajax로 확장 가능 / 여기서는 간단 표시 생략 가능) -->
    <!-- TODO: 필요 시 /board/comments?board_no=... API로 불러와 렌더링 -->

    <div class="mt-4">
      <a class="btn btn-secondary" href="${pageContext.request.contextPath}/board?category=${b.fk_board_category_no}">목록</a>
    </div>
  </div>
</body>
</html>
