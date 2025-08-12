package com.spring.app.schedule.controller;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.app.schedule.domain.CalendarEventDTO;
import com.spring.app.schedule.domain.ScheduleDTO;
import com.spring.app.schedule.service.ScheduleService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/schedule")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;
    private static final ZoneId ZONE = ZoneId.of("Asia/Seoul");
    private static final DateTimeFormatter ISO_OFFSET = DateTimeFormatter.ISO_OFFSET_DATE_TIME;

    // JSP 화면
    @GetMapping("/scheduleManagement")
    public String scheduleManagement() {
        // /WEB-INF/views/schedule/scheduleManagement.jsp
        return "schedule/scheduleManagement";
    }
    

    // 이벤트 JSON (주의: 클래스 레벨 /schedule + 메서드 /events = /schedule/events)
    @ResponseBody
    @GetMapping(value = "/events", produces = "application/json; charset=UTF-8")
    public List<CalendarEventDTO> listEvents(
            @RequestParam("start") String start,
            @RequestParam("end") String end,
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "empNo", required = false) String empNoParam,
            @RequestParam(value = "fk_emp_no", required = false) String empNoAlt
    ) {
        // empNo와 fk_emp_no 둘 다 허용
        String empNo = (empNoParam != null && !empNoParam.isBlank()) ? empNoParam : empNoAlt;

        Timestamp tsStart = parseToTimestamp(start);
        Timestamp tsEnd   = parseToTimestamp(end);

        List<ScheduleDTO> list = scheduleService.getSchedulesInRange(tsStart, tsEnd, empNo, q);

        // FullCalendar 응답 스펙으로 변환
        return list.stream().map(s -> CalendarEventDTO.builder()
                .id(s.getScheduleNo())
                .title(s.getScheduleTitle())
                .start(toIsoString(s.getStartDate()))
                .end(toIsoString(s.getEndDate()))
                .allDay(false)          // 종일 처리 필요 시 컬럼/로직 추가
                .type("MY")             // 현재 테이블에 type 없음 → 'MY' 고정
                .detail(s.getScheduleDetail())
                .loc(s.getLoc())
                .build())
            .collect(Collectors.toList());
    }

    // ===== 유틸 =====
    private Timestamp parseToTimestamp(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            // ISO(오프셋 포함) "2025-08-01T00:00:00+09:00"
            Instant ins = OffsetDateTime.parse(s).toInstant();
            return Timestamp.from(ins);
        } catch (Exception ignore) {}

        try {
            // "2025-08-01T00:00:00" 형태
            LocalDateTime ldt = LocalDateTime.parse(s.replace(' ', 'T'));
            return Timestamp.from(ldt.atZone(ZONE).toInstant());
        } catch (Exception ignore) {}

        try {
            // "2025-08-01" 형태
            LocalDate ld = LocalDate.parse(s.substring(0, 10));
            return Timestamp.from(ld.atStartOfDay(ZONE).toInstant());
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid datetime: " + s);
        }
    }

    private String toIsoString(Timestamp ts) {
        if (ts == null) return null;
        return ts.toInstant().atZone(ZONE).format(ISO_OFFSET);
    }
}
