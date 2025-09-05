package com.spring.app.dashboard.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.dashboard.domain.WidgetLayoutDTO;

@Mapper
public interface DashboardWidgetDAO {

    List<WidgetLayoutDTO> selectByEmpNo(@Param("empNo") String empNo);

    /** (선택) 보이는 위젯만 조회 */
    List<WidgetLayoutDTO> selectVisibleByEmpNo(@Param("empNo") String empNo);

    /** 단건 UPSERT (XML: <insert id="upsert"> MERGE …) */
    int upsert(WidgetLayoutDTO dto);

    /** (선택) 배치 UPSERT — XML: <insert id="upsertBatch"> with param map(empNo, widgets) */
    int upsertBatch(@Param("empNo") String empNo,
                    @Param("widgets") List<WidgetLayoutDTO> widgets);

    int deleteByEmpNoAndWidgetId(@Param("empNo") String empNo,
                                 @Param("widgetId") String widgetId);
}
