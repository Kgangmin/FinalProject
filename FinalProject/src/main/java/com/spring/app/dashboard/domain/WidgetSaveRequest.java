package com.spring.app.dashboard.domain;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Data;

@Data
public class WidgetSaveRequest {
    private List<Item> widgets;

    @Data
    public static class Item {
        // "widgetId" 또는 "id"로 와도 매핑되도록
        @JsonAlias({"widgetId", "id"})
        private String widgetId;

        // px 절대좌표/크기
        private Integer x;
        private Integer y;
        private Integer width;
        private Integer height;

        // (옵션) grid 스냅 값이 올 수도 있으니 널 허용
        private Integer col;
        private Integer row;
        private Integer w;
        private Integer h;
        
        private String visibleYn;
    }
}
