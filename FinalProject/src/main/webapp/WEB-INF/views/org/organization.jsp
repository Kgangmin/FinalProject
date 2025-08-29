<!-- /WEB-INF/views/org/organization.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>

<jsp:include page="../header/header.jsp" />

<!-- Highcharts 10.3.1 (프로젝트 경로에 맞게) -->
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/highcharts.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/sankey.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/organization.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/exporting.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/modules/accessibility.js"></script>

<style>

  .content-wrapper {
	  padding-top: var(--topbar-h);   /* 고정 헤더만큼 위 여백 */
	  margin-left: var(--sidebar-w); /* 고정 사이드바만큼 왼쪽 띄움 */
}

  /* 조직도 컨테이너: 본문 영역을 꽉 채우고 중앙 정렬 */
  .org-viewport{
	height: calc(100vh - var(--topbar-h)); /* 헤더 제외 전체 높이 */
    display: flex;
    align-items: stretch;   /* 세로 꽉 채움 */
    justify-content: center;/* 가로는 가운데 배치 */
 

}

	/* 차트 컨테이너: 가로는 본문 가득, 세로는 본문 높이에서 살짝 여유 */
	#orgContainer {
	  width: 100%;
	  height: 100%;
	  margin-left: 13.5%;
	  margin-top: 2%;
	  max-width: none;
	}
	  
  /* 노드 라벨 커스텀 */
  .hc-node { text-align:left; }
  .hc-node .dept { font-weight:700; font-size:13px; margin-bottom:4px; }
  .hc-node .mgr  { font-size:12px; color:#333; }
  .hc-node .pos  { font-size:11px; color:#666; margin-top:2px; }
  
  .highcharts-background {
  fill: #f8f9fa !important;
}

</style>

<div class="org-viewport"> 
  <div id="orgContainer" aria-label="조직도 차트"></div>
</div>

<script>
(function(){
  const CTX = '<%=ctxPath%>';

  function escHtml(s){
    if(s==null) return '';
    return String(s)
      .replace(/&/g,'&amp;')
      .replace(/</g,'&lt;')
      .replace(/>/g,'&gt;')
      .replace(/"/g,'&quot;')
      .replace(/'/g,'&#39;');
  }

  function drawChart(payload){
    const edges = payload.edges || [];
    const nodes = payload.nodes || [];
    
 	// 컨테이너 실제 높이 읽기
    const cont = document.getElementById('orgContainer');
	const H = cont ? cont.clientHeight : 720;
	const W = cont ? cont.clientWidth  : 1200;

    // Highcharts 시리즈에 맞추어 구성
    Highcharts.chart('orgContainer', {
    chart: {
      inverted: true,
      height: H-50,   				     // 컨테이너 높이에 맞춤
      width: W-50,
      reflow: true                   // 리사이즈 시 컨테이너 크기에 맞춰 재배치

    },
    title: { text: '조직도' },      
    credits: { enabled: false },

    series: [{
      type: 'organization',
      name: 'HANB',
      keys: ['from','to'],
      data: edges,                 // ex) [['PARENT','CHILD'], ...]
      nodes: nodes,                // ex) [{id,name,title,custom:{positions}}...]
      colorByPoint: false,
      color: '#007ad0',
      borderColor: '#ffffff',
      nodeWidth: 100,              // 필요 시 80~140로 조정
      
   // ★ 레벨별 스타일 지정
      levels: [
        {
          level: 0,          // 최상위 (ROOT 또는 회사전체)
          color: '#0056b3',  // 진한 파랑
          borderColor: '#003366',
          dataLabels: { style: { color: '#fff', fontWeight: 'bold' } }
        },
        {
          level: 1,          // 상위 부서
          color: '#007ad0',  // 중간 파랑
          borderColor: '#005f99',
          dataLabels: { style: { color: '#fff' } }
        },
        {
          level: 2,          // 하위 부서
          color: '#66b2ff',  // 연한 파랑
          borderColor: '#3399ff',
          dataLabels: { style: { color: '#000' } }
        },
        {
          level: 3,          // 더 하위 (있다면)
          color: '#cce6ff',
          borderColor: '#99ccff',
          dataLabels: { style: { color: '#000' } }
        }
      ],

      dataLabels: {
        useHTML: true,
        nodeFormatter: function () {
          var p = this.point || {};
          // 가상 ROOT 노드는 회사명만 표기 (불필요한 '관리자 미지정' 제거)
          if (p.id === 'ROOT') {
            return '<div class="hc-node"><div class="dept">회사전체</div></div>';
          }
          var name = escHtml(p.name || '');     // 부서명
          var title = escHtml(p.title || '');   // "사원명 직급"
          var positions = escHtml((p.custom && p.custom.positions) || ''); // 직책 문자열
          var html = '<div class="hc-node">'
                   +   '<div class="dept">'+ name +'</div>';
          if (title)     html += '<div class="mgr">'+ title +'</div>';
          if (positions) html += '<div class="pos">'+ positions +'</div>';
          html += '</div>';
          return html;
        }
      },
        tooltip: { outside: true }
      }],
      exporting: {
          allowHTML: true,
          sourceWidth:  W,
          sourceHeight: H
        }
    });
  }

  async function loadData(){
    const res = await fetch(CTX + '/org/api/orgchart', {
      credentials:'include',
      headers:{ 'Accept':'application/json' },
      cache:'no-store'
    });
    if(!res.ok){
      document.getElementById('orgContainer').innerHTML =
        '<div class="text-danger">조직도 데이터를 불러오지 못했습니다.</div>';
      return;
    }
    const json = await res.json();
    if(!json || !json.ok){
      document.getElementById('orgContainer').innerHTML =
        '<div class="text-danger">조직도 데이터 형식이 올바르지 않습니다.</div>';
      return;
    }
    drawChart(json);
  }

  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded', loadData);
  }else{
    loadData();
  }
})();
</script>

<jsp:include page="../footer/footer.jsp" />
