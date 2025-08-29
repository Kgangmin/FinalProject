package com.spring.app.drive.domain;

import lombok.Data;

@Data
public class DriveDTO {
    private String boardFileNo;
    private String boardNo;
    private String fkBoardCategoryNo;
    private String fkEmpNo;
    private String boardOriginFilename;
    private String boardSaveFilename;
    private String boardFilesize;      // bytes as String
    private String registerDate;       // to_char된 문자열
    private String ext;                // 파생: 파일 확장자
    private String humanSize;          // 파생: 사람이 읽기 좋은 크기
    private String empName;
}
