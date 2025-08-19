// src/main/java/com/spring/app/board/service/BoardServiceImpl.java
package com.spring.app.board.service;

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
        // 관리자 부서(10000)는 모두 허용
        if (deptNo != null && deptNo.trim().equals("10000")) return true;

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
        // 관리자 부서(10000)는 모두 허용
        if (deptNo != null && deptNo.trim().equals("10000")) return true;

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

    // ========= 관리자 =========
    @Override
    @Transactional
    public String createDepartmentCategory(String adminDeptNo, String boardCategoryName,
                                           String targetDeptNo, String isCommentEnabled, String isReadEnabled) {
        if (!"10000".equals(adminDeptNo)) {
            throw new RuntimeException("권한 없음(관리자만 생성 가능)");
        }

        String catNo = dao.nextCategoryNo();

        CategoryDTO c = new CategoryDTO();
        c.setBoard_category_no(catNo);
        c.setBoard_category_name(boardCategoryName);
        c.setIs_comment_enabled(isCommentEnabled);
        c.setIs_read_enabled(isReadEnabled);

        int inserted = dao.insertCategory(c);
        if (inserted != 1) throw new RuntimeException("카테고리 생성 실패");

        // 자동 권한 부여: 대상 부서 READ/WRITE
        dao.insertPermission(catNo, "DEPT", targetDeptNo, "READ");
        dao.insertPermission(catNo, "DEPT", targetDeptNo, "WRITE");

        return catNo;
    }
}
