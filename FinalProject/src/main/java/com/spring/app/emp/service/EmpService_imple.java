package com.spring.app.emp.service;

import org.springframework.stereotype.Service;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.model.EmpDAO;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class EmpService_imple implements EmpService
{
	private final EmpDAO empdao;
	 
	//	로그인 시도에 입력된 사번을 통해 사원정보 조회
	@Override
	public EmpDTO getEmp(String empNo)
	{
		return empdao.selectEmpByEmpNo(empNo);
	}

	//	로그인된 사번을 통해 사원정보 조회
	@Override
	public EmpDTO getEmpInfoByEmpno(String emp_no)
	{
		return empdao.selectEmpInfoByEmpNo(emp_no);
	}
}
