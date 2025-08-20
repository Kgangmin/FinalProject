package com.spring.app.schedule.controller;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.schedule.domain.CalendarEventDTO;
import com.spring.app.schedule.domain.ScheduleDTO;
import com.spring.app.schedule.service.ScheduleService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/schedule")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    private static final ZoneId ZONE = ZoneId.of("Asia/Seoul");
    private static final DateTimeFormatter ISO_OFFSET = DateTimeFormatter.ISO_OFFSET_DATE_TIME;

    // ===== 화면 ===== //
    @GetMapping("/scheduleManagement")
    public String scheduleManagement() {
        // /WEB-INF/views/schedule/scheduleManagement.jsp
        return "schedule/scheduleManagement";
    }

    // ===== 공통 유틸 ===== //
    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
    private static String asText(Object v) {
        return v == null ? null : String.valueOf(v);
    }
    private static String emptyToNull(String s) {
        return isBlank(s) ? null : s;
    }
    private static String nvl(String s) {
        return s == null ? "" : s;
    }

    private Timestamp parseToTimestamp(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            // ISO(오프셋 포함) 예) 2025-08-01T00:00:00+09:00
            Instant ins = OffsetDateTime.parse(s).toInstant();
            return Timestamp.from(ins);
        } catch (Exception ignore) {}

        try {
            // 예) 2025-08-01T00:00:00 (또는 공백 구분)
            LocalDateTime ldt = LocalDateTime.parse(s.replace(' ', 'T'));
            return Timestamp.from(ldt.atZone(ZONE).toInstant());
        } catch (Exception ignore) {}

        try {
            // 예) 2025-08-01
            LocalDate ld = LocalDate.parse(s.substring(0, Math.min(s.length(), 10)));
            return Timestamp.from(ld.atStartOfDay(ZONE).toInstant());
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid datetime: " + s);
        }
    }

    private String toIsoString(Timestamp ts) {
        if (ts == null) return null;
        return ts.toInstant().atZone(ZONE).format(ISO_OFFSET);
    }

    /** ScheduleDTO → FullCalendar 응답용 DTO (null 필드는 @JsonInclude로 자동 제외) */
    private CalendarEventDTO toEvent(ScheduleDTO sdto) {
        return CalendarEventDTO.builder()
                .id(nvl(sdto.getScheduleNo()))
                .title(nvl(sdto.getScheduleTitle()))
                .start(toIsoString(sdto.getStartDate()))           // null이면 자동 미포함
                .end(toIsoString(sdto.getEndDate()))               // null이면 자동 미포함
                .type("MY")                                     // 현재 테이블에 type 없으므로 고정
                .detail(emptyToNull(sdto.getScheduleDetail()))     // 공백 → null
                .loc(emptyToNull(sdto.getLoc()))                   // 공백 → null
                .build();
    }

    // ===== 일정 등록/수정 (id 유무로 분기) ===== //
    @PostMapping("/save")
    @ResponseBody
    public Map<String, Object> save(@RequestBody Map<String, Object> paraMap, HttpSession session) {

        // 로그인 확인
        EmpDTO login = (session != null) ? (EmpDTO) session.getAttribute("loginuser") : null;
        if (login == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        String empNo = login.getEmp_no();
        if (isBlank(empNo)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사번 정보를 확인할 수 없습니다.");
        }

        // 페이로드 추출
        String id    = asText(paraMap.get("id"));
        String title = asText(paraMap.get("title"));
        String start = asText(paraMap.get("start"));
        String end   = asText(paraMap.get("end"));
        String memo  = asText(paraMap.get("memo"));
        String loc   = asText(paraMap.get("loc"));

        // 필수 검증
        if (isBlank(title)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "제목은 필수입니다.");
        if (isBlank(start)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "시작일시는 필수입니다.");

        // 시간 파싱
        final Timestamp tsStart, tsEnd;
        try {
            tsStart = parseToTimestamp(start);
            tsEnd   = isBlank(end) ? tsStart : parseToTimestamp(end);
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "잘못된 날짜 형식입니다.");
        }
        if (tsEnd.before(tsStart)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "종료일시는 시작일시 이후여야 합니다.");
        }

        // DTO 구성
        ScheduleDTO dto = ScheduleDTO.builder()
                .scheduleNo(isBlank(id) ? null : id.trim())
                .fkEmpNo(empNo)
                .scheduleTitle(title.trim())
                .startDate(tsStart)
                .endDate(tsEnd)
                .scheduleDetail(emptyToNull(memo))
                .loc(emptyToNull(loc))
                .build();

        if (isBlank(id)) {
            // INSERT
            scheduleService.createSchedule(dto); // selectKey로 PK 세팅
            return Map.of("result", "OK", "mode", "CREATE", "id", dto.getScheduleNo());
        } else {
            // UPDATE (본인 소유건만)
            int rows = scheduleService.updateOwnSchedule(dto); // 조건: schedule_no & fk_emp_no
            if (rows == 0) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "대상이 없거나 권한이 없습니다.");
            }
            return Map.of("result", "OK", "mode", "UPDATE", "id", dto.getScheduleNo());
        }
    }

    // ===== 일정 삭제 (본인 소유만) ===== //
    @DeleteMapping("/delete/{id}")
    @ResponseBody
    public Map<String, Object> delete(@PathVariable("id") String scheduleNo, HttpSession session) {
        // 로그인/사번 확인
        EmpDTO login = (session != null) ? (EmpDTO) session.getAttribute("loginuser") : null;
        if (login == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        String empNo = login.getEmp_no();
        if (isBlank(empNo)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사번 정보를 확인할 수 없습니다.");
        }
        if (isBlank(scheduleNo)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "잘못된 요청입니다.");
        }

        int rows = scheduleService.deleteOwnSchedule(scheduleNo, empNo);
        if (rows == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "대상이 없거나 권한이 없습니다.");
        }
        return Map.of("result", "OK", "deleted", rows);
    }

    // ===== 내 일정 조회 (FullCalendar 이벤트 소스) =====    
    @ResponseBody
    @GetMapping("/events")
    public List<CalendarEventDTO> listEvents(
            @RequestParam("start") String start,
            @RequestParam("end") String end,
            @RequestParam(value = "q", required = false) String q,
            HttpSession session) {

        // 로그인/사번
        EmpDTO login = (session != null) ? (EmpDTO) session.getAttribute("loginuser") : null;
        if (login == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        String empNo = login.getEmp_no();
        if (isBlank(empNo)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사번 정보를 확인할 수 없습니다.");
        }

        // 기간 파싱
        Timestamp tsStart = parseToTimestamp(start);
        Timestamp tsEnd   = parseToTimestamp(end);

        // 내 일정만
        List<ScheduleDTO> list = scheduleService.getSchedulesInRange(tsStart, tsEnd, empNo, q);
     
		List<CalendarEventDTO> result = list.stream()
										    .map(this::toEvent)
										    .collect(Collectors.toList());    		
	     return result;
    }

    
    // ===== 검색(내 일정만) ===== //
    @ResponseBody
    @GetMapping("/search")
    public List<CalendarEventDTO> search(
            @RequestParam("q") String q,
            @RequestParam(value = "from", required = false) String fromStr,
            @RequestParam(value = "to",   required = false) String toStr,
            HttpSession session) {

        // 로그인/사번
        EmpDTO login = (session != null) ? (EmpDTO) session.getAttribute("loginuser") : null;
        if (login == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        String empNo = login.getEmp_no();
        if (isBlank(empNo)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사번 정보를 확인할 수 없습니다.");
        }

        if (isBlank(q)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "검색어(q)는 필수입니다.");
        }

        Timestamp from = (!isBlank(fromStr)) ? parseToTimestamp(fromStr) : null;
        Timestamp to   = (!isBlank(toStr))   ? parseToTimestamp(toStr)   : null;

        List<ScheduleDTO> list = scheduleService.searchMySchedules(empNo, q, from, to);

        List<CalendarEventDTO> result = list.stream()
									        .map(this::toEvent)
									        .collect(Collectors.toList());
       
        return result;
        		
    }
}
