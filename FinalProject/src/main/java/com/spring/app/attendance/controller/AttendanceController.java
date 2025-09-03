package com.spring.app.attendance.controller;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.Date;
import java.util.List;
import java.util.Map;


import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.app.attendance.domain.AttendanceDTO;
import com.spring.app.attendance.service.AttendanceService;
import com.spring.app.emp.domain.EmpDTO;

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

        // 1) 기준일(base) 결정: 세션에 저장해 두고 nav로 이동
        LocalDate today = LocalDate.now(KST);
        LocalDate base = (LocalDate) session.getAttribute("attBase");
        if (base == null) base = today; // 최초 진입은 오늘 기준

        if ("prev".equalsIgnoreCase(nav)) {
            base = base.minusWeeks(1);
        } else if ("next".equalsIgnoreCase(nav)) {
            base = base.plusWeeks(1);
        } else if ("today".equalsIgnoreCase(nav)) {
            base = today;
        }
        session.setAttribute("attBase", base); // 현재 화면의 기준 주 저장

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
        long totalActualSeconds = 0L;
        int workedDays = 0;

        if (attByDate != null) {
            for (AttendanceDTO dto : attByDate.values()) {
                if (dto == null) continue;
                if (dto.getClockIn() != null && dto.getClockOut() != null) {
                    workedDays++;
                    totalActualSeconds += attendanceService.calculateWorkSeconds(dto.getClockIn(), dto.getClockOut());
                }
            }
        }

        long targetSeconds = 5L * 8L * 3600L; // 주 5일 × 8시간
        double actualHours = totalActualSeconds / 3600.0;
        double targetHours = targetSeconds      / 3600.0;

        // 잔여 근로시간(= 40h - 누적)
        double remainHours = Math.max(0.0, targetHours - actualHours);

        // 진행 퍼센트
        int pct = (targetSeconds > 0)
                ? (int) Math.min(100, Math.round(100.0 * totalActualSeconds / targetSeconds))
                : 0;

        // 잔여 근무일: 이번 주 '오늘 이후' 평일 수 (월~금), 표시 주는 base 기준
        int futureRemainDays = 0;
        LocalDate wMon = base.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate wSun = wMon.plusDays(6);

        // 선택 주가 이미 과거라면 0
        if (wSun.isBefore(today)) {
            futureRemainDays = 0;
        } else {
            // 선택 주가 미래면 월요일부터, 현재 주면 '내일'부터 센다
            LocalDate start = (wMon.isAfter(today)) ? wMon : today.plusDays(1);
            LocalDate end   = wSun;

            for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
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