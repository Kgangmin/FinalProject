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
  .board-content { margin-left: 370px; padding: 24px; max-width: 1200px; }
  .card { border-color: rgba(0,0,0,.08); }
  .form-text { color:#6c757d; }
  
  
  
</style>
<script type="text/javascript" src="<%=ctxPath%>/smarteditor/js/HuskyEZCreator.js" charset="utf-8"></script> 


<!-- 현재 카테고리/기본값 세팅 -->
<c:set var="currentCatNo"   value="${not empty cat ? cat.board_category_no : param.category}" />
<c:set var="currentCatName" value="${not empty cat ? cat.board_category_name : ''}" />

<div class="board-content">

  <!-- 🔔 권한 이동 안내(Flash) -->
  <c:if test="${not empty msg}">
  <div id="flash-msg" data-msg="${fn:escapeXml(msg)}"></div>
  <script>
    (function(){
      var el = document.getElementById('flash-msg');
      if(el){
        alert(el.getAttribute('data-msg'));
        el.remove();
      }
    })();
  </script>
</c:if>


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
  <form method="post"
      action="<%=ctxPath%>/board/write"
      enctype="multipart/form-data"
      onsubmit="return submitContents(this);">

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
          <input type="text"
                 class="form-control"
                 id="title"
                 name="board_title"
                 maxlength="100"
                 required
                 placeholder="제목을 입력하세요"
                 value="${fn:escapeXml(draftTitle)}" />
          <small class="form-text">최대 100자</small>
        </div>

        <div class="form-group mb-0">
          <label for="content" class="font-weight-bold">내용</label>
          <textarea id="content"
          name="board_content"
          style="display:none;"><c:out value="${draftContent}" escapeXml="false"/></textarea>
		  

		  
		          
<!-- js 로드 -->

<script type="text/javascript">
  // 전역 에디터 핸들
  var oEditors = [];

  // 에디터 생성
  (function () {
    nhn.husky.EZCreator.createInIFrame({
      oAppRef: oEditors,
      elPlaceHolder: "content", // textarea id
      sSkinURI: "<%= ctxPath %>/smarteditor/SmartEditor2Skin.html",
      htParams: {
        bUseToolbar: true,
        bUseVerticalResizer: true,
        bUseModeChanger: true
      },
      fCreator: "createSEditor2"
    });
  })();

  // 폼 onsubmit에서 호출됨
  function submitContents(form) {
    // 1) 에디터 내용을 textarea로 반영
    try {
      oEditors.getById["content"].exec("UPDATE_CONTENTS_FIELD", []);
    } catch (e) {
      console.warn("SE2 UPDATE_CONTENTS_FIELD failed:", e);
    }

    // 2) (가벼운) 유효성 검사
    var titleEl = document.getElementById('title');
    if (!titleEl.value.trim()) {
      alert('제목을 입력하세요.');
      titleEl.focus();
      return false;
    }

    // 내용이 완전 공백/nbsp 뿐이면 막기
    var raw = document.getElementById('content').value || "";
    var stripped = raw
      .replace(/&nbsp;/gi, '')    // nbsp 제거
      .replace(/<br\s*\/?>/gi, '')// br 제거
      .replace(/<[^>]*>/g, '')    // 태그 제거
      .trim();

    if (!stripped.length) {
      alert('내용을 입력하세요.');
      return false;
    }

    // 3) 통과 → 정상 제출
    return true;
  }
</script>



 

          <small class="form-text">최대 1000자</small>
        </div>
      </div>
    </div>

    <!-- 첨부 -->
    <div class="card shadow-sm mb-3">
      <div class="card-body">
        <div class="form-group mb-0">
          <label for="files" class="font-weight-bold">첨부파일</label>
          <input type="file" id="files" name="files" class="form-control-file" multiple />
          <small class="form-text">
            여러 개 선택 가능 • 권한 이동으로 다시 오신 경우 파일은 보안상 재첨부가 필요합니다.
          </small>
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


