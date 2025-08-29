// src/main/java/com/spring/app/org/domain/EmpNodeDTO.java
package com.spring.app.org.domain;

import lombok.Data;

@Data
public class EmpNodeDTO {
    private String empNo;
    private String empName;
    private String deptNo;
    private String rankName;
    private String empStatus; // 재직/퇴직
    private String positions; // 직책들(콤마)
    private Integer rankLevel;
}
