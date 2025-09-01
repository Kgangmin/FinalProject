package com.spring.app.attendance.domain;

import lombok.*;
import java.util.Date;

@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class AttendanceDTO {
    // ===== Daily =====
    private Date   workDate;
    private Date   clockIn;
    private Date   clockOut;
    private String isLate;             // 'Y'/'N'
    private String isAbsent;           // 'Y'/'N'
    private String remark;

    // Daily 계산값
    private Integer spanMinutes;       // 그날 총 근무 분
    private Integer timelineLeftPct;   // 0~100
    private Integer timelineWidthPct;  // 0~100

    // ===== Weekly Summary =====
    private String  weekLabel;         // "yyyy-MM-dd ~ yyyy-MM-dd"
    private Integer requiredMinutes;   // 2400 (주40h)
    private Integer workedMinutes;     // 주 누적 근로 분
    private Integer workedDays;        // 근무일수(결근 제외)
    private Integer pct;               // 진행률(0~100)
}