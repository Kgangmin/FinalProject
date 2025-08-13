package com.spring.app.mail.domain;

import lombok.*;

@Getter 
@Setter
@AllArgsConstructor 
@NoArgsConstructor
@Builder
public class MailDTO {
	
    // ===== tbl_email 컬럼 =====
    private String email_no;        // PK
    private String fk_emp_no;       // 발신자 사번(세션에서 주입)
    private String email_title;     // 제목
    private String email_content;   // 내용
    private String sent_at;         // 저장 시각(문자; SELECT 시 TO_CHAR로 매핑)
    private String is_attached;     // Y/N

    // ===== UI 입력용 =====
    private String to_emp_email_csv; // 받는사람 사내이메일 CSV
}
