package com.spring.app.index.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class IndexController {

	/*	@GetMapping("")
	public String start() {
		 return "redirect:/login/loginStart";
		return "redirect:/index";
	} */
	
    @GetMapping("index") 
    public String index() {
        return "index";
    }
	
}