<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 공통 사이드바 -->
<jsp:include page="/WEB-INF/views/boardContent/boardSideBar.jsp" />

<!-- 필요 시 Bootstrap / jQuery (헤더에서 이미 넣었다면 중복 로드 안 해도 됨) -->
<link rel="stylesheet" href="<%=ctxPath%>/bootstrap-4.6.2-dist/css/bootstrap.min.css" type="text/css" />
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>

<style>
  /* 본문을 사이드바 폭만큼 오른쪽으로 밀기 (기존 레이아웃과 일치) */
  .board-content {
    margin-left: 460px;   /* left(220) + middle sidebar(400) + 여백 */
    padding: 32px;
    max-width: 1500px;
  }
</style>

<!-- SmartEditor + 검증 -->
<script type="text/javascript">
  $(function () {
    // === 스마트 에디터 구현 ===
    var obj = [];
    nhn.husky.EZCreator.createInIFrame({
      oAppRef: obj,
      elPlaceHolder: "content",
      sSkinURI: "<%= ctxPath%>/smarteditor/SmartEditor2Skin.html",
      htParams : { bUseToolbar:true, bUseVerticalResizer:true, bUseModeChanger:true }
    });

    // 제목 글자수
    $('#subject').on('input', function(){
      $('#subjectCount').text($(this).val().length);
    }).trigger('input');

    // 등록 버튼
    $('#btnWrite').on('click', function(){
      // 에디터 내용을 textarea로 반영
      if (obj.getById && obj.getById["content"]) {
        obj.getById["content"].exec("UPDATE_CONTENTS_FIELD", []);
      }

      // 제목 검사
      const subject = $('input[name="subject"]').val().trim();
      if(subject === ""){
        alert("글제목을 입력하세요!!");
        $('input[name="subject"]').focus();
        return;
      }

      // 내용 검사 (공백만 입력 방지)
      let content_val = $('textarea[name="content"]').val().trim();
      content_val = content_val.replace(/&nbsp;/gi, "");
      const s = content_val.indexOf("<p>");
      const e = content_val.indexOf("</p>");
      if (s > -1 && e > s) {
        content_val = content_val.substring(s + 3, e);
      }
      if (content_val.trim().length === 0) {
        alert("글내용을 입력하세요!!");
        return;
      }

      // 글암호 검사
      const pw = $('input[name="pw"]').val();
      if (pw === "") {
        alert("글암호를 입력하세요!!");
        $('#pw').focus();
        return;
      }

      // 토글 스위치 미체크 시 0 값 추가 (중복 hidden 정리 포함)
      ['is_notice','is_pinned'].forEach(function(name){
        // 기존 hidden 제거
        $('#addFrm input[type="hidden"][name="'+name+'"]').remove();
        // 체크 안 되면 0 추가
        if (!$('input[name="'+name+'"]').is(':checked')) {
          $('<input type="hidden" name="'+name+'" value="0">').appendTo('#addFrm');
        }
      });

      // 제출
      document.addFrm.submit();
    });
  });
</script>

<div class="board-content">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="h4 m-0">
      <c:choose>
        <c:when test="${empty requestScope.fk_seq}">글쓰기</c:when>
        <c:otherwise>답변글쓰기</c:otherwise>
      </c:choose>
    </h2>
    <a class="btn btn-outline-secondary btn-sm" href="<%=ctxPath%>/board/list">목록</a>
  </div>

  <!-- 알림/에러 영역(선택) -->
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
      <form name="addFrm" id="addFrm" method="post" action="<%=ctxPath%>/board/add" enctype="multipart/form-data">

        <!-- 성명 -->
        <div class="form-group">
          <label class="font-weight-semibold">성명</label>
          <div class="form-row">
            <div class="col-md-4">
              <input type="hidden" name="fk_userid" value="${sessionScope.loginuser.userid}" />
              <input type="text" name="name" value="${sessionScope.loginuser.name}" class="form-control" readonly />
            </div>
          </div>
        </div>

        <!-- 게시판 구분 (tbl_board_category) -->
        <div class="form-group">
          <label for="fk_board_category_no" class="font-weight-semibold">게시판 구분 <span class="text-danger">*</span></label>
          <select id="fk_board_category_no" name="fk_board_category_no" class="form-control" required>
            <option value="">선택</option>
            <!-- 컨트롤러에서 model.addAttribute("boardCategories", ...) 로 넣어주기 -->
            <c:forEach var="cat" items="${requestScope.boardCategories}">
              <!-- Map 기반이라 가정: 컬럼명 그대로 사용 -->
              <option value="${cat.board_category_no}" data-attach="${cat.is_attach_enable}">
                <c:out value="${cat.board_name}"/>
              </option>
            </c:forEach>
          </select>
          <small class="form-text text-muted">예) 전사 공지, 전사 알림, 부서 게시판 등</small>
        </div>

        <!-- 제목 -->
        <div class="form-group">
          <label for="subject" class="font-weight-semibold">제목 <span class="text-danger">*</span></label>
          <input type="text" id="subject" name="subject" class="form-control" maxlength="200"
                 value="<c:out value='${requestScope.subject}'/>"
                 <c:if test='${not empty requestScope.fk_seq}'>readonly</c:if> />
          <small class="form-text text-muted">
            <span id="subjectCount">0</span>/200
          </small>
        </div>

        <!-- 내용 (SmartEditor 대상) -->
        <div class="form-group">
          <label for="content" class="font-weight-semibold">내용 <span class="text-danger">*</span></label>
          <textarea id="content" name="content" class="form-control" rows="12"></textarea>
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
        <div class="form-group">
          <label for="attach" class="font-weight-semibold">파일첨부</label>
          <input type="file" id="attach" name="attach" class="form-control-file" />
          <small class="form-text text-muted">필요 시 하나의 파일을 첨부하세요.</small>
        </div>

        <!-- 글암호 -->
        <div class="form-group">
          <label for="pw" class="font-weight-semibold">글암호 <span class="text-danger">*</span></label>
          <div class="form-row">
            <div class="col-md-4">
              <input type="password" id="pw" name="pw" maxlength="20" class="form-control" placeholder="비밀번호" />
            </div>
          </div>
        </div>

        <!-- 답변글쓰기용 hidden -->
        <input type="hidden" name="fk_seq"  value="${requestScope.fk_seq}" />
        <input type="hidden" name="groupno" value="${requestScope.groupno}" />
        <input type="hidden" name="depthno" value="${requestScope.depthno}" />

        <div class="d-flex justify-content-end">
          <button type="button" class="btn btn-light mr-2" onclick="location.href='<%=ctxPath%>/board/list'">취소</button>
          <button type="button" id="btnWrite" class="btn btn-dark">등록</button>
        </div>
      </form>
    </div>
  </div>
</div>
