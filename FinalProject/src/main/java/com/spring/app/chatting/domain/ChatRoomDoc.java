package com.spring.app.chatting.domain;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "finalproject_chatting")
public class ChatRoomDoc {

    @Id
    private String id;

    private String docType = "room"; // "room" | "message"
    private String roomId;           // UUID string
    private String name;             // 방 이름
    private String creatorId;        // 개설자 사번

    private Set<String> participantIds = new HashSet<>(); // 참여자 사번들
    private Set<String> pinnedBy = new HashSet<>();       // 방을 고정한 사용자 사번들

    private Instant createdAt = Instant.now();
    private Instant updatedAt = Instant.now();
    private Instant lastMessageAt;

}
