<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<%
  String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%=ctxPath%>/css/emp/emp_register.css"/>

<div class="emp-register">
  <h2>사원 신규등록</h2>

  <c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
  </c:if>
  <c:if test="${not empty toast}">
    <div class="alert alert-success">${toast}</div>
  </c:if>

  <!-- 반드시 multipart -->
  <form action="<%=ctxPath%>/emp/emp_register" method="post" enctype="multipart/form-data" autocomplete="off" class="form-card">
    <!-- CSRF -->
    <%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> --%>

    <div class="section-title">기본 정보</div>
  <div class="grid-2">
    <div class="form-group">
      <label for="emp_no">사번<span class="req">*</span></label>
      <input type="text" id="emp_no" name="emp_no" class="form-control" maxlength="10" required
             value="${form.emp_no}" placeholder="예) 20250001"/>
    </div>

    <div class="form-group">
      <label for="emp_name">이름<span class="req">*</span></label>
      <input type="text" id="emp_name" name="emp_name" class="form-control" maxlength="30" required
             value="${form.emp_name}"/>
    </div>

    <div class="form-group">
      <label for="fk_rank_no">직급<span class="req">*</span></label>
      <select id="fk_rank_no" name="fk_rank_no" class="form-select" required>
        <option value="" disabled ${empty form.fk_rank_no ? 'selected' : ''}>선택</option>
        <c:forEach var="r" items="${ranks}">
          <option value="${r.rank_no}" ${form.fk_rank_no == r.rank_no ? 'selected' : ''}>${r.rank_name}</option>
        </c:forEach>
      </select>
    </div>

    <div class="form-group">
      <label for="fk_dept_no">부서</label>
      <select id="fk_dept_no" name="fk_dept_no" class="form-select">
        <option value="" ${empty form.fk_dept_no ? 'selected' : ''}>미배정</option>
        <c:forEach var="d" items="${departments}">
          <option value="${d.dept_no}" ${form.fk_dept_no == d.dept_no ? 'selected' : ''}>${d.dept_name}</option>
        </c:forEach>
      </select>
    </div>
  </div>

  <div class="section-title">연락/계정</div>
  <div class="grid-2">
    <div class="form-group">
      <label for="emp_email">사내 이메일<span class="req">*</span></label>
      <input type="email" id="emp_email" name="emp_email" class="form-control" maxlength="200" required
             value="${form.emp_email}" placeholder="name@company.com"/>
    </div>
    <div class="form-group">
      <label for="ex_email">외부 이메일<span class="req">*</span></label>
      <input type="email" id="ex_email" name="ex_email" class="form-control" maxlength="200" required
             value="${form.ex_email}" placeholder="example@gmail.com"/>
    </div>
    <div class="form-group">
      <label for="phone_num">연락처<span class="req">*</span></label>
      <input type="text" id="phone_num" name="phone_num" class="form-control" maxlength="200" required
             value="${form.phone_num}" placeholder="010-1234-5678"/>
      <small class="help">숫자만 입력</small>
    </div>
    <div class="form-group">
      <label for="birthday">생년월일<span class="req">*</span></label>
      <input type="date" id="birthday" name="birthday" class="form-control" required
             value="${form.birthday}"/>
    </div>
  </div>

  <div class="section-title">근무/급여</div>
  <div class="grid-2">
    <div class="form-group">
      <label for="hiredate">입사일<span class="req">*</span></label>
      <input type="date" id="hiredate" name="hiredate" class="form-control" required
             value="${form.hiredate}"/>
    </div>
    <div class="form-group">
      <label for="emp_account">급여 계좌</label>
      <input type="text" id="emp_account" name="emp_account" class="form-control" maxlength="30"
             value="${form.emp_account}" placeholder="123-456-789012"/>
    </div>
    <div class="form-group">
      <label for="emp_bank">은행</label>
      <input type="text" id="emp_bank" name="emp_bank" class="form-control" maxlength="30"
             value="${form.emp_bank}" placeholder="국민은행"/>
    </div>
  </div>

  <div class="section-title">보안/프로필</div>
  <div class="grid-2">
    <div class="form-group">
      <label for="emp_pwd">초기 비밀번호<span class="req">*</span></label>
      <input type="password" id="emp_pwd" name="emp_pwd" class="form-control" maxlength="50" required
             autocomplete="new-password" placeholder="영문+숫자 조합 권장"/>
    </div>

    <div class="form-group">
      <label>프로필 이미지</label>
      <div class="uploader">
        <div class="avatar">
          <c:choose>
            <c:when test="${not empty form.emp_save_filename}">
              <img id="avatarPreview" src="<%=ctxPath%>/images/emp_profile/${form.emp_save_filename}" alt="preview"/>
            </c:when>
            <c:otherwise>
              <div class="placeholder" id="avatarPlaceholder">No Image</div>
            </c:otherwise>
          </c:choose>
        </div>
        <div style="flex:1">
          <input type="file" id="attach" name="attach" class="form-control" accept="image/*"/>
        </div>
      </div>
    </div>
  </div>

</div> <!-- /.form-card -->

<div class="form-actions">
  <a href="<%=ctxPath%>/emp/emp_layout?page=emp_list" class="btn btn-secondary">취소</a>
  <button type="submit" class="btn btn-primary">등록</button>
</div>

<script>
  // 이미지 미리보기
  (function(){
    const input = document.getElementById('attach');
    if(!input) return;
    input.addEventListener('change', function(e){
      const f = e.target.files && e.target.files[0];
      if(!f) return;
      const url = URL.createObjectURL(f);

      let img = document.getElementById('avatarPreview');
      let ph  = document.getElementById('avatarPlaceholder');
      if (!img) {
        img = document.createElement('img');
        img.id = 'avatarPreview';
        const wrap = document.querySelector('.avatar');
        wrap.innerHTML = '';
        wrap.appendChild(img);
      }
      if (ph) ph.remove();

      img.src = url;
    });
  })();

  // 간단한 전화번호 하이픈 마스킹
  (function(){
    const ph = document.getElementById('phone_num');
    if(!ph) return;
    ph.addEventListener('input', function(){
      let v = this.value.replace(/[^0-9]/g,'');
      if (v.length < 4) { this.value = v; return; }
      if (v.length < 8) { this.value = v.slice(0,3)+'-'+v.slice(3); return; }
      this.value = v.slice(0,3)+'-'+v.slice(3,7)+'-'+v.slice(7,11);
    });
  })();
</script>
