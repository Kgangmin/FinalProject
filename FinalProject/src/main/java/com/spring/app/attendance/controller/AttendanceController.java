package com.spring.app.attendance.controller;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.app.attendance.domain.AttendanceDTO;
import com.spring.app.attendance.service.AttendanceService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/attendance")
@RequiredArgsConstructor
public class AttendanceController
{
	private final AttendanceService attendanceService;
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_DATE;
    
	// 근태 메인 화면
    @GetMapping("")
    public String attendanceMain(Model model,
                                 @AuthenticationPrincipal UserDetails empDetails,
                                 @RequestParam(value = "nav", required = false) String nav,
                                 HttpSession session) {

    	LocalDate today = LocalDate.now(KST);
    	
        // 1) 기준일(base) 결정: 세션에 저장해 두고 nav로 이동
        // nav 파라미터 없으면 무조건 오늘로 리셋
        LocalDate base;
        if (nav == null) {
            base = today;
            session.setAttribute("attBase", base);
        } else {
            base = (LocalDate) session.getAttribute("attBase");
            if (base == null) base = today;

            if ("prev".equalsIgnoreCase(nav)) {
                base = base.minusWeeks(1);
            } else if ("next".equalsIgnoreCase(nav)) {
                base = base.plusWeeks(1);
            } else if ("today".equalsIgnoreCase(nav)) {
                base = today;
            }
            session.setAttribute("attBase", base);
        }

        // 2) 로그인 사번
        String empNo = empDetails.getUsername();

        // 3) 오늘 근태
        AttendanceDTO todayAtt = attendanceService.getToday(empNo);
        model.addAttribute("todayAtt", todayAtt);

        // 4) 주간 달력/맵/기간 (base 기준 주)
        List<Date> weekDays = attendanceService.getWeekDays(base);
        model.addAttribute("weekDays", weekDays);

        Map<String, AttendanceDTO> attByDate = attendanceService.getWeekMap(empNo, base);
        model.addAttribute("attByDate", attByDate);

        model.addAttribute("todayKey", today.format(DateTimeFormatter.ISO_DATE)); // '오늘' 표시는 현재 날짜
        model.addAttribute("weekStart", attendanceService.getWeekStart(base));
        model.addAttribute("weekEnd",   attendanceService.getWeekEnd(base));

        // ===== 카드용 집계 =====
        long totalActualSeconds = 0L; // ✅ 코어타임(09~18)과 '겹치는 구간'만 합산
        int workedDays = 0;

        if (attByDate != null) {
            for (AttendanceDTO dto : attByDate.values()) {
                if (dto == null || dto.getClockIn() == null) continue;

                // 퇴근 전이면 "현재 시각"까지로 집계 (LocalDateTime 미사용)
                Date effectiveOut = (dto.getClockOut() != null)
                        ? dto.getClockOut()
                        : Date.from(java.time.ZonedDateTime.now(KST).toInstant());

                // 출근~퇴근 구간을 KST 기준으로 변환
                java.time.ZonedDateTime start = dto.getClockIn().toInstant().atZone(KST);
                java.time.ZonedDateTime end   = effectiveOut.toInstant().atZone(KST);
                if (end.isAfter(start)) {
                    // 시작일 ~ 종료일까지 하루씩 순회하며, 각 날짜의 09:00~18:00(코어타임)과의 '겹치는 부분'만 합산
                	for (LocalDate d = start.toLocalDate(); !d.isAfter(end.toLocalDate()); d = d.plusDays(1)) {
                	    ZonedDateTime coreStart = d.atTime(9, 0).atZone(KST);
                	    ZonedDateTime coreEnd   = d.atTime(18, 0).atZone(KST);

                	    ZonedDateTime s = start.isAfter(coreStart) ? start : coreStart;
                	    ZonedDateTime e = end.isBefore(coreEnd)     ? end   : coreEnd;

                	    if (e.isAfter(s)) {
                	        long sec = Duration.between(s, e).getSeconds();

                	        // ⏱ 점심 12:00~13:00 겹친 만큼 차감
                	        ZonedDateTime lunchS = d.atTime(12, 0).atZone(KST);
                	        ZonedDateTime lunchE = d.atTime(13, 0).atZone(KST);
                	        ZonedDateTime ls = s.isAfter(lunchS) ? s : lunchS;
                	        ZonedDateTime le = e.isBefore(lunchE) ? e : lunchE;
                	        if (le.isAfter(ls)) {
                	            sec -= Duration.between(ls, le).getSeconds();
                	        }

                	        if (sec > 0) totalActualSeconds += sec;
                	    }
                	}

                }

                if (dto.getClockOut() != null) {
                    workedDays++;
                }
            }
        }

        // 목표시간: 주 5일 × 8시간 (필요 시 "해당 주 평일 수 × 8h"로 대체 가능)
        long targetSeconds = 5L * 8L * 3600L;
        double actualHours = totalActualSeconds / 3600.0;
        double targetHours = targetSeconds      / 3600.0;

        // 잔여 근로시간(= 목표 − 누적), 음수 방지
        double remainHours = Math.max(0.0, targetHours - actualHours);

        // 진행 퍼센트
        int pct = (targetSeconds > 0)
                ? (int) Math.min(100, Math.round(100.0 * totalActualSeconds / targetSeconds))
                : 0;

        // 잔여 근무일: 이번 주 '오늘 이후' 평일 수 (월~금), 표시 주는 base 기준
        int futureRemainDays = 0;
        LocalDate wMon = base.with(java.time.temporal.TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate wSun = wMon.plusDays(6);

        // 선택 주가 이미 과거라면 0
        if (wSun.isBefore(today)) {
            futureRemainDays = 0;
        } else {
            // 선택 주가 미래면 월요일부터, 현재 주면 '내일'부터 센다
            LocalDate startCount = (wMon.isAfter(today)) ? wMon : today.plusDays(1);
            LocalDate endCount   = wSun;

            for (LocalDate d = startCount; !d.isAfter(endCount); d = d.plusDays(1)) {
                DayOfWeek dow = d.getDayOfWeek();
                if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY) {
                    futureRemainDays++;
                }
            }
        }

        // 5) 모델 바인딩
        model.addAttribute("actualSeconds", totalActualSeconds);
        model.addAttribute("targetSeconds", targetSeconds);
        model.addAttribute("workedDays", workedDays);
        model.addAttribute("actualHours", actualHours);
        model.addAttribute("targetHours", targetHours);
        model.addAttribute("remainHours", remainHours);
        model.addAttribute("pct", pct);
        model.addAttribute("futureRemainDays", futureRemainDays);

        return "attendance/attendance";
    }
    
    @PostMapping("/remark")
    @ResponseBody
    public ResponseEntity<Void> appendRemark(@AuthenticationPrincipal UserDetails empDetails,
                                             @RequestParam("remark") String remark) {
        if (remark == null || remark.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        final String empNo = empDetails.getUsername();
        final ZonedDateTime nowKst = ZonedDateTime.now(KST);
        final String ts = DateTimeFormatter.ofPattern("HH:mm").format(nowKst);
        final String entry = "[" + ts + "] " + remark.trim();   // 타임스탬프 + 내용

        attendanceService.appendRemark(empNo, nowKst.toLocalDate(), entry);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/clock-in")
    @ResponseBody
    public ResponseEntity<?> clockIn(@AuthenticationPrincipal UserDetails user) {
        attendanceService.clockIn(user.getUsername());
        return ResponseEntity.ok().build(); // 200 OK
    }

    @PostMapping("/clock-out")
    @ResponseBody
    public ResponseEntity<?> clockOut(@AuthenticationPrincipal UserDetails user) {
        attendanceService.clockOut(user.getUsername());
        return ResponseEntity.ok().build();
    }
}