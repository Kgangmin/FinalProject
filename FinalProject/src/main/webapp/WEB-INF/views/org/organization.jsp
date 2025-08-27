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
  .org-wrap{ max-width: 1100px; margin: 16px auto; background:#fff; border:1px solid #e5e5e5; border-radius:10px; padding:16px; }
  #orgContainer{ height: 720px; }
  /* 노드 라벨 커스텀 */
  .hc-node { text-align:left; }
  .hc-node .dept { font-weight:700; font-size:13px; margin-bottom:4px; }
  .hc-node .mgr  { font-size:12px; color:#333; }
  .hc-node .pos  { font-size:11px; color:#666; margin-top:2px; }
</style>

<div class="org-wrap" >
  <h5 class="mb-3">조직도</h5>
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

    // Highcharts 시리즈에 맞추어 구성
    Highcharts.chart('orgContainer', {
      chart: {
        height: 720,
        width: 1100,     // ← 차트 자체 가로폭 늘리기
        spacingLeft: 50, // 여백 조정
        spacingRight: 50,
        inverted: true
      },
      title: { text: '조직도' },
      series: [{
        type: 'organization',
        name: 'HANB',
        keys: ['from','to'],
        data: edges,            // ex) [['10000','10100'], ...]
        nodes: nodes,           // ex) [{id,name,title,custom:{positions}}...]
        colorByPoint: false,
        color: '#007ad0',
        borderColor: '#ffffff',
        nodeWidth: 80,
        
        dataLabels: {
          useHTML: true,
          // Highcharts 10.3.1 호환: escapeHTML 미사용, 자체 escape 함수 사용
          nodeFormatter: function () {
            // this.point.name (부서명), this.point.title (사원명 직급), this.point.custom.positions
            var name = escHtml(this.point.name || '');
            var title = escHtml(this.point.title || '');
            var positions = escHtml((this.point.custom && this.point.custom.positions) || '');
            var html = '<div class="hc-node">'
                     +   '<div class="dept">'+ name +'</div>'
                     +   '<div class="mgr">'+ (title || '관리자 미지정') +'</div>';
            if (positions) html += '<div class="pos">'+ positions +'</div>';
            html += '</div>';
            return html;
          }
        },
        tooltip: { outside: true }
      }],
      exporting: {
        allowHTML: true,
        sourceWidth: 1000,
        sourceHeight: 720
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
