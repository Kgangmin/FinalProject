<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>로그인 - HANB</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="<%= ctxPath %>/bootstrap-4.6.2-dist/css/bootstrap.min.css">
  <!-- jQuery -->
  <script src="<%= ctxPath %>/js/jquery-3.7.1.min.js"></script>
  <!-- Bootstrap JS -->
  <script src="<%= ctxPath %>/bootstrap-4.6.2-dist/js/bootstrap.bundle.min.js"></script>

  <style>
    :root{
      --brand:#0d6efd;
      --border:#e9ecef;
      --bg:#f8f9fa;
    }
    html, body { height: 100%; }
    body {
      background: var(--bg);
      margin: 0;
    }
    .login-wrap {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    .login-card {
      background: #fff;
      border: 1px solid var(--border);
      border-radius: .75rem;
      box-shadow: 0 8px 24px rgba(0,0,0,.06);
      width: 100%;
      max-width: 420px;
      overflow: hidden;
    }
    .login-head {
      padding: 28px 28px 12px;
      text-align: center;
    }
    .brand {
      font-weight: 800;
      font-size: 1.5rem;
      letter-spacing: .5px;
      color: var(--brand);
    }
    .login-sub {
      color: #6c757d;
      font-size: .95rem;
      margin-top: 6px;
    }
    .login-body {
      padding: 20px 28px 8px;
    }
    .form-label {
      font-weight: 600;
      color: #495057;
    }
    .form-control {
      height: 44px;
    }
    .login-actions {
      padding: 8px 28px 28px;
    }
    .btn-login {
      height: 44px;
      font-weight: 600;
      width: 100%;
    }
    .helper {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-top: 8px;
      color: #6c757d;
      font-size: .9rem;
    }
    .caps-indicator {
      display: none;
      color: #dc3545;
      font-size: .85rem;
      margin-top: 6px;
    }
    .footer-note {
      text-align: center;
      color: #adb5bd;
      font-size: .8rem;
      padding: 0 0 8px;
    }
  </style>
</head>
<body>

<div class="login-wrap">
  <div class="login-card">
    <div class="login-head">
      <div class="brand">HANB</div>
      <div class="login-sub">로그인</div>
    </div>

    <form id="loginForm" method="post" action="<%= ctxPath %>/login" autocomplete="off" novalidate>
      <div class="login-body">
        <div class="form-group mb-3">
          <label for="empNo" class="form-label">사원번호</label>
          <input type="text" class="form-control" id="empNo" name="username" placeholder="사원번호를 입력하세요" required>
          <div class="invalid-feedback">사원번호를 입력해 주세요.</div>
        </div>

        <div class="form-group mb-1">
          <label for="empPwd" class="form-label">비밀번호</label>
          <div class="input-group">
            <input type="password" class="form-control" id="empPwd" name="password" placeholder="비밀번호를 입력하세요" required>
            <div class="input-group-append">
              <button class="btn btn-outline-secondary" type="button" id="btnTogglePwd" tabindex="-1">보기</button>
            </div>
            <div class="invalid-feedback">비밀번호를 입력해 주세요.</div>
          </div>
          <div id="capsInfo" class="caps-indicator">Caps Lock이 켜져 있습니다.</div>
        </div>

        <c:if test="${param.error != null}">
          <div class="alert alert-danger mt-3 mb-0" role="alert">
            ${errorMessage}
          </div>
        </c:if>

      </div>

      <div class="login-actions">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

        <button type="submit" class="btn btn-primary btn-login" id="btnLogin">로그인</button>
        <div class="helper">
          <span></span>
        </div>
      </div>
    </form>
    <div class="footer-note">© <script>document.write(new Date().getFullYear())</script> HANB Groupware</div>
  </div>
</div>

<script>
  (function(){
    const $form   = $('#loginForm');
    const $empNo  = $('#empNo');
    const $empPwd = $('#empPwd');
    const $caps   = $('#capsInfo');

    function submitLogin(){
      let valid = true;
      if(!$empNo.val().trim()){
        $empNo.addClass('is-invalid'); valid = false;
      } else { $empNo.removeClass('is-invalid'); }

      if(!$empPwd.val()){
        $empPwd.addClass('is-invalid'); valid = false;
      } else { $empPwd.removeClass('is-invalid'); }

      if(valid){ $form.trigger('submit'); }
    }

    $('#btnLogin').on('click', function(e){
      e.preventDefault();
      submitLogin();
    });

    $form.on('keydown', function(e){
      if(e.key === 'Enter'){
        e.preventDefault();
        submitLogin();
      }
    });

    $empPwd.on('keyup keydown', function(e){
      const caps = e.getModifierState && e.getModifierState('CapsLock');
      $caps.toggle(!!caps);
    });

    $('#btnTogglePwd').on('click', function(){
      const type = $empPwd.attr('type') === 'password' ? 'text' : 'password';
      $empPwd.attr('type', type);
      $(this).text(type === 'password' ? '보기' : '숨기기');
      $empPwd.trigger('focus');
    });
  })();
</script>

</body>
</html>