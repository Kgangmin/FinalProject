package com.spring.app.index.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class IndexController {

	@GetMapping("/")
	public String start() {
		/* return "redirect:/login/loginStart"; */
		return "login";
	}
	
    @GetMapping("/index") 
    public String index() {
        return "index";
    }
	
}