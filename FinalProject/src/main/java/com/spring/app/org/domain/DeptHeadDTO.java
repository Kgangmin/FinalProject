// src/main/java/com/spring/app/org/domain/DeptHeadDTO.java
package com.spring.app.org.domain;

import lombok.Data;

@Data
public class DeptHeadDTO {
    private String deptNo;

    private String empNo;
    private String empName;

    private String rankName;
    private Integer rankLevel;

    /** "직책1, 직책2, ..." */
    private String positions;
}
