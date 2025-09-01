package com.spring.app.salary.model;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.salary.domain.SalaryDTO;

@Mapper
public interface SalaryDAO {
    SalaryDTO selectByEmpNoAndYearMonth(@Param("empNo") String empNo,
                                        @Param("year") int year,
                                        @Param("month") int month);
}
