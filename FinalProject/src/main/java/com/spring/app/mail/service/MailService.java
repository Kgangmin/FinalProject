package com.spring.app.mail.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.spring.app.mail.domain.MailDTO;
import com.spring.app.mail.domain.MailListDTO;
import com.spring.app.emp.domain.EmpDTO;

public interface MailService {
	
	// 첨부 없는 메일
	int add(MailDTO mailDto, EmpDTO sender); 
    
	// 첨부 있는 메일
	int add_withFile(MailDTO mailDto, MultipartFile[] attachments, EmpDTO sender, String uploadPath); // 첨부 있는 메일

	long countReceived(String empNo, String unread, String star, String attach);
	
    List<MailListDTO> getReceived(String empNo, String unread, String star, String attach, int offset, int limit);

}
