package com.spring.app.chatting.controller;

import java.security.Principal;
import java.util.Map;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;

import com.spring.app.chatting.domain.ChatMessageDoc;
import com.spring.app.chatting.service.ChatService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ChatWsController {

    private final ChatService chatService;
    private final SimpMessageSendingOperations msgOps;

    @MessageMapping("/rooms/{roomId}/send")
    public void send(
            @DestinationVariable("roomId") String roomId,
            Map<String, String> payload,
            Principal principal) {

        // 세션에서 사용자 정보 취득 가정(사번/이름/프로필) — 없으면 payload로 받도록 처리
        String senderId = payload.getOrDefault("senderId", "");
        String senderName = payload.getOrDefault("senderName", "");
        String senderProfile = payload.getOrDefault("senderProfile", "");
        String content = payload.getOrDefault("content", "");

        ChatMessageDoc saved = chatService.sendMessage(roomId, senderId, senderName, senderProfile, content);

        // 구독자에게 브로드캐스트
        msgOps.convertAndSend("/topic/rooms/" + roomId, Map.of(
                "type", "message",
                "data", saved
        ));
    }

    @MessageMapping("/rooms/{roomId}/read")
    public void read(
            @DestinationVariable("roomId") String roomId,
            Map<String, String> payload) {

        String userId = payload.getOrDefault("userId", "");
        chatService.markRead(roomId, userId);
        msgOps.convertAndSend("/topic/rooms/" + roomId, Map.of(
                "type", "readReceipt",
                "userId", userId
        ));
    }
}
