<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/survey/survey_side.jsp" />

<style>
body .content-wrapper{
  margin-left: 380px !important; /* 기존 유지 */
  margin-top: 0 !important;
  padding-top: 38px !important;
}
body .content-wrapper > .container-fluid{
  padding-top: 4px !important;  /* ≒ 4px */
}
.nav-tabs .nav-link.active { font-weight:600; }
</style>

<div class="content-wrapper">
  <div class="container-fluid pt-1 pb-3">
    <ul class="nav nav-tabs mb-3">
      <li class="nav-item">
        <a class="nav-link <c:if test='${type eq "ongoing"}'>active</c:if>'"
           href="<%=ctxPath%>/survey/list?type=ongoing">진행중인 설문</a>
      </li>
      <li class="nav-item">
        <a class="nav-link <c:if test='${type eq "closed"}'>active</c:if>'"
           href="<%=ctxPath%>/survey/list?type=closed">마감된 설문</a>
      </li>
      <li class="nav-item">
        <a class="nav-link <c:if test='${type eq "mine"}'>active</c:if>'"
           href="<%=ctxPath%>/survey/list?type=mine">내가 만든 설문</a>
      </li>
    </ul>

    <div class="table-responsive">
      <table class="table table-sm table-hover">
        <thead class="thead-light">
          <tr>
            <th style="width:140px;">상태</th>
            <th>설문제목</th>
            <th style="width:240px;">설문기간</th>
            <th style="width:160px;">작성자</th>
            <th style="width:120px;">참여자수</th>
          </tr>
        </thead>
        <tbody>
        <c:choose>
          <c:when test="${not empty list}">
            <c:forEach var="s" items="${list}">
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
                <td><c:out value="${s.participantCnt}"/></td>
              </tr>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <tr><td colspan="5" class="text-muted">표시할 목록이 없습니다.</td></tr>
          </c:otherwise>
        </c:choose>
        </tbody>
      </table>
    </div>

    <!-- 페이지네이션 -->
    <c:if test="${totalPages > 1}">
      <nav aria-label="page nav">
        <ul class="pagination pagination-sm">
          <c:set var="prev" value="${page-1}"/>
          <c:set var="next" value="${page+1}"/>
          <li class="page-item <c:if test='${page==1}'>disabled</c:if>">
            <a class="page-link" href="<%=ctxPath%>/survey/list?type=${type}&page=${prev}&size=${size}">이전</a>
          </li>
          <c:forEach var="p" begin="1" end="${totalPages}">
            <li class="page-item <c:if test='${p==page}'>active</c:if>">
              <a class="page-link" href="<%=ctxPath%>/survey/list?type=${type}&page=${p}&size=${size}">${p}</a>
            </li>
          </c:forEach>
          <li class="page-item <c:if test='${page==totalPages}'>disabled</c:if>">
            <a class="page-link" href="<%=ctxPath%>/survey/list?type=${type}&page=${next}&size=${size}">다음</a>
          </li>
        </ul>
      </nav>
    </c:if>
  </div>
</div>

<!-- 사이드바 배지 숫자 동기화 -->
<script>
  (function(){
    var oc = '${ongoingCnt}', cc = '${closedCnt}', mc = '${myCnt}';
    if (document.getElementById('ongoingCnt')) document.getElementById('ongoingCnt').textContent = oc || '0';
    if (document.getElementById('closedCnt'))  document.getElementById('closedCnt').textContent  = cc || '0';
    if (document.getElementById('myCnt'))      document.getElementById('myCnt').textContent      = mc || '0';
  })();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
