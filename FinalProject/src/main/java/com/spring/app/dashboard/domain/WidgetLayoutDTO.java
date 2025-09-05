package com.spring.app.dashboard.domain;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter 
@Setter
@AllArgsConstructor 
@NoArgsConstructor
@Builder
public class WidgetLayoutDTO {

	private String empNo;
    private String widgetId;

    private Integer posX;
    private Integer posY;
    private Integer sizeW;
    private Integer sizeH;
    private String visibleYn;
    
    private Integer gridCol;
    private Integer gridRow;
    private Integer gridW;
    private Integer gridH;

    private Date updatedAt;
	
}
