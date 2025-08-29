// src/main/java/com/spring/app/org/service/OrganizationService.java
package com.spring.app.org.service;

import java.util.Map;

public interface OrganizationService {
    /** Highcharts Organization Chart 시리즈에 바로 넣을 수 있는 JSON 제작 */
	Map<String, Object> buildOrgChart();
}
