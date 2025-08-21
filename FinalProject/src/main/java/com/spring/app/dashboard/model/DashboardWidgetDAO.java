package com.spring.app.dashboard.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;

@Mapper
public interface DashboardWidgetDAO {

	List<WidgetLayoutDTO> selectByEmpNo(@Param("empNo") String empNo);

    int upsert(WidgetLayoutDTO dto);

    int deleteByEmpNoAndWidgetId(@Param("empNo") String empNo,
                                 @Param("widgetId") String widgetId);
	
}

