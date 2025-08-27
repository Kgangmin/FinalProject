package com.spring.app.survey.service;

import java.util.*;
import java.util.stream.Collectors;

import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SurveyMongoService_imple implements SurveyMongoService {

    private static final String COLL = "surveys";

    private final MongoTemplate mongoTemplate;

    @Override
    public Map<String, MongoSummary> findSummariesByIds(Collection<String> ids) {
        if (ids == null || ids.isEmpty()) return Collections.emptyMap();

        // ★ 유효한 ObjectId만 사용
        List<ObjectId> oids = ids.stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(s -> !s.isEmpty() && ObjectId.isValid(s))
                .map(ObjectId::new)
                .collect(Collectors.toList());

        if (oids.isEmpty()) return Collections.emptyMap();

        Query q = new Query(Criteria.where("_id").in(oids));
        q.fields().include("title").include("introText"); // _id 는 기본 포함

        List<Document> docs = mongoTemplate.find(q, Document.class, COLL);

        Map<String, MongoSummary> map = new HashMap<>(docs.size());
        for (Document d : docs) {
            ObjectId oid = d.getObjectId("_id");
            if (oid == null) continue;

            MongoSummary m = new MongoSummary();
            m.setId(oid.toHexString());
            // 제목 폴백
            String title = d.getString("title");
            m.setTitle((title != null && !title.isBlank()) ? title : "(제목 없음)");
            m.setIntroText(d.getString("introText"));

            map.put(m.getId(), m);
        }
        return map;
    }

    @Override
    public MongoFullDoc findFullById(String id) {
        if (id == null || id.isBlank() || !ObjectId.isValid(id)) return null;

        Document d = mongoTemplate.findById(new ObjectId(id), Document.class, COLL);
        if (d == null) return null;

        MongoFullDoc doc = new MongoFullDoc();
        ObjectId oid = d.getObjectId("_id");
        doc.setId(oid != null ? oid.toHexString() : null);
        doc.setTitle(d.getString("title"));
        doc.setIntroText(d.getString("introText"));

        @SuppressWarnings("unchecked")
        List<Document> qList = (List<Document>) d.get("questions", List.class);
        if (qList != null) {
            List<MongoFullDoc.Question> qs = new ArrayList<>();
            for (Document qd : qList) {
                MongoFullDoc.Question q = new MongoFullDoc.Question();
                q.setId(qd.getString("id"));
                q.setText(qd.getString("text"));

                Object multiple = qd.get("multiple");
                boolean isMultiple = false;
                if (multiple instanceof Boolean) {
                    isMultiple = (Boolean) multiple;
                } else if (multiple instanceof String) {
                    isMultiple = Boolean.parseBoolean((String) multiple);
                }
                q.setMultiple(isMultiple);

                @SuppressWarnings("unchecked")
                List<Document> opt = (List<Document>) qd.get("options", List.class);
                if (opt != null) {
                    List<MongoFullDoc.Question.Option> opts = new ArrayList<>();
                    for (Document od : opt) {
                        MongoFullDoc.Question.Option o = new MongoFullDoc.Question.Option();
                        o.setId(od.getString("id"));
                        o.setText(od.getString("text"));
                        opts.add(o);
                    }
                    q.setOptions(opts);
                }
                qs.add(q);
            }
            doc.setQuestions(qs);
        }
        return doc;
    }

    @Override
    public String upsertSurveyDoc(String mongoId, MongoFullDoc doc) {
        Document d = new Document();
        d.put("title", doc.getTitle());
        d.put("introText", doc.getIntroText());

        List<Document> qDocs = new ArrayList<>();
        if (doc.getQuestions() != null) {
            for (MongoFullDoc.Question q : doc.getQuestions()) {
                Document qd = new Document();
                qd.put("id", q.getId());
                qd.put("text", q.getText());
                qd.put("multiple", q.isMultiple());

                List<Document> oDocs = new ArrayList<>();
                if (q.getOptions() != null) {
                    for (MongoFullDoc.Question.Option o : q.getOptions()) {
                        Document od = new Document();
                        od.put("id", o.getId());
                        od.put("text", o.getText());
                        oDocs.add(od);
                    }
                }
                qd.put("options", oDocs);
                qDocs.add(qd);
            }
        }
        d.put("questions", qDocs);

        // ★ 유효한 _id 이면 교체(save), 아니면 새로 insert
        if (mongoId != null && !mongoId.isBlank() && ObjectId.isValid(mongoId)) {
            d.put("_id", new ObjectId(mongoId));
            mongoTemplate.save(d, COLL); // upsert 동작(동일 _id면 교체)
            return mongoId;
        } else {
            Document inserted = mongoTemplate.insert(d, COLL);
            ObjectId oid = inserted.getObjectId("_id");
            return (oid != null ? oid.toHexString() : null);
        }
    }
}
