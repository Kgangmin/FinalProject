package com.spring.app.schedule.service;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.spring.app.schedule.domain.ScheduleDTO;
import com.spring.app.schedule.model.ScheduleDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ScheduleService_imple implements ScheduleService {

    private final ScheduleDAO dao;

    // 일정 보여주기
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
	
	
	
	
	
	
}
