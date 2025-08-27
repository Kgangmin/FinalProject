package com.spring.app.chatting.dao;

import java.time.Instant;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.bson.Document;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.mongodb.core.query.*;
import org.springframework.stereotype.Repository;

import com.spring.app.chatting.domain.ChatMessageDoc;
import com.spring.app.chatting.domain.ChatRoomDoc;

@Repository
public class ChatMongoDAO implements InitializingBean {

    private final MongoTemplate template;
    private static final String COLL = "finalproject_chatting";

    public ChatMongoDAO(MongoTemplate template) {
        this.template = template;
    }

    @Override
    public void afterPropertiesSet() {
        // 필요한 인덱스 생성
        template.indexOps(COLL).ensureIndex(new Index().on("docType", Sort.Direction.ASC));
        template.indexOps(COLL).ensureIndex(new Index().on("roomId", Sort.Direction.ASC));
        template.indexOps(COLL).ensureIndex(new Index().on("createdAt", Sort.Direction.DESC));
        template.indexOps(COLL).ensureIndex(new Index().on("lastMessageAt", Sort.Direction.DESC));
        template.indexOps(COLL).ensureIndex(new Index().on("participantIds", Sort.Direction.ASC));
        template.indexOps(COLL).ensureIndex(new Index().on("pinnedBy", Sort.Direction.ASC));
    }

    /* ===== 공용 유틸 ===== */
    private static long getAsLong(Document doc, String key, long defaultVal) {
        Object v = doc.get(key);
        if (v == null) return defaultVal;
        if (v instanceof Number) return ((Number) v).longValue();
        try { return Long.parseLong(v.toString()); } catch (Exception ignore) { return defaultVal; }
    }

    private static String getAsString(Document doc, String key) {
        Object v = doc.get(key);
        return v == null ? null : v.toString();
    }

    /* ===== Room ===== */
    public ChatRoomDoc createRoom(String name, String creatorId) {
        ChatRoomDoc room = new ChatRoomDoc();
        room.setRoomId(UUID.randomUUID().toString());
        room.setName(name);
        room.setCreatorId(creatorId);
        room.getParticipantIds().add(creatorId);
        room.setCreatedAt(Instant.now());
        room.setUpdatedAt(Instant.now());
        template.insert(room, COLL);
        return room;
    }

    public void addParticipants(String roomId, Collection<String> userIds) {
        Query q = Query.query(Criteria.where("docType").is("room").and("roomId").is(roomId));
        Update u = new Update().addToSet("participantIds").each(new ArrayList<>(userIds).toArray());
        u.set("updatedAt", Instant.now());
        template.updateFirst(q, u, COLL);
    }

    public void setPinned(String roomId, String userId, boolean pin) {
        Query q = Query.query(Criteria.where("docType").is("room").and("roomId").is(roomId));
        Update u = pin ? new Update().addToSet("pinnedBy", userId) : new Update().pull("pinnedBy", userId);
        u.set("updatedAt", Instant.now());
        template.updateFirst(q, u, COLL);
    }

    public List<ChatRoomDoc> findRoomsForUser(String userId, String queryText) {
        Criteria c = Criteria.where("docType").is("room").and("participantIds").in(userId);
        if (queryText != null && !queryText.trim().isEmpty()) {
            c = c.and("name").regex(".*" + Pattern.quote(queryText.trim()) + ".*", "i");
        }
        Query q = Query.query(c).with(Sort.by(Sort.Order.desc("lastMessageAt"), Sort.Order.desc("updatedAt")));
        return template.find(q, ChatRoomDoc.class, COLL);
    }

    public Optional<ChatRoomDoc> getRoom(String roomId) {
        Query q = Query.query(Criteria.where("docType").is("room").and("roomId").is(roomId));
        ChatRoomDoc r = template.findOne(q, ChatRoomDoc.class, COLL);
        return Optional.ofNullable(r);
    }

    /* ===== Message ===== */
    public ChatMessageDoc insertMessage(ChatMessageDoc msg) {
        msg.setCreatedAt(Instant.now());
        template.insert(msg, COLL);
        // 방 갱신
        Query q = Query.query(Criteria.where("docType").is("room").and("roomId").is(msg.getRoomId()));
        Update u = new Update().set("lastMessageAt", msg.getCreatedAt()).set("updatedAt", Instant.now());
        template.updateFirst(q, u, COLL);
        return msg;
    }

    public List<ChatMessageDoc> listMessages(String roomId, int limit, String beforeIdExclusive) {
        Criteria c = Criteria.where("docType").is("message").and("roomId").is(roomId);
        Query q = Query.query(c).with(Sort.by(Sort.Direction.DESC, "createdAt")).limit(Math.max(1, limit));
        if (beforeIdExclusive != null) {
            // createdAt 기준 페이징을 권장하지만 간단화
        }
        List<ChatMessageDoc> rev = template.find(q, ChatMessageDoc.class, COLL);
        Collections.reverse(rev);
        return rev;
    }

    public void markAllRead(String roomId, String userId) {
        Query q = Query.query(
            Criteria.where("docType").is("message")
                    .and("roomId").is(roomId)
                    .and("readBy").nin(userId) // 배열에 userId가 없을 때만
        );
        Update u = new Update().addToSet("readBy", userId);
        template.updateMulti(q, u, COLL);
    }

    /**
     * 방별 미읽음 개수
     * - 내가 보낸 메시지는 제외
     * - readBy 배열에 내가 포함되어 있지 않은 메시지만 카운트
     */
    public Map<String, Long> countUnreadByRoom(String userId, Collection<String> roomIds) {
        if (roomIds == null || roomIds.isEmpty()) return Collections.emptyMap();

        // db.collection.aggregate([...])
        List<Document> pipeline = Arrays.asList(
            new Document("$match", new Document("docType", "message")
                .append("roomId", new Document("$in", roomIds))
                .append("senderId", new Document("$ne", userId))         // 내가 보낸 메시지는 제외
                .append("readBy", new Document("$nin", Collections.singletonList(userId))) // 내가 아직 안 읽은 것만
            ),
            new Document("$group", new Document("_id", "$roomId")
                .append("cnt", new Document("$sum", 1))
            )
            // 필요 시 타입 고정
            // , new Document("$project", new Document("_id", 0).append("roomId", "$_id").append("cnt", new Document("$toLong", "$cnt")))
        );

        List<Document> agg = template.getDb()
                .getCollection(COLL)
                .aggregate(pipeline)
                .into(new ArrayList<>());

        // 타입 안전하게 매핑
        return agg.stream().collect(Collectors.toMap(
            d -> {
                Object id = d.get("_id");
                return id == null ? "" : id.toString();
            },
            d -> getAsLong(d, "cnt", 0L)
        ));
    }

    public void leaveRoom(String roomId, String userId) {
        Query q = Query.query(Criteria.where("docType").is("room").and("roomId").is(roomId));
        Update u = new Update().pull("participantIds", userId)
                               .set("updatedAt", Instant.now());
        template.updateFirst(q, u, COLL);
    }
}
