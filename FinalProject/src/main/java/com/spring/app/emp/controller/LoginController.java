package com.spring.app.emp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/login/")
@RequiredArgsConstructor
public class LoginController {

    private final EmpService empService;

    @GetMapping("loginStart")
    public String login() {
        return "login"; // /WEB-INF/views/login.jsp
    }

    @PostMapping("loginEnd")
    public String loginEnd(@RequestParam(name="empNo") String empNo,
                           @RequestParam(name="empPwd") String empPwd,
                           HttpServletRequest request) {

        EmpDTO empDto = empService.getEmp(empNo);

     // === 사번/비번 검증 ===
        if (empDto == null) {
            request.setAttribute("message", "존재하지 않는 사번입니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }
        if (empDto.getEmp_pwd() == null || !empPwd.equals(empDto.getEmp_pwd())) {
            request.setAttribute("message", "비밀번호가 올바르지 않습니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }
        
        // === 계정 상태 검증: '재직'만 허용  ===
        String status = empDto.getEmp_status();
        if (status == null || !"재직".equals(status.trim())) {
            // 상태가 '퇴직' 또는 기타인 경우 로그인 차단
            request.setAttribute("message", "로그인 불가: 현재 계정 상태는 '" + status + "' 입니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }

        HttpSession session = request.getSession();
        session.setAttribute("loginuser", empDto);

        return "redirect:/index";
    }

    @GetMapping("logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession();
        session.invalidate();

        request.setAttribute("message", "로그아웃 되었습니다.");
        request.setAttribute("loc", request.getContextPath()+"/");
        return "msg";
    }
}
