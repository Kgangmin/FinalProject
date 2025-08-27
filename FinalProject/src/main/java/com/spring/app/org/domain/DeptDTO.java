// src/main/java/com/spring/app/org/domain/DeptDTO.java
package com.spring.app.org.domain;

import lombok.Data;

@Data
public class DeptDTO {
    private String deptNo;
    private String deptName;
    private String parentDeptNo;
}
