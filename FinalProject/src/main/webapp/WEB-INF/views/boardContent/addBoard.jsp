<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 공통 사이드바 -->
<jsp:include page="/WEB-INF/views/boardContent/boardSideBar.jsp" />

<!-- Bootstrap / jQuery (헤더에서 이미 로드됐다면 중복 제거 가능) -->
<link rel="stylesheet" href="<%=ctxPath%>/bootstrap-4.6.2-dist/css/bootstrap.min.css" type="text/css" />
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>

<style>
  /* 사이드바 폭만큼 본문 우측 이동 (네 레이아웃 유지) */
  .board-content{
    margin-left: 640px; /* left 220 + middle 400 + 여백 */
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
    // 저장 클릭
    $('#btnSaveBoard').on('click', function(){
      // 간단 검증
      var name = $.trim($('#board_name').val());
      if(!name){
        alert('게시판 이름을 입력하세요.');
        $('#board_name').focus();
        return;
      }

      // 미체크 토글은 0으로 값 추가 (중복 파라미터 방지: 체크 안 된 것만 hidden 추가)
      var toggles = [
        'is_comment_enabled',
        'is_attach_enable',
        'readcheck_enable'
      ];
      toggles.forEach(function(nm){
        var $cb = $('input[name="'+nm+'"]');
        if(!$cb.is(':checked')){
          // 같은 name으로 값이 없을 때만 0을 추가
          if($('#addBoardFrm input[type="hidden"][name="'+nm+'"]').length === 0){
            $('<input type="hidden" name="'+nm+'" value="0">').appendTo('#addBoardFrm');
          }
        }else{
          // 체크된 경우, 혹시 이전에 만들어진 hidden이 있으면 제거
          $('#addBoardFrm input[type="hidden"][name="'+nm+'"]').remove();
        }
      });

      $('#addBoardFrm').submit();
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
      <!-- 저장은 다음 단계에서 POST 매핑 연결 (/board/addBoard POST) -->
      <form id="addBoardFrm" method="post" action="<%=ctxPath%>/board/addBoard">
        <!-- 게시판 이름 -->
        <div class="form-group">
          <label for="board_name" class="font-weight-semibold">게시판 이름 <span class="text-danger">*</span></label>
          <input type="text" id="board_name" name="board_name" class="form-control" maxlength="100" placeholder="예) 전사 공지" required />
        </div>

        <!-- 설명 -->
        <div class="form-group">
          <label for="board_desc" class="font-weight-semibold">설명</label>
          <textarea id="board_desc" name="board_desc" class="form-control" rows="4" placeholder="게시판 용도나 안내를 적어주세요."></textarea>
        </div>

        <!-- 옵션 (토글 스위치) -->
        <div class="mb-3">
          <label class="font-weight-semibold d-block mb-2">옵션</label>

          <div class="row">
            <div class="col-md-4 mb-3">
              <div class="feature-card h-100">
                <div class="custom-control custom-switch">
                  <input type="checkbox" class="custom-control-input" id="is_comment_enabled" name="is_comment_enabled" value="1">
                  <label class="custom-control-label" for="is_comment_enabled">댓글 허용</label>
                </div>
                <p class="feature-desc mb-0">사용자 댓글 기능을 켭니다.</p>
              </div>
            </div>

            <div class="col-md-4 mb-3">
              <div class="feature-card h-100">
                <div class="custom-control custom-switch">
                  <input type="checkbox" class="custom-control-input" id="is_attach_enable" name="is_attach_enable" value="1">
                  <label class="custom-control-label" for="is_attach_enable">첨부파일 허용</label>
                </div>
                <p class="feature-desc mb-0">파일 업로드를 허용합니다.</p>
              </div>
            </div>

            <div class="col-md-4 mb-3">
              <div class="feature-card h-100">
                <div class="custom-control custom-switch">
                  <input type="checkbox" class="custom-control-input" id="readcheck_enable" name="readcheck_enable" value="1">
                  <label class="custom-control-label" for="readcheck_enable">수신확인 사용</label>
                </div>
                <p class="feature-desc mb-0">수신 확인기능 활성화 여부.</p>
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


