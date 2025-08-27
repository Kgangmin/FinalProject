<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<!-- 설문 전용 사이드바 포함 -->
<jsp:include page="/WEB-INF/views/survey/survey_side.jsp" />

<style>
/* 카드형 설문 */
.sv-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); grid-gap: 16px; }
.sv-card  { border:1px solid #dee2e6; border-radius:10px; background:#fff; box-shadow:0 1px 2px rgba(0,0,0,.04); }
.sv-card .hd{ padding:12px 14px; border-bottom:1px solid #f1f1f1; display:flex; justify-content:space-between; align-items:center;}
.sv-card .bd{ padding:12px 14px; }
.badge-dot{ display:inline-flex; align-items:center; gap:6px; }
.badge-dot .dot{ width:8px; height:8px; border-radius:50%; background:#28a745; }
.badge-dot.closed .dot{ background:#6c757d; }
.badge-dot.participated .dot{ background:#17a2b8; }

/* 상단바 아래 여백 압축 + 좌측 사이드바 폭 */
body .content-wrapper{
  margin-left: 380px !important;
  margin-top: 0 !important;
  padding-top: 38px !important;
}
body .content-wrapper > .container-fluid{
  padding-top: 4px !important;
}
</style>

<!-- 목록 공급자 우선순위: cardList -> ongoingList -> list (없으면 빈 리스트) -->
<c:choose>
  <c:when test="${not empty cardList}">
    <c:set var="cards" value="${cardList}"/>
  </c:when>
  <c:when test="${not empty ongoingList}">
    <c:set var="cards" value="${ongoingList}"/>
  </c:when>
  <c:when test="${not empty list}">
    <c:set var="cards" value="${list}"/>
  </c:when>
  <c:otherwise>
    <c:set var="cards" value="${emptyList}"/>
  </c:otherwise>
</c:choose>

<!-- 최근 생성 목록 공급자: recentList -> recents -> myList -> list -->
<c:choose>
  <c:when test="${not empty recentList}">
    <c:set var="recents" value="${recentList}"/>
  </c:when>
  <c:when test="${not empty recents}">
    <c:set var="recents" value="${recents}"/>
  </c:when>
  <c:when test="${not empty myList}">
    <c:set var="recents" value="${myList}"/>
  </c:when>
  <c:otherwise>
    <c:set var="recents" value="${list}"/>
  </c:otherwise>
</c:choose>

<div class="content-wrapper">
  <div class="container-fluid pt-1 pb-3">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h4 class="mb-0">설문 홈</h4>
      <a class="btn btn-outline-primary btn-sm" href="<%=ctxPath%>/survey/list?type=ongoing">전체 보기</a>
    </div>

    <!-- 카드형 설문 (참여 가능한 진행중 설문만) -->
    <div class="sv-cards mb-4">
      <c:set var="hasCard" value="false"/>
      <c:forEach var="s" items="${cards}">
        <c:if test="${s.status eq 'ONGOING' and s.participatedYn ne 'Y'}">
          <c:set var="hasCard" value="true"/>
          <div class="sv-card">
            <div class="hd">
              <div class="font-weight-bold text-truncate" title="${s.title}"><c:out value="${s.title}"/></div>
              <span class="badge-dot <c:if test='${s.status eq "CLOSED"}'>closed</c:if><c:if test='${s.participatedYn eq "Y"}'> participated</c:if>">
                <span class="dot"></span>
                <span class="small">
                  진행중 /
                  <c:choose>
                    <c:when test='${s.participatedYn eq "Y"}'>참여완료</c:when>
                    <c:otherwise>미참여</c:otherwise>
                  </c:choose>
                </span>
              </span>
            </div>
            <div class="bd">
              <div class="small text-muted mb-1">기간: <c:out value="${s.startDate}"/> ~ <c:out value="${s.endDate}"/></div>
              <div class="small text-muted mb-2">작성자: <c:out value="${s.ownerName}"/></div>
              <a class="btn btn-primary btn-sm" href="<%=ctxPath%>/survey/detail?sid=${s.surveyId}">
                설문 참여 / 상세
              </a>
            </div>
          </div>
        </c:if>
      </c:forEach>

      <c:if test="${not hasCard}">
        <div class="text-muted">참여 가능한 진행중 설문이 없습니다.</div>
      </c:if>
    </div>

    <!-- 최근 생성 설문 (표는 그대로, 데이터가 없으면 안내) -->
    <h5 class="mb-2">최근 생성 설문</h5>
    <div class="table-responsive">
      <table class="table table-sm table-hover">
        <thead class="thead-light">
          <tr>
            <th style="width:120px;">상태</th>
            <th>설문제목</th>
            <th style="width:220px;">설문기간</th>
            <th style="width:140px;">작성자</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${not empty recents}">
              <c:forEach var="s" items="${recents}">
                <tr>
                  <td>
                    <span class="badge badge-<c:out value='${s.status eq "CLOSED" ? "secondary" : "success"}'/>">
                      <c:out value='${s.status eq "CLOSED" ? "마감" : "진행중"}'/>
                    </span>
                    <c:choose>
                      <c:when test='${s.participatedYn eq "Y"}'>
                        <span class="badge badge-info ml-1">참여</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge badge-light ml-1">미참여</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <a href="<%=ctxPath%>/survey/detail?sid=${s.surveyId}">
                      <c:out value="${s.title != null ? s.title : '(제목 없음)'}"/>
                    </a>
                  </td>
                  <td><c:out value="${s.startDate}"/> ~ <c:out value="${s.endDate}"/></td>
                  <td><c:out value="${s.ownerName}"/></td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr><td colspan="4" class="text-muted">표시할 목록이 없습니다.</td></tr>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- 사이드바 배지 숫자 동기화 (list 페이지와 동일) -->
<script>
  (function(){
    var oc = '${ongoingCnt}', cc = '${closedCnt}', mc = '${myCnt}';
    if (document.getElementById('ongoingCnt')) document.getElementById('ongoingCnt').textContent = oc || '0';
    if (document.getElementById('closedCnt'))  document.getElementById('closedCnt').textContent  = cc || '0';
    if (document.getElementById('myCnt'))      document.getElementById('myCnt').textContent      = mc || '0';
  })();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
