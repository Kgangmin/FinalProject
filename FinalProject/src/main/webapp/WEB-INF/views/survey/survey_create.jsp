<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %> 
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/survey/survey_side.jsp" />

<style>
.sv-box{ background:#fff; border:1px solid #dee2e6; border-radius:10px; box-shadow:0 1px 2px rgba(0,0,0,.04); }
.sv-box .hd{ padding:12px 14px; border-bottom:1px solid #f1f1f1; }
.sv-box .bd{ padding:14px; }
.q-item{ border:1px dashed #ced4da; border-radius:10px; padding:10px; margin-bottom:10px; }
.opt-item{ display:flex; gap:8px; align-items:center; margin-bottom:6px; }
.badge-tag{ display:inline-block; padding:2px 8px; border-radius:999px; background:#eef1f3; margin-right:6px; }
body .content-wrapper{
  margin-left: 380px !important; /* 기존 유지 */
  margin-top: 0 !important;
  padding-top: 38px !important;
}
body .content-wrapper > .container-fluid{
  padding-top: 4px !important;  /* ≒ 4px */
}
</style>

<div class="content-wrapper">
  <div class="container-fluid py-3">
    <form method="post" action="<%=ctxPath%>/survey/create" onsubmit="return buildDocJson();">
      <div class="sv-box mb-3">
        <div class="hd"><h5 class="mb-0">설문 작성</h5></div>
        <div class="bd">
          <div class="form-group">
            <label>설문 제목</label>
            <input type="text" class="form-control" name="title" required maxlength="200">
          </div>
          <div class="form-row">
            <div class="form-group col-md-3">
              <label>시작일</label>
              <input type="date" class="form-control" name="startDate" required>
            </div>
            <div class="form-group col-md-3">
              <label>종료일</label>
              <input type="date" class="form-control" name="endDate" required>
            </div>
            <div class="form-group col-md-3">
              <label>결과 공개</label>
              <select class="form-control" name="resultPublicYn">
                <option value="Y">공개</option>
                <option value="N">비공개</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <label>대상 범위</label>
              <select class="form-control" name="targetScope" id="targetScope">
                <option value="ALL">회사 전체</option>
                <option value="DEPT">소속부서</option>
                <option value="DIRECT">직접선택</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>시작 안내 문구</label>
            <textarea class="form-control" name="introText" rows="3" maxlength="2000"></textarea>
          </div>
        </div>
      </div>

      <!-- 대상 설정 -->
      <div class="sv-box mb-3" id="scopeDeptBox" style="display:none;">
        <div class="hd"><strong>부서 선택(DEPT)</strong></div>
        <div class="bd">
          <div id="deptArea">
            <!-- 서버에서 주입된 부서목록 -->
            <c:forEach var="d" items="${deptList}">
			  <label class="mr-3 mb-2">
			    <input type="checkbox" class="deptChk"
			           value="${empty d['dept_no'] ? d['deptNo'] : d['dept_no']}">
			    <c:out value="${empty d['dept_name'] ? d['deptName'] : d['dept_name']}"/>
			  </label>
			</c:forEach>
          </div>
        </div>
      </div>

      <div class="sv-box mb-3" id="scopeDirectBox" style="display:none;">
        <div class="hd"><strong>직접 선택(DIRECT)</strong></div>
        <div class="bd">
          <div class="form-inline mb-2">
            <input type="text" class="form-control mr-2" id="empKeyword" placeholder="이름/사번/부서">
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="searchEmp()">검색</button>
          </div>
          <div id="empResult" class="mb-2"></div>
          <div>선택됨: <span id="empSelected"></span></div>
        </div>
      </div>

      <!-- 질문/보기 -->
      <div class="sv-box mb-3">
        <div class="hd d-flex justify-content-between align-items-center">
          <strong>질문</strong>
          <button type="button" class="btn btn-sm btn-primary" onclick="addQuestion()">질문 추가</button>
        </div>
        <div class="bd" id="qList"></div>
      </div>

      <input type="hidden" name="docJson" id="docJson">
      <input type="hidden" name="deptNos" id="deptNos">
      <input type="hidden" name="empNos" id="empNos">
      <div class="text-right">
        <button type="submit" class="btn btn-success">작성하기</button>
        <a href="<%=ctxPath%>/survey/home" class="btn btn-outline-secondary">취소</a>
      </div>
    </form>
  </div>
</div>
<script>
  (function(){
    var oc = '${ongoingCnt}', cc = '${closedCnt}', mc = '${myCnt}';
    if (document.getElementById('ongoingCnt')) document.getElementById('ongoingCnt').textContent = oc || '0';
    if (document.getElementById('closedCnt'))  document.getElementById('closedCnt').textContent  = cc || '0';
    if (document.getElementById('myCnt'))      document.getElementById('myCnt').textContent      = mc || '0';
  })();
</script>
<script>
(function(){
  var scopeSel = document.getElementById('targetScope');
  scopeSel.addEventListener('change', function(){
    document.getElementById('scopeDeptBox').style.display   = (this.value==='DEPT') ? '' : 'none';
    document.getElementById('scopeDirectBox').style.display = (this.value==='DIRECT') ? '' : 'none';
  });
})();

// 직접선택 인메모리
var selectedEmp = new Set();

function searchEmp(){
  var q = document.getElementById('empKeyword').value || '';
  if(!q.trim()) return;
  fetch('<%=ctxPath%>/survey/api/employees?q=' + encodeURIComponent(q))
    .then(r=>r.json())
    .then(list=>{
      var html = '';
      if(!list || list.length===0){ html = '<div class="text-muted small">검색 결과 없음</div>'; }
      else{
        html = '<ul class="list-unstyled mb-0">'
        + list.map(function(e){
            var key = e.emp_no + '|' + (e.emp_name||'') + '|' + (e.dept_name||'');
            return '<li>'
              + '<button type="button" class="btn btn-sm btn-outline-primary mr-2" onclick="pickEmp(\''+ e.emp_no +'\')">추가</button>'
              + '['+(e.emp_no||'')+'] ' + (e.emp_name||'') + ' / ' + (e.dept_name||'')
              + '</li>';
          }).join('')
        + '</ul>';
      }
      document.getElementById('empResult').innerHTML = html;
    });
}
function pickEmp(empNo){
  selectedEmp.add(empNo);
  renderPicked();
}
function removeEmp(empNo){
  selectedEmp.delete(empNo);
  renderPicked();
}
function renderPicked(){
  var arr = Array.from(selectedEmp);
  document.getElementById('empSelected').innerHTML =
    arr.length ? arr.map(function(no){ return '<span class="badge-tag">'+no+' <a href="javascript:void(0)" onclick="removeEmp(\''+no+'\')">×</a></span>'; }).join('') : '<span class="text-muted small">없음</span>';
}

// 질문/보기
var qSeq = 1;
function addQuestion(pref){
  var qid = 'q' + (qSeq++);
  var wrap = document.createElement('div');
  wrap.className = 'q-item';
  wrap.dataset.qid = qid;
  wrap.innerHTML =
    '<div class="form-group">'
    +  '<label>질문 내용</label>'
    +  '<input type="text" class="form-control q-text" required>'
    +  '<div class="form-check mt-1">'
    +    '<input class="form-check-input q-multiple" type="checkbox" id="'+qid+'_mul">'
    +    '<label class="form-check-label" for="'+qid+'_mul">복수선택 허용</label>'
    +  '</div>'
    + '</div>'
    + '<div class="opt-list"></div>'
    + '<button type="button" class="btn btn-sm btn-outline-secondary" onclick="addOption(this)">보기 추가</button>'
    + '  <button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest(\'.q-item\').remove()">질문 삭제</button>';
  document.getElementById('qList').appendChild(wrap);
  // 초기 보기 2개
  addOption(wrap.querySelector('button'));
  addOption(wrap.querySelector('button'));
}

function addOption(btn){
  var q = btn.closest('.q-item');
  var optList = q.querySelector('.opt-list');
  var opt = document.createElement('div');
  opt.className = 'opt-item';
  opt.innerHTML =
    '<input type="text" class="form-control opt-text" placeholder="보기 내용" required style="flex:1;">'
  + '<button type="button" class="btn btn-sm btn-outline-danger" onclick="this.parentNode.remove()">삭제</button>';
  optList.appendChild(opt);
}

function buildDocJson(){
  // 대상
  var scope = document.getElementById('targetScope').value;
  if(scope==='DEPT'){
    var depts = Array.from(document.querySelectorAll('.deptChk:checked')).map(function(ch){return ch.value;});
    document.getElementById('deptNos').value = depts.join(',');
  }else if(scope==='DIRECT'){
    document.getElementById('empNos').value = Array.from(selectedEmp).join(',');
  }

  // 질문 JSON
  var qs = [];
  var qItems = document.querySelectorAll('.q-item');
  if(qItems.length===0){ alert('최소 1개 이상의 질문을 추가하세요.'); return false; }
  qItems.forEach(function(q, idx){
    var text = q.querySelector('.q-text').value.trim();
    var mul  = q.querySelector('.q-multiple').checked;
    var opts = Array.from(q.querySelectorAll('.opt-text')).map(function(i){ return i.value.trim(); }).filter(Boolean);
    if(!text){ return; }
    if(opts.length < 2){ return; }
    var qid = 'q' + (idx+1); // 저장용 question id (단순 일련)
    var qdoc = { id: qid, text: text, multiple: mul, options: [] };
    opts.forEach(function(t, j){
      qdoc.options.push({ id: 'o' + (j+1), text: t });
    });
    qs.push(qdoc);
  });
  if(qs.length===0){ alert('질문/보기를 올바르게 입력하세요.'); return false; }

  document.getElementById('docJson').value = JSON.stringify(qs);
  return true;
}

</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
