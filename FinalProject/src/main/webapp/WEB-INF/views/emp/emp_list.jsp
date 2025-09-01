<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
	String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%=ctxPath%>/css/emp/emp_list.css">

<div class="emp-list-container">
	<h2 class="page-title text-secondary pl-2">사원 목록</h2>

	<!-- 검색 -->
	<form id="searchForm" class="form-inline mb-3" action="<%= ctxPath %>/emp/emp_list" method="get">
    <select name="qCategory" class="form-control mr-2">
        <option value="emp_no" <%= "emp_no".equals(request.getParameter("qCategory")) ? "selected" : "" %>>사번</option>
        <option value="dept" <%= "dept".equals(request.getParameter("qCategory")) ? "selected" : "" %>>부서</option>
        <option value="team" <%= "team".equals(request.getParameter("qCategory")) ? "selected" : "" %>>소속(팀)</option>
        <option value="name" <%= "name".equals(request.getParameter("qCategory")) ? "selected" : "" %>>이름</option>
    </select>
    <input type="text" class="form-control mr-2" name="qValue" placeholder="검색어" 
           value="<%= request.getParameter("qValue") != null ? request.getParameter("qValue") : "" %>">
    <button type="submit" class="btn btn-primary">검색</button>
</form>

  <!-- 목록 -->
  <div class="table-responsive">
    <table class="table table-sm table-hover">
      <thead class="thead-light">
        <tr>
          <th style="width:120px">사번</th>
          <th>이름</th>
          <th>부서</th>
          <th>소속</th>
          <th>직급</th>
          <th>사내 이메일</th>
        </tr>
      </thead>
      <tbody id="empTableBody">
        <c:forEach var="emp" items="${empList}">
        	<tr class="emp-row" style="cursor:pointer" data-empno="${emp.emp_no}">
        		<td>${emp.emp_no}</td>
        		<td>${emp.emp_name}</td>
        		<td>
					<c:choose>
						<c:when test='${emp.fk_dept_no eq "01"}'>
							${emp.dept_name}
						</c:when>
						<c:when test='${emp.fk_dept_no ne "01" && fn:length(emp.fk_dept_no) == 2}'>
							${emp.team_name}
						</c:when>
						<c:otherwise>
							${emp.dept_name}
						</c:otherwise>
					</c:choose>
				</td>
				<td>
					<c:choose>
						<c:when test='${emp.fk_dept_no eq "01"}'>
							${emp.dept_name}
						</c:when>
						<c:when test='${emp.fk_dept_no ne "01" && fn:length(emp.fk_dept_no) == 2}'>
							${emp.team_name}
						</c:when>
						<c:otherwise>
							${emp.team_name}
						</c:otherwise>
					</c:choose>
				</td>
        		<td>${emp.rank_name}</td>
        		<td>${emp.emp_email}</td>
        	</tr>
        	
        	
        </c:forEach>
      </tbody>
    </table>
  </div>

  <!-- 페이징 -->
  <nav>
    <ul class="pagination justify-content-center mb-0">
        <c:if test="${page > 1}">
            <li class="page-item">
                <a class="page-link" href="<%= ctxPath %>/emp/emp_list?page=${page-1}&qCategory=${qCategory}&qValue=${qValue}">Prev</a>
            </li>
        </c:if>

        <c:forEach var="i" begin="1" end="${totalPage}">
            <li class="page-item ${page == i ? 'active' : ''}">
                <a class="page-link" href="<%= ctxPath %>/emp/emp_list?page=${i}&qCategory=${qCategory}&qValue=${qValue}">${i}</a>
            </li>
        </c:forEach>

        <c:if test="${page < totalPage}">
            <li class="page-item">
                <a class="page-link" href="<%= ctxPath %>/emp/emp_list?page=${page+1}&qCategory=${qCategory}&qValue=${qValue}">Next</a>
            </li>
        </c:if>
    </ul>
</nav>
</div>

<!-- 모달 영역 (빈 모달) -->
<div class="modal fade" id="empDetailModal" tabindex="-1" role="dialog">
  <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">사원 정보</h5>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body">
        <!-- AJAX로 emp_info.jsp 내용이 들어올 자리 -->
      </div>
    </div>
  </div>
</div>

<script>
$(document).on('click', '.emp-row', function() {
    var empNo = $(this).data('empno');

    $.ajax({
        url: '<%= ctxPath %>/emp/emp_info_modal', // emp_no 파라미터로 emp_info.jsp 렌더링
        type: 'GET',
        data: { emp_no: empNo },
        dataType: 'html', // JSON → HTML로 변경
        success: function(html) {
            $('#empDetailModal .modal-body').html(html); // 모달 body에 JSP 삽입
            $('#empDetailModal').modal('show');          // 모달 표시
        },
        error: function() {
            alert('사원 정보를 불러오는 데 실패했습니다.');
        }
    });
});

</script>