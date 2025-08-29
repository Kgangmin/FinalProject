package com.spring.app.notify.domain.source;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class SurveyRow {

    private String surveyId;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    
}
