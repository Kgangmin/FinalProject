package com.spring.app.emp.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.emp.domain.EmpDTO;

@Mapper
public interface EmpDAO
{

	//	로그인된 사번으로 내 사원정보 조회
	EmpDTO selectEmpInfoByEmpNo(String emp_no);

    //	현재 직원의 프로필 파일명 가져오기
	String getEmpProfileFileName(String emp_no);

    //	현재 직원의 기존 프로필 사진 정보 가져오기
	EmpDTO getEmpProfileInfo(String emp_no);

	//	프로필 사진 변경이 없는 사원정보 수정
	int updateEmpInfo(EmpDTO empDto);

    // 프로필 사진 변경이 있는 사원정보 수정
	int updateEmpInfoWithFile(EmpDTO empDto);
	
	////////////////////////////////////////////////////////////
	
	//	1. 사원번호로 정보 조회(로그인 시 사용)
	EmpDTO findByEmpNo(String empNo);
	
	//	2. 사원번호로 권한 목록 조회(로그인 시 사용)
	List<String> findPermissionByEmpNo(String empNo);

	//	현재 비밀번호 검증을 위한 조회
	String selectPasswordHashByEmpNo(String empNo);

	//	비밀번호 변경
	int updatePasswordByEmpNo(String empNo, String encodedPassword);

	//	사원목록에 띄울 정보 조회
	List<EmpDTO> getEmpList();
}
