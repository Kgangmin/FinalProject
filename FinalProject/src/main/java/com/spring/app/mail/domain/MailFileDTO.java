package com.spring.app.mail.domain;

import lombok.*;

@Getter 
@Setter
@AllArgsConstructor 
@NoArgsConstructor
@Builder
public class MailFileDTO {
    private String email_file_no;         // PK
    private String fk_email_no;           // FK
    private String email_origin_filename;
    private String email_save_filename;
    private String email_filesize;       // number -> String
}
