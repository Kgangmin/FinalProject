package com.spring.app.schedule.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.schedule.domain.ScheduleDTO;

@Mapper
public interface ScheduleDAO {
	
	// 일정 보여주기
	List<ScheduleDTO> selectSchedulesInRange(Map<String,Object> param);

    // 일정 등록하기
	int createSchedule(ScheduleDTO dto);

	// 일정 삭제하기
	int deleteScheduleByOwner(@Param("scheduleNo") String scheduleNo, // @Param 을 쓰면 mapper에서 바로 #{scheduleNo} 이렇게 쓸 수 있음
							  @Param("empNo")      String empNo);
	// 내 일정 수정하기
	int updateOwnSchedule(ScheduleDTO dto);
	
	
}
