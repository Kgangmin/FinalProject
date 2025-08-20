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

<script>const ctxPath = '<%=ctxPath%>';</script>
            
<link rel="stylesheet" href="<%=ctxPath%>/css/emp_info.css">
<script src="<%=ctxPath%>/js/emp_info.js"></script>

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
				<td><span class="display-field" data-name="emp_no" data-editable="false">${empdto.emp_no}</span></td>
				<td class="label">이름</td>
				<td><span class="display-field" data-name="emp_name" data-editable="false">${empdto.emp_name}</span></td>
			</tr>
			<tr>
				<td class="label">주민등록번호</td>
				<td><span class="display-field" data-name="rr_number" data-editable="false">${empdto.rr_number}</span></td>
				<td class="label">성별</td>
				<td>
					<span class="display-field" data-name="gender" data-editable="false">
						<c:choose>
							<c:when test="${genderCode == '1' || genderCode == '3'}">남</c:when>
							<c:when test="${genderCode == '2' || genderCode == '4'}">여</c:when>
						</c:choose>
					</span>
				</td>
			</tr>
			<tr>
				<td class="label">생년월일</td>
				<td><span class="display-field" data-name="birthday" data-editable="false">${yyyy_mm_dd}</span></td>
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
					<span class="display-field" data-name="postcode" data-editable="false">${empdto.postcode}</span>
					<span class="display-field" data-name="address" data-editable="false">${empdto.address}&nbsp;&nbsp;${empdto.detail_address}&nbsp;${empdto.extra_address}</span>
				</td>
			</tr>
			
			<tr>
				<td colspan="5"><br></td>
			</tr>
			
			<tr>
				<td colspan="2" class="label">직급</td>
				<td><span class="display-field" data-name="rank_name" data-editable="false">${empdto.rank_name}</span></td>
				<td class="label">부서</td>
				<td><span class="display-field" data-name="dept_name" data-editable="false">${empdto.dept_name}</span></td>
			</tr>
			<tr>
				<td colspan="2" class="label"></td>
				<td></td>
				<td class="label">소속</td>
				<td><span class="display-field" data-name="team_name" data-editable="false">${empdto.team_name}</span></td>
			</tr>
			
			<tr>
				<td colspan="5"><br></td>
			</tr>
			
			<tr>
				<td colspan="2" class="label">휴대폰 번호</td>
				<td><span class="display-field" data-name="phone_num" data-editable="true">${empdto.phone_num}</span></td>
				<td class="label"></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="2" class="label">사내 이메일</td>
				<td><span class="display-field" data-name="emp_email" data-editable="true">${empdto.emp_email}</span></td>
				<td class="label">외부 이메일</td>
				<td><span class="display-field" data-name="ex_email" data-editable="true">${empdto.ex_email}</span></td>
			</tr>
			<tr>
				<td colspan="2" class="label">은행</td>
				<td><span class="display-field" data-name="emp_bank" data-editable="true">${empdto.emp_bank}</span></td>
				<td class="label">계좌번호</td>
				<td><span class="display-field" data-name="emp_account" data-editable="true">${empdto.emp_account}</span></td>
			</tr>
			
		</table>
	
	</div>

    <div style="text-align: center; margin-top: 20px;">
        <button type="button" id="toggleEditBtn" class="btn btn-primary">정보수정</button>
    </div>

</div>