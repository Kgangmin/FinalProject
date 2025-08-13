package com.spring.app.emp.model;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.emp.domain.EmpDTO;

@Mapper
public interface EmpDAO {

	EmpDTO selectEmpByEmpNo(String empNo);
	
}
