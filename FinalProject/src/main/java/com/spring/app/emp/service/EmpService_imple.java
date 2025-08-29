package com.spring.app.emp.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.model.EmpDAO;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class EmpService_imple implements EmpService
{
	private final EmpDAO empdao;
	
	//	로그인된 사번을 통해 사원정보 조회
	@Override
	public EmpDTO getEmpInfoByEmpno(String emp_no)
	{
		return empdao.selectEmpInfoByEmpNo(emp_no);
	}

    //	현재 직원의 프로필 파일명 가져오기
    @Override
    public String getEmpProfileFileName(String emp_no)
    {
        return empdao.getEmpProfileFileName(emp_no);
    }

    //	현재 직원의 기존 프로필 사진 정보 가져오기
	@Override
	public EmpDTO getEmpProfileInfo(String emp_no)
	{
		
		return empdao.getEmpProfileInfo(emp_no);
	}
	
	//	프로필 사진 변경이 없는 사원정보 수정
	@Override
    @Transactional // DB 트랜잭션 처리
    public int updateEmpInfo(EmpDTO empDto)
	{
        int n = empdao.updateEmpInfo(empDto);
        
        return n;
    }

	//	프로필 사진 변경이 있는 사원정보 수정
    @Override
    @Transactional // DB 트랜잭션 처리
    public int updateEmployeeInfoWithFile(EmpDTO empDto)
    {
        int n = empdao.updateEmpInfoWithFile(empDto);
        
        return n;
    }

	//	현재 비밀번호 검증을 위해 조회
	@Override
	public String findPasswordHashByEmpNo(String empNo)
	{
		return empdao.selectPasswordHashByEmpNo(empNo);
	}

	//	새 비밀번호로 변경
	@Override
	@Transactional
	public void updatePassword(String empNo, String encodedPassword)
	{
		if (empNo == null || empNo.isBlank()) throw new IllegalArgumentException("empNo empty");
        if (encodedPassword == null || encodedPassword.isBlank()) throw new IllegalArgumentException("encoded pwd empty");
        int n = empdao.updatePasswordByEmpNo(empNo, encodedPassword);
        if (n != 1) throw new IllegalStateException("Password update failed for empNo=" + empNo);
	}

	//	사원목록에 띄울 정보 조회
	@Override
	public List<EmpDTO> getEmpList()
	{
		return empdao.getEmpList();
	}
}