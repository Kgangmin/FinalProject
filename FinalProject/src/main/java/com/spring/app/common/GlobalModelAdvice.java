package com.spring.app.common;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;

import lombok.RequiredArgsConstructor;

@ControllerAdvice
@RequiredArgsConstructor
public class GlobalModelAdvice
{
	private final EmpService empservice;
	
	//	전역에 empDto를 모델에 담기
	@ModelAttribute("loginEmp")
    public EmpDTO addEmpDto(@AuthenticationPrincipal UserDetails empDetails)
	{
		if(empDetails == null) return null;
		else
		{
			//	UserDetails에서 로그인 된 사원번호(username) 가져오기
			String empNo = empDetails.getUsername();
			
			//	사원번호를 이용하여 EmpDTO 조회
			EmpDTO empDto = empservice.getEmpInfoByEmpno(empNo);
			
			return empDto;
		}
    }
}
