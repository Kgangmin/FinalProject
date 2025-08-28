package com.spring.app.survey.domain;

import lombok.Data;

@Data
public class SurveyDTO {
    // tbl_survey
    private String surveyId;
    private String mongoSurveyId;
    private String title;
    private String ownerEmpNo;
    private String startDate;     // yyyy-mm-dd (Mapper에서 TO_CHAR)
    private String endDate;       // yyyy-mm-dd
    private String resultPublicYn;
    private String closedYn;
    private String deletedYn;
    private String targetScope;   // ALL / DEPT / DIRECT
    private String introText;     // 짧은 설명
    private String createdAt;     // yyyy-mm-dd hh24:mi
    private String updatedAt;

    // joined / computed
    private String ownerName;     // 작성자 이름
    private String status;        // ONGOING / CLOSED
    private String participatedYn;// Y/N (현재 로그인자 기준)
    private Integer participantCnt;
}
