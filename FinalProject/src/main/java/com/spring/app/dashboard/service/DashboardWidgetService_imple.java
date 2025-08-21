package com.spring.app.dashboard.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;
import com.spring.app.dashboard.domain.WidgetSaveRequest;
import com.spring.app.dashboard.model.DashboardWidgetDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DashboardWidgetService_imple implements DashboardWidgetService {

	 private final DashboardWidgetDAO WidgetDAO;
	
	@Override
	public List<WidgetLayoutDTO> list(String empNo) {
		return WidgetDAO.selectByEmpNo(empNo);
	}

	@Override
    @Transactional
    public int saveAll(String empNo, List<WidgetSaveRequest.Item> items) {
        int cnt = 0;
        if (items == null) return 0;
        for (WidgetSaveRequest.Item it : items) {
            WidgetLayoutDTO dto = new WidgetLayoutDTO();
            dto.setEmpNo(empNo);
            dto.setWidgetId(it.getWidgetId());

            // px 좌표/크기
            dto.setPosX(it.getX());
            dto.setPosY(it.getY());
            dto.setSizeW(it.getWidth());
            dto.setSizeH(it.getHeight());

            // grid 스냅 값(있으면 저장)
            dto.setGridCol(it.getCol());
            dto.setGridRow(it.getRow());
            dto.setGridW(it.getW());
            dto.setGridH(it.getH());

            cnt += WidgetDAO.upsert(dto);
        }
        return cnt;
    }

}
