<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
html, body {
  background-color: #fff !important; /* 전체 화면 흰색 */
  margin: 0;
  padding: 0;
  height: 100%;
}

  /* ===== 중간 사이드바(카테고리) ===== */
  .board-panel {
    position: fixed;
    top: 70px;          /* 헤더 높이 */
    left: 180px;        /* 메인(왼쪽) 사이드바 폭 */
    width: 250px;
    height: calc(100vh - 70px);
    background: #fff;
    border-right: 1px solid rgba(0,0,0,.12);
    padding: 20px;
    overflow-y: auto;
    z-index: 1020;
  }
  .board-panel .section-title { font-weight: 700; }
  .board-panel .write-btn,
  .board-panel .boardAdd-btn { width: 100%; }
  .board-panel .toggle .arrow { width: 1rem; display: inline-block; text-align: center; }
  .board-panel .arrow { visibility: hidden; }
  .board-panel .toggle:hover .arrow { visibility: visible; }
  .board-panel .acc-list { display: none; }

  /* ===== 본문 영역: 카테고리 폭만큼 왼쪽 여백 확보 ===== */
  /* 기존 .board-content 수정 */
.board-content {   
  padding: 32px;
  max-width: 1200px;      /* 본문 최대 폭 제한 */
  margin-right: auto;    /* 왼쪽, 오른쪽 여백 균등 */
  margin-left: 440px;    /* 카테고리 여백 유지 */
}


</style>
<script>
  // jQuery만으로 토글(열기/닫기) + 화살표 변경
  $(function(){
    $('.board-panel').on('click', '.toggle', function(){
      var $btn   = $(this);
      var target = $btn.data('target');        // "#favList"
      var $list  = $(target);
      var $arrow = $btn.find('.arrow');

      if ($list.is(':visible')) {
        $list.stop(true, true).slideUp(160);
        $btn.attr('aria-expanded', 'false');
        $arrow.text('▷');
      } else {
        $list.stop(true, true).slideDown(160);
        $btn.attr('aria-expanded', 'true');
        $arrow.text('▽');
      }
    });
  });
</script>

<!-- ===== 중간 사이드바 ===== -->
<div class="board-panel">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="h4 section-title m-0">게시판</h2>
  </div>

<button type="button"
        class="btn btn-primary write-btn btn-lg mb-4"
        onclick="location.href='<%=ctxPath%>/board/addPost'">글쓰기</button>

  <!-- 즐겨찾기 -->
  <div class="mb-3">
    <button type="button" class="btn btn-link text-left w-100 toggle px-0 text-dark"
            data-target="#favList" aria-expanded="false" aria-controls="favList">
      <span class="arrow mr-1">▷</span><span class="font-weight-bold">즐겨찾기</span>
    </button>
    <div id="favList" class="acc-list pl-3">
      <ul class="list-unstyled mb-0">
        <li><a class="d-inline-block py-1 text-dark" href="#">전사 알림</a></li>
        <li><a class="d-inline-block py-1 text-dark" href="#">자유 게시판</a></li>
      </ul>
    </div>
  </div>

  <!-- 전사게시판 -->
  <div class="mb-3">
    <button type="button" class="btn btn-link text-left w-100 toggle px-0 text-dark"
            data-target="#corpList" aria-expanded="false" aria-controls="corpList">
      <span class="arrow mr-1">▷</span><span class="font-weight-bold">전사게시판</span>
    </button>
    <div id="corpList" class="acc-list pl-3">
      <ul class="list-unstyled mb-0">
        <li><a class="d-inline-block py-1 text-dark" href="#">전사 공지</a></li>
        <li><a class="d-inline-block py-1 text-dark" href="#">전사 알림</a></li>
        <li><a class="d-inline-block py-1 text-dark" href="#">자유 게시판</a></li>
        <li><a class="d-inline-block py-1 text-dark" href="#">동호회 소식</a></li>
      </ul>
    </div>
  </div>

  <!-- 부서게시판 -->
  <div class="mb-3">
    <button type="button" class="btn btn-link text-left w-100 toggle px-0 text-dark"
            data-target="#deptList" aria-expanded="false" aria-controls="deptList">
      <span class="arrow mr-1">▷</span><span class="font-weight-bold">부서게시판</span>
    </button>
    <div id="deptList" class="acc-list pl-3">
      <ul class="list-unstyled mb-0">
        <li><a class="d-inline-block py-1 text-dark" href="#">경영</a></li>
        <li><a class="d-inline-block py-1 text-dark" href="#">마케팅</a></li>
        <li><a class="d-inline-block py-1 text-dark" href="#">인사</a></li>
      </ul>
    </div>
  </div>

<button type="button"
        class="btn btn-primary write-btn btn-lg mb-4"
        onclick="location.href='<%=ctxPath%>/board/addBoard'">+게시판 추가</button>
        
</div>

