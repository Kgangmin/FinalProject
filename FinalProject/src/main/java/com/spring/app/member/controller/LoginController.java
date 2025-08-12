package com.spring.app.member.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import com.spring.app.member.domain.MemberDTO;
import com.spring.app.member.service.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/login/")
@RequiredArgsConstructor
public class LoginController {

    private final MemberService memberService;

    @GetMapping("loginStart")
    public String login() {
        return "login"; // /WEB-INF/views/login.jsp
    }

    @PostMapping("loginEnd")
    public String loginEnd(@RequestParam(name="empNo") String empNo,
                           @RequestParam(name="empPwd") String empPwd,
                           HttpServletRequest request) {

        MemberDTO mbrDto = memberService.getMember(empNo);

     // === 사번/비번 검증 ===
        if (mbrDto == null) {
            request.setAttribute("message", "존재하지 않는 사번입니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }
        if (mbrDto.getEmp_pwd() == null || !empPwd.equals(mbrDto.getEmp_pwd())) {
            request.setAttribute("message", "비밀번호가 올바르지 않습니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }
        
        // === 계정 상태 검증: '재직'만 허용  ===
        String status = mbrDto.getEmp_status();
        if (status == null || !"재직".equals(status.trim())) {
            // 상태가 '퇴직' 또는 기타인 경우 로그인 차단
            request.setAttribute("message", "로그인 불가: 현재 계정 상태는 '" + status + "' 입니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }

        HttpSession session = request.getSession();
        session.setAttribute("loginuser", mbrDto);

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
