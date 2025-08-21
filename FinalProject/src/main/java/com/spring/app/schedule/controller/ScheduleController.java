package com.spring.app.schedule.controller;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
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
import com.spring.app.schedule.domain.TaskDTO;
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
                .type("MY")                                     
                .detail(emptyToNull(sdto.getScheduleDetail()))     // 공백 → null
                .loc(emptyToNull(sdto.getLoc()))                   // 공백 → null
                .build();
    }
    
    private CalendarEventDTO toEvent(TaskDTO tdto) {
        return CalendarEventDTO.builder()
                .id(nvl(tdto.getTaskNo()))
                .title(nvl(tdto.getTaskTitle()))
                .start(toIsoString(tdto.getStartDate()))           // null이면 자동 미포함
                .end(toIsoString(tdto.getEndDate()))               // null이면 자동 미포함
                .type("DEPT")                                     
                .detail(emptyToNull(tdto.getTaskDetail()))   
                .loc(null)// 공백 → null
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
    
    
    // ===== 부서일정 조회 (FullCalendar 이벤트 소스) =====    
    @ResponseBody
    @GetMapping("/events/dept")
    public List<CalendarEventDTO> listEvents2(
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
        
        String deptNo = login.getFk_dept_no();

        // 기간 파싱
        Timestamp tsStart = parseToTimestamp(start);
        Timestamp tsEnd   = parseToTimestamp(end);

        // 내 일정만
        List<TaskDTO> list = scheduleService.getSchedulesInRange2(tsStart, tsEnd, empNo, q, deptNo);
     
		List<CalendarEventDTO> result = list.stream()
										    .map(this::toEvent)
										    .collect(Collectors.toList());    		
	     return result;
    }
    
    
    
    // ===== 회사일정 조회 (전사 공개: dept '01') =====
    @ResponseBody
    @GetMapping("/events/comp")
    public List<CalendarEventDTO> listCompanyEvents(
            @RequestParam("start") String start,
            @RequestParam("end")   String end,
            @RequestParam(value = "q", required = false) String q,
            HttpSession session) {

        // 로그인만 확인(전사 공개이므로 부서/사번 조건 불필요)
        EmpDTO login = (session != null) ? (EmpDTO) session.getAttribute("loginuser") : null;
        if (login == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");

        Timestamp tsStart = parseToTimestamp(start);
        Timestamp tsEnd   = parseToTimestamp(end);

        // companyDeptNo = '01' (상수로 관리 추천)
        String companyDeptNo = "01";

        List<TaskDTO> list = scheduleService.getCompanyTasksInRange(tsStart, tsEnd, q, companyDeptNo);

        // type을 COMP로 내려줌
        return list.stream()
                .map(this::toEventCompany)
                .collect(Collectors.toList());
    }

    // 회사일정 전용 매핑기
    private CalendarEventDTO toEventCompany(TaskDTO tdto) {
        return CalendarEventDTO.builder()
                .id(nvl(tdto.getTaskNo()))
                .title(nvl(tdto.getTaskTitle()))
                .start(toIsoString(tdto.getStartDate()))
                .end(toIsoString(tdto.getEndDate()))
                .type("COMP")
                .detail(emptyToNull(tdto.getTaskDetail()))
                .loc(null)
                .build();
    }

    
    // ===== 검색 ===== //
    @ResponseBody
    @GetMapping("/search")
    public List<CalendarEventDTO> search(
            @RequestParam("q") String q,
            @RequestParam(value = "from",  required = false) String fromStr,
            @RequestParam(value = "to",    required = false) String toStr,
            @RequestParam(value = "types", required = false) String types,
            @RequestParam(value = "limit", required = false) Integer limit,
            HttpSession session) {

        // 로그인/사번/부서
        EmpDTO login = (session != null) ? (EmpDTO) session.getAttribute("loginuser") : null;
        if (login == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        String empNo  = login.getEmp_no();
        String deptNo = login.getFk_dept_no();
        if (isBlank(empNo)) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사번 정보를 확인할 수 없습니다.");

        // 검색어 필수
        if (isBlank(q)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "검색어(q)는 필수입니다.");
        q = q.trim();

        // 기간 파싱 (+ from > to 시 스왑)
        Timestamp from = (!isBlank(fromStr)) ? parseToTimestamp(fromStr) : null;
        Timestamp to   = (!isBlank(toStr))   ? parseToTimestamp(toStr)   : null;
        if (from != null && to != null && from.after(to)) {
            Timestamp tmp = from; from = to; to = tmp;
        }

        // 타입 파싱: 기본값 MY,DEPT / 대소문자·공백 정리
        java.util.Set<String> typeSet = new java.util.HashSet<>();
        if (!isBlank(types)) {
            for (String t : types.split(",")) {
                String v = (t == null ? "" : t.trim().toUpperCase());
                if (!v.isEmpty()) typeSet.add(v);
            }
        }
        if (typeSet.isEmpty()) {
            typeSet.add("MY"); 
            typeSet.add("DEPT"); 
            typeSet.add("COMP");
        }

        // 1) 개인일정
        List<ScheduleDTO> myList = Collections.emptyList();
        if (typeSet.contains("MY")) {
            myList = scheduleService.searchMySchedules(empNo, q, from, to);
        }

        // 2) 부서업무(부서매핑 OR access:dept OR access:emp)
        List<TaskDTO> deptList = Collections.emptyList();
        if (typeSet.contains("DEPT")) {
            deptList = scheduleService.searchDeptTasks(empNo, deptNo, q, from, to);
        }
        
        // 회사
        List<TaskDTO> compList = Collections.emptyList();
        if (typeSet.contains("COMP")) {
            String companyDeptNo = "01";
            compList = scheduleService.searchCompanyTasks(q, from, to, companyDeptNo);
        }

        // 병합
        List<CalendarEventDTO> result = new ArrayList<>();
        for (ScheduleDTO s : myList) {
            CalendarEventDTO ev = this.toEvent(s);
            if (ev.getType() == null || ev.getType().isBlank()) ev.setType("MY");
            result.add(ev);
        }
        for (TaskDTO t : deptList) {
            CalendarEventDTO ev = this.toEvent(t);
            if (ev.getType() == null || ev.getType().isBlank()) ev.setType("DEPT");
            result.add(ev);
        }
        for (TaskDTO t : compList) {
            CalendarEventDTO ev = this.toEventCompany(t); // COMP로 보장
            result.add(ev);
        }

       
        // 4) 정렬: 시작시각 → 제목 → id (null 안전)
        result.sort((a, b) -> {
            String sa = a.getStart() == null ? "" : a.getStart();
            String sb = b.getStart() == null ? "" : b.getStart();
            int cmp = sa.compareTo(sb);
            if (cmp != 0) return cmp;
            String ta = a.getTitle() == null ? "" : a.getTitle();
            String tb = b.getTitle() == null ? "" : b.getTitle();
            cmp = ta.compareTo(tb);
            if (cmp != 0) return cmp;
            String ia = a.getId() == null ? "" : a.getId();
            String ib = b.getId() == null ? "" : b.getId();
            return ia.compareTo(ib);
        });

        // 5) limit 적용(기본 100, 상한 1000)
        int max = (limit != null && limit > 0 && limit <= 1000) ? limit : 100;
        if (result.size() > max) {
            result = result.subList(0, max);
        }

        return result;
    }
    
    
    
}
