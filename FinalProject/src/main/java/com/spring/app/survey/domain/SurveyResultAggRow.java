package com.spring.app.survey.domain;

import lombok.Data;

@Data
public class SurveyResultAggRow {
    private String questionKey;
    private String optionKey;
    private int cnt;
}
