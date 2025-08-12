<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>

<!-- 메일 전용 사이드바 (고정 레이아웃은 email.css에서 처리) -->
<aside class="mail-sidebar">
  <div class="mail-card card mb-3">
    <div class="card-header d-flex align-items-center justify-content-between">
      <span class="h6 mb-0">메일함</span>
    </div>

    <div class="card-body">
      <!-- 상단 버튼 2개 -->
      <div class="d-flex mb-3">
        <button type="button" class="btn btn-primary mr-2" style="flex:1" id="btnCompose">메일쓰기</button>
        <button type="button" class="btn btn-primary" style="flex:1" id="btnToMe">내게쓰기</button>
      </div>

      <!-- 필터 버튼 3개 가로 배치 -->
      <div class="mail-filter-group btn-group btn-group-toggle d-flex mb-3" data-toggle="buttons">
        <label class="btn btn-soft flex-fill">
          <input type="checkbox" autocomplete="off" id="filterUnread"> 안읽음
        </label>
        <label class="btn btn-soft flex-fill">
          <input type="checkbox" autocomplete="off" id="filterStar"> 중요
        </label>
        <label class="btn btn-soft flex-fill">
          <input type="checkbox" autocomplete="off" id="filterAttach"> 첨부
        </label>
      </div>

      <hr class="my-3">

      <!-- 폴더 목록 -->
      <div class="mail-folders list-group">
        <a href="<%=ctxPath%>/mail/email" class="list-group-item active" data-folder="all">전체메일</a>
        <a href="#" class="list-group-item" data-folder="inbox">받은메일</a>
        <a href="#" class="list-group-item" data-folder="sent">보낸메일</a>
        <a href="#" class="list-group-item" data-folder="tome">내게쓴메일</a>
      </div>

      <!-- 하단 휴지통 -->
      <div class="mail-trash">
        <hr>
        <a href="#" class="list-group-item" data-folder="trash">휴지통</a>
      </div>
    </div>
  </div>
</aside>
<script type="text/javascript">

$(document).ready(function(){
  $('#btnCompose').on('click', function() {
    location.href = '<%=ctxPath%>/mail/compose';
  });
});


</script>