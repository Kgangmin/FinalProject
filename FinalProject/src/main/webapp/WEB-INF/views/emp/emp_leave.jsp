<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
	String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // 컨트롤러에서 내려주는 값 (예시)
    // request.setAttribute("emp", emp); // emp.emp_no, emp.emp_name, emp.dept_name, emp.rank_name, emp.photo_url
    // request.setAttribute("leaveStats", Map.of("remain", 0, "used", 0, "total", 0));
    // request.setAttribute("leaveList", list); // LeaveDTO: type, startDate, endDate, days, status, reason
    // request.setAttribute("page", 1);
    // request.setAttribute("pageSize", 10);
    // request.setAttribute("totalCount", 0);
    String ctx = request.getContextPath();
%>

<style>
  /* ===== 페이지 레이아웃(빨간 박스 영역) ===== */
  .leave-page{
    display:grid; grid-template-columns: 360px 1fr; gap: 24px; margin-top: 100px;;
  }
  .lp-card{
    background:#fff; border:1px solid #e5e7eb; border-radius:12px;
    box-shadow:0 4px 14px rgba(0,0,0,.04);
  }
  .lp-card .lp-h{
    padding:16px 18px; font-weight:600; font-size:18px; border-bottom:1px solid #f1f5f9;
  }
  .lp-card .lp-b{ padding:18px; }

  /* ===== 좌측: 사원 정보 ===== */
  .emp-profile{
    display:flex; flex-direction:column; align-items:center; gap:14px; padding-top:6px;
  }
  .emp-photo{
    width:170px; height:170px; border-radius:50%;
    border:3px dashed #11182722; background:#f8fafc; overflow:hidden;
    display:flex; align-items:center; justify-content:center; font-weight:700; color:#6b7280;
  }
  .emp-photo img{ width:100%; height:100%; object-fit:cover; display:block; }
  .emp-name{ font-size:20px; font-weight:700; }
  .emp-meta{ color:#6b7280; font-size:13px; }

  .stat-grid{
    margin-top:6px; display:grid; grid-template-columns:1fr 1fr; gap:12px;
  }
  .stat{
    border:1px solid #e5e7eb; border-radius:10px; padding:12px; text-align:center;
    background:#fcfcfd;
  }
  .stat .label{ font-size:12px; color:#6b7280; display:block; margin-bottom:4px; }
  .stat .val{ font-size:20px; font-weight:800; }

  .total-wrap{
    margin-top:12px; display:flex; justify-content:center;
  }
  .total{
    width:220px; border:1px solid #e5e7eb; border-radius:10px; padding:12px; text-align:center;
    background:#f8fafc;
  }

  /* ===== 우측: 휴가 리스트 & 페이징 ===== */
  .lp-actions{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:10px; }
  .lp-actions .filters{ display:flex; gap:8px; }
  .lp-actions select, .lp-actions input{
    border:1px solid #e5e7eb; border-radius:8px; padding:6px 10px; font-size:14px;
  }

  .lp-table{ width:100%; border-collapse:collapse; }
  .lp-table thead th{
    background:#f8fafc; border-bottom:1px solid #e5e7eb; font-weight:600; font-size:13px; color:#334155;
    padding:12px 10px; text-align:center;
  }
  .lp-table tbody td{
    border-bottom:1px solid #f1f5f9; padding:12px 10px; font-size:14px; text-align:center;
  }
  .badge{
    display:inline-block; padding:3px 8px; border-radius:999px; font-size:12px; font-weight:700;
  }
  .badge.approved { background:#ecfeff; color:#0369a1; border:1px solid #bae6fd; }
  .badge.pending  { background:#fff7ed; color:#b45309; border:1px solid #fed7aa; }
  .badge.rejected { background:#fef2f2; color:#b91c1c; border:1px solid #fecaca; }

  .pagination{ display:flex; gap:6px; justify-content:center; padding:14px 6px; }
  .pagination a, .pagination span{
    min-width:36px; height:36px; padding:0 10px; border:1px solid #e5e7eb; border-radius:8px;
    display:flex; align-items:center; justify-content:center; text-decoration:none; color:#374151; font-size:14px;
    background:#fff;
  }
  .pagination .active{ background:#111827; color:#fff; border-color:#111827; }
  .pagination .disabled{ opacity:.45; pointer-events:none; }
  @media (max-width: 1200px){
    .leave-page{ grid-template-columns: 1fr; }
  }
</style>

<div class="leave-page">

  <!-- ========== 좌측: 사원정보 카드 ========== -->
<div class="lp-card">
  <div class="lp-h">사원정보</div>
  <div class="lp-b">
    <div class="emp-profile">

      <!-- 사진 (있으면 표시) -->
      <div class="emp-photo">
        <c:choose>
          <c:when test="${not empty emp.emp_save_filename}">
           	<img src="${pageContext.request.contextPath}/resources/images/emp_profile/${emp.emp_save_filename}" />
          </c:when>
          <c:otherwise>
            <span><c:out value="${fn:substring(emp.emp_name,0,1)}"/></span>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- 이름 -->
      <div class="emp-name"><c:out value="${emp.emp_name}"/></div>

      <!-- 부서명 / 직급명 -->
      <div class="emp-meta">
        <c:out value="${emp.team_name}"/> · <c:out value="${emp.rank_name}"/>
      </div>

    </div>

        <div class="stat-grid">
          <div class="stat">
            <span class="label">잔여 연차</span>
            <span class="val">${15 - used_leave}</span>
          </div>
          <div class="stat">
            <span class="label">사용 연차</span>
            <span class="val">${used_leave}</span>
          </div>
        </div>
    </div>
  </div>

  <div class="lp-card">
	  <div class="lp-h">휴가 사용 내역</div>
	  <div class="lp-b">
	
	    <!-- 리스트 -->
	    <table class="lp-table">
	      <thead>
	        <tr>
	          <th style="width:120px">구분</th>
	          <th style="width:160px">시작일</th>
	          <th style="width:160px">종료일</th>
	          <th style="width:90px">일수</th>
	          <th style="width:300px">사유</th>
	        </tr>
	      </thead>
	      <tbody>
	        <c:choose>
	          <c:when test="${empty leaveList}">
	            <tr>
	              <td colspan="6" style="padding:34px; color:#6b7280;">등록된 휴가 내역이 없습니다.</td>
	            </tr>
	          </c:when>
	          <c:otherwise>
	            <c:forEach var="lv" items="${leaveList}">
	              <tr>
	                <td>
	                	<c:choose>
					        <c:when test="${lv.fk_leave_type_no == 1}">연차</c:when>
					        <c:when test="${lv.fk_leave_type_no == 2}">병가</c:when>
					        <c:when test="${lv.fk_leave_type_no == 3}">경조사</c:when>
					        <c:otherwise>-</c:otherwise>
				    	</c:choose></td>
	                <td>${fn:substring(lv.start_date, 0, 16)}</td>
	                <td>${fn:substring(lv.end_date, 0, 16)}</td>
	                <td>${lv.used_days} 일</td>
	                <td style="text-align:left;">${lv.leave_remark}</td>
	              </tr>
	            </c:forEach>
	          </c:otherwise>
	        </c:choose>
	      </tbody>
	    </table>
	
	    <!-- 네가 준 스타일 그대로(링크는 무시, data-page만 사용) -->
	    <nav class="mt-3">
	      <ul class="pagination justify-content-center">
	
	        <li class="page-item ${page<=1?'disabled':''}">
	          <a class="page-link" href="<%= ctxPath %>/emp/emp_leave?page=${page-1}" data-page="${page-1}">이전</a>
	        </li>
	
	        <c:forEach var="p" begin="1" end="${totalPage}">
	          <li class="page-item ${page==p ? 'active' : ''}">
	            <a class="page-link" href="<%= ctxPath %>/emp/emp_leave?page=${p}" data-page="${p}">${p}</a>
	          </li>
	        </c:forEach>
	
	        <li class="page-item ${page>=totalPage?'disabled':''}">
	          <a class="page-link" href="<%= ctxPath %>/emp/emp_leave?page=${page+1}" data-page="${page+1}">다음</a>
	        </li>
	
	      </ul>
	    </nav>
	
	  </div>
	</div>
</div>
