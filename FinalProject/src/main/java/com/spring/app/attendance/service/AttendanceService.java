package com.spring.app.attendance.service;

import com.spring.app.attendance.domain.AttendanceDTO;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceService {
    List<AttendanceDTO> getWeeklyRecords(String empNo, LocalDate weekStart);
    AttendanceDTO getWeeklySummary(String empNo, LocalDate weekStart);
}