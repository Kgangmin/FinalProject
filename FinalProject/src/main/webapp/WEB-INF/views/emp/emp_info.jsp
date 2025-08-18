<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    
<%
	String ctxPath = request.getContextPath();
%>

<div class="emp-info-container">
    <h2>내 사원정보</h2>

    <div class="container">
        <div class="card profile-card p-4">
            <div class="row g-4 align-items-center">
                <!-- 프로필 이미지 -->
                <div class="col-md-4 text-center">
                    <img src="${pageContext.request.contextPath}/images/emp_profile/${empdto.emp_save_filename}"
                         alt="프로필 사진"
                         class="profile-img"/>
                    <h5 class="mt-3"><c:out value="${empdto.emp_name}"/></h5>
                    <p class="text-muted">사원번호: <c:out value="${empdto.emp_no}"/></p>
                </div>

                <!-- 사원 정보 -->
                <div class="col-md-8">
                    <table class="table table-sm">
                        <tbody>
                        <tr>
                            <th>부서</th>
                            <td><c:out value="${empdto.fk_dept_no}"/></td>
                        </tr>
                        <tr>
                            <th>직급</th>
                            <td><c:out value="${empdto.fk_rank_no}"/></td>
                        </tr>
                        <tr>
                            <th>직책</th>
                            <td>
                                <c:forEach var="pos" items="${empdto.position}">
                                    <span class="badge bg-primary me-1">
                                        <c:out value="${pos.position_name}"/>
                                    </span>
                                </c:forEach>
                            </td>
                        </tr>
                        <tr>
                            <th>이메일</th>
                            <td><c:out value="${empdto.emp_email}"/></td>
                        </tr>
                        <tr>
                            <th>내선</th>
                            <td><c:out value="${empdto.ex_email}"/></td>
                        </tr>
                        <tr>
                            <th>휴대폰</th>
                            <td><c:out value="${empdto.phone_num}"/></td>
                        </tr>
                        <tr>
                            <th>생년월일</th>
                            <td><c:out value="${empdto.birthday}"/></td>
                        </tr>
                        <tr>
                            <th>입사일</th>
                            <td><c:out value="${empdto.hiredate}"/></td>
                        </tr>
                        <tr>
                            <th>퇴사일</th>
                            <td><c:out value="${empdto.resigndate}"/></td>
                        </tr>
                        <tr>
                            <th>상태</th>
                            <td><c:out value="${empdto.emp_status}"/></td>
                        </tr>
                        <tr>
                            <th>계좌</th>
                            <td><c:out value="${empdto.emp_bank}"/> / <c:out value="${empdto.emp_account}"/></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>