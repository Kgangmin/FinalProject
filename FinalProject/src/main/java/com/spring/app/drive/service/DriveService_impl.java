package com.spring.app.drive.service;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.drive.domain.DriveDTO;
import com.spring.app.drive.domain.DrivePageDTO;
import com.spring.app.drive.domain.DriveUploadDTO;
import com.spring.app.drive.model.DriveDAO;

import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DriveService_impl implements DriveService {

    private final DriveDAO driveDAO;
    private final Environment env;

    private String uploadRoot;
    private long CAP_CORP;
    private long CAP_DEPT;
    private long CAP_EMP;

    @PostConstruct
    void init() throws Exception {
        this.uploadRoot = env.getProperty("file.upload.root", "C:/temp/uploads");
        this.CAP_CORP   = env.getProperty("drive.capacity.corp", Long.class, 1L * 1024 * 1024 * 1024); 
        this.CAP_DEPT   = env.getProperty("drive.capacity.dept", Long.class, 50L * 1024 * 1024); 
        this.CAP_EMP    = env.getProperty("drive.capacity.emp",  Long.class, 5L * 1024 * 1024); 

        Files.createDirectories(Paths.get(uploadRoot));
        Files.createDirectories(Paths.get(uploadRoot, "corp"));
        Files.createDirectories(Paths.get(uploadRoot, "dept"));
        Files.createDirectories(Paths.get(uploadRoot, "emp"));
    }

    /**
     * 카테고리 키 매핑 (테이블의 FK_BOARD_CATEGORY_NO에 저장/조회할 값)
     * - 전사: 고정 "DR_CORP"
     * - 부서: "DR_{deptNo}" (예: 5010 -> DR_5010)
     * - 개인: 고정 "DR_EMP"
     */
    private String resolveCategory(String scope, String empNo, String deptNo) {
        if (scope == null) throw new IllegalArgumentException("scope is null");
        switch (scope) {
            case "CORP": return "DR_CORP";
            case "DEPT":
                if (deptNo == null || deptNo.isBlank())
                    throw new IllegalArgumentException("deptNo required for DEPT scope");
                return "DR_" + deptNo;
            case "EMP":  return "DR_EMP";
            default: throw new IllegalArgumentException("invalid scope: " + scope);
        }
    }

    private void computePaging(DrivePageDTO p) {
        int page  = Integer.parseInt(Optional.ofNullable(p.getPage()).orElse("1"));
        int size  = Integer.parseInt(Optional.ofNullable(p.getSize()).orElse("10"));
        int block = Integer.parseInt(Optional.ofNullable(p.getBlockSize()).orElse("10"));

        int total = Integer.parseInt(Optional.ofNullable(p.getTotalCount()).orElse("0"));
        int totalPage = Math.max(1, (int)Math.ceil(total / (double) size)); // 최소 1

        if (page < 1) page = 1;
        if (page > totalPage) page = totalPage;

        int startRow = (page - 1) * size + 1; // 1-based
        int endRow   = page * size;

        int startPage = ((page - 1) / block) * block + 1;
        int endPage   = Math.min(startPage + block - 1, totalPage);

        p.setPage(String.valueOf(page));
        p.setSize(String.valueOf(size));
        p.setBlockSize(String.valueOf(block));
        p.setTotalPage(String.valueOf(totalPage));
        p.setStartRow(String.valueOf(startRow));
        p.setEndRow(String.valueOf(endRow));
        p.setStartPage(String.valueOf(startPage));
        p.setEndPage(String.valueOf(endPage));
    }

    @Override
    public int count(DrivePageDTO p) {
        String category = resolveCategory(p.getScope(), p.getEmpNo(), p.getDeptNo());
        // DAO: countFiles(@Param("categoryNo") String categoryNo,
        //                 @Param("scope") String scope,
        //                 @Param("empNo") String empNo,
        //                 @Param("keyword") String keyword)
        return driveDAO.countFiles(category, p.getScope(), p.getEmpNo(), p.getKeyword());
    }

    @Override
    public List<DriveDTO> list(DrivePageDTO p) {
        int total = count(p);
        p.setTotalCount(String.valueOf(total));
        computePaging(p);

        String category = resolveCategory(p.getScope(), p.getEmpNo(), p.getDeptNo());
        int startRow = Integer.parseInt(p.getStartRow());
        int endRow   = Integer.parseInt(p.getEndRow());

        // DAO: selectFiles(categoryNo, scope, empNo, keyword, startRow, endRow)
        return driveDAO.selectFiles(
                category,
                p.getScope(),
                p.getEmpNo(),
                p.getKeyword(),
                startRow,
                endRow
        );
    }

    @Override
    public Map<String, Long> capacity(String scope, String empNo, String deptNo) {
        String category = resolveCategory(scope, empNo, deptNo);
        // DAO: sumFilesize(categoryNo, scope, empNo)
        Long used = driveDAO.sumFilesize(category, scope, empNo);

        long total;
        switch (scope) {
            case "CORP": total = CAP_CORP; break;
            case "DEPT": total = CAP_DEPT; break;
            case "EMP":  total = CAP_EMP;  break;
            default: throw new IllegalArgumentException("invalid scope");
        }

        long usedVal = (used == null ? 0L : used);
        Map<String, Long> r = new HashMap<>();
        r.put("used", usedVal);
        r.put("total", total);
        r.put("remain", Math.max(0, total - usedVal));
        return r;
    }

    @Override
    @Transactional
    public void upload(MultipartFile file, String scope, String empNo, String deptNo) throws IOException {
        if (file == null || file.isEmpty()) throw new IllegalArgumentException("파일이 비어있음");

        // 용량 체크
        Map<String, Long> cap = capacity(scope, empNo, deptNo);
        if (cap.get("used") + file.getSize() > cap.get("total")) {
            throw new IllegalStateException("용량 초과");
        }

        // 저장 파일명
        String origin = file.getOriginalFilename();
        String uuid = UUID.randomUUID().toString().replace("-", "");
        String save = uuid + "_" + origin;

        // 물리 저장
        Path dir = Paths.get(uploadRoot, scope.toLowerCase()); // corp/dept/emp
        Files.createDirectories(dir);
        Path dest = dir.resolve(save);
        try (InputStream in = file.getInputStream()) {
            Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
        }

        // DB 기록
        if (empNo == null || empNo.isBlank()) {
            throw new IllegalStateException("로그인 정보(empNo)가 없습니다.");
        }
        if ("DEPT".equalsIgnoreCase(scope) && (deptNo == null || deptNo.isBlank())) {
            throw new IllegalStateException("부서 자료실은 deptNo가 필요합니다.");
        }

        DriveUploadDTO dto = new DriveUploadDTO();
        dto.setCategoryNo(resolveCategory(scope, empNo, deptNo)); // FK_BOARD_CATEGORY_NO
        dto.setEmpNo(empNo);                                      // ★ 반드시 세팅 (FK_EMP_NO NOT NULL)
        dto.setDeptNo(deptNo);                                    // (XML에서 FK_DEPT_NO는 사용하지 않지만 DTO에 보관)
        dto.setOriginFilename(origin);
        dto.setSaveFilename(save);
        dto.setFilesize(String.valueOf(file.getSize()));

        driveDAO.insertBoard(dto);      // boardNo selectKey 채움
        driveDAO.insertBoardFile(dto);  // fileNo selectKey 채움
    }

    @Override
    public void downloadSingle(String boardFileNo, HttpServletResponse resp) throws IOException {
        // 접근제어 포함된 조회 사용
        throw new UnsupportedOperationException("downloadSingle(boardFileNo, resp) 오버로드 대신 권한 인자를 포함한 메서드를 사용하세요.");
    }

    // 권장: 접근제어 포함 다운로드(컨트롤러에서 scope/empNo/deptNo 넘김) - deptNo는 사용하지 않음
    public void downloadSingle(String boardFileNo, String scope, String empNo, String deptNo, HttpServletResponse resp) throws IOException {
        // DAO: selectFileByFileNo(boardFileNo, scope, empNo)
        DriveDTO f = driveDAO.selectFileByFileNo(boardFileNo, scope, empNo);
        if (f == null) throw new FileNotFoundException("파일 없음 또는 접근권한 없음");

        Path path = findFileOnDisk(f.getBoardSaveFilename());
        streamFile(resp, path, f.getBoardOriginFilename());
    }

    @Override
    public void downloadMulti(List<String> ids, HttpServletResponse resp) throws IOException {
        throw new UnsupportedOperationException("downloadMulti(ids, resp) 오버로드 대신 권한 인자를 포함한 메서드를 사용하세요.");
    }

    // 권장: 접근제어 포함 다건 다운로드 - deptNo는 사용하지 않음
    public void downloadMulti(List<String> ids, String scope, String empNo, String deptNo, HttpServletResponse resp) throws IOException {
        if (ids == null || ids.isEmpty()) throw new IllegalArgumentException("선택된 파일 없음");

        // DAO: selectFilesByFileNos(ids, scope, empNo)
        List<DriveDTO> files = driveDAO.selectFilesByFileNos(ids, scope, empNo);

        resp.setContentType("application/zip");
        resp.setHeader("Content-Disposition", "attachment; filename=\"drive_files.zip\"");

        try (java.util.zip.ZipOutputStream zos = new java.util.zip.ZipOutputStream(resp.getOutputStream())) {
            for (DriveDTO f : files) {
                Path p = findFileOnDisk(f.getBoardSaveFilename());
                if (!Files.exists(p)) continue;
                java.util.zip.ZipEntry entry = new java.util.zip.ZipEntry(f.getBoardOriginFilename());
                zos.putNextEntry(entry);
                Files.copy(p, zos);
                zos.closeEntry();
            }
            zos.finish();
        }
    }

    @Override
    @Transactional
    public int deleteByIds(List<String> ids, String scope, String empNo, String deptNo) {
        if (ids == null || ids.isEmpty()) return 0;

        // 접근제어 반영된 대상 조회
        List<DriveDTO> targets = driveDAO.selectFilesByFileNos(ids, scope, empNo);

        // 물리 파일 삭제
        for (DriveDTO f : targets) {
            try {
                Path p = findFileOnDisk(f.getBoardSaveFilename());
                Files.deleteIfExists(p);
            } catch (Exception ignore) {}
        }

        // DB 삭제: 파일 → 게시글(접근제어 포함)
        int delFiles = driveDAO.deleteFilesByFileNos(ids, scope, empNo);

        List<String> boardNos = targets.stream()
                .map(DriveDTO::getBoardNo)
                .distinct()
                .collect(Collectors.toList());

        if (!boardNos.isEmpty()) {
            driveDAO.deleteBoardsByBoardNos(boardNos, scope, empNo);
        }
        return delFiles;
    }

    private Path findFileOnDisk(String saveName) {
        for (String s : Arrays.asList("corp", "dept", "emp")) {
            Path p = Paths.get(uploadRoot, s, saveName);
            if (Files.exists(p)) return p;
        }
        return Paths.get(uploadRoot, saveName); // fallback
    }

    private void streamFile(HttpServletResponse resp, Path path, String downloadName) throws IOException {
        if (!Files.exists(path)) throw new FileNotFoundException("물리 파일 없음: " + path);
        String enc = java.net.URLEncoder.encode(downloadName, java.nio.charset.StandardCharsets.UTF_8)
                .replaceAll("\\+", "%20");
        resp.setContentType("application/octet-stream");
        resp.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + enc);
        resp.setHeader("Content-Length", String.valueOf(Files.size(path)));
        try (OutputStream out = resp.getOutputStream()) {
            Files.copy(path, out);
        }
    }
}
