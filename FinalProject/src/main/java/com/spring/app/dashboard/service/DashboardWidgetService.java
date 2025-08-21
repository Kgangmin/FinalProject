package com.spring.app.dashboard.service;

import java.util.List;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;
import com.spring.app.dashboard.domain.WidgetSaveRequest;

public interface DashboardWidgetService {

	List<WidgetLayoutDTO> list(String empNo);
	int saveAll(String empNo, List<WidgetSaveRequest.Item> items);
}
