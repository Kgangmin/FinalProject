<!-- /WEB-INF/views/org/organization.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>

<jsp:include page="../header/header.jsp" />

<!-- Highcharts 10.3.1 -->
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/highcharts.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/sankey.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/organization.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/exporting.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/modules/accessibility.js"></script>

<style>
  .content-wrapper {
    padding-top: var(--topbar-h);
    margin-left: var(--sidebar-w);
  }

  .org-viewport{
    height: calc(100vh - var(--topbar-h));
    display: flex;
    align-items: stretch;
    justify-content: center;
  }
  #orgContainer {
    width: 100%;
    height: 100%;
    margin-left: 13.5%;
    margin-top: 2%;
    max-width: none;
  }

  .hc-node { text-align:left;}
  .hc-node .dept { font-weight:700; font-size:13px; margin-bottom:4px; }
  .hc-node .mgr  { font-size:12px; color:#333; }
  .hc-node .pos  { font-size:11px; color:#666; margin-top:2px; }

  .highcharts-background { fill: #f8f9fa !important; }
  .hc-node-photo { text-align:center; width:100%; }
  .hc-node-photo img {
    width: 54px; height: 54px; border-radius: 50%;
    object-fit: cover; display:block; margin: 0 auto 6px;
  }
  .hc-node-photo .nm { font-size:12px; font-weight:600; }

</style>

<select name="searchType" id="searchType" style="margin:1.5% 0 0 87%;">
  <option value="all">회사전체조직도</option>
  <option value="1">경영지원부 조직도</option>
  <option value="2">영업/마케팅부</option>
  <option value="3">기술/연구부</option>
  <option value="4">생산/운영부</option>
  <option value="5">기타 지원부</option>
</select>

<div class="org-viewport">
  <div id="orgContainer" aria-label="조직도 차트"></div>
</div>

<script>
(function(){
  function escHtml(s){
    if(s==null) return '';
    return String(s)
      .replace(/&/g,'&amp;')
      .replace(/</g,'&lt;')
      .replace(/>/g,'&gt;')
      .replace(/"/g,'&quot;')
      .replace(/'/g,'&#39;');
  }

  // 공통 draw: mode = 'company' | 'photo'
  function drawChart(payload, mode, titleText){
    const edges = payload.edges || [];
    const nodes = payload.nodes || [];

    const cont = document.getElementById('orgContainer');
    const H = cont ? cont.clientHeight : 720;
    const W = cont ? cont.clientWidth  : 1200;

    const seriesBase = {
      type: 'organization',
      name: 'HANB',
      keys: ['from','to'],
      data: edges,
      nodes: nodes,
      colorByPoint: false,
      color: '#007ad0',
      borderColor: '#ffffff',
      nodeWidth: (mode === 'photo' ? 110 : 100),
      levels: [
        { level: 0, color: '#0056b3', borderColor: '#003366',
          dataLabels: { style: { color: '#000', fontWeight: 'bold'} } },
        { level: 1, color: '#007ad0', borderColor: '#005f99',
          dataLabels: { style: { color: '#000' } } },
        { level: 2, color: '#66b2ff', borderColor: '#3399ff',
          dataLabels: { style: { color: '#000' } } },
        { level: 3, color: '#cce6ff', borderColor: '#99ccff',
          dataLabels: { style: { color: '#000' } } }
      ],
      dataLabels: { useHTML: true},
      tooltip: { outside: true }
    };

    if (mode === 'photo') {
      // 사진+이름 전용 라벨
      seriesBase.dataLabels.nodeFormatter = function () {
        var p = this.point || {};
        var fn = (p.custom && p.custom.photo) || 'default_profile.jpg';
        var nm = (p.custom && p.custom.empName) || '';
        var imgUrl = '<%=ctxPath %>/resources/images/emp_profile/' + escHtml(fn);
        var html = '<div class="hc-node-photo">'
                 +   '<img src="'+ imgUrl +'" alt="">'
                 +   '<div class="nm">' + escHtml(nm) + '</div>'
                 + '</div>';
        return html;
      };
    } else {
      // 기존 회사 전체 라벨
      seriesBase.dataLabels.nodeFormatter = function () {
        var p = this.point || {};
        if (p.id === 'ROOT') {
          return '<div class="hc-node"><div class="dept">회사전체</div></div>';
        }
        var name = escHtml(p.name || '');     // 부서명
        var title = escHtml(p.title || '');   // "사원명 직급"
        var positions = escHtml((p.custom && p.custom.positions) || '');
        var html = '<div class="hc-node">'
                 +   '<div class="dept">'+ name +'</div>';
        if (title)     html += '<div class="mgr">'+ title +'</div>';
        if (positions) html += '<div class="pos">'+ positions +'</div>';
        html += '</div>';
        return html;
      };
    }

    Highcharts.chart('orgContainer', {
      chart: {
        inverted: true,
        height: H - 50,
        width: W - 50,
        reflow: true
      },
      title: { text: titleText || (mode === 'photo' ? '부서 조직도' : '조직도') },
      credits: { enabled: false },
      series: [seriesBase],
      exporting: { allowHTML: true, sourceWidth: W, sourceHeight: H }
    });
  }

  async function loadAll(){
    const res = await fetch('<%=ctxPath %>/org/api/orgchart', {
      credentials:'include',
      headers:{ 'Accept':'application/json' },
      cache:'no-store'
    });
    if(!res.ok){ return showError('조직도 데이터를 불러오지 못했습니다.'); }
    const json = await res.json();
    if(!json || !json.ok){ return showError('조직도 데이터 형식이 올바르지 않습니다.'); }
    drawChart(json, 'company', '조직도');
  }

  async function loadDept(rootDept, titleText){
    const url = '<%=ctxPath %>/org/api/orgchart?rootDept=' + encodeURIComponent(rootDept);
    const res = await fetch(url, {
      credentials:'include',
      headers:{ 'Accept':'application/json' },
      cache:'no-store'
    });
    if(!res.ok){ return showError('부서 조직도 데이터를 불러오지 못했습니다.'); }
    const json = await res.json();
    if(!json || !json.ok){ return showError(json && json.msg ? json.msg : '부서 조직도 데이터가 없습니다.'); }
    drawChart(json, 'photo', titleText);
  }

  function showError(msg){
    document.getElementById('orgContainer').innerHTML =
      '<div class="text-danger">'+ escHtml(msg) +'</div>';
  }

  // select 값 -> 루트 부서번호 매핑
  const sel = document.getElementById('searchType');
  function onChangeSelect(){
    switch(sel.value){
      case 'all':
        loadAll();
        break;
      case '1':
        loadDept('10', '경영지원부 조직도');
        break;
      case '2':
        loadDept('20', '영업/마케팅부 조직도');
        break;
      case '3':
        loadDept('30', '기술/연구부 조직도');
        break;
      case '4':
        loadDept('40', '생산/운영부 조직도');
        break;
      case '5':
        loadDept('50', '기타 지원부 조직도');
        break;
      default:
        loadAll();
    }
  }
  sel.addEventListener('change', onChangeSelect);

  // 최초 로드: 회사 전체 조직도
  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded', loadAll);
  }else{
    loadAll();
  }
})();
</script>

<jsp:include page="../footer/footer.jsp" />
