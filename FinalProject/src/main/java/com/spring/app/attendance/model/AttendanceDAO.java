package com.spring.app.attendance.model;

import com.spring.app.attendance.domain.AttendanceDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface AttendanceDAO {
    List<AttendanceDTO> selectDailyRange(@Param("empNo") String empNo,
                                         @Param("start") LocalDate start,
                                         @Param("end")   LocalDate end);

    AttendanceDTO selectWeeklyStats(@Param("empNo") String empNo,
                                    @Param("start") LocalDate start,
                                    @Param("end")   LocalDate end);
}