<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 공통 헤더 / 사이드바 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/boardContent/boardSideBar.jsp" />

<!-- Bootstrap / jQuery (헤더에서 이미 로드됐다면 생략 가능) -->
<link rel="stylesheet" href="<%=ctxPath%>/bootstrap-4.6.2-dist/css/bootstrap.min.css" type="text/css" />
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>

<style>
  /* 사이드바 폭만큼 본문 우측 이동 (네 레이아웃 유지) */
  .board-content{
    margin-left: 460px; /* left 220 + middle 400 + 여백 */
    padding: 32px;
    max-width: 1000px;
  }
  .feature-card{
    border: 1px solid rgba(0,0,0,.08);
    border-radius: .5rem;
    padding: 16px;
  }
  .feature-desc{
    font-size: .875rem;
    color: #6c757d;
    margin: 4px 0 0 0;
  }
</style>

<script>
  $(function(){
    $('#btnSaveBoard').on('click', function(){
      // 1) 필수값 체크
      const name = $('#board_category_name').val().trim();
      if(!name){
        alert('게시판 이름을 입력하세요');
        $('#board_category_name').focus();
        return;
      }

      // 2) 토글값을 Y/N으로 고정 (미체크 시 N을 히든으로 보냄)
      const $frm = $('#addBoardFrm');

      // 중복 히든 제거
      $frm.find('input[type="hidden"][name="is_comment_enabled"]').remove();
      $frm.find('input[type="hidden"][name="is_read_enabled"]').remove();

      // 댓글 허용
      if ($('#is_comment_enabled').is(':checked')) {
        $('#is_comment_enabled').val('Y'); // 체크되면 Y
      } else {
        $('<input type="hidden" name="is_comment_enabled" value="N">').appendTo($frm);
      }

      // 읽음확인 사용
      if ($('#is_read_enabled').is(':checked')) {
        $('#is_read_enabled').val('Y'); // 체크되면 Y
      } else {
        $('<input type="hidden" name="is_read_enabled" value="N">').appendTo($frm);
      }

      // 3) 제출
      $frm[0].submit();
    });
  });
</script>

<div class="board-content">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="h4 m-0">게시판 추가</h2>
    <a class="btn btn-outline-secondary btn-sm" href="<%=ctxPath%>/board/board">목록</a>
  </div>

  <div class="card shadow-sm">
    <div class="card-body">
      <!-- POST 매핑: /board/addBoard -->
      <form id="addBoardFrm" method="post" action="<%=ctxPath%>/board/addBoard">
        <!-- 게시판 이름 (== board_category_name) -->
        <div class="form-group">
          <label for="board_category_name" class="font-weight-semibold">게시판 이름 <span class="text-danger">*</span></label>
          <input type="text"
                 id="board_category_name"
                 name="board_category_name"
                 class="form-control"
                 maxlength="100"
                 placeholder="예) 전사 공지"
                 required />
        </div>

        <!-- 옵션 (토글 스위치) -->
        <div class="mb-3">
          <label class="font-weight-semibold d-block mb-2">옵션</label>

          <div class="row">
            <!-- is_comment_enabled (Y/N) -->
            <div class="col-md-6 mb-3">
              <div class="feature-card h-100">
                <div class="custom-control custom-switch">
                  <input type="checkbox"
                         class="custom-control-input"
                         id="is_comment_enabled"
                         name="is_comment_enabled"
                         value="Y">
                  <label class="custom-control-label" for="is_comment_enabled">댓글 허용</label>
                </div>
                <p class="feature-desc mb-0">사용자 댓글 기능을 켭니다.</p>
              </div>
            </div>

            <!-- is_read_enabled (Y/N) -->
            <div class="col-md-6 mb-3">
              <div class="feature-card h-100">
                <div class="custom-control custom-switch">
                  <input type="checkbox"
                         class="custom-control-input"
                         id="is_read_enabled"
                         name="is_read_enabled"
                         value="Y">
                  <label class="custom-control-label" for="is_read_enabled">읽음 확인 사용</label>
                </div>
                <p class="feature-desc mb-0">수신/열람 확인 기능을 활성화합니다.</p>
              </div>
            </div>
          </div>
        </div>

        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-light mr-2" onclick="location.href='<%=ctxPath%>/board/board'">취소</button>
          <button type="button" id="btnSaveBoard" class="btn btn-dark">저장</button>
        </div>
      </form>
    </div>
  </div>
</div>
