// src/main/java/com/spring/app/board/service/BoardServiceImpl.java
package com.spring.app.board.service;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.domain.BoardFileDTO;
import com.spring.app.board.domain.CategoryDTO;
import com.spring.app.board.domain.CommentDTO;
import com.spring.app.board.model.BoardDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BoardServiceImpl implements BoardService {

    private final BoardDAO dao;
 // ★ 관리자 부서번호 상수(문자열 '01')
    private static final String ADMIN_DEPT_NO = "01";

    // ========= 카테고리 =========
    @Override
    public CategoryDTO getCategoryByNo(String no) {
        return dao.selectCategoryByNo(no);
    }

    @Override
    public CategoryDTO getCategoryByName(String name) {
        return dao.selectCategoryByName(name);
    }

    @Override
    public List<CategoryDTO> getAllCategories() {
        return dao.selectAllCategories();
    }

    // ========= 권한 =========
    @Override
    public boolean canRead(String catNo, String empNo, String deptNo, String catName) {
        // 관리자 부서(01)는 모두 허용
        if (deptNo != null && deptNo.trim().equals("01")) return true;

        // 전사 3종은 모두 허용
        String nm = (catName == null ? "" : catName).replace(" ", "");
        if ("전사공지".equals(nm) || "전사알림".equals(nm) || "자유게시판".equals(nm)) {
            return true;
        }
        // 부서/개별 권한 READ/WRITE/ADMIN 중 하나라도 있으면 허용
        int cnt = dao.existsReadPermission(catNo, empNo, deptNo);
        return cnt > 0;
    }

    @Override
    public boolean canWrite(String catNo, String empNo, String deptNo, String catName) {
        // 관리자 부서(01)는 모두 허용
        if (deptNo != null && deptNo.trim().equals("01")) return true;

        // 자유게시판은 전사 쓰기 허용
        String nm = (catName == null ? "" : catName).replace(" ", "");
        if ("자유게시판".equals(nm)) return true;

        // 부서/개별 권한 WRITE/ADMIN 있으면 허용
        int cnt = dao.existsWritePermission(catNo, empNo, deptNo);
        return cnt > 0;
    }

    // ========= 목록/상세 =========
    @Override
    public int countBoardList(Map<String, String> param) {
        return dao.countBoardList(param);
    }

    @Override
    public List<BoardDTO> selectBoardList(Map<String, String> param) {
        return dao.selectBoardList(param);
    }

    @Override
    @Transactional
    public BoardDTO getBoardAndTouchRead(String boardNo, String empNo, String deptNo) {
        BoardDTO b = dao.selectBoardByNo(boardNo);
        if (b == null) return null;

        CategoryDTO cat = dao.selectCategoryByNo(b.getFk_board_category_no());
        if (cat == null) return null;

        if (!canRead(cat.getBoard_category_no(), empNo, deptNo, cat.getBoard_category_name())) {
            return null; // 컨트롤러에서 "권한 없음" 안내
        }

        dao.increaseViewCnt(boardNo);

        if ("Y".equals(cat.getIs_read_enabled())) {
            // 읽은 사람 기록 (중복시 무시)
            dao.insertReadIfAbsent(boardNo, empNo);
        }
        return dao.selectBoardByNo(boardNo);
    }

    @Override
    public BoardDTO prevBoard(String catNo, String boardNo) {
        return dao.selectPrevBoard(catNo, boardNo);
    }

    @Override
    public BoardDTO nextBoard(String catNo, String boardNo) {
        return dao.selectNextBoard(catNo, boardNo);
    }

    @Override
    public List<Map<String, String>> getReaders(String boardNo) {
        return dao.selectReaders(boardNo);
    }

    @Override
    public int countReaders(String boardNo) {
        return dao.countReaders(boardNo);
    }

    // ========= 글/파일/댓글 =========
    @Override
    @Transactional
    public String writeBoard(BoardDTO dto, List<BoardFileDTO> filesMeta) {
        // PK는 mapper의 selectKey가 dto.board_no에 세팅됨
        int n = dao.insertBoard(dto);
        if (n != 1) throw new RuntimeException("게시글 저장 실패");

        if (filesMeta != null) {
            for (BoardFileDTO f : filesMeta) {
                f.setFk_board_no(dto.getBoard_no());
                dao.insertBoardFile(f);
            }
        }
        return dto.getBoard_no();
    }

    @Override
    @Transactional
    public void writeComment(CommentDTO c) {
        dao.insertComment(c);
    }
    
    @Override
    public BoardDTO getBoard(String boardNo) {
        return dao.selectBoardByNo(boardNo);
    }
    
    @Override
    public List<CommentDTO> getComments(String boardNo) {
        return dao.selectComments(boardNo);
    }

    @Override
    public List<BoardFileDTO> getFilesByBoardNo(String boardNo) {
        return dao.selectFilesByBoardNo(boardNo);
    }

    @Override
    public BoardFileDTO getFileByNo(String fileNo) {
        return dao.selectFileByNo(fileNo);
    }

    @Override
    public CategoryDTO getFirstWritableCategoryForDept(String deptNo) {
        if (deptNo == null || deptNo.isBlank()) return null;
        return dao.selectFirstWritableCategoryByDept(deptNo.trim());
    }

    @Override
    public CategoryDTO pickWriteRedirectCategory(String deptNo) {
        CategoryDTO deptCat = getFirstWritableCategoryForDept(deptNo);
        if (deptCat != null) return deptCat;
        return dao.selectCategoryByName("자유게시판"); // 안전망
    }
    
    

    private String trimOrEmpty(String s){ return s==null? "": s.trim(); }

    // ========= 관리자: 카테고리 생성 =========
    @Override
    @Transactional
    public String createDepartmentCategory(String adminDeptNo, String boardCategoryName,
                                           String targetDeptNo, String isCommentEnabled, String isReadEnabled) {
        // ★ 관리자 부서번호 = "01" 만 허용
        if (!ADMIN_DEPT_NO.equals(trimOrEmpty(adminDeptNo))) {
            throw new RuntimeException("권한 없음(관리자만 생성 가능)");
        }

        // (선택) 중복 방지: 같은 이름 카테고리 존재 여부 체크
        CategoryDTO exists = dao.selectCategoryByName(boardCategoryName);
        if (exists != null) throw new RuntimeException("동일한 카테고리명이 이미 존재합니다.");

        String catNo = dao.nextCategoryNo();

        CategoryDTO c = new CategoryDTO();
        c.setBoard_category_no(catNo);
        c.setBoard_category_name(boardCategoryName);
        c.setIs_comment_enabled(isCommentEnabled);
        c.setIs_read_enabled(isReadEnabled);

        int inserted = dao.insertCategory(c);
        if (inserted != 1) throw new RuntimeException("카테고리 생성 실패");

        // 기본 권한: 대상 부서 READ/WRITE
        dao.insertPermission(catNo, "DEPT", targetDeptNo, "READ");
        dao.insertPermission(catNo, "DEPT", targetDeptNo, "WRITE");

        // ★ 관리자(부서 01)에게 ADMIN 권한 부여 (감사/관리 용도)
        dao.insertPermission(catNo, "DEPT", ADMIN_DEPT_NO, "ADMIN");

        return catNo;
    }
    
    
 // src/main/java/com/spring/app/board/service/BoardServiceImpl.java

    @Override
    @Transactional
    public void deleteDepartmentCategoryForce(String adminDeptNo, String catNo, String uploadDir) {
        if (!"01".equals(adminDeptNo)) {
            throw new RuntimeException("권한 없음(관리자만 삭제 가능)");
        }

        CategoryDTO cat = dao.selectCategoryByNo(catNo);
        if (cat == null) throw new RuntimeException("존재하지 않는 카테고리입니다.");

        String nm = (cat.getBoard_category_name()==null?"":cat.getBoard_category_name().replace(" ",""));
        if ("전사공지".equals(nm) || "전사알림".equals(nm) || "자유게시판".equals(nm)) {
            throw new RuntimeException("해당 게시판은 삭제할 수 없습니다.");
        }

        // 1) 물리 파일 삭제용 저장파일명 목록 미리 조회
        List<String> saveNames = dao.selectSaveFilenamesByCat(catNo);

        // 2) 자식 → 부모 순서로 삭제
        dao.deleteBoardReadByCat(catNo);
        dao.deleteBoardFileByCat(catNo);
        dao.deleteCommentByCat(catNo);
        dao.deleteBoardByCat(catNo);
        dao.deletePermissionByCat(catNo);
        dao.deleteCategory(catNo);

        // 3) 물리 파일 정리(베스트 에포트)
        if (saveNames != null && uploadDir != null) {
            File dir = new File(uploadDir);
            for (String name : saveNames) {
                if (name == null) continue;
                try {
                    File f = new File(dir, name);
                    if (f.exists()) f.delete();
                } catch (Exception ignore) {}
            }
        }
    }

 // BoardServiceImpl.java (추가)
    @Override
    @Transactional
    public void deleteBoardByOwner(String boardNo, String empNo, String uploadDir) {
        BoardDTO b = dao.selectBoardByNo(boardNo);
        if (b == null) throw new RuntimeException("존재하지 않는 글입니다.");

        // 소유자 검증
        if (empNo == null || !empNo.equals(b.getFk_emp_no())) {
            throw new RuntimeException("본인이 작성한 글만 삭제할 수 있습니다.");
        }

        // 1) 파일 저장명 먼저 조회(물리파일 삭제용)
        List<String> saveNames = dao.selectSaveFilenamesByBoard(boardNo);

        // 2) 자식 → 부모 순서 삭제
        dao.deleteBoardReadByBoard(boardNo);
        dao.deleteBoardFileByBoard(boardNo);
        dao.deleteCommentByBoard(boardNo);
        dao.deleteBoard(boardNo);

        // 3) 물리파일 삭제 (best effort)
        if (saveNames != null && uploadDir != null) {
            File dir = new File(uploadDir);
            for (String name : saveNames) {
                if (name == null) continue;
                try {
                    File f = new File(dir, name);
                    if (f.exists()) f.delete();
                } catch (Exception ignore) {}
            }
        }
    }

 // BoardServiceImpl.java (추가)
    @Override
    public CommentDTO getCommentByNo(String commentNo) {
        return dao.selectCommentByNo(commentNo);
    }

    @Override
    @Transactional
    public void deleteCommentByOwner(String commentNo, String empNo) {
        CommentDTO c = dao.selectCommentByNo(commentNo);
        if (c == null) throw new RuntimeException("존재하지 않는 댓글입니다.");
        if (empNo == null || !empNo.equals(c.getFk_emp_no())) {
            throw new RuntimeException("본인이 작성한 댓글만 삭제할 수 있습니다.");
        }
        dao.deleteCommentByNo(commentNo);
    }

    
    

        
}
