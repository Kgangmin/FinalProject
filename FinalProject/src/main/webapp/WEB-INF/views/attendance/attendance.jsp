<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<%
    String ctxPath = request.getContextPath();
%>

<!-- 헤더 먼저 include (전역 변수/레이아웃 선언) -->
<jsp:include page="../header/header.jsp"/>

<!-- 페이지 전용 CSS는 헤더 다음에 -->
<link rel="stylesheet" href="<%=ctxPath %>/css/attendance.css"/>

<div class="att2-layout">
<!-- 오늘 기록 소스: 기존 맵 그대로 쓰거나, 컨트롤러에서 todayAtt로 내려줘도 됩니다 -->
<c:if test="${empty todayAtt}">
  <c:set var="todayAtt" value='${attByDate[todayKey]}'/>
</c:if>

<!-- 상태 텍스트(배지) 계산 -->
<c:set var="attState"
       value="${empty todayAtt ? '대기'
                 : (empty todayAtt.clockIn ? '대기'
                    : (empty todayAtt.clockOut ? '근무중' : '퇴근'))}"/>

<!-- 버튼 enable/disable 플래그 -->
<c:set var="canIn"  value="${empty todayAtt or empty todayAtt.clockIn}"/>
<c:set var="canOut" value="${not empty todayAtt.clockIn and empty todayAtt.clockOut}"/>

<aside class="att2-aside">
  <div class="as2-head">
    <div class="as2-title">근태</div>

    <!-- 날짜 + 현재 시각 + 상태배지 -->
    <div class="as2-topline">
      <span class="as2-dt">
        <fmt:formatDate value="<%=new java.util.Date()%>" pattern="yyyy년 MM월 dd일 (E)"/>
        <span id="as2Time" class="as2-clock">--:--:--</span>
      </span>
      <span class="as2-badge ${attState eq '근무중' ? 'on' : ''}">
        ${attState}
      </span>
    </div>
  </div>

  <div class="as2-panel">

    <!-- 출근 → 퇴근 요약 박스 -->
    <div class="io2-twin">
      <div class="tcol">
        <span class="tlabel">출근시간</span>
        <span class="tval">
          <c:choose>
            <c:when test="${not empty todayAtt && not empty todayAtt.clockIn}">
              <fmt:formatDate value="${todayAtt.clockIn}" pattern="HH:mm:ss"/>
            </c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </span>
      </div>
      <div class="tarrow">→</div>
      <div class="tcol">
        <span class="tlabel">퇴근시간</span>
        <span class="tval">
          <c:choose>
            <c:when test="${not empty todayAtt && not empty todayAtt.clockOut}">
              <fmt:formatDate value="${todayAtt.clockOut}" pattern="HH:mm:ss"/>
            </c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </span>
      </div>
    </div>

    <!-- 버튼 두 개 (항상 보이되 상태로 disable) -->
    <div class="btn-row">
      <button type="button" class="btn2 btn2-primary"
              id="btnClockIn" ${canIn ? "" : "disabled"}>출근하기</button>

      <button type="button" class="btn2 btn2-outline"
              id="btnClockOut" ${canOut ? "" : "disabled"}>퇴근하기</button>
    </div>

    <button type="button" class="btn2 btn2-ghost wide" id="btnRemark">
      비고란 작성
    </button>
  </div>
</aside>

  <!-- ===== 우측 컨텐츠 ===== -->
  <main class="att2-main">
    <!-- 상단: 타이틀 + 주간 네비 -->
    <div class="mh2">
      <div class="mh2-title">내 근태현황</div>
      <div class="mh2-range">
        <button class="mh2-nav" onclick="location.href='${pageContext.request.contextPath}/attendance?nav=prev'">‹</button>
        <div class="mh2-text"><fmt:formatDate value="${weekStart}" pattern="yyyy-MM-dd"/> ~ <fmt:formatDate value="${weekEnd}" pattern="yyyy-MM-dd"/></div>
        <button class="mh2-nav" onclick="location.href='${pageContext.request.contextPath}/attendance?nav=next'">›</button>
        <button class="mh2-today" onclick="location.href='${pageContext.request.contextPath}/attendance?nav=today'">오늘</button>
      </div>
    </div>

    <!-- 기본그룹 + 주간누적 진행바 -->
    <fmt:formatNumber value="${actualHours}" maxFractionDigits="1" minFractionDigits="1" var="actualH1"/>
	<fmt:formatNumber value="${targetHours}" maxFractionDigits="1" minFractionDigits="1" var="targetH1"/>
	<fmt:formatNumber value="${remainHours}" maxFractionDigits="1" minFractionDigits="1" var="remainH1"/>

    <div class="card2 sum2">
      <div class="sum2-head">
        <div class="sum2-title">기본그룹 <span class="muted2">(09:00 ~ 18:00)</span></div>
        <div class="sum2-help">i</div>
      </div>

	<div class="sum2-progress">
		<div class="sp2-label">주간누적</div>
		<div class="sp2-bar"><div class="sp2-fill" style="width:${pct}%;"></div></div>
		<div class="sp2-meta">이번 주는 ${targetH1}시간 중 ${actualH1}시간이 기록되었어요.</div>
	</div>

