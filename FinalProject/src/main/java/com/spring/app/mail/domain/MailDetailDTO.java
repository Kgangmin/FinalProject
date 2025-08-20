package com.spring.app.mail.domain;

import lombok.*;

@Getter 
@Setter
@AllArgsConstructor 
@NoArgsConstructor 
@Builder
public class MailDetailDTO {
    // 기본 메일 정보
    private String emailNo;       // EMAIL.EMAIL_NO
    private String fromEmpNo;     // EMAIL.FK_EMP_NO (발신자 사번)
    private String fromName;      // 발신자 이름
    private String fromEmail;     // 발신자 이메일
    private String emailTitle;    // 제목
    private String emailContent;  // 내용 (TEXT)
    private String sentAt;        // 보낸 시각 (TO_CHAR로 문자열)

    // 조회자(=로그인 사용자) 기준 상태
    private String isRead;        // 'Y'/'N' (받은편지함/전체에서만 의미, 보낸편지함은 null)
    private String isImportant;   // 'Y'/'N' (받은편지함/전체에서만 의미, 보낸편지함은 null)

    // 수신자 표시용 (콤마로 연결된 문자열)
    private String toNames;       // 예) "홍길동, 김철수"
    private String toEmails;      // 예) "hong@..., kim@..."
}
