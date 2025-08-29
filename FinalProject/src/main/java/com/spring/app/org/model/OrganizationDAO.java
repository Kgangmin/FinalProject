// src/main/java/com/spring/app/org/model/OrganizationDAO.java
package com.spring.app.org.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.org.domain.DeptDTO;
import com.spring.app.org.domain.EmpNodeDTO;

@Mapper
public interface OrganizationDAO {

    // 활성 부서 조회 (조직도 spine) 
    List<DeptDTO> selectDepartmentsHavingEmployees();
	
    // 각 부서에 속하는 모든 사원 조회
    List<EmpNodeDTO> selectDepartmentEmployeesWithPositions();
}
