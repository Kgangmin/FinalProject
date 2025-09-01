package com.spring.app.salary.domain;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class SalaryDTO {
    private String sal_no;
    private String fk_emp_no;
    private String sal_year;
    private String sal_month;
    private String base_sal;
    private String bonus;
    private String deduction;
    private String net_pay; // virtual column
    private String remark;
}
