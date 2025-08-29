<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
	String ctxPath = request.getContextPath();
%>


<div class="emp-list-container">
  <h2 class="page-title text-secondary pl-2">사원 목록</h2>

  <!-- 검색 -->
<form id="searchForm" class="form-inline mb-3">
  <select id="qCategory" class="form-control mr-2">
  	<option value="emp_no">사번</option>
    <option value="dept">부서</option>
    <option value="team">소속(팀)</option>
    <option value="name">이름</option>
  </select>
  <input type="text" class="form-control mr-2" id="qValue" placeholder="검색어">
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
        	<tr>
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
    <ul id="paging" class="pagination justify-content-center mb-0"></ul>
  </nav>
</div>

<script>
	
</script>