package com.spring.app.emp.service;

import com.spring.app.emp.domain.EmpDTO;

public interface EmpService
{
	//	로그인 시도에 입력된 사번을 통해 사원정보 조회
	EmpDTO getEmp(String empNo);

	//	로그인된 사번을 통해 내 사원정보 조회
	EmpDTO getEmpInfoByEmpno(String emp_no);
}
