package com.spring.app.dashboard.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;
import com.spring.app.dashboard.domain.WidgetSaveRequest;
import com.spring.app.dashboard.service.DashboardWidgetService;
import com.spring.app.emp.domain.EmpDTO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/dashboard/widgets")
public class DashboardWidgetController {

	 private final DashboardWidgetService service;
	 
	 private String requireEmpNo(HttpSession session){
		 
		 EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
		 if (loginuser == null) {
			 throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
	        }
		 return loginuser.getEmp_no();
	 }
	 
	 
	 @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
	 public Map<String,Object> list(HttpSession session){
		 String empNo = requireEmpNo(session);
		 List<WidgetLayoutDTO> list = service.list(empNo);
		 Map<String,Object> res = new HashMap<>();
		 res.put("ok", true);
		 res.put("list", list);
		 return res;
	 }

	 @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
	 public Map<String,Object> save(@RequestBody WidgetSaveRequest req, HttpSession session){
		 String empNo = requireEmpNo(session);
		 int updated = service.saveAll(empNo, req.getWidgets());
		 Map<String,Object> res = new HashMap<>();
		 res.put("ok", true);
		 res.put("updated", updated);
		 return res;
	 }
	 
	 
	 
}
