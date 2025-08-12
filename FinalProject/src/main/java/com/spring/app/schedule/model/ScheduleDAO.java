package com.spring.app.schedule.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.schedule.domain.ScheduleDTO;

@Mapper
public interface ScheduleDAO {
    List<ScheduleDTO> selectSchedulesInRange(Map<String, Object> paramMap);
}
