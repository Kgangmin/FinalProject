package com.spring.app.mail.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.spring.app.mail.domain.MailDTO;
import com.spring.app.mail.domain.MailDetailDTO;
import com.spring.app.mail.domain.MailFileDTO;
import com.spring.app.mail.domain.MailListDTO;
import com.spring.app.emp.domain.EmpDTO;

public interface MailService {
	
	// 첨부 없는 메일
	int add(MailDTO mailDto, EmpDTO sender); 
    
	// 첨부 있는 메일
	int add_withFile(MailDTO mailDto, MultipartFile[] attachments, EmpDTO sender, String uploadPath); 

	// 목록용
	long countReceived(String empNo, String folder, String unread, String star, String attach);
	
	List<MailListDTO> listReceived(String empNo, String folder, String unread, String star, String attach, int offset, int limit);

    // 상세 + 읽음 처리
    MailDetailDTO getDetailAndMarkRead(String emailNo, String viewerEmpNo);

    // 첨부 목록
    List<MailFileDTO> getFiles(String emailNo);

    // 파일 단건
    MailFileDTO getFileByPk(String emailFileNo);

    // 파일 접근 권한
    boolean canAccessFile(String emailFileNo, String empNo);
    
    // 중요표시 토글: 수신자(로그인 사용자) 기준
    int updateImportant(String emailNo, String empNo, String value); // 1=성공, 0=대상없음
    
    // 휴지통보내기(수신메일)
    int markReceivedDeleted(String empNo, List<String> emailNos, String value); // value: 'Y' or 'N'
    
    // 휴지통보내기(발신메일)
    int markSentDeleted(String empNo, List<String> emailNos, String value);     // value: 'Y' or 'N'
    
    // 자동완성 검색
    List<EmpDTO> searchContacts(String keyword);
}
