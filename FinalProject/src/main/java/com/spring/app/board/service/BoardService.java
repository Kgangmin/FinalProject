// src/main/java/com/spring/app/board/service/BoardService.java
package com.spring.app.board.service;

import java.util.List;
import java.util.Map;

import com.spring.app.board.domain.*;

public interface BoardService {

    // 카테고리
    CategoryDTO getCategoryByNo(String no);
    CategoryDTO getCategoryByName(String name);
    List<CategoryDTO> getAllCategories();

    // 권한
    boolean canRead(String catNo, String empNo, String deptNo, String catName);
    boolean canWrite(String catNo, String empNo, String deptNo, String catName);

    // 목록/상세 (이미 쓰고 있는 시그니처 유지)
    int countBoardList(Map<String,String> param);
    List<BoardDTO> selectBoardList(Map<String,String> param);

    BoardDTO getBoardAndTouchRead(String boardNo, String empNo, String deptNo);
    BoardDTO prevBoard(String catNo, String boardNo);
    BoardDTO nextBoard(String catNo, String boardNo);

    List<Map<String,String>> getReaders(String boardNo);
    int countReaders(String boardNo);

    // 글/파일/댓글
    String writeBoard(BoardDTO dto, List<BoardFileDTO> filesMeta);
    void writeComment(CommentDTO c);

    // 관리자
    String createDepartmentCategory(String adminDeptNo, String boardCategoryName,
                                    String targetDeptNo, String isCommentEnabled, String isReadEnabled);
}
