package com.spring.app.emp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.app.common.FileManager;
import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor	//	@RequiredArgsConstructor는 Lombok 라이브러리에서 제공하는 애너테이션으로, final 필드 또는 @NonNull이 붙은 필드에 대해 생성자를 자동으로 생성해준다.
@RequestMapping(value="/emp/")
public class EmpController
{
	private final EmpService empservice;
	private final FileManager fileManager;
	
	//	로그인정보를 모델에 담기
	@ModelAttribute
    public void addLoginEmp(HttpSession session, Model model)
	{
        EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
        EmpDTO empdto = empservice.getEmpInfoByEmpno(loginuser.getEmp_no());
        model.addAttribute("empdto", empdto);
    }
	
	@GetMapping(value="emp_layout")
	public String emp_layout(@RequestParam(value="page", required=false) String page, Model model)
	{
		if (page == null || page.isEmpty())
		{
            page = "emp_info"; // 기본 페이지
        }
        model.addAttribute("subPage", page); 
        return "emp/emp_layout"; // emp_layout.jsp
	}
	
//	@PostMapping(value="updateEmpInfo")
//	public
	
	@GetMapping("emp_attendance")
    public String emp_attendance(Model model)
	{
        model.addAttribute("subPage", "emp_attendance");
        return "emp/emp_layout";
    }

    @GetMapping("emp_leave")
    public String emp_leave(Model model)
    {
        model.addAttribute("subPage", "emp_leave");
        return "emp/emp_layout";
    }

    @GetMapping("emp_certificate")
    public String emp_certificate(Model model)
    {
        model.addAttribute("subPage", "emp_certificate");
        return "emp/emp_layout";
    }

}
