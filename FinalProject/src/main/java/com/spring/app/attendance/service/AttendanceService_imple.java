package com.spring.app.attendance.service;

import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

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
    private static final SimpleDateFormat KEY_FMT = new SimpleDateFormat("yyyy-MM-dd");

    /* =========================
       배치: 자정에 당일 row 생성
       ========================= */
    @Transactional
    @Override
    public int generateFor(LocalDate workDate) {
        // DAO 호출 시 java.sql.Date 변환
        int n = attendanceDAO.insertDailyIfMissing(java.sql.Date.valueOf(workDate));
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
        AttendanceDTO dto = attendanceDAO.selectToday(empNo);
        if (dto != null && dto.getClockIn() != null && dto.getClockOut() == null) {
            // 출근만 한 경우 현재 시간 기준 근무시간 계산
            dto.setWorkSeconds(calculateWorkSeconds(dto.getClockIn(), new java.util.Date()));
        } else if (dto != null && dto.getClockIn() != null && dto.getClockOut() != null) {
            dto.setWorkSeconds(calculateWorkSeconds(dto.getClockIn(), dto.getClockOut()));
        } else if (dto != null) {
            dto.setWorkSeconds(0L);
        }
        return dto;
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
            attendanceDAO.insertDailyIfMissing(java.sql.Date.valueOf(LocalDate.now(KST)));
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
    private LocalDate mondayOf(LocalDate base) {
        return base.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    private LocalDate sundayOf(LocalDate base) {
        return mondayOf(base).plusDays(6);
    }

    @Override
    @Transactional(readOnly = true)
    public List<java.util.Date> getWeekDays(LocalDate base) {
        LocalDate mon = mondayOf(base);
        List<java.util.Date> days = new ArrayList<>(7);
        for (int i = 0; i < 7; i++) {
            days.add(java.sql.Date.valueOf(mon.plusDays(i))); // java.sql.Date는 java.util.Date 하위 타입
        }
        return days;
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, AttendanceDTO> getWeekMap(String empNo, LocalDate base) {
        LocalDate mon = mondayOf(base);
        LocalDate sun = sundayOf(base);

        List<AttendanceDTO> list = attendanceDAO.selectRange(
                empNo,
                java.sql.Date.valueOf(mon),
                java.sql.Date.valueOf(sun)
        );

        Map<String, AttendanceDTO> map = new LinkedHashMap<>();
        for (AttendanceDTO dto : list) {
            map.put(KEY_FMT.format(dto.getWorkDate()), dto); // workDate는 java.util.Date
        }
        return map;
    }

    @Override
    public java.util.Date getWeekStart(LocalDate base) {
        return java.sql.Date.valueOf(mondayOf(base));
    }

    @Override
    public java.util.Date getWeekEnd(LocalDate base) {
        return java.sql.Date.valueOf(sundayOf(base));
    }

    @Override
    public List<AttendanceDTO> getAttendanceList(String empNo) {
        List<AttendanceDTO> list = attendanceDAO.getAttendanceList(empNo);
        if (list == null) return new ArrayList<>();
        list.removeIf(Objects::isNull);

        for (AttendanceDTO dto : list) {
            if (dto.getClockIn() != null) {
                if (dto.getClockOut() != null) {
                    dto.setWorkSeconds(calculateWorkSeconds(dto.getClockIn(), dto.getClockOut()));
                } else {
                    dto.setWorkSeconds(calculateWorkSeconds(dto.getClockIn(), new java.util.Date()));
                }
            } else {
                dto.setWorkSeconds(0L);
            }
        }
        
        return list;
    }

    @Override
    public long calculateWorkSeconds(java.util.Date clockIn, java.util.Date clockOut) {
        LocalDateTime in = LocalDateTime.ofInstant(clockIn.toInstant(), KST);
        LocalDateTime out = LocalDateTime.ofInstant(clockOut.toInstant(), KST);

        long totalSeconds = Duration.between(in, out).getSeconds();

        // 점심시간 (12~13시) 차감
        LocalDateTime lunchStart = in.toLocalDate().atTime(12, 0);
        LocalDateTime lunchEnd   = in.toLocalDate().atTime(13, 0);

        if (!in.isAfter(lunchEnd) && !out.isBefore(lunchStart)) {
            long overlap = Duration.between(
                    in.isBefore(lunchStart) ? lunchStart : in,
                    out.isAfter(lunchEnd) ? lunchEnd : out
            ).getSeconds();
            totalSeconds -= Math.max(overlap, 0);
        }

        return Math.max(totalSeconds, 0);
    }

	@Override
	public void appendRemark(String empNo, LocalDate workDate, String entry)
	{
		int updated = attendanceDAO.appendRemark(empNo, java.sql.Date.valueOf(workDate), entry);
	}
}
