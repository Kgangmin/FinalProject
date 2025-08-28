package com.spring.app.notify.domain.source;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class ScheduleRow {

    private String scheduleNo;
    private String scheduleTitle;
    private LocalDateTime startDate;
    private LocalDateTime endDate;	
}