<div class="sum2-metrics">
  <div class="met2">
	<div class="met2-label">잔여 근무일</div>
	<div class="met2-value">${futureRemainDays}<span class="met2-unit">일/5일</span></div>
  </div>
  <div class="met2">
    <div class="met2-label">잔여 근로시간</div>
    <div class="met2-value">${remainH1}h<span class="met2-unit">/${targetH1}h</span></div>
    <div class="met2-mini"><div class="bar" style="width:${pct}%;"></div></div>
  </div>
  <div class="met2">
    <div class="met2-label">총 근로시간</div>
    <!-- h와 m 분리표시 대신 1자리 소수의 시간만 -->
    <div class="met2-value">${actualH1}h</div>
  </div>
  <div class="met2">
    <div class="met2-label">휴가</div>
    <div class="met2-value">0h00m</div>
  </div>
</div>
    </div>

    <!-- 주간 달력(1주) -->
    <div class="card2 week2">
      <div class="week2-row">
        <c:forEach var="d" items="${weekDays}">
          <c:set var="key"><fmt:formatDate value="${d}" pattern="yyyy-MM-dd"/></c:set>
          <c:set var="it" value='${attByDate[key]}'/>
          <div class="day2 <c:out value='${key eq todayKey ? "today" : ""}'/>">
            <div class="day2-head">
              <span class="dow2"><fmt:formatDate value="${d}" pattern="E"/></span>
              <span class="dnum2"><fmt:formatDate value="${d}" pattern="d"/></span>
            </div>
            <div class="day2-body">
              <c:choose>
                <c:when test="${empty it}">
                  <div class="chip2 muted2">기록없음</div>
                </c:when>
                <c:otherwise>
                  <div class="line2">
                    <span class="chip2 on">출근</span>
                    <span class="val2">
                      <c:choose>
                        <c:when test="${not empty it.clockIn}">
                          <fmt:formatDate value="${it.clockIn}" pattern="HH:mm"/>
                        </c:when><c:otherwise>-</c:otherwise>
                      </c:choose>
                    </span>
                  </div>
                  <div class="line2">
                    <span class="chip2 off">퇴근</span>
                    <span class="val2">
                      <c:choose>
                        <c:when test="${not empty it.clockOut}">
                          <fmt:formatDate value="${it.clockOut}" pattern="HH:mm"/>
                        </c:when><c:otherwise>-</c:otherwise>
                      </c:choose>
                    </span>
                  </div>
                  <div class="line2 flags2">
                    <c:if test="${it.isLate eq 'Y'}"><span class="badge2 warn">지각</span></c:if>
                    <c:if test="${it.isAbsent eq 'Y'}"><span class="badge2 bad">결근</span></c:if>
                  </div>
                  <c:if test="${not empty it.remark}">
                    <div class="remark2" title="${it.remark}">
                      <span class="material-symbols-outlined" style="font-size:16px"></span>
                      <span class="r2text">${fn:length(it.remark) > 20 ? fn:substring(it.remark,0,20).concat('…') : it.remark}</span>
                    </div>
                  </c:if>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>

    <!-- 상세 근로시간 -->
    <div class="card2 detail2">
      <div class="c2-head">금일 상세 근로시간</div>
      <div class="tl2-wrap">
      <div class="tl2">
        <div class="tl2-grid"></div>
    <c:if test="${not empty todayAtt and not empty todayAtt.clockIn}">
  <%-- 출근시각 (시.분 소수 형태) --%>
  <fmt:formatDate value="${todayAtt.clockIn}" pattern="HH" var="inH"/>
  <fmt:formatDate value="${todayAtt.clockIn}" pattern="mm" var="inM"/>
  <c:set var="startHM" value="${inH + (inM/60.0)}"/>

  <c:choose>
    <c:when test="${not empty todayAtt.clockOut}">
      <%-- 퇴근시각 (시.분 소수 형태) --%>
      <fmt:formatDate value="${todayAtt.clockOut}" pattern="HH" var="outH"/>
      <fmt:formatDate value="${todayAtt.clockOut}" pattern="mm" var="outM"/>
      <c:set var="endHM" value="${outH + (outM/60.0)}"/>
    </c:when>
    <c:otherwise>
      <%-- 퇴근 안 했으면 현재 시간 사용 --%>
      <fmt:formatDate value="<%=new java.util.Date()%>" pattern="HH" var="nowH"/>
      <fmt:formatDate value="<%=new java.util.Date()%>" pattern="mm" var="nowM"/>
      <c:set var="endHM" value="${nowH + (nowM/60.0)}"/>
    </c:otherwise>
  </c:choose>

  <%-- 정상 근무 시간대 (09:00 - 18:00) --%>
  <c:set var="normalStart" value="9"/>
  <c:set var="normalEnd" value="18"/>

  <%-- 첫 번째 막대: 전체 근무 시간을 빨간색으로 그리기 --%>
  <div class="tl2-span red-bar"
       style="left:${startHM * (100/24)}%; width:${(endHM - startHM) * (100/24)}%"></div>

  <%-- 두 번째 막대: 정상 근무 시간(초록색)을 위에 겹쳐서 그리기 --%>
  <c:set var="greenStart" value="${startHM > normalStart ? startHM : normalStart}"/>
  <c:set var="greenEnd"   value="${endHM < normalEnd ? endHM : normalEnd}"/>
