// src/main/java/com/spring/app/org/controller/OrganizationController.java
package com.spring.app.org.controller;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.app.org.service.OrganizationService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/org")
public class OrganizationController {

    private final OrganizationService organizationService;

    /** 조직도 화면 */
    @GetMapping("/organization")
    public String organizationView() {
        // /WEB-INF/views/org/organization.jsp
        return "org/organization";
    }

    /** Highcharts Organization Chart용 JSON 데이터 */
    @GetMapping("/api/orgchart")
    @ResponseBody
    public Map<String, Object> getOrgChartData() {
        // { ok, root, edges, nodes } 형태
        return organizationService.buildOrgChart();
    }
}
