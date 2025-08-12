package com.spring.app.schedule.domain;

import java.sql.Timestamp;
import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class ScheduleDTO {
    private String scheduleNo;
    private String fkEmpNo;
    private String scheduleTitle;
    private Timestamp startDate;   // Oracle DATE ↔ Timestamp
    private Timestamp endDate;
    private String scheduleDetail;
    private String loc;
}