<%-- 초록바(09~18) 모서리 반응: 빨강과 겹치면 각, 단독이면 둥글게 --%>
<c:set var="greenLeftRadius"  value="${startHM lt greenStart ? '0' : '9999px'}"/>
<c:set var="greenRightRadius" value="${endHM   gt greenEnd   ? '0' : '9999px'}"/>



<c:if test="${greenStart < greenEnd}">
  <div class="tl2-span green-bar"
       style="
         left:${greenStart * (100/24)}%;
         width:${(greenEnd - greenStart) * (100/24)}%;
         border-top-left-radius:${greenLeftRadius};
         border-bottom-left-radius:${greenLeftRadius};
         border-top-right-radius:${greenRightRadius};
         border-bottom-right-radius:${greenRightRadius};
       "></div>
</c:if>
</c:if>
      </div>
      
          <div class="tl2-hours">
  <c:forEach var="h" begin="1" end="23">
    <div class="tl2-hour" style="left:${h * (100/24)}%;">
      ${h lt 10 ? '0' : ''}${h}
    </div>
  </c:forEach>
</div>
  </div> <!-- /.tl2-wrap -->
      <div class="legend2">
        <span class="dot2 green"></span>정상근무
        <span class="dot2 red"></span>초과근무
      </div>
    </div>
  </main>
</div>

<jsp:include page="../footer/footer.jsp"/>

<script>
$(function(){
  function z(n){ return ('0' + n).slice(-2); }

  function tick(){
    var d = new Date();
    // ✅ 문자열 덧셈으로 EL 충돌 회피
    $('#as2Time').text(
      z(d.getHours()) + ':' + z(d.getMinutes()) + ':' + z(d.getSeconds())
    );
  }
  tick();
  setInterval(tick, 1000);

  var CTX = '<%=ctxPath%>';
  $('#btnClockIn').on('click', function(){
    $.post(CTX + '/attendance/clock-in', function(){ location.reload(); })
     .fail(function(){ alert('출근 기록 실패'); });
  });
  $('#btnClockOut').on('click', function(){
    $.post(CTX + '/attendance/clock-out', function(){ location.reload(); })
     .fail(function(){ alert('퇴근 기록 실패'); });
  });
  $('#btnRemark').on('click', function(){
    var txt = prompt('비고를 입력하세요.'); if(txt==null) return;
    $.post(CTX + '/attendance/remark', {remark: txt}, function(){ location.reload(); })
     .fail(function(){ alert('비고 저장 실패'); });
  });
});
</script>