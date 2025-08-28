package com.spring.app.notify.domain;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NotificationDTO {
    private String type;       // MAIL|SCHEDULE|TASK|SURVEY|NOTICE
    private String id;         // email_no, schedule_no, task_no, survey_id, board_no
    private String title;      // 표시 제목
    private String message;    // 부가 메시지
    private LocalDateTime time;
    private String targetUrl;  // 이동 URL


}
