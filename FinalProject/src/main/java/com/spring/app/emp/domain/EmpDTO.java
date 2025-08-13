package com.spring.app.emp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * tbl_employee 테이블 DTO
 * 모든 컬럼명을 DB 컬럼명과 동일하게, 모든 타입을 String으로 통일
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class EmpDTO {

    private String emp_no;              // 사원번호 (PK)
    private String emp_pwd;             // 비밀번호
    private String emp_name;            // 사원이름
    private String fk_rank_no;          // 직급번호 (FK)
    private String fk_dept_no;          // 부서번호 (FK)
    private String ex_email;            // 외부이메일
    private String emp_email;           // 사내이메일
    private String phone_num;           // 전화번호
    private String birthday;            // 생년월일 (DATE → String)
    private String emp_account;         // 계좌번호
    private String emp_bank;            // 은행명
    private String hiredate;            // 입사일 (DATE → String)
    private String resigndate;          // 퇴사일 (DATE → String)
    private String emp_status;          // 재직 상태 ('재직', '퇴직')
    private String emp_origin_filename; // 프로필 원본 파일명
    private String emp_save_filename;   // 프로필 저장 파일명
    private String emp_filesize;        // 파일 크기 (number → String)
}
