package com.spring.app.survey.domain;

import lombok.Data;
import java.util.List;

@Data
public class SurveyDetailVO {
    /* ===== 메타(RDB) ===== */
    private String surveyId;
    private String mongoSurveyId;
    private String ownerEmpNo;
    private String ownerName;

    private String startDate;       // yyyy-MM-dd
    private String endDate;         // yyyy-MM-dd
    private String resultPublicYn;  // Y/N
    private String closedYn;        // Y/N
    private String deletedYn;       // Y/N
    private String targetScope;     // ALL / DEPT / DIRECT

    private String createdAt;       // yyyy-MM-dd HH:mm
    private String updatedAt;       // yyyy-MM-dd HH:mm

    private String status;          // ONGOING / CLOSED
    private String participatedYn;  // Y/N (현재 로그인자)
    private Integer participantCnt; // 참여자 수

    /* ===== Mongo 문서(본문) ===== */
    private String title;           // 설문 제목
    private String introText;       // 시작 안내 문구
    private List<QuestionVO> questions;

    /* 편집/수정 폼에서 숨은필드로 원문 JSON을 넘길 때 사용 */
    private String docJson;

    @Data
    public static class QuestionVO {
        private String id;          // question_key (Mongo)
        private String text;        // 질문 내용
        private boolean multiple;   // 복수선택 여부
        private List<OptionVO> options;
    }

    @Data
    public static class OptionVO {
        private String id;          // option_key (Mongo)
        private String text;        // 보기 텍스트
    }
}
