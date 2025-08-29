package com.spring.app.emp.service;

import java.util.List;

import com.spring.app.emp.domain.EmpDTO;

public interface EmpService
{
	//	로그인된 사번을 통해 내 사원정보 조회
	EmpDTO getEmpInfoByEmpno(String emp_no);

    //	현재 직원의 프로필 파일명 가져오기
	String getEmpProfileFileName(String emp_no);

	//	현재 직원의 기존 프로필 사진 정보 가져오기
	EmpDTO getEmpProfileInfo(String emp_no);
	
	//	사원정보 수정(프로필 사진 변경이 없는)
	int updateEmpInfo(EmpDTO empDto);

	//	사원정보 수정(프로필 사진 변경이 있는)
	int updateEmployeeInfoWithFile(EmpDTO empDto);

	//	현재 비밀번호 검증을 위해 조회
	String findPasswordHashByEmpNo(String empNo);

	//	새 비밀번호로 변경
	void updatePassword(String empNo, String encodedPassword);

	//	사원목록에 띄울 정보 조회
	List<EmpDTO> getEmpList();
}
