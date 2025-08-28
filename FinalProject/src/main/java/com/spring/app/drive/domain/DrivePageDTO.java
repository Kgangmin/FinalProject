package com.spring.app.drive.domain;

import lombok.Data;

@Data
public class DrivePageDTO {
    private String scope;      // CORP | DEPT | EMP
    private String empNo;      // 세션에서
    private String deptNo;     // 세션에서
    private String keyword;    // 파일명 검색

    // 페이지네이션(전부 String으로)
    private String page;       // 현재 페이지(기본 "1")
    private String size;       // 페이지당 개수(기본 "10")
    private String blockSize;  // 페이지블록 크기(기본 "10")

    private String totalCount;
    private String totalPage;
    private String startPage;
    private String endPage;
    private String startRow;   // rownum 기준 시작
    private String endRow;     // rownum 기준 끝
}