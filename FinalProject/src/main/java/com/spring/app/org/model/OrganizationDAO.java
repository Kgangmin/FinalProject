// src/main/java/com/spring/app/org/model/OrganizationDAO.java
package com.spring.app.org.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.org.domain.DeptDTO;
import com.spring.app.org.domain.DeptHeadDTO;

@Mapper
public interface OrganizationDAO {

    /** 활성 부서 조회 (조직도 spine) */
    List<DeptDTO> selectActiveDepartments();

    /** 각 부서의 최고직급 재직자 + 직책들(콤마) */
    List<DeptHeadDTO> selectDeptHeads();
}
