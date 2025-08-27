package com.spring.app.chatting.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EmpSearchDTO {
    private String empNo;
    private String empName;
    private String deptName;
    private String email;
    private String saveFilename; // 프로필 파일명

}
