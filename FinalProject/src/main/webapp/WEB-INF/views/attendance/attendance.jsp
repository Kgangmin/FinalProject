<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
	String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%=ctxPath%>/css/attendance.css">

<div id="hb-att" class="container-fluid">
  <!-- 상단 타이틀/주간 범위 -->
  <div class="hb-title">
    <h1 class="mb-0">내 근태현황</h1>
    <div class="hb-range">${weekly.weekLabel}</div>
  </div>

  <!-- 상단 2열: 요약/범례 -->
  <div class="row">
    <!-- 좌: 요약/진척 -->
    <div class="col-lg-8 mb-3">
      <div class="hb-card">
        <div class="hb-muted">기본그룹 (09:00 ~ 18:00)</div>

        <!-- 누적 진행바 -->
        <div class="d-flex align-items-center mt-2">
          <div class="flex-grow-1">
            <div class="hb-bar">
              <i style="width:${weekly.pct}%"></i>
            </div>
            <div class="hb-bar-label">
              <span>
                주간누적 
                <span class="hb-time">
                  <c:set var="wm" value="${weekly.workedMinutes}"/>
                  <c:set var="wrH" value="${wm/60}"/>
                  <c:set var="wrM" value="${wm%60}"/>
                  ${wrH}h <fmt:formatNumber value="${wrM}" minIntegerDigits="2"/>m
                </span>
              </span>
              <span class="hb-time">
                <c:set var="rm" value="${weekly.requiredMinutes}"/>
                <c:set var="rqH" value="${rm/60}"/>
                <c:set var="rqM" value="${rm%60}"/>
                ${rqH}h <fmt:formatNumber value="${rqM}" minIntegerDigits="2"/>m
              </span>
            </div>
          </div>
          <span class="hb-chip ${weekly.workedMinutes >= weekly.requiredMinutes ? 'hb-chip-ok' : 'hb-chip-warn'} ml-2">
            <strong>${weekly.pct}%</strong>
          </span>
        </div>

        <!-- KPI -->
        <div class="hb-kpi">
          <div class="hb-kpi-item">
            <div class="hb-muted">전여 근무일</div>
            <div class="hb-num">${weekly.workedDays}일 / 5일</div>
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
            <div class="hb-num">
              ${wrH}h <fmt:formatNumber value="${wrM}" minIntegerDigits="2"/>m
            </div>
          </div>
          <div class="hb-kpi-item">
            <div class="hb-muted">휴가</div>
            <div class="hb-num">0h 00m</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 우: 범례/안내 -->
    <div class="col-lg-4 mb-3">
      <div class="hb-card">
        <div class="font-weight-bold mb-2">주간 타임라인</div>
        <div class="hb-legend">
          <span><i class="hb-dot hb-dot-work"></i>근무시간</span>
          <span><i class="hb-dot hb-dot-late"></i>지각</span>
          <span><i class="hb-dot hb-dot-absent"></i>결근</span>
        </div>
        <div class="hb-muted mt-2">
          아래 박스와 표에서 요일별 출퇴근 및 누적 시간을 확인하세요.
        </div>
      </div>
    </div>
  </div>

  <!-- 요일 카드 -->
  <div class="hb-card mb-3">
    <div class="hb-week-grid">
      <c:forEach var="rec" items="${records}">
        <div class="hb-day">
          <h4 class="d-flex align-items-center">
            <fmt:formatDate value="${rec.workDate}" pattern="E (d)" />
            <c:choose>
              <c:when test="${rec.isAbsent == 'Y'}">
                <span class="hb-chip hb-chip-danger ml-2">결근</span>
              </c:when>
              <c:when test="${rec.isLate == 'Y'}">
                <span class="hb-chip hb-chip-warn ml-2">지각</span>
              </c:when>
            </c:choose>
          </h4>

          <div class="hb-timeline">
            <c:if test="${rec.timelineWidthPct > 0}">
              <i class="hb-slot"
                 style="left:${rec.timelineLeftPct}%; width:${rec.timelineWidthPct}%"></i>
            </c:if>
          </div>

          <div class="hb-muted mt-1">
            <span class="hb-time">
              출근:
              <c:choose>
                <c:when test="${empty rec.clockIn}">-</c:when>
                <c:otherwise><fmt:formatDate value="${rec.clockIn}" pattern="HH:mm"/></c:otherwise>
              </c:choose>
               · 퇴근:
              <c:choose>
                <c:when test="${empty rec.clockOut}">-</c:when>
                <c:otherwise><fmt:formatDate value="${rec.clockOut}" pattern="HH:mm"/></c:otherwise>
              </c:choose>
            </span>

            <span class="ml-2">
              누적:
              <c:set var="dm" value="${rec.spanMinutes}"/>
              <c:set var="dh" value="${dm/60}"/>
              <c:set var="dmm" value="${dm%60}"/>
              <c:choose>
                <c:when test="${dm <= 0}">-</c:when>
                <c:otherwise>${dh}h <fmt:formatNumber value="${dmm}" minIntegerDigits="2"/>m</c:otherwise>
              </c:choose>
            </span>
          </div>

          <c:if test="${not empty rec.remark}">
            <div class="hb-muted">메모: <c:out value="${rec.remark}"/></div>
          </c:if>
        </div>
      </c:forEach>
    </div>
  </div>

  <!-- 하단 상세표 -->
  <div class="hb-card">
    <div class="d-flex justify-content-between align-items-center mb-2">
      <div class="font-weight-bold">상세 근로시간</div>
      <div class="hb-muted small">단위: 시:분</div>
    </div>
    <table class="hb-table table-sm">
      <thead>
        <tr>
          <th style="width:140px">근무일자</th>
          <th style="width:90px">출근</th>
          <th style="width:90px">퇴근</th>
          <th class="hb-center" style="width:80px">지각</th>
          <th class="hb-center" style="width:80px">결근</th>
          <th class="hb-right" style="width:120px">총 근로시간</th>
          <th>비고</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="rec" items="${records}">
          <c:set var="dm" value="${rec.spanMinutes}"/>
          <c:set var="dh" value="${dm/60}"/>
          <c:set var="dmm" value="${dm%60}"/>
          <tr>
            <td><fmt:formatDate value="${rec.workDate}" pattern="yyyy-MM-dd (E)"/></td>
            <td class="hb-time">
              <c:choose>
                <c:when test="${empty rec.clockIn}">-</c:when>
                <c:otherwise><fmt:formatDate value="${rec.clockIn}" pattern="HH:mm"/></c:otherwise>
              </c:choose>
            </td>
            <td class="hb-time">
              <c:choose>
                <c:when test="${empty rec.clockOut}">-</c:when>
                <c:otherwise><fmt:formatDate value="${rec.clockOut}" pattern="HH:mm"/></c:otherwise>
              </c:choose>
            </td>
            <td class="hb-center">
              <c:choose>
                <c:when test="${rec.isLate == 'Y'}"><span class="hb-chip hb-chip-warn">Y</span></c:when>
                <c:otherwise><span class="hb-muted">N</span></c:otherwise>
              </c:choose>
            </td>
            <td class="hb-center">
              <c:choose>
                <c:when test="${rec.isAbsent == 'Y'}"><span class="hb-chip hb-chip-danger">Y</span></c:when>
                <c:otherwise><span class="hb-muted">N</span></c:otherwise>
              </c:choose>
            </td>
            <td class="hb-right">
              <c:choose>
                <c:when test="${dm <= 0}">-</c:when>
                <c:otherwise>${dh}h <fmt:formatNumber value="${dmm}" minIntegerDigits="2"/>m</c:otherwise>
              </c:choose>
            </td>
            <td><c:out value="${rec.remark}"/></td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>