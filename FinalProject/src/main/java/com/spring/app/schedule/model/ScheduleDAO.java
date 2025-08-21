package com.spring.app.schedule.model;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.schedule.domain.ScheduleDTO;
import com.spring.app.schedule.domain.TaskDTO;

@Mapper
public interface ScheduleDAO {
	
	// 개인일정 보여주기
	List<ScheduleDTO> selectSchedulesInRange(Map<String,Object> param);

    // 일정 등록하기
	int createSchedule(ScheduleDTO dto);

	// 일정 삭제하기
	int deleteScheduleByOwner(@Param("scheduleNo") String scheduleNo, // @Param 을 쓰면 mapper에서 바로 #{scheduleNo} 이렇게 쓸 수 있음
							  @Param("empNo")      String empNo);
	// 내 일정 수정하기
	int updateOwnSchedule(ScheduleDTO dto);

	// 내일정 검색
	List<ScheduleDTO> selectSearchResults(@Param("empNo") String empNo,
							              @Param("q") String q,
							              @Param("from") Timestamp from,
							              @Param("to") Timestamp to);

	// 부서일정(업무) 불러오기
	List<TaskDTO> selectSchedulesInRange2(Map<String, Object> param);

	// 부서일정(업무) 검색
	List<TaskDTO> searchDeptTasks(Map<String, Object> map);
	
	// 회사일정 불러오기 
	List<TaskDTO> selectCompanyTasksInRange(Map<String, Object> param);
	
	// 회사일정 검색
	List<TaskDTO> searchCompanyTasks(Map<String, Object> param);
	
	
}
