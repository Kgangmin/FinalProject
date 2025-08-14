package com.spring.app.mail.domain;

import lombok.*;

@Getter @Setter
@AllArgsConstructor @NoArgsConstructor @Builder
public class MailListDTO {
    private String emailNo;      // 메일 PK
    private String fromEmpNo;    // 발신자 사번
    private String fromName;     // 발신자 이름
    private String emailTitle;   // 제목
    private String sentAt;       // 보낸 시각 (TO_CHAR)
    private String isRead;       // 'Y'/'N' (수신자 기준)
    private String isImportant;  // 'Y'/'N' (수신자 기준)
    private String hasAttach;    // 'Y'/'N' (첨부 존재)
    
    private String toNames; 	 // 수신자 이름
}
