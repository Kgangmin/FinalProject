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
      <div class="mail-filter-group btn-group d-flex mb-3 filter-tabs" role="group">
        <a href="#" class="btn btn-soft flex-fill" data-filter="unread">안읽음</a>
        <a href="#" class="btn btn-soft flex-fill" data-filter="star">중요</a>
        <a href="#" class="btn btn-soft flex-fill" data-filter="attach">첨부</a>
      </div>


      <hr class="my-3">

      <!-- 폴더 목록 -->
      <div class="mail-folders list-group">
        <a href="<%=ctxPath%>/mail/email?folder=all" class="list-group-item active" data-folder="all">전체메일</a>
        <a href="<%=ctxPath%>/mail/email?folder=inbox" class="list-group-item" data-folder="inbox">받은메일</a>
        <a href="<%=ctxPath%>/mail/email?folder=sent" class="list-group-item" data-folder="sent">보낸메일</a>
        <a href="<%=ctxPath%>/mail/email?folder=tome" class="list-group-item" data-folder="tome">내게쓴메일</a>
      </div>

      <!-- 하단 휴지통 -->
      <div class="mail-trash">
        <hr>
        <div class="d-flex align-items-center justify-content-between">
        <a href="<%=ctxPath%>/mail/email?folder=trash" class="list-group-item" data-folder="trash">휴지통</a>
        <button type="button"
                  id="btnEmptyTrash"
                  class="btn btn-link p-0 ml-2"
                  title="휴지통 비우기">
            🗑️
          </button>
       </div>
      </div>
    </div>
  </div>
</aside>
<script type="text/javascript">

$(document).ready(function(){
  $('#btnCompose').on('click', function() {
    location.href = '<%=ctxPath%>/mail/compose';
  });
  
  $('#btnToMe').on('click', function(){ 
	  location.href = '<%=ctxPath%>/mail/composeToMe'; 
	  });
  
  
  $(document).on('click', '#btnEmptyTrash', function(e){
	    e.preventDefault();
	    // 전역 커스텀 이벤트 발생 → email.jsp에서 잡아 처리
	    $(document).trigger('mail.emptyTrashAll');
	  });
  
});


</script>
