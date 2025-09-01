// src/main/java/com/spring/app/org/service/OrganizationService.java
package com.spring.app.org.service;

import java.util.Map;

public interface OrganizationService {
    /** Highcharts Organization Chart 시리즈에 바로 넣을 수 있는 JSON 제작 (회사 전체) */
    Map<String, Object> buildOrgChart();

    /** 특정 부서를 루트로 하는 조직도(JSON) - 10/20/30/40/50 등 */
    Map<String, Object> buildOrgChartByDept(String rootDeptNo);
}
