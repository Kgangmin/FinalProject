package com.spring.app.dashboard.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;
import com.spring.app.dashboard.model.DashboardWidgetDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DashboardWidgetService_imple implements DashboardWidgetService {

    private final DashboardWidgetDAO widgetDAO;

    @Override
    public List<WidgetLayoutDTO> list(String empNo) {
        return widgetDAO.selectByEmpNo(empNo);
    }

    @Override
    public List<WidgetLayoutDTO> listVisible(String empNo) {
        return widgetDAO.selectVisibleByEmpNo(empNo);
    }

    @Override
    @Transactional
    public int saveAll(String empNo, List<WidgetLayoutDTO> widgets) {
        if (widgets == null || widgets.isEmpty()) return 0;

        int updated = 0;

        for (WidgetLayoutDTO w : widgets) {
            if (w == null || !StringUtils.hasText(w.getWidgetId())) continue;

            // 사번 주입(보안상 서버 결정)
            w.setEmpNo(empNo);

            // 가드(하한/음수 보정) — 프론트에서 이미 처리해도 서버에서 2중 방어
            if (w.getPosX()  != null && w.getPosX()  < 0)   w.setPosX(0);
            if (w.getPosY()  != null && w.getPosY()  < 0)   w.setPosY(0);
            if (w.getSizeW() != null && w.getSizeW() < 240) w.setSizeW(240); // JS MIN_W=240
            if (w.getSizeH() != null && w.getSizeH() < 160) w.setSizeH(160); // JS MIN_H=160

            // Y/N 정규화 (null/공백/기타 => 'Y')
            w.setVisibleYn(normalizeYN(w.getVisibleYn()));

            updated += widgetDAO.upsert(w);
        }

        return updated;
    }

    private static String normalizeYN(String v) {
        if (!StringUtils.hasText(v)) return "Y";
        String u = v.trim().toUpperCase();
        return "N".equals(u) ? "N" : "Y";
    }
}
