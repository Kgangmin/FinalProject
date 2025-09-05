package com.spring.app.dashboard.controller;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;
import com.spring.app.dashboard.domain.WidgetSaveRequest;
import com.spring.app.dashboard.service.DashboardWidgetService;
import com.spring.app.emp.domain.EmpDTO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/dashboard/widgets")
public class DashboardWidgetController {

    private final DashboardWidgetService service;

    /** 로그인 사용자 사번 필수 */
    private String requireEmpNo(HttpSession session){
        EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
        if (loginuser == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        return loginuser.getEmp_no();
    }

    /** 레이아웃 조회 (VISIBLE_YN 포함 반환) */
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String,Object> list(HttpSession session){
        String empNo = requireEmpNo(session);
        List<WidgetLayoutDTO> list = service.list(empNo);

        Map<String,Object> res = new LinkedHashMap<>();
        res.put("ok", true);
        res.put("list", list);
        return res;
    }

    /** 레이아웃 저장 (숨김/보임 상태 포함) */
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String,Object> save(@RequestBody WidgetSaveRequest req, HttpSession session){
        String empNo = requireEmpNo(session);

        if (req == null || req.getWidgets() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "요청 바디가 비었습니다.");
        }

        // 중복 widgetId는 "마지막 값" 우선
        Map<String, WidgetLayoutDTO> dedup = new LinkedHashMap<>();

        // ✅ 요소 타입을 WidgetSaveRequest.Item 으로 받습니다.
        for (WidgetSaveRequest.Item it : req.getWidgets()) {
            if (it == null) continue;
            String widgetId = trimToNull(it.getWidgetId());
            if (widgetId == null) continue;

            // 기본/보정값 설정
            Integer posX  = nonNegativeOrNull(it.getX());
            Integer posY  = nonNegativeOrNull(it.getY());
            Integer sizeW = minBound(nonNegativeOrNull(it.getWidth()), 240); // JS MIN_W=240
            Integer sizeH = minBound(nonNegativeOrNull(it.getHeight()), 160); // JS MIN_H=160

            // 프론트에서 visibleYn을 보낼 수도 있고 아닐 수도 있으니 기본 'Y'
            String visibleYn = normalizeYN(it.getVisibleYn()); // 없으면 'Y'

            WidgetLayoutDTO normalized = WidgetLayoutDTO.builder()
                    .empNo(empNo)
                    .widgetId(widgetId)
                    .posX(posX)
                    .posY(posY)
                    .sizeW(sizeW)
                    .sizeH(sizeH)
                    .visibleYn(visibleYn)
                    // grid 계열은 보존
                    .gridCol(it.getCol())
                    .gridRow(it.getRow())
                    .gridW(it.getW())
                    .gridH(it.getH())
                    .build();

            dedup.put(widgetId, normalized);
        }

        List<WidgetLayoutDTO> toSave = new ArrayList<>(dedup.values());
        int updated = 0;
        if (!toSave.isEmpty()) {
            // ⚠️ 서비스 시그니처가 List<WidgetLayoutDTO>로 수정돼 있어야 합니다.
            updated = service.saveAll(empNo, toSave);
        }

        Map<String,Object> res = new LinkedHashMap<>();
        res.put("ok", true);
        res.put("updated", updated);
        return res;
    }


    /* -------------------- 내부 유틸 -------------------- */

    private static String trimToNull(String s) {
        if (!StringUtils.hasText(s)) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    /** null 허용, 음수면 0으로 보정 */
    private static Integer nonNegativeOrNull(Integer v) {
        if (v == null) return null;
        return (v < 0) ? 0 : v;
        // 필요 시 상한도 추가 가능 (예: Math.min(v, 20000))
    }

    /** 최소 하한 보정 (v가 null이면 null 유지) */
    private static Integer minBound(Integer v, int min) {
        if (v == null) return null;
        return (v < min) ? min : v;
    }

    /** 'Y'/'N'만 허용, 그 외/null/공백 ⇒ 'Y' */
    private static String normalizeYN(String v) {
        if (!StringUtils.hasText(v)) return "Y";
        String u = v.trim().toUpperCase();
        return ("N".equals(u)) ? "N" : "Y";
    }
}
