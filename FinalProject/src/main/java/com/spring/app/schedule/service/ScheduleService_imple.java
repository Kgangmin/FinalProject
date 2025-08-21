package com.spring.app.schedule.service;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.spring.app.schedule.domain.ScheduleDTO;
import com.spring.app.schedule.domain.TaskDTO;
import com.spring.app.schedule.model.ScheduleDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ScheduleService_imple implements ScheduleService {

    private final ScheduleDAO dao;

    // 개인일정 보여주기
    @Override
    public List<ScheduleDTO> getSchedulesInRange(Timestamp start, Timestamp end, String empNo, String q) {
        Map<String,Object> param = new HashMap<>();
        param.put("start", start);
        param.put("end", end);
        param.put("empNo", empNo);  
        param.put("q", q);
        return dao.selectSchedulesInRange(param);
    }

    
    // 일정 등록하기
	@Override
	public int createSchedule(ScheduleDTO dto) {
		
		return dao.createSchedule(dto);		
	}


	// 일정 삭제하기
	@Override
    public int deleteOwnSchedule(String scheduleNo, String empNo) {
        return dao.deleteScheduleByOwner(scheduleNo, empNo);
    }


	// 내 일정 수정하기
	@Override
	public int updateOwnSchedule(ScheduleDTO dto) {
		return dao.updateOwnSchedule(dto);
	}


	// 검색결과 리스트
	@Override
	public List<ScheduleDTO> searchMySchedules(String empNo, String q, Timestamp from, Timestamp to) {
		return dao.selectSearchResults(empNo, q, from, to);
	}


	// 부서일정(업무) 불러오기
	@Override
	public List<TaskDTO> getSchedulesInRange2(Timestamp tsStart, Timestamp tsEnd, String empNo, String q,
											  String deptNo) {
		
		Map<String,Object> param = new HashMap<>();
        param.put("start", tsStart);
        param.put("end", tsEnd);
        param.put("empNo", empNo);  
        param.put("q", q);
        param.put("deptNo", deptNo);
        return dao.selectSchedulesInRange2(param);	
	}
	
	
	

	
	
	
	
	
	
}
