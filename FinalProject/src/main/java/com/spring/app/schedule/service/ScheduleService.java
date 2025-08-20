package com.spring.app.schedule.service;

import java.sql.Timestamp;
import java.util.List;

import com.spring.app.schedule.domain.ScheduleDTO;
import com.spring.app.schedule.domain.TaskDTO;

public interface ScheduleService {
	// 개인일정 불러오기
    List<ScheduleDTO> getSchedulesInRange(Timestamp start, Timestamp end, String empNo, String keyword);

    // 일정 등록하기
	int createSchedule(ScheduleDTO dto);

	// 내 일정 삭제하기
	int deleteOwnSchedule(String scheduleNo, String empNo);

	// 내 일정 수정하기
	int updateOwnSchedule(ScheduleDTO dto);

	// 검색결과 리스트
	List<ScheduleDTO> searchMySchedules(String empNo, String q, Timestamp from, Timestamp to);

	// 부서일정(업무) 불러오기
	List<TaskDTO> getSchedulesInRange2(Timestamp tsStart, Timestamp tsEnd, String empNo, String q, String deptNo);
	

	
	
}
