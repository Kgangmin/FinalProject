<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<!-- 설문 전용 사이드바 -->
<aside id="surveySidebar" class="survey-sidebar" style="
  position: fixed;
  top: 70px;              /* header.jsp의 상단바 높이 */
  left: 170px;            /* menu.jsp 사이드바 폭(고정 170px) 바로 오른쪽 */
  width: 200px;
  height: calc(100vh - 70px);
  background: #fff;
  border-right: 1px solid #dee2e6;
  z-index: 1018;          /* 메뉴(1020)보다 낮게, 본문보다 높게 */
  overflow-y: auto;
">
  <div style="padding: 12px;">
    <a class="btn btn-success btn-block mb-3" href="<%=ctxPath%>/survey/create">설문 작성</a>

    <div class="list-group">
      <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
         href="<%=ctxPath%>/survey/list?type=ongoing">
        진행중인 설문
        <span class="badge badge-primary badge-pill" id="ongoingCnt">0</span>
      </a>
      <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
         href="<%=ctxPath%>/survey/list?type=closed">
        마감된 설문
        <span class="badge badge-secondary badge-pill" id="closedCnt">0</span>
      </a>
      <a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
         href="<%=ctxPath%>/survey/list?type=mine">
        내가 만든 설문
        <span class="badge badge-dark badge-pill" id="myCnt">0</span>
      </a>
    </div>
  </div>
</aside>
