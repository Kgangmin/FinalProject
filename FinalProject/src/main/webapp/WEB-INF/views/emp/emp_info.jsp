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
	
		<table class="emp-info-table">
			<tr>
				<td rowspan="3" class="profile-cell">
					<img src="${pageContext.request.contextPath}/images/emp_profile/${empdto.emp_save_filename}" 
                     alt="프로필 사진" class="profile-img"/>
				</td>
				<td class="label">사원번호</td>
				<td><input type="text" name="emp_no" value="${empdto.emp_no}" readonly/></td>
				<td class="label">이름</td>
				<td><input type="text" name="emp_name" value="${empdto.emp_name}" readonly/></td>
			</tr>
			<tr>
				<td class="label">주민등록번호</td>
				<td><input type="text" name="rr_number" value="${empdto.rr_number}" readonly/></td>
				<td class="label">성별</td>
				<td>
					<c:choose>
						<c:when test="${genderCode == '1' || genderCode == '3'}">남</c:when>
						<c:when test="${genderCode == '2' || genderCode == '4'}">여</c:when>
					</c:choose>
				</td>
			</tr>
			<tr>
				<td class="label">생년월일</td>
				<td><input type="text" name="birthday" readonly value="${yyyy_mm_dd}"/></td>
				<td class="label"></td>
				<td></td>
			</tr>
			<tr>
				<td class="text-center label">
					<span class="status-badge 
                    	<c:choose>
                        	<c:when test="${empdto.emp_status == '재직'}">bg-primary</c:when>
                        	<c:when test="${empdto.emp_status == '퇴사'}">bg-light text-secondary</c:when>
                    	</c:choose>
                	">
                    	<c:out value="${empdto.emp_status != null ? empdto.emp_status : ''}"/>
                	</span>
				</td>
				<td class="label">주소</td>
				<td colspan="3">
					<input type="text" name="postcode"	value="${empdto.postcode}"/>
					<input type="text" name="address"	value="${empdto.address}&nbsp;&nbsp;${empdto.detail_address}&nbsp;${empdto.extra_address}"/>
				</td>
			</tr>
			
			<tr>
				<td colspan="5"><br></td>
			</tr>
			
			<tr>
				<td colspan="2" class="label">직급</td>
				<td><input type="text" name="rank_name" value="${empdto.rank_name}" readonly/></td>
				<td class="label">부서</td>
				<td><input type="text" name="dept_name" value="${empdto.dept_name}" readonly/></td>
			</tr>
			<tr>
				<td colspan="2" class="label"></td>
				<td></td>
				<td class="label">소속</td>
				<td><input type="text" name="team_name" value="${empdto.team_name}" readonly/></td>
			</tr>
			
			<tr>
				<td colspan="5"><br></td>
			</tr>
			
			<tr>
				<td colspan="2" class="label">휴대폰 번호</td>
				<td><input type="text" name="phone_num" value="${empdto.phone_num}"/></td>
				<td class="label"></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="2" class="label">사내 이메일</td>
				<td><input type="text" name="emp_email" value="${empdto.emp_email}"/></td>
				<td class="label">외부 이메일</td>
				<td><input type="text" name="ex_email" value="${empdto.ex_email}"/></td>
			</tr>
			<tr>
				<td colspan="2" class="label">은행</td>
				<td><input type="text" name="emp_bank" value="${empdto.emp_bank}"/></td>
				<td class="label">계좌번호</td>
				<td><input type="text" name="emp_account" value="${empdto.emp_account}"/></td>
			</tr>
			

		</table>
	
	</div>

</div>