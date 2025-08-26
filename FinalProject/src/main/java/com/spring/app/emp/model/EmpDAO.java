package com.spring.app.emp.model;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.emp.domain.EmpDTO;

@Mapper
public interface EmpDAO
{
	EmpDTO selectEmpByEmpNo(String empNo);

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
}
