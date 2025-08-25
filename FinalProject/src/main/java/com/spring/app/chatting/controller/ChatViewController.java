package com.spring.app.chatting.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ChatViewController {

    @GetMapping("/chat")
    public String chat() {
        // /WEB-INF/views/chat/chat.jsp
        return "chat/chat";
    }
}
