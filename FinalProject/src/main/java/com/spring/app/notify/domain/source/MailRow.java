package com.spring.app.notify.domain.source;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class MailRow {

	private String emailNo;
    private String emailTitle;
    private LocalDateTime sentAt;
}
