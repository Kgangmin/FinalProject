package com.spring.app.emp.service;

import java.util.List;
import java.util.Map;

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
	public List<EmpDTO> getEmpList(Map<String, Object> paramap)
	{
		return empdao.getEmpList(paramap);
	}

	@Override
	public int getEmpCount(Map<String, Object> paramap)
	{
		return empdao.selectEmpCount(paramap);
	}
	
	@Override
    public EmpDTO getEmpByNo(String emp_no)
	{
        // 단순 조회라면 바로 DAO 호출
        return empdao.selectEmpInfoByEmpNo(emp_no);
    }

	// 페이징 처리를 위한 휴가 리스트 조회
	@Override
	public int selectLeaveCount(Map<String, Object> paramap) {
		
		return empdao.selectLeaveCount(paramap);
	}

	// 휴가리스트 조회
	@Override
	public List<Map<String, Object>> getEmpLeavelist(Map<String, Object> param) {
		
		return empdao.getEmpLeavelist(param);
	}
	// 연차사용횟수 가져오기
	@Override
	public List<Integer> getUsed_days(String emp_no) {
		return empdao.getUsed_days(emp_no);
	}

	
}