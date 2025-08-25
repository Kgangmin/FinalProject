package com.spring.app.mail.service;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.common.FileManager;
import com.spring.app.mail.domain.MailDTO;
import com.spring.app.mail.domain.MailDetailDTO;
import com.spring.app.mail.domain.MailFileDTO;
import com.spring.app.mail.domain.MailListDTO;
import com.spring.app.mail.model.MailDAO;
import com.spring.app.emp.domain.EmpDTO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MailService_imple implements MailService {

	private final MailDAO mailDAO;
    private final FileManager fileManager;
	
	 /** 업로드 루트 경로 (application.properties 로 설정) */
    @Value("${file.upload.mail-dir:/var/app/upload/mail}")
    private String mailUploadDir;

    
    private List<String> toEmpNos(String toEmpEmailCsv) {
        List<String> recvNos = new ArrayList<>();
        if (!StringUtils.hasText(toEmpEmailCsv)) return recvNos;

        for (String em : toEmpEmailCsv.split(",")) {
            String email = em.trim();
            if (email.isEmpty()) continue;
            String empNo = mailDAO.selectEmpNoByEmpEmail(email);
            if (empNo == null) {
                throw new IllegalArgumentException("존재하지 않는 사내 이메일: " + email);
            }
            recvNos.add(empNo);
        }
        return recvNos;
    }
    
    
    @Override
    public int add(MailDTO mailDto, EmpDTO sender) {
        // 1) 발신자 사번 주입
        mailDto.setFk_emp_no(sender.getEmp_no());
        mailDto.setIs_attached("N");

        // 2) 수신자 검증/변환
        List<String> recvNos = toEmpNos(mailDto.getTo_emp_email_csv());
        if (recvNos.isEmpty()) {
            throw new IllegalArgumentException("수신자(사내이메일)를 1명 이상 입력하세요.");
        }

        // 3) tbl_email 저장 (email_no 생성)
        int n1 = mailDAO.insertEmail(mailDto);

        // 4) 수신자 저장
        int n2sum = 0;
        for (String rno : recvNos) {
            n2sum += mailDAO.insertEmailReceived(mailDto.getEmail_no(), rno, "N", "N", "N");
        }

        return (n1 == 1 && n2sum == recvNos.size()) ? 1 : 0;
    }

    @Override
    public int add_withFile(MailDTO mailDto, MultipartFile[] attachments, EmpDTO sender, String uploadPath) {
        // 1) 발신자 사번 주입
        mailDto.setFk_emp_no(sender.getEmp_no());
        mailDto.setIs_attached("Y");

        // 2) 수신자
        List<String> recvNos = toEmpNos(mailDto.getTo_emp_email_csv());
        if (recvNos.isEmpty()) {
            throw new IllegalArgumentException("수신자(사내이메일)를 1명 이상 입력하세요.");
        }

        // 3) 기본 경로(디렉터리) 준비
        File baseDir = new File(uploadPath);
        if (!baseDir.exists()) baseDir.mkdirs();

        // 4) 본문 저장
        int n1 = mailDAO.insertEmail(mailDto); // email_no 생성됨

        // 5) 첨부 저장 (메일별 하위폴더)
        File emailDir = new File(baseDir, mailDto.getEmail_no());
        if (!emailDir.exists()) emailDir.mkdirs();

        int fileCnt = 0;
        if (attachments != null) {
            for (MultipartFile mf : attachments) {
                if (mf == null || mf.isEmpty()) continue;

                try {
                    byte[] bytes = mf.getBytes();
                    String origin = mf.getOriginalFilename();
                    String saveName = fileManager.doFileUpload(bytes, origin, emailDir.getAbsolutePath());
                    long size = mf.getSize();

                    MailFileDTO f = MailFileDTO.builder()
                            .fk_email_no(mailDto.getEmail_no())
                            .email_origin_filename(origin)
                            .email_save_filename(saveName)
                            .email_filesize(String.valueOf(size))
                            .build();
                    mailDAO.insertEmailFile(f);
                    fileCnt++;

                } catch (Exception e) {
                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
                }
            }
        }

        // 6) 수신자 저장
        int n2sum = 0;
        for (String rno : recvNos) {
            n2sum += mailDAO.insertEmailReceived(mailDto.getEmail_no(), rno, "N", "N", "N");
        }

        return (n1 == 1 && n2sum == recvNos.size()) ? 1 : 0;
    }
	
    
    @Override
    public long countReceived(String empNo, String folder, String unread, String star, String attach) {
        return mailDAO.countReceivedMailList(empNo, folder, unread, star, attach);
    }

    @Override
    public List<MailListDTO> listReceived(String empNo, String folder, String unread, String star, String attach, int offset, int limit) {
        return mailDAO.selectReceivedMailList(empNo, folder, unread, star, attach, offset, limit);
    }
    
    @Override
    public MailDetailDTO getDetailAndMarkRead(String emailNo, String viewerEmpNo) {
        // 1) 읽음 처리 시도 (수신자인 경우에만 1 row 갱신됨)
        try {
            mailDAO.updateMarkRead(emailNo, viewerEmpNo);
        } catch (Exception ignore) {
            // 보낸메일함에서 본 경우 등, 수신행이 없으면 0 row 이고 예외는 발생하지 않는게 정상
        }

        // 2) 상세 조회
        return mailDAO.selectEmailDetail(emailNo, viewerEmpNo);
    }

    @Override
    public List<MailFileDTO> getFiles(String emailNo) {
        return mailDAO.selectFilesByEmailNo(emailNo);
    }

    @Override
    public MailFileDTO getFileByPk(String emailFileNo) {
        return mailDAO.selectFileByPk(emailFileNo);
    }

    @Override
    public boolean canAccessFile(String emailFileNo, String empNo) {
        return mailDAO.canAccessFile(emailFileNo, empNo) > 0;
    }
    
    @Override
    public int updateImportant(String emailNo, String empNo, String value) {
        // value 는 'Y' 또는 'N'만 허용
        if (!"Y".equals(value) && !"N".equals(value)) {
            throw new IllegalArgumentException("value must be 'Y' or 'N'");
        }
        return mailDAO.updateImportant(emailNo, empNo, value);
    }
    
    @Override
    public int markReceivedDeleted(String empNo, List<String> emailNos, String value) {
        if (!"Y".equals(value) && !"N".equals(value)) {
            throw new IllegalArgumentException("value must be 'Y' or 'N'");
        }
        if (emailNos == null || emailNos.isEmpty()) return 0;
        return mailDAO.updateReceivedDeleted(empNo, emailNos, value);
    }

    @Override
    public int markSentDeleted(String empNo, List<String> emailNos, String value) {
        if (!"Y".equals(value) && !"N".equals(value)) {
            throw new IllegalArgumentException("value must be 'Y' or 'N'");
        }
        if (emailNos == null || emailNos.isEmpty()) return 0;
        return mailDAO.updateSentDeleted(empNo, emailNos, value);
    }
    
    
    
    @Override
    public List<EmpDTO> searchContacts(String keyword) {
        String q = (keyword == null ? "" : keyword.trim());
        if (q.length() < 2) {
            // 2글자 미만은 빈 결과 (프론트도 2글자부터 요청)
            return List.of();
        }
        // 상위 20건으로 제한 (원하면 properties 로 빼서 주입해도 됨)
        final int limit = 20;
        return mailDAO.searchContacts(q, limit);
    }
    
    
    
}
