<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/survey/survey_side.jsp" />

<style>
.chart-box{ background:#fff; border:1px solid #dee2e6; border-radius:10px; box-shadow:0 1px 2px rgba(0,0,0,.04); }
.chart-box .hd{ padding:12px 14px; border-bottom:1px solid #f1f1f1;}
.chart-box .bd{ padding:14px; }
.chart { min-height: 320px; }
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
    <div class="d-flex align-items-center justify-content-between mb-2">
      <h5 class="mb-0"><c:out value="${detail.title}"/> — 결과</h5>
      <a class="btn btn-outline-secondary btn-sm" href="<%=ctxPath%>/survey/detail?sid=${detail.surveyId}">상세로</a>
    </div>
    <div class="mb-2 text-muted">기간: <c:out value="${detail.startDate}"/> ~ <c:out value="${detail.endDate}"/></div>

    <c:forEach var="q" items="${detail.questions}" varStatus="st">
      <div class="chart-box mb-3">
        <div class="hd"><strong>Q${st.index+1}.</strong> <c:out value="${q.text}"/></div>
        <div class="bd">
          <div id="chart_${q.id}" class="chart"></div>
        </div>
      </div>
    </c:forEach>
  </div>
</div>

<!-- Highcharts 10.3.1 -->
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/highcharts.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/code/modules/exporting.js"></script>
<script src="<%=ctxPath %>/Highcharts-10.3.1/modules/accessibility.js"></script>

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
  // 서버에서 전달된 집계: Map<questionKey, List<{name: optionText, y: count}>>
  var agg = {
    <c:forEach var="q" items="${detail.questions}" varStatus="st">
      "${q.id}": [
        <c:forEach var="pt" items="${agg[q.id]}" varStatus="s2">
          {"name": "<c:out value='${pt.name}'/>", "y": ${pt.y}}<c:if test='${!s2.last}'>,</c:if>
        </c:forEach>
      ]<c:if test='${!st.last}'>,</c:if>
    </c:forEach>
  };

  <c:forEach var="q" items="${detail.questions}">
    Highcharts.chart("chart_${q.id}", {
      title: { text: null },
      credits: { enabled: false },
      xAxis: { type: 'category' },
      yAxis: { title: { text: '응답 수' }, allowDecimals: false },
      legend: { enabled: false },
      tooltip: { pointFormat: '<b>{point.y}</b>명' },
      series: [{
        type: 'column',
        data: agg["${q.id}"] || []
      }]
    });
  </c:forEach>
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
