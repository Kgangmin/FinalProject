package com.spring.app.survey.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @NoArgsConstructor @AllArgsConstructor
public class SurveyAnswerRow {
    private String questionKey;
    private String optionKey;
}
