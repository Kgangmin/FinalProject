package com.spring.app.notify.domain.source;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class TaskRow {

    private String taskNo;
    private String taskTitle;
    private LocalDateTime startDate;
    private LocalDateTime endDate;	
}
