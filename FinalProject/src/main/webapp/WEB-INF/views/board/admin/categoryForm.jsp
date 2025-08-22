<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 사이드바 -->
<jsp:include page="/WEB-INF/views/board/boardSideBar.jsp" />

<style>
  /* 메인(170) + 게시판(200) = 370px 만큼 본문을 오른쪽으로 */
  .board-content { margin-left: 390px; padding: 24px; max-width: 1200px; }

</style> 


<div class="board-content" >
  <div class="card shadow-sm">
    <div class="card-header bg-primary text-white">부서 게시판 추가</div>
    <div class="card-body">
      <form method="post" action="${pageContext.request.contextPath}/board/admin/category/add">
        <div class="form-group">
          <label class="font-weight-bold">게시판 이름</label>
          <input type="text" name="board_category_name" class="form-control" placeholder="예) 플랫폼개발팀" required />
        </div>
        <div class="form-group">
          <label class="font-weight-bold">대상 부서번호</label>
          <input type="text" name="target_dept_no" class="form-control" placeholder="예) 10101" required />
          <small class="text-muted">이 부서에 READ/WRITE 권한이 자동 부여됩니다.</small>
        </div>
        <div class="form-row">
          <div class="form-group col-md-6">
            <label class="font-weight-bold d-block">댓글 허용</label>
            <div class="custom-control custom-radio custom-control-inline">
              <input type="radio" id="cmtY" name="is_comment_enabled" value="Y" class="custom-control-input" checked>
              <label class="custom-control-label" for="cmtY">허용</label>
            </div>
            <div class="custom-control custom-radio custom-control-inline">
              <input type="radio" id="cmtN" name="is_comment_enabled" value="N" class="custom-control-input">
              <label class="custom-control-label" for="cmtN">비허용</label>
            </div>
          </div>
          <div class="form-group col-md-6">
            <label class="font-weight-bold d-block">열람자 목록 공개</label>
            <div class="custom-control custom-radio custom-control-inline">
              <input type="radio" id="rdY" name="is_read_enabled" value="Y" class="custom-control-input" checked>
              <label class="custom-control-label" for="rdY">공개</label>
            </div>
            <div class="custom-control custom-radio custom-control-inline">
              <input type="radio" id="rdN" name="is_read_enabled" value="N" class="custom-control-input">
              <label class="custom-control-label" for="rdN">비공개</label>
            </div>
          </div>
        </div>

        <div class="d-flex justify-content-between mt-3">
          <a class="btn btn-secondary" href="${pageContext.request.contextPath}/board">목록</a>
          <button type="submit" class="btn btn-primary">추가</button>
        </div>
      </form>
    </div>
  </div>
</div>
