package com.spring.app.attendance.controller;

import java.time.LocalDate;
import java.time.ZoneId;
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
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.app.attendance.domain.AttendanceDTO;
import com.spring.app.attendance.service.AttendanceService;

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
    public String attendanceMain(Model model
    							,@AuthenticationPrincipal UserDetails empDetails)
    {
        // 필요한 데이터 있으면 model.addAttribute("키", 값) 해서 JSP로 전달
        // 예: model.addAttribute("weekStart", ...);

    	String empNo = empDetails.getUsername();
    	LocalDate base = LocalDate.now(KST); // 오늘(기준일)
    	
    	AttendanceDTO todayAtt = attendanceService.getToday(empNo);
        model.addAttribute("todayAtt", todayAtt);
        
     // 주간 달력(월~일 7개)
        List<Date> weekDays = attendanceService.getWeekDays(base);
        model.addAttribute("weekDays", weekDays);

        // 주간 근태 맵: "yyyy-MM-dd" -> AttendanceDTO
        Map<String, AttendanceDTO> attByDate = attendanceService.getWeekMap(empNo, base);
        model.addAttribute("attByDate", attByDate);

        // 오늘 키 (JSP에서 weekDays를 "yyyy-MM-dd"로 포맷해서 키로 씀)
        model.addAttribute("todayKey", base.format(ISO));

        // 상단 네비용 기간
        model.addAttribute("weekStart", attendanceService.getWeekStart(base));
        model.addAttribute("weekEnd",   attendanceService.getWeekEnd(base));
    	
        return "attendance/attendance"; 
        // => /WEB-INF/views/attendance/attendance.jsp 로 forward 됨
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