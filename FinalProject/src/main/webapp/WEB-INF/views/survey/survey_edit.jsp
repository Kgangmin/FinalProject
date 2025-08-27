<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %> 
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
  String ctxPath = request.getContextPath();
%>

<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/survey/survey_side.jsp" />

<style>
  .q-item{ border:1px dashed #ced4da; border-radius:10px; padding:10px; margin-bottom:10px; }
  .opt-item{ display:flex; gap:8px; align-items:center; margin-bottom:6px; }
  .badge-tag{ display:inline-block; padding:.15rem .5rem; border:1px solid #dee2e6; border-radius:999px; margin-right:6px; }
  .sv-box .hd{ padding:8px 0; border-bottom:1px solid #e9ecef; margin-bottom:10px; }
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
    <form method="post" action="<%=ctxPath%>/survey/edit" onsubmit="return buildDocJson();">
      <input type="hidden" name="sid"     value="${fn:escapeXml(detail.surveyId)}">
      <input type="hidden" name="mongoId" value="${fn:escapeXml(detail.mongoSurveyId)}">

      <div class="sv-box mb-3">
        <div class="hd"><h5 class="mb-0">설문 수정</h5></div>
        <div class="bd">
          <div class="form-group">
            <label>설문 제목</label>
            <input type="text" class="form-control" name="title" required maxlength="200"
                   value="${fn:escapeXml(detail.title)}">
          </div>

          <div class="form-row">
            <div class="form-group col-md-3">
              <label>시작일</label>
              <input type="date" class="form-control" name="startDate" required
                     value="${fn:escapeXml(detail.startDate)}">
            </div>
            <div class="form-group col-md-3">
              <label>종료일</label>
              <input type="date" class="form-control" name="endDate" required
                     value="${fn:escapeXml(detail.endDate)}">
            </div>
            <div class="form-group col-md-3">
              <label>결과 공개</label>
              <select class="form-control" name="resultPublicYn" id="resultPublicYn">
                <option value="Y" <c:if test="${detail.resultPublicYn eq 'Y'}">selected</c:if>>공개</option>
                <option value="N" <c:if test="${detail.resultPublicYn eq 'N'}">selected</c:if>>비공개</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <label>대상 범위</label>
              <select class="form-control" name="targetScope" id="targetScope">
                <option value="ALL"    <c:if test="${detail.targetScope eq 'ALL'}">selected</c:if>>회사 전체</option>
                <option value="DEPT"   <c:if test="${detail.targetScope eq 'DEPT'}">selected</c:if>>소속부서</option>
                <option value="DIRECT" <c:if test="${detail.targetScope eq 'DIRECT'}">selected</c:if>>직접선택</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>시작 안내 문구</label>
            <textarea class="form-control" name="introText" rows="3" maxlength="2000">${fn:escapeXml(detail.introText)}</textarea>
          </div>
        </div>
      </div>

      <!-- DEPT / DIRECT 영역 -->
      <div class="sv-box mb-3" id="scopeDeptBox" style="display:none;">
        <div class="hd"><strong>부서 선택(DEPT)</strong></div>
        <div class="bd">
          <c:forEach var="d" items="${deptList}">
            <label class="mr-3 mb-2">
              <input type="checkbox" class="deptChk" value="${fn:escapeXml(d.dept_no)}">
              ${fn:escapeXml(d.dept_name)}
            </label>
          </c:forEach>
        </div>
      </div>

      <div class="sv-box mb-3" id="scopeDirectBox" style="display:none;">
        <div class="hd"><strong>직접 선택(DIRECT)</strong></div>
        <div class="bd">
          <div class="form-inline mb-2">
            <input type="text" class="form-control mr-2" id="empKeyword" placeholder="이름/사번/부서">
            <button type="button" class="btn btn-outline-secondary btn-sm" id="btnEmpSearch">검색</button>
          </div>
          <div id="empResult" class="mb-2"></div>
          <div>선택됨: <span id="empSelected" class="align-middle"></span></div>
        </div>
      </div>

      <!-- 질문/보기 -->
      <div class="sv-box mb-3">
        <div class="hd d-flex justify-content-between align-items-center">
          <strong>질문</strong>
          <button type="button" class="btn btn-sm btn-primary" id="btnAddQuestion">질문 추가</button>
        </div>
        <div class="bd" id="qList"></div>
      </div>

      <!-- 서버로 보낼 히든 -->
      <input type="hidden" name="docJson"  id="docJson">
      <input type="hidden" name="deptNos"  id="deptNos">
      <input type="hidden" name="empNos"   id="empNos">

      <div class="text-right">
        <button type="submit" class="btn btn-primary">수정 저장</button>
        <a href="<%=ctxPath%>/survey/detail?sid=${fn:escapeXml(detail.surveyId)}" class="btn btn-outline-secondary">취소</a>
      </div>
    </form>
  </div>
</div>

<!-- 초기 질문/보기 JSON: 기본 escapeXml=true 로 안전하게 출력 -->
<script type="application/json" id="init-questions">
<c:out value="${questionsJson}" />
</script>
<script>
  (function(){
    var oc = '${ongoingCnt}', cc = '${closedCnt}', mc = '${myCnt}';
    if (document.getElementById('ongoingCnt')) document.getElementById('ongoingCnt').textContent = oc || '0';
    if (document.getElementById('closedCnt'))  document.getElementById('closedCnt').textContent  = cc || '0';
    if (document.getElementById('myCnt'))      document.getElementById('myCnt').textContent      = mc || '0';
  })();
</script>
<script>
  // ---------- 공통 ----------
  function parseInitJson(elId, fallback){
    try{
      const el = document.getElementById(elId);
      if(!el) return fallback;
      // HTML 엔티티(&lt; &gt; &quot; 등)는 브라우저가 DOM으로 만들 때 복원됨
      
      const raw = (el.innerHTML || '').trim();
      if(!raw) return fallback;

      const decoder = document.createElement('textarea');
      decoder.innerHTML = raw;
      let decoded = decoder.value;

      // BOM 제거(혹시 모를 인코딩 잔재 대비)
      if (decoded.charCodeAt(0) === 0xFEFF) {
        decoded = decoded.slice(1);
      }

      return JSON.parse(decoded);
    }catch(e){
      console.error('init json parse error:', e);
      return fallback;
    }
  }

  // ---------- DIRECT 대상 검색/선택 ----------
  const selectedEmp = new Set();
  document.getElementById('btnEmpSearch').addEventListener('click', function(){
    const q = (document.getElementById('empKeyword').value || '').trim();
    if(!q) return;
    fetch('<%=ctxPath%>/survey/api/employees?q=' + encodeURIComponent(q))
      .then(r=>r.json())
      .then(list=>{
        let html = '';
        if(!list || list.length===0){
          html = '<div class="text-muted small">검색 결과 없음</div>';
        }else{
          html = '<ul class="list-unstyled mb-0">'
              + list.map(e => (
                '<li>'
                + '<button type="button" class="btn btn-sm btn-outline-primary mr-2" data-add-emp="'+ (e.emp_no||'') +'">추가</button>'
                + '['+(e.emp_no||'')+'] '+ (e.emp_name||'') +' / '+ (e.dept_name||'')
                + '</li>'
              )).join('')
              + '</ul>';
        }
        document.getElementById('empResult').innerHTML = html;
      })
      .catch(()=>{ document.getElementById('empResult').innerHTML = '<div class="text-danger small">검색 실패</div>'; });
  });

  document.getElementById('empResult').addEventListener('click', function(e){
    const btn = e.target.closest('button[data-add-emp]');
    if(!btn) return;
    const no = btn.getAttribute('data-add-emp');
    if(no){ selectedEmp.add(no); renderPicked(); }
  });

  function renderPicked(){
    const arr = Array.from(selectedEmp);
    document.getElementById('empSelected').innerHTML =
      arr.length
        ? arr.map(no => '<span class="badge-tag">'+no+' <a href="javascript:void(0)" data-del-emp="'+no+'">×</a></span>').join('')
        : '<span class="text-muted small">없음</span>';
  }
  document.getElementById('empSelected').addEventListener('click', function(e){
    const a = e.target.closest('a[data-del-emp]');
    if(!a) return;
    selectedEmp.delete(a.getAttribute('data-del-emp'));
    renderPicked();
  });

  // ---------- 질문/보기 편집 ----------
  function addOptionTo(qEl, text){
    const optList = qEl.querySelector('.opt-list');
    const opt = document.createElement('div');
    opt.className = 'opt-item';
    opt.innerHTML =
      '<input type="text" class="form-control opt-text" placeholder="보기 내용" required style="flex:1;" value="'+ (text||'') +'">\
       <button type="button" class="btn btn-sm btn-outline-danger btn-del-opt">삭제</button>';
    optList.appendChild(opt);
    opt.querySelector('.btn-del-opt').addEventListener('click', function(){ opt.remove(); });
  }

  function addQuestion(pref){
    const wrap = document.createElement('div');
    wrap.className = 'q-item';
    wrap.innerHTML =
      '<div class="form-group">\
         <label>질문 내용</label>\
         <input type="text" class="form-control q-text" required>\
         <div class="form-check mt-1">\
           <input class="form-check-input q-multiple" type="checkbox">\
           <label class="form-check-label">복수선택 허용</label>\
         </div>\
       </div>\
       <div class="opt-list"></div>\
       <div class="mt-2">\
         <button type="button" class="btn btn-sm btn-outline-secondary btn-add-option">보기 추가</button>\
         <button type="button" class="btn btn-sm btn-outline-danger btn-del-question">질문 삭제</button>\
       </div>';
    document.getElementById('qList').appendChild(wrap);

    wrap.querySelector('.btn-add-option').addEventListener('click', function(){ addOptionTo(wrap); });
    wrap.querySelector('.btn-del-question').addEventListener('click', function(){ wrap.remove(); });

    if (pref){
      if (pref.text) wrap.querySelector('.q-text').value = pref.text;
      if (pref.multiple) wrap.querySelector('.q-multiple').checked = true;
      if (pref.options && pref.options.length){
        pref.options.forEach(function(o){ addOptionTo(wrap, o.text); });
      } else {
        addOptionTo(wrap, '보기 1'); addOptionTo(wrap, '보기 2');
      }
    }else{
      addOptionTo(wrap, '보기 1'); addOptionTo(wrap, '보기 2');
    }
    return wrap;
  }

  document.getElementById('btnAddQuestion').addEventListener('click', function(){ addQuestion(); });

  function buildDocJson(){
    // 대상 수집
    const scope = (document.getElementById('targetScope').value || '').trim();
    if (scope === 'DEPT'){
      const depts = Array.from(document.querySelectorAll('.deptChk:checked')).map(ch => ch.value);
      document.getElementById('deptNos').value = depts.join(',');
    } else if (scope === 'DIRECT'){
      document.getElementById('empNos').value = Array.from(selectedEmp).join(',');
    }

    // 질문 JSON 수집
    const qs = [];
    document.querySelectorAll('.q-item').forEach(function(q, idx){
      const text = (q.querySelector('.q-text').value || '').trim();
      const mul  = q.querySelector('.q-multiple').checked;
      const opts = Array.from(q.querySelectorAll('.opt-text'))
                        .map(i => (i.value || '').trim())
                        .filter(Boolean);
      if (!text || opts.length < 2) return;
      qs.push({
        id: 'q'+(idx+1),
        text: text,
        multiple: !!mul,
        options: opts.map((t, j) => ({ id:'o'+(j+1), text:t }))
      });
    });

    if (qs.length === 0){
      alert('질문/보기를 올바르게 입력하세요. (각 질문은 최소 2개 보기 필요)');
      return false;
    }
    document.getElementById('docJson').value = JSON.stringify(qs);
    return true;
  }

  // ---------- 초기 로딩 ----------
  (function(){
    // 스코프 토글
    const scopeSel = document.getElementById('targetScope');
    function syncScope(){
      document.getElementById('scopeDeptBox').style.display   = (scopeSel.value === 'DEPT')   ? '' : 'none';
      document.getElementById('scopeDirectBox').style.display = (scopeSel.value === 'DIRECT') ? '' : 'none';
    }
    scopeSel.addEventListener('change', syncScope);
    syncScope();

    // 질문 초기화
    const initQuestions = parseInitJson('init-questions', []);
    if (initQuestions && initQuestions.length){
      initQuestions.forEach(function(q){ addQuestion(q); });
    } else {
      addQuestion(); addQuestion();
    }
  })();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
