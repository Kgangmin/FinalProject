package com.spring.app.attendance.scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.spring.app.attendance.service.AttendanceService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
public class AttendanceDailyScheduler {

    private final AttendanceService service;

    /** 매일 00:00 KST (부하가 있다면 00:05로 바꿔도 좋음) */
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    public void runAtMidnight() {
        int n = service.generateToday();
        log.info("[ATT-SCHED] 자정 배치 완료 - {}건", n);
    }
}