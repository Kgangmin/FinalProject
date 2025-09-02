package com.spring.app.attendance.model;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.attendance.domain.AttendanceDTO;

@Mapper
public interface AttendanceDAO
{
	int insertDailyIfMissing(@Param("workDate") Date workDate);

	AttendanceDTO selectToday(String empNo);
	
	int updateClockIn(@Param("empNo") String empNo);

    int updateClockOut(@Param("empNo") String empNo);
    
    List<AttendanceDTO> selectRange(@Param("empNo") String empNo,
            @Param("start") Date start,
            @Param("end")   Date end);
}