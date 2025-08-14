package com.spring.app.mail.controller;

import java.io.File;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.mail.domain.MailDTO;
import com.spring.app.mail.domain.MailListDTO;
import com.spring.app.mail.service.MailService;
import com.spring.app.emp.domain.EmpDTO;

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
	public String compose(HttpSession session, HttpServletRequest request, Model model) {
        EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
        if (loginuser == null) {
            request.setAttribute("message", "로그인이 필요합니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }
        model.addAttribute("senderEmail", loginuser.getEmp_email()); // readonly로 표시
        return "mail/compose"; // /WEB-INF/views/mail/compose.jsp
    }

	// 메일 발송 처리
	@PostMapping("send")
    public String sendMail(@ModelAttribute MailDTO mailDto,
                           @RequestParam(value="attachments", required=false) MultipartFile[] attachments,
                           HttpSession session,
                           HttpServletRequest request) {
        EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
        if (loginuser == null) {
            request.setAttribute("message", "로그인이 필요합니다.");
            request.setAttribute("loc", request.getContextPath()+"/login/loginStart");
            return "msg";
        }

     // === webapp 절대경로로 업로드 경로 생성 ===
        // /FinalProject/src/main/webapp/resources/email_attach_file
        String root = session.getServletContext().getRealPath("/"); // webapp/
        String path = root + "resources" + File.separator + "email_attach_file";

        // 첨부 유무 판정(최소 1개가 비어있지 않아야 첨부로 간주)
        boolean hasFile = false;
        if (attachments != null) {
            for (MultipartFile mf : attachments) {
                if (mf != null && !mf.isEmpty()) { hasFile = true; break; }
            }
        }

        int n;
        Map<String,String> paraMap = new HashMap<>(); // 교육용 코드 스타일 유지용(필요 시 확장)

        if (!hasFile) {
            // 첨부 없는 메일
            n = mailService.add(mailDto, loginuser);
        } else {
            // 첨부 있는 메일(파일 저장 + DB 기록)
            n = mailService.add_withFile(mailDto, attachments, loginuser, path);
        }

        if (n == 1) {
            // 발송 성공 페이지로
            return "mail/send_result";
        } else {
            request.setAttribute("message", "메일 발송에 실패했습니다.");
            request.setAttribute("loc", request.getContextPath() + "/mail/compose");
            return "msg";
        }
    }
	
	
	@GetMapping("/list")
    public ResponseEntity<Map<String, Object>> list(@RequestParam(name="folder", defaultValue="all") String folder,
                                                    @RequestParam(name="unread", defaultValue="N") String unread,
                                                    @RequestParam(name="star",   defaultValue="N") String star,
                                                    @RequestParam(name="attach", defaultValue="N") String attach,
                                                    @RequestParam(name="page",   defaultValue="1") int page,
                                                    @RequestParam(name="size",   defaultValue="20") int size,
                                                    HttpSession session) {

        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            // 로그인 세션 없음
            return ResponseEntity.status(401).body(Map.of("list", Collections.emptyList(), "total", 0));
        }

        String empNo = login.getEmp_no();

        // 페이징 보정
        if (page < 1) page = 1;
        if (size < 1) size = 20;
        int offset = (page - 1) * size;

        // folder는 현재 'all'만 사용. 필요한 경우 조건 분기 추가 가능.
        long total = mailService.countReceived(empNo, unread, star, attach);
        List<MailListDTO> list = mailService.getReceived(empNo, unread, star, attach, offset, size);

        Map<String, Object> res = new HashMap<>();
        res.put("list", list);
        res.put("total", total);
        res.put("page", page);
        res.put("size", size);

        return ResponseEntity.ok(res);
    }
	
	// 내게 쓰기
	@GetMapping("composeToMe")
	public String composeToMe() {
	    return "mail/compose_self"; // /WEB-INF/views/mail/compose_self.jsp
	}
	
	
}
