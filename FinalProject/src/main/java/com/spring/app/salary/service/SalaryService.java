package com.spring.app.salary.service;

import com.spring.app.salary.domain.SalaryDTO;

public interface SalaryService {
    SalaryDTO findByEmpNoAndYearMonth(String empNo, int year, int month);
}
