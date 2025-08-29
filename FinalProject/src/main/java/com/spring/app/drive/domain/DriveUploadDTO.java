package com.spring.app.drive.domain;

import lombok.Data;

@Data
public class DriveUploadDTO {
    private String categoryNo;      // DR_CORP / DR_D10 / DR_EMP
    private String empNo;           // 업로더
    private String boardNo;         // insert 후 채움
    private String boardFileNo;     // insert 후 채움
    private String originFilename;
    private String saveFilename;    // 서버 저장명(UUID)
    private String filesize;        // bytes as String
    private String deptNo;
}