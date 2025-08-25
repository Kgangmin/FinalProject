package com.spring.app.emp.service;

import com.spring.app.emp.domain.EmpDTO;

public interface EmpService
{
	//	로그인 시도에 입력된 사번을 통해 사원정보 조회
	EmpDTO getEmp(String empNo);

	//	로그인된 사번을 통해 내 사원정보 조회
	EmpDTO getEmpInfoByEmpno(String emp_no);

    //	현재 직원의 프로필 파일명 가져오기
	String getEmpProfileFileName(String emp_no);

	//	현재 직원의 기존 프로필 사진 정보 가져오기
	EmpDTO getEmpProfileInfo(String emp_no);
	
	//	프로필 사진 변경이 없는 사원정보 수정
	int updateEmpInfo(EmpDTO empDto);

	//	프로필 사진 변경이 있는 사원정보 수정
	int updateEmployeeInfoWithFile(EmpDTO empDto);
}
