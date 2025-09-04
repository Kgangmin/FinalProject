<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
  String companyName = (String) request.getServletContext().getAttribute("companyName");
  if (companyName == null) companyName = "HANB";
%>

<jsp:include page="../../header/header.jsp" />

<style>
.paper-wrap{ padding:16px; }
.paper{ width:210mm; min-height:297mm; margin:8px auto 24px; background:#fff; color:#222;
  box-shadow:0 10px 25px rgba(0,0,0,.1); padding:20mm; border-radius:6px; }
.title{ font-size:22px; font-weight:800; text-align:center; letter-spacing:2px; margin-bottom:22px; }
.meta{ width:100%; border-collapse:collapse; }
.meta th,.meta td{ border:1px solid #ddd; padding:10px 12px; font-size:14px; }
.meta th{ width:22%; background:#fafafa; text-align:left; }
.sign{ margin-top:28px; text-align:center; }
.foot{ margin-top:10px; font-size:12px; color:#666; }
.toolbar{ display:flex; gap:8px; justify-content:flex-end; margin:8px auto 0; width:210mm; max-width:100%; }
.btn-plain{ display:inline-block; padding:8px 12px; border:1px solid #ddd; background:#fff; border-radius:8px; text-decoration:none; font-size:14px; }
@media print{
  .topbar-fixed, .sidebar, .toolbar { display:none !important; }
  .content-wrapper{ margin:0 !important; padding:0 !important; }
  .paper{ margin:0; box-shadow:none; border-radius:0; }
}
</style>

<div class="paper-wrap">
  <div class="toolbar">
    <a href="javascript:window.print()" class="btn-plain">인쇄</a>
    <a href="<%=ctxPath%>/emp/emp_certificate" class="btn-plain">다른 서류</a>
  </div>

  <div class="paper">
    <div class="title">재&nbsp;직&nbsp;증&nbsp;명&nbsp;서</div>

    <table class="meta">
      <tr><th>성명</th><td>${emp.emp_name}</td></tr>
      <tr><th>사번</th><td>${emp.emp_no}</td></tr>
      <tr><th>부서</th><td>${emp.team_name}</td></tr>
      <tr><th>직급</th><td>${emp.rank_name}</td></tr>
      <tr><th>입사일</th><td>${emp.hiredate}</td></tr>
      <tr><th>재직상태</th><td>${empty emp.emp_status ? '재직' : emp.emp_status}</td></tr>
      <tr><th>용도</th><td>${purpose}</td></tr>
      <tr><th>발급일</th><td>${issueDate}</td></tr>
    </table>

    <div class="sign">
      상기와 같이 재직하고 있음을 증명합니다.<br/><br/>
      <strong><%=companyName%></strong><br/><br/><br/>
      (직인)
    </div>

    <div class="foot">※ 본 증명서는 사내 시스템에서 발급되었습니다.</div>
  </div>
</div>

<jsp:include page="../../footer/footer.jsp" />
