package com.spring.app.emp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController
{

    @GetMapping("/login")
    public String loginForm(@RequestParam(value="error", required=false) String error, Model model)
    {
    	if(error != null)
    	{
    		model.addAttribute("errorMessage", "사번 또는 비밀번호가 올바르지 않거나, 재직 상태가 아닌 사원입니다.");
    	}
        return "login"; // /WEB-INF/views/login.jsp
    }
}
