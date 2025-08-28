package com.spring.app.security;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class LegacyLoginuserBridgeFilter extends OncePerRequestFilter {

    private final EmpService empService;

    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        HttpSession session = req.getSession(false);

        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            if (session == null || session.getAttribute("loginuser") == null) {
                String empNo = ((org.springframework.security.core.userdetails.UserDetails) auth.getPrincipal()).getUsername();
                EmpDTO loginuser = empService.getEmpInfoByEmpno(empNo);
                HttpSession s = (session != null ? session : req.getSession(true));
                s.setAttribute("loginuser", loginuser);
                System.out.println("[BridgeFilter] filled loginuser for " + empNo + ", sid=" + s.getId());
            }
        }
        chain.doFilter(req, res);
    }
}