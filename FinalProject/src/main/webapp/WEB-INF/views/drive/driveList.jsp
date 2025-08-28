<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<%
  String ctxPath = request.getContextPath();
%>

<!-- 공통 헤더 (Bootstrap 4.6.2 + jQuery + Popper + bootstrap.bundle.min.js 로딩됨) -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 드라이브 사이드바 -->
<jsp:include page="/WEB-INF/views/drive/driveSideBar.jsp" />

<style>
  .drive-content { margin-left: 370px; padding: 16px; }
  .drive-toolbar .btn { margin-right: 6px; }
  .filename-clip { max-width: 420px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .upload-hint { font-size: .875rem; color: #6c757d; }
  
  /* 카드 전체 높이를 10줄 기준으로 고정 */
  .drive-table-fixed {
    max-height: 610px;  /* 10줄 × 48px = 480px */
    min-height: 610px;  /* 항상 고정 높이 */
    overflow-y: auto;   /* 데이터가 넘치면 스크롤 */
  }
  
</style>

<%-- 세션에서 로그인 정보 뽑기 (loginuser 우선, 없으면 loginEmp 폴백) --%>
<c:set var="empNoSess"  value="${not empty sessionScope.loginuser ? sessionScope.loginuser.emp_no  : (not empty sessionScope.loginEmp ? sessionScope.loginEmp.empNo  : '')}" />
<c:set var="deptNoSess" value="${not empty sessionScope.loginuser ? sessionScope.loginuser.fk_dept_no : (not empty sessionScope.loginEmp ? sessionScope.loginEmp.fkDeptNo : '')}" />


<!-- 루트에 남은 용량을 data-remaining 으로 심어 JS에서 사용 -->
<div id="driveRoot" class="drive-content" data-remaining="${empty cap ? 0 : cap.remain}">
  <c:set var="ctx" value="${pageContext.request.contextPath}" />

  <!-- 브레드크럼 (JS가 텍스트를 채운다) -->
  <nav aria-label="breadcrumb" class="mb-3">
    <ol class="breadcrumb">
      <li class="breadcrumb-item">Home</li>
      <li class="breadcrumb-item">Drive</li>
      <li class="breadcrumb-item active" aria-current="page" id="driveBreadcrumb">전사 자료실</li>
    </ol>
  </nav>

  <!-- 용량 바 (서버에서 넘어온 cap 그대로 사용) -->
  <c:if test="${not empty cap}">
    <c:set var="used"    value="${cap.used}" />
    <c:set var="total"   value="${cap.total}" />
    <c:set var="percent" value="${total gt 0 ? (used * 100 / total) : 0}" />

    <div class="mb-3">
      <div class="d-flex justify-content-between align-items-end">
        <div class="small text-secondary">사용량</div>
        <div class="small text-secondary">
          <strong><fmt:formatNumber value="${used/1024/1024}" maxFractionDigits="1"/> MB</strong>
          /
          <fmt:formatNumber value="${total/1024/1024}" maxFractionDigits="1"/> MB
        </div>
      </div>
      <div class="progress" role="progressbar" aria-label="capacity">
        <div class="progress-bar" style="width: ${percent}%;"></div>
      </div>
    </div>
  </c:if>

  <!-- 툴바 -->
  <div class="drive-toolbar mb-3">
    <form class="form-row align-items-center" method="get" action="${ctx}/drive/list">
      <!-- 검색 시 현재 scope 유지: JS가 아래 hidden에 현재 scope를 채운다 -->
      <input type="hidden" name="scope" id="searchScopeInput" value="" />

      <div class="col-auto">
        <input type="text" class="form-control" name="keyword" value="${param.keyword}" placeholder="파일명 검색" />
      </div>

      <div class="col-auto">
        <button type="submit" class="btn btn-primary">검색</button>
        <a class="btn btn-outline-primary" id="btnRefresh" href="${ctx}/drive/list?scope=CORP">새로고침</a>
      </div>

      <div class="col-auto ml-auto">
        <!-- 파일 추가 (모달 오픈) : 남은 용량 0이면 JS가 disable -->
        <button type="button" class="btn btn-primary" id="btnOpenUpload"
                data-toggle="modal" data-target="#modalUpload">파일 추가</button>

		 <!-- 선택 다운로드(Zip) -->
	  <button type="button" class="btn btn-outline-secondary" id="btnDownload">선택 다운로드</button>
  
        <!-- 선택 삭제 -->
        <button type="button" class="btn btn-danger" id="btnDelete">삭제</button>
      </div>
    </form>
  </div>

  <!-- 파일 리스트 -->
  <div class="card drive-table-fixed">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="thead-light">
          <tr>
            <th style="width:40px;"><input type="checkbox" onclick="toggleAll(this)"></th>
            <th>파일명</th>
            <th style="width:120px;">크기</th>
            <th style="width:140px;">등록자</th>
            <th style="width:300px;">등록일</th>
            <th style="width:90px;">다운</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty files}">
              <tr><td colspan="6" class="text-center text-muted py-4">파일이 없습니다.</td></tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="f" items="${files}">
                <tr>
                  <td><input type="checkbox" name="ids" value="${f.boardFileNo}"></td>
                  <td class="filename-clip" title="${f.boardOriginFilename}"><c:out value="${f.boardOriginFilename}"/></td>
                  <td><c:out value="${empty f.humanSize ? f.boardFilesize : f.humanSize}"/></td>
                  <td><c:out value="${empty f.empName ? f.fkEmpNo : f.empName}"/></td>
                  <td><c:out value="${f.registerDate}"/></td>
                  <td>
                    <a class="btn btn-sm btn-outline-primary"
					   href="${ctx}/drive/download?id=${f.boardFileNo}&scope=${scope}">
					  받기
					</a>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
  </div>

  <!-- 페이지 네비게이션 -->
  <c:if test="${not empty page and page.totalPage ne '0'}">
    <nav class="mt-3">
      <ul class="pagination d-flex justify-content-center">
        <c:set var="safeKeyword" value="${param.keyword}" />
        <c:set var="qBase" value="scope=CORP&keyword=${fn:escapeXml(safeKeyword)}&size=${page.size}&blockSize=${page.blockSize}" />
        <!-- 링크의 scope=CORP 는 JS가 로드 시 현 scope로 교체한다 -->
        <li class="page-item ${page.startPage == '1' ? 'disabled' : ''}">
          <a class="page-link page-link-scope" href="${ctx}/drive/list?${qBase}&page=${page.startPage - 1}">이전</a>
        </li>
        <c:forEach var="pp" begin="${page.startPage}" end="${page.endPage}">
          <li class="page-item ${pp == page.page ? 'active' : ''}">
            <a class="page-link page-link-scope" href="${ctx}/drive/list?${qBase}&page=${pp}">${pp}</a>
          </li>
        </c:forEach>
        <li class="page-item ${page.endPage == page.totalPage ? 'disabled' : ''}">
          <a class="page-link page-link-scope" href="${ctx}/drive/list?${qBase}&page=${page.endPage + 1}">다음</a>
        </li>
      </ul>
    </nav>
  </c:if>
</div>

<!-- ===== 업로드 모달 (BS4) ===== -->
<div class="modal fade" id="modalUpload" tabindex="-1" role="dialog" aria-labelledby="modalUploadLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="modalUploadLabel">파일 업로드</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <form id="uploadForm" action="${ctx}/drive/upload" method="post" enctype="multipart/form-data">
        <div class="modal-body">
          <c:if test="${not empty _csrf}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
          </c:if>

          <!-- 업로드 scope 는 JS가 채운다 -->
          <input type="hidden" name="scope" id="uploadScopeInput" value="">
		  <input type="hidden" name="empNo"  value="${empNoSess}" />
 		  <input type="hidden" name="deptNo" value="${deptNoSess}" />
          <div class="form-group">
            <label class="form-label">파일 선택</label>
            <input class="form-control" type="file" name="file" id="uploadFile" required />
            <c:if test="${not empty cap}">
              <small class="form-text text-muted upload-hint">
                남은 용량:
                <strong><fmt:formatNumber value="${cap.remain/1024/1024}" maxFractionDigits="1"/> MB</strong>
              </small>
            </c:if>
            <div id="fileErr" class="text-danger small mt-1" style="display:none;"></div>
          </div>

          <!-- 안내 문구(부서/개인/전사) 는 JS가 채운다 -->
          <div id="uploadScopeMsg" class="alert py-2 mb-0"></div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">취소</button>
          <button type="submit" class="btn btn-primary" id="btnUpload">업로드</button>
        </div>
      </form>

    </div>
  </div>
</div>

<form id="multiDownloadForm" method="post" action="${ctx}/drive/download" style="display:none;">
  <input type="hidden" name="ids" value="">
  <input type="hidden" name="scope" value="">
</form>


<script>
  // 전체선택
  function toggleAll(master){
    document.querySelectorAll("input[name='ids']").forEach(function(chk){ chk.checked = master.checked; });
  }

  (function($){
    // 현재 scope 결정: URL 파라미터 우선, 없으면 기본 CORP
    function getScope(){
      var params = new URLSearchParams(window.location.search);
      var q = (params.get('scope') || '').trim().toUpperCase();
      if (q === 'DEPT' || q === 'EMP' || q === 'CORP') return q;
      return 'CORP';
    }

    // 화면에 scope 반영
    function applyScopeUI(scope){
      // 브레드크럼
      var label = (scope === 'DEPT') ? '부서 자료실' : (scope === 'EMP') ? '개인 자료실' : '전사 자료실';
      $('#driveBreadcrumb').text(label);

      // 업로드 hidden input & 검색 hidden input
      $('#uploadScopeInput').val(scope);
      $('#searchScopeInput').val(scope);

      // 새로고침 링크의 scope 대체
      $('#btnRefresh').attr('href', function(_, old){
        return old.replace(/scope=CORP/i, 'scope=' + scope);
      });

      // 페이지네이션 링크의 scope 대체
      $('.page-link-scope').each(function(){
        var h = $(this).attr('href') || '';
        $(this).attr('href', h.replace(/scope=CORP/i, 'scope=' + scope));
      });

      // 모달 안내문
      var $msg = $('#uploadScopeMsg').removeClass('alert-info alert-warning');
      if (scope === 'DEPT'){
        $msg.addClass('alert-info').text('부서 자료실로 업로드됩니다. 같은 부서원에게만 보입니다.');
      } else if (scope === 'EMP'){
        $msg.addClass('alert-info').text('개인 자료실로 업로드됩니다. 본인에게만 보입니다.');
      } else {
        $msg.addClass('alert-warning').text('전사 자료실로 업로드됩니다. 모든 사원이 볼 수 있습니다.');
      }

      // 사이드바 active (사이드바 a에 id 부여되어 있지 않아도, href 매칭으로 처리)
      // /drive/list?scope=DEPT 같은 패턴을 보고 active 교체
      $('.board-panel a.list-group-item').removeClass('active').each(function(){
        var href = $(this).attr('href') || '';
        if (href.indexOf('scope=' + scope) >= 0) $(this).addClass('active');
      });

      // 남은 용량으로 업로드 버튼 상태 제어
      var remain = Number($('#driveRoot').data('remaining')) || 0;
      $('#btnOpenUpload').prop('disabled', remain <= 0);
    }

    // 선택삭제
    function bindDelete(scope){
      $('#btnDelete').on('click', function(){
        var checked = Array.from(document.querySelectorAll("input[name='ids']:checked"))
                           .map(function(x){ return x.value; });
        if (checked.length === 0){ alert('삭제할 파일을 선택하세요.'); return; }

        var params = new URLSearchParams();
        params.append('ids', checked.join(',')); // 컨트롤러: "a,b,c" 형태
        params.append('scope', scope);

        fetch('<c:out value="${ctx}"/>/drive/delete', {
          method: 'POST',
          headers: {'Content-Type':'application/x-www-form-urlencoded'},
          body: params
        }).then(function(){ location.reload(); });
      });
    }

    // 업로드 용량 체크
    function bindCapacityGuard(){
      var remainBytes = Number($('#driveRoot').data('remaining')) || 0;
      var $file = $('#uploadFile'), $err = $('#fileErr'), $btn = $('#btnUpload');
      function human(n){
        if (n >= 1073741824) return (n/1073741824).toFixed(2) + ' GB';
        if (n >= 1048576)    return (n/1048576).toFixed(2)  + ' MB';
        if (n >= 1024)       return (n/1024).toFixed(2)     + ' KB';
        return n + ' B';
      }
      function check(){
        $err.hide().text(''); $btn.prop('disabled', false);
        var f = $file[0] && $file[0].files && $file[0].files[0];
        if (!f) return;
        if (remainBytes > 0 && f.size > remainBytes){
          $err.text('남은 용량을 초과합니다. 파일 ' + human(f.size) + ' / 남은 ' + human(remainBytes))
              .show();
          $btn.prop('disabled', true);
        }
      }
      $file.on('change', check);
      $('#uploadForm').on('submit', function(e){
        if ($btn.prop('disabled')) { e.preventDefault(); return false; }
        $btn.prop('disabled', true).text('업로드 중...');
      });
    }
    
    function bindMultiDownload(scope){
    	  $('#btnDownload').on('click', function(){
    	    var checked = Array.from(document.querySelectorAll("input[name='ids']:checked"))
    	                       .map(function(x){ return x.value; });
    	    if (checked.length === 0){
    	      alert('다운로드할 파일을 선택하세요.');
    	      return;
    	    }
    	    var form = document.getElementById('multiDownloadForm');
    	    form.elements['ids'].value = checked.join(',');  // "a,b,c"
    	    form.elements['scope'].value = scope;
    	    form.submit(); // 서버에서 application/zip 으로 응답 → 브라우저가 저장 대화상자 오픈
    	  });
    	}


    $(function(){
      var scope = getScope();
      applyScopeUI(scope);
      bindDelete(scope);
      bindCapacityGuard();
      bindMultiDownload(scope);
    });
    
    
  })(jQuery);
</script>
