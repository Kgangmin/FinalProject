package com.spring.app.survey.service;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import lombok.Data;

public interface SurveyMongoService {
    Map<String, MongoSummary> findSummariesByIds(Collection<String> ids);
    MongoFullDoc findFullById(String id);

    @Data
    class MongoSummary {
        private String id;
        private String title;
        private String introText;
    }

    @Data
    class MongoFullDoc {
        private String id;
        private String title;
        private String introText;
        private List<Question> questions;

        @Data
        public static class Question {
            private String id;
            private String text;
            private boolean multiple;
            private List<Option> options;

            @Data
            public static class Option {
                private String id;
                private String text;
            }
        }
    }
    
    String upsertSurveyDoc(String mongoId, MongoFullDoc doc); // mongoId null이면 insert 후 새 id 반환
}
