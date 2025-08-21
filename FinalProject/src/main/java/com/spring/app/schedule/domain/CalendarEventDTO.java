package com.spring.app.schedule.domain;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CalendarEventDTO {
    private String id;       // scheduleNo
    private String title;    // scheduleTitle
    private String start;    // ISO-8601 문자열 (FullCalendar가 파싱)
    private String end;      // ISO-8601 문자열
    private String type;     // "MY" | "DEPT" | "COMP"
    private String detail;   // scheduleDetail
    private String loc;      // loc
}
