package com.spring.app.schedule.service;

import java.sql.Timestamp;
import java.util.List;
import com.spring.app.schedule.domain.ScheduleDTO;

public interface ScheduleService {
    List<ScheduleDTO> getSchedulesInRange(Timestamp start, Timestamp end, String empNo, String keyword);
}
