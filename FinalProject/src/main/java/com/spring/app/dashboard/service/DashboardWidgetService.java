package com.spring.app.dashboard.service;

import java.util.List;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;

public interface DashboardWidgetService {

    /** 사번의 전체 위젯 레이아웃 조회 (VISIBLE_YN 포함) */
    List<WidgetLayoutDTO> list(String empNo);

    /** (선택) 보이는 위젯만 조회하고 싶을 때 사용 */
    List<WidgetLayoutDTO> listVisible(String empNo);

    /** 레이아웃 일괄 저장 (프론트에서 정규화된 DTO 리스트를 그대로 받음) */
    int saveAll(String empNo, List<WidgetLayoutDTO> widgets);
}
