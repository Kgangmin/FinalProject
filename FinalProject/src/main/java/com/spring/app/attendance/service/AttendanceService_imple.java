package com.spring.app.attendance.service;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.app.attendance.domain.AttendanceDTO;
import com.spring.app.attendance.model.AttendanceDAO;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttendanceService_imple implements AttendanceService {

    private final AttendanceDAO attendanceDAO;

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    // 주간 맵 key 포맷 (JSP의 fmt:formatDate value="${d}" pattern="yyyy-MM-dd"와 맞춤)
    private static final SimpleDateFormat KEY_FMT = new SimpleDateFormat("yyyy-MM-dd");

    /* =========================
       배치: 자정에 당일 row 생성
       ========================= */
    @Transactional
    @Override
    public int generateFor(LocalDate workDate) {
        int n = attendanceDAO.insertDailyIfMissing(Date.valueOf(workDate));
        log.info("[ATT-BATCH] {} 생성: {}건", workDate, n);
        return n;
    }

    @Transactional
    @Override
    public int generateToday() {
        LocalDate today = LocalDate.now(KST);
        return generateFor(today);
    }

    /* =========================
       단건 조회: 오늘
       ========================= */
    @Override
    @Transactional(readOnly = true)
    public AttendanceDTO getToday(String empNo) {
        return attendanceDAO.selectToday(empNo);
    }

    /* =========================
       출근/퇴근 처리
       ========================= */
    @Transactional
    @Override
    public void clockIn(String empNo) {
        int n = attendanceDAO.updateClockIn(empNo);
        if (n == 0) {
            // 오늘 레코드가 없으면 생성 후 한 번 더 시도
            attendanceDAO.insertDailyIfMissing(Date.valueOf(LocalDate.now(KST)));
            n = attendanceDAO.updateClockIn(empNo);
            if (n == 0) {
                throw new IllegalStateException("이미 출근 처리되었거나 오늘 레코드가 없습니다.");
            }
        }
    }

    @Transactional
    @Override
    public void clockOut(String empNo) {
        int n = attendanceDAO.updateClockOut(empNo);
        if (n == 0) {
            throw new IllegalStateException("출근 전이거나 이미 퇴근 처리되었습니다.");
        }
    }

    /* =========================
       주간 달력/요약 데이터
       ========================= */

    // 기준일의 '해당 주의 월요일'
    private LocalDate mondayOf(LocalDate base) {
        return base.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    // 기준일의 '해당 주의 일요일'
    private LocalDate sundayOf(LocalDate base) {
        return mondayOf(base).plusDays(6);
    }

    /** 주간 달력에 뿌릴 7일 날짜 (java.util.Date) */
    @Override
    @Transactional(readOnly = true)
    public List<java.util.Date> getWeekDays(LocalDate base) {
        LocalDate mon = mondayOf(base);
        List<java.util.Date> days = new ArrayList<>(7);
        for (int i = 0; i < 7; i++) {
            days.add(Date.valueOf(mon.plusDays(i))); // java.sql.Date는 java.util.Date의 하위타입이라 JSP에서 그대로 사용 가능
        }
        return days;
    }

    /** 주간 근태 맵: key = "yyyy-MM-dd", value = AttendanceDTO */
    @Override
    @Transactional(readOnly = true)
    public Map<String, AttendanceDTO> getWeekMap(String empNo, LocalDate base) {
        LocalDate mon = mondayOf(base);
        LocalDate sun = sundayOf(base);

        List<AttendanceDTO> list = attendanceDAO.selectRange(
                empNo,
                Date.valueOf(mon),
                Date.valueOf(sun)
        );

        Map<String, AttendanceDTO> map = new LinkedHashMap<>();
        for (AttendanceDTO dto : list) {
            String key = KEY_FMT.format(dto.getWorkDate()); // DTO의 workDate는 java.util.Date
            map.put(key, dto);
        }
        return map;
    }

    /** 상단 네비: 주 시작일 */
    @Override
    public java.util.Date getWeekStart(LocalDate base) {
        return Date.valueOf(mondayOf(base));
    }

    /** 상단 네비: 주 종료일 */
    @Override
    public java.util.Date getWeekEnd(LocalDate base) {
        return Date.valueOf(sundayOf(base));
    }
}
