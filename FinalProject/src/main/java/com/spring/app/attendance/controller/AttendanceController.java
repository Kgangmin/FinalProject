package com.spring.app.attendance.controller;

import com.spring.app.attendance.domain.AttendanceDTO;
import com.spring.app.attendance.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Controller
@RequestMapping("/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    @GetMapping
    public String weekly(Model model,
                         @RequestParam(value = "weekStart", required = false) String weekStartStr,
                         Authentication authentication) {

        // Security 인증객체에서 로그인 사용자 정보 얻기
        String empNo = authentication.getName(); // ★ username을 empNo로 쓰도록 UserDetails 세팅했을 경우

        LocalDate weekStart = resolveWeekStart(weekStartStr);

        List<AttendanceDTO> records = attendanceService.getWeeklyRecords(empNo, weekStart);
        AttendanceDTO weekly = attendanceService.getWeeklySummary(empNo, weekStart);

        model.addAttribute("records", records);
        model.addAttribute("weekly", weekly);
        return "attendance/attendance"; // /WEB-INF/views/attendance/attendance.jsp
    }

    private LocalDate resolveWeekStart(String s) {
        if (s != null && !s.isBlank()) return LocalDate.parse(s);
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));
        int dow = today.getDayOfWeek().getValue(); // Mon=1..Sun=7
        return today.minusDays(dow - 1L);
    }
}