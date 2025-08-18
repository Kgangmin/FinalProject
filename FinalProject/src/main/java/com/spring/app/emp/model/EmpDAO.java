package com.spring.app.emp.model;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.emp.domain.EmpDTO;

@Mapper
public interface EmpDAO
{
	EmpDTO selectEmpByEmpNo(String empNo);

	//	로그인된 사번으로 내 사원정보 조회
	EmpDTO selectEmpInfoByEmpNo(String emp_no);	
}
