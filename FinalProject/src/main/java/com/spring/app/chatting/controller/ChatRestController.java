package com.spring.app.chatting.controller;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import com.spring.app.chatting.domain.ChatMessageDoc;
import com.spring.app.chatting.domain.ChatRoomDoc;
import com.spring.app.chatting.model.EmpSearchDAO;
import com.spring.app.chatting.model.EmpSearchDTO;
import com.spring.app.chatting.service.ChatService;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/chat")
@Validated
@RequiredArgsConstructor
public class ChatRestController {

    private final ChatService chatService;
    private final EmpSearchDAO empSearchDAO;

    // 세션에서 로그인 사용자 사번 추출 유틸(프로젝트 세션 모델에 맞게 조정)
    private String currentUserId(HttpSession session) {
        try {
            Object user = session.getAttribute("loginuser");
            // 예: getEmp_no()
            return (String) user.getClass().getMethod("getEmp_no").invoke(user);
        } catch (Exception e) {
            return null;
        }
    }
    private String currentUserName(HttpSession session) {
        try {
            Object user = session.getAttribute("loginuser");
            return (String) user.getClass().getMethod("getEmp_name").invoke(user);
        } catch (Exception e) {
            return null;
        }
    }
    private String currentUserProfile(HttpSession session) {
        try {
            Object user = session.getAttribute("loginuser");
            return (String) user.getClass().getMethod("getEmp_save_filename").invoke(user);
        } catch (Exception e) {
            return null;
        }
    }

    /* 방 생성 */
    @PostMapping("/rooms")
    public ResponseEntity<?> createRoom(@RequestBody Map<String, String> body, HttpSession session) {
        String name = body.getOrDefault("name", "").trim();
        if (name.isEmpty()) return ResponseEntity.badRequest().body(Map.of("ok", false, "msg", "방 이름 필요"));
        String me = currentUserId(session);
        ChatRoomDoc room = chatService.createRoom(name, me);
        return ResponseEntity.ok(Map.of("ok", true, "room", room));
    }

    /* 방 목록 (검색어 optional), 핀/정렬 포함 */
    @GetMapping("/rooms")
    public ResponseEntity<?> listRooms(@RequestParam(value = "q", required = false) String q, HttpSession session) {
        String me = currentUserId(session);
        List<ChatRoomDoc> rooms = chatService.listRooms(me, q);
        Map<String, Long> unread = chatService.unreadCountMap(me,
                rooms.stream().map(ChatRoomDoc::getRoomId).collect(Collectors.toList()));

        // 고정 방이 위로 오도록 정렬(프론트에서 또 정렬하지만 서버도 맞춤)
        rooms.sort((a, b) -> {
            boolean ap = a.getPinnedBy().contains(me);
            boolean bp = b.getPinnedBy().contains(me);
            if (ap != bp) return ap ? -1 : 1;
            // 최근 대화
            var at = Optional.ofNullable(a.getLastMessageAt()).orElse(a.getUpdatedAt());
            var bt = Optional.ofNullable(b.getLastMessageAt()).orElse(b.getUpdatedAt());
            return bt.compareTo(at);
        });

        return ResponseEntity.ok(Map.of("ok", true, "list", rooms, "unread", unread));
    }

    /* 방 핀 토글 */
    @PostMapping("/rooms/{roomId}/pin")
    public ResponseEntity<?> pinRoom(@PathVariable String roomId, @RequestBody Map<String, Boolean> body, HttpSession session) {
        String me = currentUserId(session);
        boolean pin = Boolean.TRUE.equals(body.get("pin"));
        chatService.setPinned(roomId, me, pin);
        return ResponseEntity.ok(Map.of("ok", true));
    }

    /* 방 참여자 추가 */
    @PostMapping("/rooms/{roomId}/participants")
    public ResponseEntity<?> addParticipants(@PathVariable String roomId, @RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<String> list = (List<String>) body.getOrDefault("empNos", Collections.emptyList());
        chatService.addParticipants(roomId, list);
        return ResponseEntity.ok(Map.of("ok", true));
    }

    /* 메시지 목록 */
    @GetMapping("/rooms/{roomId}/messages")
    public ResponseEntity<?> listMessages(@PathVariable String roomId, @RequestParam(defaultValue="50") int size) {
        List<ChatMessageDoc> msgs = chatService.listMessages(roomId, Math.min(200, Math.max(1, size)));
        return ResponseEntity.ok(Map.of("ok", true, "list", msgs));
    }

    /* 자동완성: 직원 검색 */
    @GetMapping("/users")
    public ResponseEntity<?> searchUsers(@RequestParam @NotBlank String q) {
        Map<String, Object> param = new HashMap<>();
        param.put("q", q);
        List<EmpSearchDTO> list = empSearchDAO.search(param);
        return ResponseEntity.ok(Map.of("ok", true, "list", list));
    }

    /* (옵션) 단건 전송 REST (STOMP 미사용시 테스트 용) */
    @PostMapping("/rooms/{roomId}/send")
    public ResponseEntity<?> sendOnce(@PathVariable String roomId, @RequestBody Map<String, String> body, HttpSession session) {
        String me = currentUserId(session);
        String myName = currentUserName(session);
        String myProfile = currentUserProfile(session);
        String content = body.getOrDefault("content", "");
        var saved = chatService.sendMessage(roomId, me, myName, myProfile, content);
        return ResponseEntity.ok(Map.of("ok", true, "msg", saved));
    }
    
    @PostMapping(value = "/rooms/{roomId}/leave", consumes = "application/json")
    public ResponseEntity<?> leaveRoom(@PathVariable String roomId,
                                       @RequestBody Map<String, String> body) {
        String userId = body.get("userId");
        if(userId == null || userId.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("ok", false, "error", "userId required"));
        }
        chatService.leaveRoom(roomId, userId);
        return ResponseEntity.ok(Map.of("ok", true));
    }
    
}
