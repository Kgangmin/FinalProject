package com.spring.app.chatting.service;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.app.chatting.dao.ChatMongoDAO;
import com.spring.app.chatting.domain.ChatMessageDoc;
import com.spring.app.chatting.domain.ChatRoomDoc;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatMongoDAO dao;

    @Override
    public ChatRoomDoc createRoom(String name, String creatorId) {
        return dao.createRoom(name, creatorId);
    }

    @Override
    public void addParticipants(String roomId, List<String> empNos) {
        dao.addParticipants(roomId, empNos);
    }

    @Override
    public void setPinned(String roomId, String userId, boolean pin) {
        dao.setPinned(roomId, userId, pin);
    }

    @Override
    public List<ChatRoomDoc> listRooms(String userId, String query) {
        return dao.findRoomsForUser(userId, query);
    }

    @Override
    public List<ChatMessageDoc> listMessages(String roomId, int limit) {
        return dao.listMessages(roomId, limit, null);
    }

    @Override
    @Transactional
    public ChatMessageDoc sendMessage(String roomId, String senderId, String senderName, String senderProfile, String content) {
        ChatMessageDoc m = new ChatMessageDoc();
        m.setRoomId(roomId);
        m.setSenderId(senderId);
        m.setSenderName(senderName);
        m.setSenderProfile(senderProfile);
        m.setContent(content);
        m.getReadBy().add(senderId); // 보낸 사람은 자동 읽음
        return dao.insertMessage(m);
    }

    @Override
    public void markRead(String roomId, String userId) {
        dao.markAllRead(roomId, userId);
    }

    @Override
    public Map<String, Long> unreadCountMap(String userId, List<String> roomIds) {
        return dao.countUnreadByRoom(userId, roomIds);
    }
    
    
    @Override
    public void leaveRoom(String roomId, String userId) {
        dao.leaveRoom(roomId, userId);
    }
}
