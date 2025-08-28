package com.spring.app.notify.domain.source;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NoticeRow {

    private String boardNo;
    private String boardTitle;
    private LocalDateTime registerDate;
}
