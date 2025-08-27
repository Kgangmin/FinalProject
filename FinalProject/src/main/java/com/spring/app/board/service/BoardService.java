// src/main/java/com/spring/app/board/service/BoardService.java
package com.spring.app.board.service;

import java.util.List;
import java.util.Map;

import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.domain.BoardFileDTO;
import com.spring.app.board.domain.CategoryDTO;
import com.spring.app.board.domain.CommentDTO;


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

    List<CommentDTO> getComments(String boardNo);
    
    BoardDTO getBoardAndTouchRead(String boardNo, String empNo, String deptNo);
    BoardDTO prevBoard(String catNo, String boardNo);
    BoardDTO nextBoard(String catNo, String boardNo);

    List<Map<String,String>> getReaders(String boardNo);
    int countReaders(String boardNo);

    List<BoardFileDTO> getFilesByBoardNo(String boardNo);
    BoardFileDTO getFileByNo(String fileNo);

    CategoryDTO getFirstWritableCategoryForDept(String deptNo);
    CategoryDTO pickWriteRedirectCategory(String deptNo); // (부서 우선, 없으면 자유게시판)
    
    // 글/파일/댓글
    String writeBoard(BoardDTO dto, List<BoardFileDTO> filesMeta);
    void writeComment(CommentDTO c);

    BoardDTO getBoard(String boardNo); // 조회수 증가/읽은사람 기록 없음
    
    // 관리자
    String createDepartmentCategory(String adminDeptNo, String boardCategoryName,
                                    String targetDeptNo, String isCommentEnabled, String isReadEnabled);
    
 // BoardService.java (추가)
    void deleteDepartmentCategoryForce(String adminDeptNo, String catNo, String uploadDir);


    void deleteBoardByOwner(String boardNo, String empNo, String uploadDir);


    CommentDTO getCommentByNo(String commentNo);
    void deleteCommentByOwner(String commentNo, String empNo);

 // 1) 전사 + 해당 부서가 볼 수 있는 카테고리만 리턴
    List<CategoryDTO> getVisibleCategories(String deptNo, String empNo);

 

    
    
}
