package com.spring.app.survey.service;

import java.util.*;
import java.util.stream.Collectors;

import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.*;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SurveyMongoService_imple implements SurveyMongoService {

    private final MongoTemplate mongoTemplate;

    @Override
    public Map<String, MongoSummary> findSummariesByIds(Collection<String> ids) {
        if (ids == null || ids.isEmpty()) return Collections.emptyMap();
        Query q = new Query(Criteria.where("_id").in(
            ids.stream().filter(Objects::nonNull).map(ObjectId::new).collect(Collectors.toList())
        ));
        q.fields().include("title").include("introText");
        List<Document> docs = mongoTemplate.find(q, Document.class, "surveys");
        Map<String, MongoSummary> map = new HashMap<>();
        for (Document d : docs) {
            MongoSummary m = new MongoSummary();
            ObjectId oid = d.getObjectId("_id");
            m.setId(oid != null ? oid.toHexString() : null);
            m.setTitle(d.getString("title"));
            m.setIntroText(d.getString("introText"));
            map.put(m.getId(), m);
        }
        return map;
    }

    @Override
    public MongoFullDoc findFullById(String id) {
        if (id == null) return null;
        Document d = mongoTemplate.findById(new ObjectId(id), Document.class, "surveys");
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
                q.setMultiple(Boolean.TRUE.equals(multiple) || "true".equalsIgnoreCase(String.valueOf(multiple)));

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
                List<Document> odocs = new ArrayList<>();
                if (q.getOptions() != null) {
                    for (MongoFullDoc.Question.Option o : q.getOptions()) {
                        Document od = new Document();
                        od.put("id", o.getId());
                        od.put("text", o.getText());
                        odocs.add(od);
                    }
                }
                qd.put("options", odocs);
                qDocs.add(qd);
            }
        }
        d.put("questions", qDocs);

        if (mongoId == null || mongoId.isBlank()) {
            Document inserted = mongoTemplate.insert(d, "surveys");
            ObjectId oid = inserted.getObjectId("_id");
            return oid != null ? oid.toHexString() : null;
        } else {
            Query q = new Query(Criteria.where("_id").is(new ObjectId(mongoId)));
            mongoTemplate.findAndReplace(q, d, "surveys");
            return mongoId;
        }
    }

}
