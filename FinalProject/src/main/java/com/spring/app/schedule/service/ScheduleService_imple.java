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


	// 내일정 검색
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


	// 부서일정(업무) 검색
	@Override
	public List<TaskDTO> searchDeptTasks(String empNo, String deptNo, String q, Timestamp from, Timestamp to) {
	    Map<String,Object> map = new java.util.HashMap<>();
	    map.put("empNo", empNo);
	    map.put("deptNo", deptNo);
	    map.put("q", q);
	    map.put("from", from);
	    map.put("to", to);
	    return dao.searchDeptTasks(map);
	}
	
	
	// 회사일정 불러오기
	@Override
	public List<TaskDTO> getCompanyTasksInRange(Timestamp tsStart, Timestamp tsEnd, String q, String companyDeptNo) {
	    Map<String,Object> p = new HashMap<>();
	    p.put("start", tsStart);
	    p.put("end", tsEnd);
	    p.put("q", q);
	    p.put("companyDeptNo", companyDeptNo);
	    return dao.selectCompanyTasksInRange(p);
	}

	
	// 회사일정 검색
	@Override
	public List<TaskDTO> searchCompanyTasks(String q, Timestamp from, Timestamp to, String companyDeptNo) {
	    Map<String,Object> p = new HashMap<>();
	    p.put("q", q);
	    p.put("from", from);
	    p.put("to", to);
	    p.put("companyDeptNo", companyDeptNo);
	    return dao.searchCompanyTasks(p);
	}

	
	
	
	
	
	
}
