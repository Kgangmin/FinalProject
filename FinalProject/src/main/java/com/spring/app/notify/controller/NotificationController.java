package com.spring.app.notify.controller;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spring.app.notify.domain.NotificationDTO;
import com.spring.app.notify.service.NotificationService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class NotificationController {

    private static final Logger log = LoggerFactory.getLogger(NotificationController.class);
    private final NotificationService service;

    @SuppressWarnings("unchecked")
    @GetMapping(value = "/api/notifications", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<NotificationDTO>> getNotifications(HttpServletRequest request) {
        try {
            HttpSession session = request.getSession(false);

            String empNo = null;
            String deptNo = null;

            // 1) 세션(loginEmp)에서 꺼내기
            if (session != null) {
                Object loginEmpObj = session.getAttribute("loginEmp");
                if (loginEmpObj != null) {
                    if (loginEmpObj instanceof Map) {
                        Map<String, Object> m = (Map<String, Object>) loginEmpObj;
                        Object empNoObj  = m.get("emp_no") != null ? m.get("emp_no") : m.get("empNo");
                        Object deptNoObj = m.get("fk_dept_no") != null ? m.get("fk_dept_no") : m.get("deptNo");
                        if (empNoObj  != null) empNo  = String.valueOf(empNoObj);
                        if (deptNoObj != null) deptNo = String.valueOf(deptNoObj);
                    } else {
                        try { empNo  = String.valueOf(loginEmpObj.getClass().getMethod("getEmp_no").invoke(loginEmpObj)); } catch (Exception ignore) {}
                        try { deptNo = String.valueOf(loginEmpObj.getClass().getMethod("getFk_dept_no").invoke(loginEmpObj)); } catch (Exception ignore) {}
                    }
                }
            }

            // 2) 보조: SecurityContext
            if (empNo == null || "null".equalsIgnoreCase(empNo)) {
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                if (auth != null && auth.isAuthenticated() && auth.getPrincipal() != null) {
                    try {
                        empNo = String.valueOf(auth.getPrincipal().getClass().getMethod("getEmpNo").invoke(auth.getPrincipal()));
                    } catch (Exception e) {
                        try { empNo = auth.getName(); } catch (Exception ignore) {}
                    }
                }
            }

            // 문자열 "null" / 공백 방지
            if (empNo != null && "null".equalsIgnoreCase(empNo)) empNo = null;
            if (deptNo != null && ("null".equalsIgnoreCase(deptNo) || deptNo.isBlank())) deptNo = null;

            if (empNo == null) {
                log.debug("notifications: empNo not found. return empty list.");
                return ResponseEntity.ok(Collections.emptyList());
            }

            String ctx = request.getContextPath();
            List<NotificationDTO> list = service.getNotifications(empNo, deptNo, ctx);
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            // 에러는 로그만 남기고 200 + 빈 리스트 반환(프론트에서 fail 안 타게)
            log.error("Failed to load notifications", e);
            return ResponseEntity.ok(Collections.emptyList());
        }
    }
}
