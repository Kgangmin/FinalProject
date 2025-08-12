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

    private final ScheduleDAO scheduleDAO;

    @Override
    public List<ScheduleDTO> getSchedulesInRange(Timestamp start, Timestamp end, String empNo, String keyword) {
        Map<String,Object> map = new HashMap<>();
        map.put("start", start);
        map.put("end", end);
        map.put("empNo", (empNo != null && !empNo.isBlank()) ? empNo : null);
        map.put("q", (keyword != null && !keyword.isBlank()) ? keyword : null);
        return scheduleDAO.selectSchedulesInRange(map);
    }
}
