package com.spring.app.security;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final EmpService empService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        String empNo = ((UserDetails)authentication.getPrincipal()).getUsername();
        EmpDTO loginuser = empService.getEmpInfoByEmpno(empNo);

        HttpSession session = request.getSession(true);
        session.setAttribute("loginuser", loginuser);   // ★ 레거시 호환 포인트

        // 원래 가던 곳으로 보내거나, 기본 페이지로 이동
        response.sendRedirect(request.getContextPath() + "/index");
    }    
}