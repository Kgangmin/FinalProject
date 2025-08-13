package com.spring.app.emp.service;

import org.springframework.stereotype.Service;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.model.EmpDAO;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class EmpService_imple implements EmpService {

	 private final EmpDAO empdao;
	 
	    @Override
	    public EmpDTO getEmp(String empNo) {
	        return empdao.selectEmpByEmpNo(empNo);
	    }
}
