package com.spring.app.mail.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spring.app.mail.service.MailService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping(value="/mail/*")
public class MailController {

	private final MailService mailService;
	
	@GetMapping("email")
	public String email() {
		
		return "mail/email";
	}

	
	
	
}
