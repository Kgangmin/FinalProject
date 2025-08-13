package com.spring.app.mail.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.mail.domain.MailDTO;
import com.spring.app.mail.service.MailService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping(value="/mail/*")
public class MailController {

	private final MailService mailService;
	// 메일함 가기
	@GetMapping("email")
	public String email() {
		
		return "mail/email";
	}
	
	// 메일 보내기 
	@GetMapping("compose")
    public String compose() {
        return "mail/compose"; // /WEB-INF/views/mail/compose.jsp
    }

	// 메일 보내기 완료
	@PostMapping("send")
	public String sendMail(@ModelAttribute MailDTO mailDTO,
	                       @RequestParam(value="attachments", required=false) MultipartFile[] files,
	                       HttpSession session,
	                       HttpServletRequest request) {
	    Object loginuser = session.getAttribute("loginuser");
	    if (loginuser == null) {
	        request.setAttribute("message", "로그인이 필요합니다.");
	        request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
	        return "msg";
	    }

	    try {
	        // TODO: mailService.sendMail(mailDTO, files, loginuser);
	        return "mail/send_result"; // ▼ 아래 JSP
	    } catch (Exception e) {
	        request.setAttribute("message", "메일 발송 중 오류가 발생했습니다.");
	        request.setAttribute("loc", request.getContextPath()+"/mail/compose");
	        return "msg";
	    }
	}
	
}
