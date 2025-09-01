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

<!-- ===== 본문 시작 ===== -->
<div id="hb-att" class="container-fluid">

  <!-- ===== 당일 출근/퇴근 위젯 ===== -->
  <div class="hb-today card hb-card">
    <div class="hb-today-head">
      <div class="hb-today-title">오늘</div>
      <div class="hb-now" id="hbNow">--:--:--</div>
    </div>

    <div class="hb-today-times">
      <div class="hb-timebox">
        <div class="label">출근 시간</div>
        <div class="value" id="hbInVal">
          <c:choose>
            <c:when test="${not empty todayClockIn}">${todayClockIn}</c:when>
            <c:otherwise>--:--:--</c:otherwise>
          </c:choose>
        </div>
      </div>
      <div class="hb-timebox">
        <div class="label">퇴근 시간</div>
        <div class="value" id="hbOutVal">
          <c:choose>
            <c:when test="${not empty todayClockOut}">${todayClockOut}</c:when>
            <c:otherwise>--:--:--</c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

    <div class="hb-today-actions">
      <form method="post" action="<%=ctxPath%>/attendance/clock-in" class="mr-1">
        <sec:csrfInput/>
        <button type="submit" class="btn btn-primary btn-sm" ${not empty todayClockIn ? "disabled" : ""}>출근하기</button>
      </form>
      <form method="post" action="<%=ctxPath%>/attendance/clock-out">
        <sec:csrfInput/>
        <button type="submit" class="btn btn-outline-primary btn-sm" ${empty todayClockIn || not empty todayClockOut ? "disabled" : ""}>퇴근하기</button>
      </form>
    </div>
  </div>
  <!-- ===== /당일 출근/퇴근 위젯 ===== -->

  <!-- 상단 툴바 -->
  <div class="hb-toolbar">
    <div class="hb-toolbar-left">
      <button type="button" class="hb-icon-btn" aria-label="이전 주">‹</button>
      <div class="hb-range">${weekly.weekLabel}</div>
      <a href="?today=1" class="hb-link ml-2">오늘</a>
    </div>
    <div class="hb-toolbar-right">
      <div class="hb-toggle">
        <a class="active" href="?view=week">주간</a>
        <span>·</span>
        <a class="muted" href="?view=day">일간</a>
      </div>
      <div class="hb-divider"></div>
      <a class="hb-link" href="#">전자결재</a>
      <div class="hb-divider"></div>
      <a class="hb-link" href="#">목록 다운로드</a>
    </div>
  </div>

  <!-- 요약 카드 -->
  <div class="hb-card hb-summary">
    <div class="hb-summary-head">
      <div class="hb-muted">기본그룹 <span class="hb-dot-sep">·</span> 09:00 ~ 18:00</div>
      <div class="hb-help" title="기본근무제 기준입니다.">i</div>
    </div>

    <c:set var="wm" value="${weekly.workedMinutes}"/>
    <c:set var="wrH" value="${wm/60}"/>
    <c:set var="wrM" value="${wm%60}"/>
    <c:set var="rm" value="${weekly.requiredMinutes}"/>
    <c:set var="rqH" value="${rm/60}"/>
    <c:set var="rqM" value="${rm%60}"/>

    <div class="hb-progress-row">
      <div class="hb-progress">
        <div class="hb-bar"><i style="width:${weekly.pct}%"></i></div>
        <div class="hb-bar-label">
          <span>주간누적 <span class="hb-time">${wrH}h <fmt:formatNumber value="${wrM}" minIntegerDigits="2"/>m</span></span>
          <span class="hb-time">${rqH}h <fmt:formatNumber value="${rqM}" minIntegerDigits="2"/>m</span>
        </div>
      </div>
      <span class="hb-chip ${weekly.workedMinutes >= weekly.requiredMinutes ? 'hb-chip-ok' : 'hb-chip-warn'}">
        <strong>${weekly.pct}%</strong>
      </span>
    </div>

    <div class="hb-kpi">
      <div class="hb-kpi-item">
        <div class="hb-muted">전여 근무일</div>
        <div class="hb-num">${weekly.workedDays}일/5일</div>
      </div>
      <div class="hb-kpi-item">
        <div class="hb-muted">전여 근로시간</div>
        <div class="hb-num">
          ${wrH}h <fmt:formatNumber value="${wrM}" minIntegerDigits="2"/>m /
          ${rqH}h <fmt:formatNumber value="${rqM}" minIntegerDigits="2"/>m
        </div>
      </div>
      <div class="hb-kpi-item">
        <div class="hb-muted">총 근로시간</div>
        <div class="hb-num">${wrH}h <fmt:formatNumber value="${wrM}" minIntegerDigits="2"/>m</div>
      </div>
      <div class="hb-kpi-item">
        <div class="hb-muted">휴가</div>
        <div class="hb-num">0h 00m</div>
      </div>
    </div>
  </div>

  <!-- 주간 보드 -->
  <div class="hb-week-board">
    <div class="hb-week-strip hb-card">
      <div class="hb-week-strip-inner">
        <c:forEach var="rec" items="${records}">
          <div class="hb-daymini">
            <div class="hb-daymini-top">
              <span class="hb-day-badge"><fmt:formatDate value="${rec.workDate}" pattern="E"/></span>
              <span class="hb-day-date"><fmt:formatDate value="${rec.workDate}" pattern="d"/></span>
              <c:if test="${rec.isAbsent=='Y'}"><span class="hb-label danger">결</span></c:if>
              <c:if test="${rec.isLate=='Y'}"><span class="hb-label warn">지</span></c:if>
            </div>
            <div class="hb-daymini-body">
              <span class="hb-mini-time in">
                <c:choose><c:when test="${empty rec.clockIn}">-</c:when><c:otherwise><fmt:formatDate value="${rec.clockIn}" pattern="HH:mm"/></c:otherwise></c:choose>
              </span>
              <span class="hb-mini-time out">
                <c:choose><c:when test="${empty rec.clockOut}">-</c:when><c:otherwise><fmt:formatDate value="${rec.clockOut}" pattern="HH:mm"/></c:otherwise></c:choose>
              </span>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>

    <div class="hb-card hb-note">
      <div class="hb-note-body"><div class="hb-muted">메모/공지 영역</div></div>
    </div>
  </div>

  <!-- 상세 타임라인 -->
  <div class="hb-card hb-detail">
    <div class="hb-detail-head">
      <div class="hb-detail-title">근무시작</div>
      <div class="hb-detail-title">근무종료</div>
      <div class="hb-detail-title">총 근로시간</div>
      <div class="hb-detail-title">상세 근로시간</div>
      <div class="hb-detail-title">승인요청내역</div>
    </div>

    <div class="hb-ruler">
      <div class="hb-hours">
        <c:forEach begin="0" end="23" var="h">
          <div class="hb-hour"><span class="hb-hour-label"><c:out value="${h < 10 ? ('0' += h) : h}"/></span></div>
        </c:forEach>
      </div>

      <div class="hb-runs">
        <c:forEach var="rec" items="${records}">
          <div class="hb-run-row">
            <div class="hb-runbar">
              <c:if test="${rec.timelineWidthPct > 0}">
                <i style="left:${rec.timelineLeftPct}%;width:${rec.timelineWidthPct}%"></i>
              </c:if>
            </div>
          </div>
        </c:forEach>
      </div>

      <div class="hb-legend">
        <span class="dot work"></span>업무시간
        <span class="dot info"></span>업무미포함시간
        <span class="dot rest"></span>휴게시간
        <span class="dot approve"></span>승인 초과근로
        <span class="dot night"></span>야간근로
        <span class="dot leave"></span>휴가
      </div>
    </div>
  </div>

</div>
<!-- ===== 본문 끝 ===== -->

<jsp:include page="../footer/footer.jsp"/>

<script>
  // 실시간 시계 (HH:mm:ss)
  (function tick(){
    var el = document.getElementById('hbNow');
    if(!el) return;
    var d = new Date();
    var z = n => String(n).padStart(2,'0');
    el.textContent = z(d.getHours()) + ':' + z(d.getMinutes()) + ':' + z(d.getSeconds());
    setTimeout(tick, 1000);
  })();
</script>