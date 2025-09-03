package com.spring.app.memo.controller;

import java.util.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.memo.domain.MemoPadDTO;
import com.spring.app.memo.service.MemoService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/memo")
@RequiredArgsConstructor
public class MemoController {

    private static final Logger log = LoggerFactory.getLogger(MemoController.class);

    private final MemoService memoService;

    /** 세션에서 사번을 안전하게 꺼냄 */
    private String currentEmpNo(HttpSession session) {
        if (session == null) {
            log.debug("[memo] no HttpSession");
            return null;
        }

        // 프로젝트 전체에서 쓰는 세션 키 확인: loginEmp 우선, 없으면 loginuser도 시도
        Object attr = session.getAttribute("loginEmp");
        if (attr == null) attr = session.getAttribute("loginuser");
        if (!(attr instanceof EmpDTO)) {
            log.debug("[memo] session has no EmpDTO (keys: loginEmp/loginuser)");
            return null;
        }
        EmpDTO u = (EmpDTO) attr;

        // 필드/게터 명이 환경마다 다른 경우를 모두 케어
        String empNo = null;
        try {
            // camelCase
            if (u.getEmp_no() != null && !u.getEmp_no().isBlank()) empNo = u.getEmp_no();
        } catch (Throwable ignore) {}
        try {
            // snake_case
            if (empNo == null && u.getEmp_no() != null && !u.getEmp_no().isBlank()) empNo = u.getEmp_no();
        } catch (Throwable ignore) {}

        if (empNo == null || empNo.isBlank()) {
            log.debug("[memo] EmpDTO found but empNo is null/blank");
            return null;
        }
        return empNo;
    }

    private ResponseEntity<?> unauthorized(String why) {
        return ResponseEntity.status(401).body(Map.of("ok", false, "code", "UNAUTHORIZED", "why", why));
    }

    @GetMapping("/pads")
    public ResponseEntity<?> list(HttpSession session) {
        String empNo = currentEmpNo(session);
        if (empNo == null) return unauthorized("no-empNo-in-session");
        List<MemoPadDTO> list = memoService.listMine(empNo);
        return ResponseEntity.ok(Map.of("ok", true, "list", list));
    }

    @Data static class CreateReq { String title; }
    @PostMapping("/pads")
    public ResponseEntity<?> create(@RequestBody(required=false) CreateReq req, HttpSession session) {
        String empNo = currentEmpNo(session);
        if (empNo == null) return unauthorized("no-empNo-in-session");
        String title = (req == null ? null : req.getTitle());
        MemoPadDTO created = memoService.createPad(empNo, title);
        return ResponseEntity.ok(Map.of("ok", true, "pad", created));
    }

    @Data static class SaveReq { String title; String content; }
    @PutMapping("/pads/{padId}")
    public ResponseEntity<?> save(@PathVariable("padId") Long padId, @RequestBody SaveReq req, HttpSession session) {
        String empNo = currentEmpNo(session);
        if (empNo == null) return unauthorized("no-empNo-in-session");
        memoService.savePad(empNo, padId,
            (req == null || req.title == null) ? "" : req.title,
            (req == null || req.content == null) ? "" : req.content);
        return ResponseEntity.ok(Map.of("ok", true));
    }

    @Data static class OrderReq { List<Long> padIds; }
    @PutMapping("/pads/order")
    public ResponseEntity<?> reorder(@RequestBody OrderReq req, HttpSession session) {
        String empNo = currentEmpNo(session);
        if (empNo == null) return unauthorized("no-empNo-in-session");
        memoService.reorder(empNo, (req == null ? List.of() : req.padIds));
        return ResponseEntity.ok(Map.of("ok", true));
    }

    @DeleteMapping("/pads/{padId}")
    public ResponseEntity<?> delete(@PathVariable("padId") Long padId, HttpSession session) {
        String empNo = currentEmpNo(session);
        if (empNo == null) return unauthorized("no-empNo-in-session");
        memoService.remove(empNo, padId);
        return ResponseEntity.ok(Map.of("ok", true));
    }
}
