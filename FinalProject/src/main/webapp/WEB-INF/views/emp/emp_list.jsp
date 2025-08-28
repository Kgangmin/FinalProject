<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
	String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%=ctxPath%>/css/emp/emp_list.css"/>

<div class="emp-list-container">
  <h2 class="page-title text-secondary pl-2">사원 목록</h2>

  <!-- 검색 -->
  <form id="searchForm" class="form-inline mb-3">
    <input type="text" class="form-control mr-2" id="qDept" placeholder="부서">
    <input type="text" class="form-control mr-2" id="qTeam" placeholder="소속(팀)">
    <input type="text" class="form-control mr-2" id="qName" placeholder="이름">
    <button type="submit" class="btn btn-primary">검색</button>
  </form>

  <!-- 목록 -->
  <div class="table-responsive">
    <table class="table table-sm table-hover">
      <thead class="thead-light">
        <tr>
          <th style="width:120px">사번</th>
          <th>이름</th>
          <th>부서</th>
          <th>소속</th>
          <th>직급</th>
          <th>사내 이메일</th>
        </tr>
      </thead>
      <tbody id="empTableBody">
        <!-- JS로 렌더링 -->
      </tbody>
    </table>
  </div>

  <!-- 페이징 -->
  <nav>
    <ul id="paging" class="pagination justify-content-center mb-0"></ul>
  </nav>
</div>

<script>
(function(){
  const ctxPath = '<%=ctxPath%>';
  const $form   = $('#searchForm');
  const $tbody  = $('#empTableBody');
  const $paging = $('#paging');

  let state = {
    page: 1,
    size: 10,
    dept: '',
    team: '',
    name: ''
  };

  function fetchList(page){
    state.page = page || 1;

    $.ajax({
      url: ctxPath + '/emp/list',
      type: 'GET',
      dataType: 'json',
      data: {
        dept: state.dept,
        team: state.team,
        name: state.name,
        page: state.page,
        size: state.size
      },
      success: renderList,
      error: function(req,st,err){
        console.error(req,st,err);
        alert('사원 목록을 불러오지 못했습니다.');
      }
    });
  }

  function renderList(json){
    const items = json.items || [];
    $tbody.empty();

    if(items.length === 0){
      $tbody.append('<tr><td colspan="6" class="text-center text-muted">데이터가 없습니다.</td></tr>');
    }else{
      items.forEach(function(e){
        const row = `
          <tr>
            <td>${e.emp_no || ''}</td>
            <td>${e.emp_name || ''}</td>
            <td>${e.dept_name || ''}</td>
            <td>${e.team_name || ''}</td>
            <td>${e.rank_name || ''}</td>
            <td>${e.emp_email || ''}</td>
          </tr>`;
        $tbody.append(row);
      });
    }

    // paging
    const page = json.page || 1;
    const totalPages = json.totalPages || 1;

    $paging.empty();
    if(totalPages <= 1) return;

    function addPage(num, text, disabled, active){
      const li = $('<li class="page-item"></li>');
      if(disabled) li.addClass('disabled');
      if(active) li.addClass('active');
      const a = $('<a class="page-link" href="#"></a>').text(text)
        .on('click', function(e){
          e.preventDefault();
          if(!disabled && !active) fetchList(num);
        });
      li.append(a); $paging.append(li);
    }

    const blockSize = 5;
    const currentBlock = Math.floor((page-1)/blockSize);
    const start = currentBlock*blockSize + 1;
    const end   = Math.min(start + blockSize - 1, totalPages);

    addPage(page-1, '이전', page<=1, false);
    for(let p=start; p<=end; p++){
      addPage(p, String(p), false, p===page);
    }
    addPage(page+1, '다음', page>=totalPages, false);
  }

  $form.on('submit', function(e){
    e.preventDefault();
    state.dept = $('#qDept').val().trim();
    state.team = $('#qTeam').val().trim();
    state.name = $('#qName').val().trim();
    fetchList(1);
  });

  // 초기 로드
  fetchList(1);
})();
</script>