package com.spring.app.draft.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spring.app.draft.service.DraftService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/draft/")
@RequiredArgsConstructor
public class DraftController {

	
	private final DraftService draftService; 
	
	
	@GetMapping("draftList")
	public String draftList() {
		
		
		
		return "draft/draftList";
	}
	
}
