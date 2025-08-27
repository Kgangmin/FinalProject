<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />
<jsp:include page="/WEB-INF/views/survey/survey_side.jsp" />

<style>
.sv-box{ background:#fff; border:1px solid #dee2e6; border-radius:10px; box-shadow:0 1px 2px rgba(0,0,0,.04); }
.sv-box .hd{ padding:12px 14px; border-bottom:1px solid #f1f1f1; display:flex; justify-content:space-between; align-items:center;}
.sv-box .bd{ padding:14px; }
.q-title{ font-weight:600; margin-bottom:6px; }
.q-item{ padding:10px 12px; border:1px solid #eee; border-radius:8px; margin-bottom:12px; }
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
    <div class="sv-box mb-3">
      <div class="hd">
        <h5 class="mb-0">
          <c:out value="${detail.title != null ? detail.title : '(제목 없음)'}"/>
        </h5>
        <div>
		<c:if test="${isOwner}">
		  <a class="btn btn-outline-secondary btn-sm" href="<%=ctxPath%>/survey/edit?sid=${detail.surveyId}">수정</a>
		  <form method="post" action="<%=ctxPath%>/survey/close" style="display:inline" onsubmit="return confirm('마감하시겠습니까?');">
		    <input type="hidden" name="sid" value="${detail.surveyId}">
		    <button type="submit" class="btn btn-outline-warning btn-sm">마감</button>
		  </form>
		  <form method="post" action="<%=ctxPath%>/survey/delete" style="display:inline" onsubmit="return confirm('삭제하시겠습니까?');">
		    <input type="hidden" name="sid" value="${detail.surveyId}">
		    <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
		  </form>
		</c:if>
        </div>
      </div>
      <div class="bd">
        <div class="mb-1 text-muted">
          작성자: <c:out value="${detail.ownerName}"/>
          &nbsp;|&nbsp; 기간: <c:out value="${detail.startDate}"/> ~ <c:out value="${detail.endDate}"/>
          &nbsp;|&nbsp; 상태:
          <span class="badge badge-<c:out value='${detail.status eq "CLOSED" ? "secondary" : "success"}'/>">
            <c:out value='${detail.status eq "CLOSED" ? "마감" : "진행중"}'/>
          </span>
          &nbsp;|&nbsp;
          <c:choose>
            <c:when test='${detail.participatedYn eq "Y"}'><span class="badge badge-info">참여완료</span></c:when>
            <c:otherwise><span class="badge badge-light">미참여</span></c:otherwise>
          </c:choose>
          &nbsp;|&nbsp; 결과공개:
          <span class="badge badge-<c:out value='${detail.resultPublicYn eq "Y" ? "primary" : "dark"}'/>">
            <c:out value='${detail.resultPublicYn eq "Y" ? "공개" : "비공개"}'/>
          </span>
        </div>
        <div class="mb-3">
          <div class="small text-muted">시작 안내</div>
          <div><c:out value="${detail.introText}"/></div>
        </div>

        <c:set var="disabled" value="${detail.status eq 'CLOSED' or detail.participatedYn eq 'Y'}"/>
        <c:if test="${disabled}">
          <div class="alert alert-warning py-2">
            <c:choose>
              <c:when test='${detail.participatedYn eq "Y"}'>이미 해당 설문에 참여하셨습니다.</c:when>
              <c:otherwise>마감된 설문입니다.</c:otherwise>
            </c:choose>
            <c:if test='${detail.resultPublicYn eq "Y"}'>
              &nbsp; <a href="<%=ctxPath%>/survey/result?sid=${detail.surveyId}">결과 보기</a>
            </c:if>
          </div>
        </c:if>

        <form method="post" action="<%=ctxPath%>/survey/submit">
          <input type="hidden" name="sid" value="${detail.surveyId}"/>

          <c:forEach var="q" items="${detail.questions}" varStatus="st">
            <div class="q-item">
              <div class="q-title">Q${st.index+1}. <c:out value="${q.text}"/></div>
              <div>
                <c:choose>
                  <c:when test="${q.multiple}">
                    <!-- 체크박스 -->
                    <c:forEach var="o" items="${q.options}">
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="q_${q.id}" value="${o.id}" <c:if test='${disabled}'>disabled</c:if> />
                        <label class="form-check-label"><c:out value="${o.text}"/></label>
                      </div>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <!-- 라디오 -->
                    <c:forEach var="o" items="${q.options}">
                      <div class="form-check">
                        <input class="form-check-input" type="radio" name="q_${q.id}" value="${o.id}" <c:if test='${disabled}'>disabled</c:if> required />
                        <label class="form-check-label"><c:out value="${o.text}"/></label>
                      </div>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </c:forEach>

          <div class="mt-3">
            <button type="submit" class="btn btn-primary" <c:if test='${disabled}'>disabled</c:if>>설문 제출</button>
            <c:if test='${detail.resultPublicYn eq "Y"}'>
              <a class="btn btn-outline-secondary" href="<%=ctxPath%>/survey/result?sid=${detail.surveyId}">결과 보기</a>
            </c:if>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<script>
  (function(){
    var oc = '${ongoingCnt}', cc = '${closedCnt}', mc = '${myCnt}';
    if (document.getElementById('ongoingCnt')) document.getElementById('ongoingCnt').textContent = oc || '0';
    if (document.getElementById('closedCnt'))  document.getElementById('closedCnt').textContent  = cc || '0';
    if (document.getElementById('myCnt'))      document.getElementById('myCnt').textContent      = mc || '0';
  })();
</script>
<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
