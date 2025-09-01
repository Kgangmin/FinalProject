<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="ko_KR"/>
<%
  String ctxPath = request.getContextPath();
%>

<jsp:include page="../../header/header.jsp" />

<style>
.paper-wrap{ padding:16px; }
.paper{ width:210mm; min-height:297mm; margin:8px auto 24px; background:#fff; color:#222;
  box-shadow:0 10px 25px rgba(0,0,0,.1); padding:18mm; border-radius:6px; }
.title{ font-size:20px; font-weight:700; text-align:center; margin-bottom:16px; }
.meta{ display:grid; grid-template-columns:120px 1fr 120px 1fr; gap:8px 14px; margin-bottom:14px; font-size:14px; }
.table{ width:100%; border-collapse:collapse; margin-top:6px; }
.table th,.table td{ border:1px solid #ddd; padding:8px 10px; font-size:14px; }
.table th{ background:#fafafa; text-align:left; }
.sum{ text-align:right; font-weight:700; }
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
    <div class="title">급여명세서 (${year}년 ${month}월)</div>

    <div class="meta">
      <div>성명</div><div>${emp.emp_name}</div>
      <div>사번</div><div>${emp.emp_no}</div>
      <div>부서</div><div>${emp.dept_name}</div>
      <div>직급</div><div>${emp.rank_name}</div>
    </div>

    <table class="table">
      <tr><th style="width:30%;">지급항목</th><th style="width:20%;">금액</th><th style="width:30%;">공제항목</th><th style="width:20%;">금액</th></tr>
      <tr>
        <td>기본급</td><td class="sum"><fmt:formatNumber value="${salary.base_sal}" pattern="#,##0"/>원</td>
        <td>공제합계</td><td class="sum"><fmt:formatNumber value="${salary.deduction}" pattern="#,##0"/>원</td>
      </tr>
      <tr>
        <td>성과/상여</td><td class="sum"><fmt:formatNumber value="${salary.bonus}" pattern="#,##0"/>원</td>
        <td></td><td></td>
      </tr>
       <%-- 지급합계(기본급+상여) 계산 → 포맷팅 --%>
  		<c:set var="grossPay" value="${(empty salary.base_sal ? 0 : salary.base_sal) + (empty salary.bonus ? 0 : salary.bonus)}"/>
      
      <tr>
        <th>지급합계</th><td class="sum"><fmt:formatNumber value="${grossPay}" pattern="#,##0"/>원</td>
        <th>실지급액</th><td class="sum"><fmt:formatNumber value="${salary.net_pay}" pattern="#,##0"/>원</td>
      </tr>
    </table>

    <p style="margin-top:18px; font-size:13px; color:#666;">
      ※ 본 명세서는 사내 시스템에서 발급되었습니다.
    </p>
  </div>
</div>

<jsp:include page="../../footer/footer.jsp" />
