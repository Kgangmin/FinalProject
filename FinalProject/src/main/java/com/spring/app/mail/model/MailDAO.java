package com.spring.app.mail.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.mail.domain.MailDTO;
import com.spring.app.mail.domain.MailDetailDTO;
import com.spring.app.mail.domain.MailFileDTO;
import com.spring.app.mail.domain.MailListDTO;

@Mapper
public interface MailDAO {

	// tbl_email INSERT (selectKey로 email_no 세팅)
    int insertEmail(MailDTO dto);

    // tbl_email_received INSERT
    int insertEmailReceived(@Param("fk_email_no") String fkEmailNo,
                            @Param("fk_emp_no")   String fkEmpNo,
                            @Param("is_read")     String isRead,
                            @Param("is_important")String isImportant,
                            @Param("is_deleted")  String isDeleted);

    // tbl_email_file INSERT
    int insertEmailFile(MailFileDTO fileDto);

    // 사내 이메일 -> 사번
    String selectEmpNoByEmpEmail(@Param("emp_email") String empEmail);
    
    List<MailListDTO> selectReceivedMailList(
            @Param("emp_no") String empNo,
            @Param("folder") String folder,
            @Param("unread") String unread,     // 'Y'/'N'
            @Param("star")   String star,       // 'Y'/'N'
            @Param("attach") String attach,     // 'Y'/'N'
            @Param("offset") int offset,
            @Param("limit")  int limit
    );

    long countReceivedMailList(
            @Param("emp_no") String empNo,
            @Param("folder") String folder,
            @Param("unread") String unread,
            @Param("star")   String star,
            @Param("attach") String attach
    );
	
    
    // 상세 페이지용: viewer(로그인 사용자) 관점에서 메일 상세 1건
    MailDetailDTO selectEmailDetail(@Param("email_no") String emailNo,
                                    @Param("viewer_emp_no") String viewerEmpNo);

    // 상세 페이지용: 첨부파일 목록
    List<MailFileDTO> selectFilesByEmailNo(@Param("email_no") String emailNo);

    // 파일 1건 조회(다운로드용)
    MailFileDTO selectFileByPk(@Param("email_file_no") String emailFileNo);

    // 읽음 처리 (받은사람 기준)
    int updateMarkRead(@Param("email_no") String emailNo,
                       @Param("emp_no") String empNo);

    // 파일 접근 권한 확인(발신자이거나 수신자면 접근 가능)
    int canAccessFile(@Param("email_file_no") String emailFileNo,
                      @Param("emp_no") String empNo);
    
    int updateImportant(@Param("email_no") String emailNo,
            @Param("emp_no") String empNo,
            @Param("value") String value);
}
