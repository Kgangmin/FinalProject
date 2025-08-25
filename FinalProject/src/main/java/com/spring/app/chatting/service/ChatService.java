package com.spring.app.chatting.service;

import java.util.List;
import java.util.Map;

import com.spring.app.chatting.domain.ChatMessageDoc;
import com.spring.app.chatting.domain.ChatRoomDoc;

public interface ChatService {
    ChatRoomDoc createRoom(String name, String creatorId);
    void addParticipants(String roomId, List<String> empNos);
    void setPinned(String roomId, String userId, boolean pin);
    List<ChatRoomDoc> listRooms(String userId, String query);
    List<ChatMessageDoc> listMessages(String roomId, int limit);
    ChatMessageDoc sendMessage(String roomId, String senderId, String senderName, String senderProfile, String content);
    void markRead(String roomId, String userId);
    Map<String, Long> unreadCountMap(String userId, List<String> roomIds);
	void leaveRoom(String roomId, String userId);
}
