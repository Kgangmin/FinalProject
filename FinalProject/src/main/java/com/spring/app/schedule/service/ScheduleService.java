package com.spring.app.schedule.service;

import java.sql.Timestamp;
import java.util.List;
import com.spring.app.schedule.domain.ScheduleDTO;

public interface ScheduleService {
    List<ScheduleDTO> getSchedulesInRange(Timestamp start, Timestamp end, String empNo, String keyword);

    // 일정 등록하기
	int createSchedule(ScheduleDTO dto);

	// 내 일정 삭제하기
	int deleteOwnSchedule(String scheduleNo, String empNo);

	// 내 일정 수정하기
	int updateOwnSchedule(ScheduleDTO dto);
}
