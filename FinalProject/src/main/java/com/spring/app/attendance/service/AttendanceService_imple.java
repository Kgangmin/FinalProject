package com.spring.app.attendance.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.stereotype.Service;

import com.spring.app.attendance.domain.AttendanceDTO;
import com.spring.app.attendance.model.AttendanceDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AttendanceService_imple implements AttendanceService {

    private final AttendanceDAO attendanceDAO;

    private static final int REQUIRED_MINUTES_DEFAULT = 40 * 60; // 2400

    @Override
    public List<AttendanceDTO> getWeeklyRecords(String empNo, LocalDate weekStart) {
        return attendanceDAO.selectDailyRange(empNo, weekStart, weekStart.plusDays(6));
    }

    @Override
    public AttendanceDTO getWeeklySummary(String empNo, LocalDate weekStart) {
        AttendanceDTO sum = attendanceDAO.selectWeeklyStats(empNo, weekStart, weekStart.plusDays(6));
        if (sum == null) sum = new AttendanceDTO();
        int required = (sum.getRequiredMinutes() != null) ? sum.getRequiredMinutes() : REQUIRED_MINUTES_DEFAULT;
        int worked   = (sum.getWorkedMinutes()   != null) ? sum.getWorkedMinutes()   : 0;

        int pct = (required > 0) ? Math.min(100, (int)Math.round(worked * 100.0 / required)) : 0;

        LocalDate end = weekStart.plusDays(6);
        String label = weekStart.format(DateTimeFormatter.ISO_DATE) + " ~ " + end.format(DateTimeFormatter.ISO_DATE);

        sum.setRequiredMinutes(required);
        sum.setPct(pct);
        sum.setWeekLabel(label);
        return sum;
    }
}