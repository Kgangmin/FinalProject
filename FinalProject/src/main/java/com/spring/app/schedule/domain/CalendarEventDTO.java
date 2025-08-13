package com.spring.app.schedule.domain;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class CalendarEventDTO {
    private String id;       // scheduleNo
    private String title;    // scheduleTitle
    private String start;    // ISO-8601 문자열 (FullCalendar가 파싱)
    private String end;      // ISO-8601 문자열
    private String type;     // DB엔 없으므로 'MY' 고정(향후 확장)
    private String detail;   // scheduleDetail
    private String loc;      // loc
}
