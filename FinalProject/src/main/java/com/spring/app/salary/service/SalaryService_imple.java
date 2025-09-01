package com.spring.app.salary.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.app.salary.domain.SalaryDTO;
import com.spring.app.salary.model.SalaryDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SalaryService_imple implements SalaryService {

    private final SalaryDAO salaryDAO;

    @Override
    @Transactional(readOnly = true)
    public SalaryDTO findByEmpNoAndYearMonth(String empNo, int year, int month) {
        return salaryDAO.selectByEmpNoAndYearMonth(empNo, year, month);
    }
}
