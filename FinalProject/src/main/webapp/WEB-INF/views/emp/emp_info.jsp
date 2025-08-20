<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<%
	String ctxPath = request.getContextPath();
%>

<c:set var="yymmdd" value="${fn:substring(empdto.rr_number,0,6)}"/>
<c:set var="genderCode" value="${fn:substring(empdto.rr_number,7,8)}"/>

<c:choose>
    <c:when test="${genderCode == '1' || genderCode == '2'}">
        <c:set var="yyyy_mm_dd" value="19${fn:substring(yymmdd,0,2)}-${fn:substring(yymmdd,2,4)}-${fn:substring(yymmdd,4,6)}"/>
    </c:when>
    <c:when test="${genderCode == '3' || genderCode == '4'}">
        <c:set var="yyyy_mm_dd" value="20${fn:substring(yymmdd,0,2)}-${fn:substring(yymmdd,2,4)}-${fn:substring(yymmdd,4,6)}"/>
    </c:when>
    <c:otherwise>
        <c:set var="yyyy_mm_dd" value="--"/>
    </c:otherwise>
</c:choose>
            
<link rel="stylesheet" href="<%=ctxPath%>/css/emp_info.css">

<div class="emp-info-container">

    <h2 class="page-title">사원 정보</h2>

    <div class="emp-card">

        <!-- 좌측 프로필 -->
        <div class="profile-section">
            <div class="profile-img-wrapper">
                <img src="${pageContext.request.contextPath}/images/emp_profile/${empdto.emp_save_filename}" 
                     alt="프로필 사진" class="profile-img"/>
            </div>
            <div class="emp-name-status">
                <span class="emp-name">
                    <c:out value="${empdto.emp_name != null ? empdto.emp_name : ''}"/>
                </span>
                <span class="status-badge 
                    <c:choose>
                        <c:when test="${empdto.emp_status == '재직'}">bg-primary</c:when>
                        <c:when test="${empdto.emp_status == '퇴사'}">bg-light text-secondary</c:when>
                        <c:otherwise>bg-secondary</c:otherwise>
                    </c:choose>
                ">
                    <c:out value="${empdto.emp_status != null ? empdto.emp_status : ''}"/>
                </span>
            </div>
        </div>

        <!-- 우측 정보 테이블 -->
        <div class="info-section">
            <form action="<%=ctxPath%>/emp/updateEmpInfo" method="post">
                <table class="emp-info-table">
                    <tbody>
                        <tr>
                            <td>사원번호</td>
                            <td><input type="text" name="emp_no" value="${empdto.emp_no}" readonly/></td>
                            <td>부서</td>
                            <td><input type="text" name="dept_name" value="${empdto.dept_name}" readonly/></td>
                        </tr>
                        <tr>
                            <td>직급</td>
                            <td><input type="text" name="rank_name" value="${empdto.rank_name}" readonly/></td>
                            <td>소속</td>
                            <td><input type="text" name="team_name" value="${empdto.team_name}" readonly/></td>                            
                        </tr>
                        <tr>
        					<td>생년월일</td>
        					
    						<td><input type="text" name="birthday" readonly value="${yyyy_mm_dd}"/></td>
    
                            <td>입사일</td>
                            <td><input type="text" name="hiredate" value="${empdto.hiredate}" readonly/></td>
                        </tr>
                        <tr>
                        	<td>휴대폰번호</td>
                            <td><input type="text" name="phone_num" value="${empdto.phone_num}"/></td>
                            <td>사내 이메일</td>
                            <td><input type="text" name="emp_email" value="${empdto.emp_email}"/></td>
                        </tr>
                        <tr>
                            <td>외부 이메일</td>
                            <td><input type="text" name="ex_email" value="${empdto.ex_email}"/></td>
                            <td>은행</td>
                            <td><input type="text" name="emp_bank" value="${empdto.emp_bank}"/></td>
                        </tr>
                        <tr>
                        	<td>계좌번호</td>
                            <td><input type="text" name="emp_account" value="${empdto.emp_account}"/></td>
                        </tr>
                    </tbody>
                </table>

                <div class="text-end mt-2">
                    <button type="submit" class="btn btn-primary btn-sm">정보 수정</button>
                </div>
            </form>
        </div>

    </div>
</div>