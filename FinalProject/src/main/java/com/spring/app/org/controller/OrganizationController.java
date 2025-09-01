// src/main/java/com/spring/app/org/controller/OrganizationController.java
package com.spring.app.org.controller;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;

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

    /** Highcharts Organization Chart용 JSON 데이터
     *  - rootDept가 없으면: 회사 전체 조직도(기존 동작 유지)
     *  - rootDept가 있으면: 해당 부서 루트 조직도(사진+이름 전용 라벨은 프런트에서 mode로 결정)
     */
    @GetMapping("/api/orgchart")
    @ResponseBody
    public Map<String, Object> getOrgChartData(
            @RequestParam(name = "rootDept", required = false) String rootDept) {

        if (rootDept == null || rootDept.isBlank()) {
            // 기존 회사 전체 조직도 (변경 없음)
            return organizationService.buildOrgChart();
        } else {
            // 신규: 특정 부서를 루트로 하는 서브트리 조직도
            return organizationService.buildOrgChartByDept(rootDept.trim());
        }
    }
}
