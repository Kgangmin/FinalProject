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
import org.springframework.web.bind.annotation.PathVariable;
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
            request.setAttribute("loc", request.getContextPath()+"/login");
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
            request.setAttribute("loc", request.getContextPath()+"/login");
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
	public ResponseEntity<Map<String, Object>> list(
	        @RequestParam(name="folder", defaultValue="all") String folder,
	        @RequestParam(name="unread", defaultValue="N") String unread,
	        @RequestParam(name="star",   defaultValue="N") String star,
	        @RequestParam(name="attach", defaultValue="N") String attach,
	        @RequestParam(name="page",   defaultValue="1") int page,
	        @RequestParam(name="size",   defaultValue="20") int size,
	        HttpSession session) {

	    EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
	    if (login == null || login.getEmp_no() == null) {
	        return ResponseEntity.status(401).body(Map.of("list", Collections.emptyList(), "total", 0));
	    }

	    String empNo = login.getEmp_no();
	    if (page < 1) page = 1;
	    if (size < 1) size = 20;
	    int offset = (page - 1) * size;

	    // ★ 반드시 folder/unread/star/attach 모두 전달
	    long total = mailService.countReceived(empNo, folder, unread, star, attach);
	    List<MailListDTO> list = mailService.listReceived(empNo, folder, unread, star, attach, offset, size);

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
	
	/** 메일 상세 보기: 제목 클릭 시 진입
     *  - 수신자인 경우 TBL_EMAIL_RECEIVED.IS_READ = 'Y' 로 즉시 갱신
     */
    @GetMapping("detail")
    public String detail(@RequestParam("emailNo") String emailNo,
                         HttpSession session,
                         HttpServletRequest request,
                         Model model) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            request.setAttribute("message", "로그인이 필요합니다.");
            request.setAttribute("loc", request.getContextPath()+"/login");
            return "msg";
        }

        String viewerEmpNo = login.getEmp_no();

        // 1) 읽음 처리 + 상세 조회
        var detail = mailService.getDetailAndMarkRead(emailNo, viewerEmpNo);
        if (detail == null) {
            request.setAttribute("message", "존재하지 않거나 접근 권한이 없는 메일입니다.");
            request.setAttribute("loc", request.getContextPath()+"/mail/email");
            return "msg";
        }

        // 2) 첨부 목록
        var files = mailService.getFiles(emailNo);

        model.addAttribute("detail", detail);
        model.addAttribute("files", files);

        return "mail/detail"; // /WEB-INF/views/mail/detail.jsp
    }

    /** 첨부 다운로드
     *  - 발신자 또는 수신자만 접근 허용
     *  - 파일은 업로드시 저장한 경로에서 찾아 스트리밍
     */
    @GetMapping("file/{fileNo}")
    public ResponseEntity<?> download(@PathVariable("fileNo") String fileNo,
                                      HttpSession session,
                                      HttpServletRequest request) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }
        String empNo = login.getEmp_no();

        // 접근 권한 확인
        if (!mailService.canAccessFile(fileNo, empNo)) {
            return ResponseEntity.status(403).body("다운로드 권한이 없습니다.");
        }

        // 파일 메타 조회
        var fileDto = mailService.getFileByPk(fileNo);
        if (fileDto == null) {
            return ResponseEntity.notFound().build();
        }

        // 저장 경로 조립: /resources/email_attach_file/{emailNo}/{saveName}
        String root = session.getServletContext().getRealPath("/");
        File file = new File(root + "resources" + File.separator + "email_attach_file"
                + File.separator + fileDto.getFk_email_no()
                + File.separator + fileDto.getEmail_save_filename());

        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        // 원본 파일명 Content-Disposition
        String origin = fileDto.getEmail_origin_filename();
        String encoded = origin;
        try {
            // RFC 5987 형태 인코딩(브라우저 호환성↑)
            encoded = java.net.URLEncoder.encode(origin, java.nio.charset.StandardCharsets.UTF_8)
                    .replaceAll("\\+", "%20");
        } catch (Exception ignore) {}

        org.springframework.core.io.Resource resource =
                new org.springframework.core.io.FileSystemResource(file);

        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename*=UTF-8''" + encoded)
                .header("Content-Length", String.valueOf(file.length()))
                .contentType(org.springframework.http.MediaType.APPLICATION_OCTET_STREAM)
                .body(resource);
    }
    
    // 중요표시 토글
    @PostMapping("api/important")
    public ResponseEntity<Map<String, Object>> toggleImportant(
            @RequestParam("emailNo") String emailNo,
            @RequestParam("value")   String value,
            HttpSession session) {

        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            return ResponseEntity.status(401).body(Map.of("ok", false, "reason", "unauth"));
        }
        if (!"Y".equals(value) && !"N".equals(value)) {
            return ResponseEntity.badRequest().body(Map.of("ok", false, "reason", "bad_value"));
        }

        int n = mailService.updateImportant(emailNo, login.getEmp_no(), value);
        if (n == 1) {
            return ResponseEntity.ok(Map.of("ok", true, "value", value));
        } else {
            // 보낸메일함 등 수신행이 없는 경우 0건 갱신 → 클라이언트에서 비활성화 처리 권장
            return ResponseEntity.status(400).body(Map.of("ok", false, "reason", "not_recipient"));
        }
    }
    
    @PostMapping("api/delete")
    public ResponseEntity<Map<String, Object>> deleteSelected(
            @RequestParam("folder") String folder,             // all/inbox/tome/sent
            @RequestParam("emailNos") List<String> emailNos,   // 다중
            HttpSession session) {

        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            return ResponseEntity.status(401).body(Map.of("ok", false, "reason", "unauth"));
        }
        if (emailNos == null || emailNos.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("ok", false, "reason", "empty"));
        }

        String empNo = login.getEmp_no();
        int updated;
        if ("sent".equals(folder)) {
            // 발신자 기준 삭제 → SENT_DELETED = 'Y'
            updated = mailService.markSentDeleted(empNo, emailNos, "Y");
        } else if ("trash".equals(folder)) {
            // 휴지통에서 '삭제'는 아직 미지원(7단계에서 영구삭제 처리)
            return ResponseEntity.badRequest().body(Map.of("ok", false, "reason", "not_supported_in_trash"));
        } else {
            // 수신자 기준 삭제 → IS_DELETED = 'Y'
            updated = mailService.markReceivedDeleted(empNo, emailNos, "Y");
        }
        return ResponseEntity.ok(Map.of("ok", true, "updated", updated));
    }

    /** 휴지통 복원: 수신자/발신자 혼합 가능
     *  - recvs:  수신자 항목 emailNo CSV (IS_DELETED='N')
     *  - sents:  발신자 항목 emailNo CSV (SENT_DELETED='N')
     */
    @PostMapping("api/restore")
    public ResponseEntity<Map<String, Object>> restoreFromTrash(
            @RequestParam(name="recvs", required=false) String recvsCsv,
            @RequestParam(name="sents", required=false) String sentsCsv,
            HttpSession session) {

        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            return ResponseEntity.status(401).body(Map.of("ok", false, "reason", "unauth"));
        }
        String empNo = login.getEmp_no();

        List<String> recvs = (recvsCsv == null || recvsCsv.isBlank())
                ? Collections.emptyList()
                : java.util.Arrays.stream(recvsCsv.split(","))
                    .map(String::trim).filter(s -> !s.isEmpty()).toList();

        List<String> sents = (sentsCsv == null || sentsCsv.isBlank())
                ? Collections.emptyList()
                : java.util.Arrays.stream(sentsCsv.split(","))
                    .map(String::trim).filter(s -> !s.isEmpty()).toList();

        if (recvs.isEmpty() && sents.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("ok", false, "reason", "empty"));
        }

        int u1 = 0, u2 = 0;
        if (!recvs.isEmpty()) u1 = mailService.markReceivedDeleted(empNo, recvs, "N");
        if (!sents.isEmpty()) u2 = mailService.markSentDeleted(empNo, sents, "N");

        return ResponseEntity.ok(Map.of("ok", true, "restored_received", u1, "restored_sent", u2));
    }
	
    
    
    // 받는사람 자동완성 API
    @GetMapping("api/contacts/search")
    public ResponseEntity<Map<String, Object>> searchContacts(@RequestParam("q") String q,
                                                              HttpSession session) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null || login.getEmp_no() == null) {
            return ResponseEntity.status(401).body(Map.of("ok", false, "reason", "unauth", "list", List.of()));
        }

        String keyword = (q == null ? "" : q.trim());
        if (keyword.length() < 2) {
            return ResponseEntity.ok(Map.of("ok", true, "list", List.of()));
        }

       
        List<EmpDTO> found = mailService.searchContacts(keyword);  

        List<Map<String,Object>> list = found == null ? List.of() :
                found.stream().map(emp -> {
                    Map<String,Object> m = new HashMap<>();
                    m.put("name", emp.getEmp_name());
                    m.put("teamName", emp.getTeam_name());   // 필드명은 실제 DTO에 맞게
                    m.put("email", emp.getEmp_email());
                    return m;
                }).toList();

        return ResponseEntity.ok(Map.of("ok", true, "list", list));
    }
    
    
	
}
