// DriveService.java
package com.spring.app.drive.service;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.spring.app.drive.domain.DriveDTO;
import com.spring.app.drive.domain.DrivePageDTO;

import jakarta.servlet.http.HttpServletResponse;

public interface DriveService {
    int count(DrivePageDTO p);
    List<DriveDTO> list(DrivePageDTO p);
    Map<String, Long> capacity(String scope, String empNo, String deptNo); // used,total

    void upload(MultipartFile file, String scope, String empNo, String deptNo) throws IOException;

    // 권한 인자 포함(컨트롤러에서 사용)
    void downloadSingle(String boardFileNo, String scope, String empNo, String deptNo, HttpServletResponse resp) throws IOException;
    void downloadMulti(List<String> ids, String scope, String empNo, String deptNo, HttpServletResponse resp) throws IOException;

    int deleteByIds(List<String> ids, String scope, String empNo, String deptNo);

    // (선택) 레거시 시그니처 — 기존 코드 호환용
    @Deprecated
    default void downloadSingle(String boardFileNo, HttpServletResponse resp) throws IOException {
        throw new UnsupportedOperationException("downloadSingle(boardFileNo, resp) 대신 권한 인자 포함 오버로드를 사용하세요.");
    }

    @Deprecated
    default void downloadMulti(List<String> ids, HttpServletResponse resp) throws IOException {
        throw new UnsupportedOperationException("downloadMulti(ids, resp) 대신 권한 인자 포함 오버로드를 사용하세요.");
    }
}
