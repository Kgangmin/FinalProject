package com.spring.app.chatting.domain;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.Data;

@Data
@Document(collection = "finalproject_chatting")
public class ChatMessageDoc {

    @Id
    private String id;

    private String docType = "message"; // "room" | "message"

    private String roomId;
    private String senderId;
    private String senderName;
    private String senderProfile; // emp_save_filename

    private String content;
    private Instant createdAt = Instant.now();

    // 읽음 처리
    private Set<String> readBy = new HashSet<>(); // 읽은 사용자 사번들

}
