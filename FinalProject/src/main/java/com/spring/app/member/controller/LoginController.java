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

        if (mbrDto == null || mbrDto.getEmp_pwd() == null || !empPwd.equals(mbrDto.getEmp_pwd())) {
            request.setAttribute("message", "로그인 실패!!");
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
