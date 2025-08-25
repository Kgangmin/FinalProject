// src/main/java/com/spring/app/board/model/BoardDAO.java
package com.spring.app.board.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.domain.BoardFileDTO;
import com.spring.app.board.domain.CategoryDTO;
import com.spring.app.board.domain.CommentDTO;

@Mapper
public interface BoardDAO {

    // 카테고리
    CategoryDTO selectCategoryByNo(@Param("no") String no);
    CategoryDTO selectCategoryByName(@Param("name") String name);
    List<CategoryDTO> selectAllCategories();

    // 권한
    int existsReadPermission(@Param("catNo") String catNo,
                             @Param("empNo") String empNo,
                             @Param("deptNo") String deptNo);

    int existsWritePermission(@Param("catNo") String catNo,
                              @Param("empNo") String empNo,
                              @Param("deptNo") String deptNo);

    // 목록/상세
    int countBoardList(Map<String,String> param);
    List<BoardDTO> selectBoardList(Map<String,String> param);

    List<CommentDTO> selectComments(@org.apache.ibatis.annotations.Param("boardNo") String boardNo);

    
    BoardDTO selectBoardByNo(@Param("boardNo") String boardNo);
    void increaseViewCnt(@Param("boardNo") String boardNo);

    void insertReadIfAbsent(@Param("boardNo") String boardNo, @Param("empNo") String empNo);
    List<Map<String,String>> selectReaders(@Param("boardNo") String boardNo);
    int countReaders(@Param("boardNo") String boardNo);

    BoardDTO selectPrevBoard(@Param("catNo") String catNo, @Param("boardNo") String boardNo);
    BoardDTO selectNextBoard(@Param("catNo") String catNo, @Param("boardNo") String boardNo);

 // 첨부 조회
    List<BoardFileDTO> selectFilesByBoardNo(@Param("boardNo") String boardNo);
    BoardFileDTO selectFileByNo(@Param("fileNo") String fileNo);

    // 내 부서가 WRITE/ADMIN 권한 가진 첫 카테고리(있으면 1개)
    CategoryDTO selectFirstWritableCategoryByDept(@Param("deptNo") String deptNo);
    
    // 글/파일/댓글
    int insertBoard(BoardDTO dto);
    int insertBoardFile(BoardFileDTO f);
    void insertComment(CommentDTO c);

    // 관리자
    String nextCategoryNo();
    int insertCategory(CategoryDTO c);
    int insertPermission(@Param("catNo") String catNo,
                         @Param("targetType") String targetType,
                         @Param("targetNo") String targetNo,
                         @Param("perm") String perm);
    
    

    List<String> selectSaveFilenamesByCat(@Param("catNo") String catNo);

    int deleteBoardReadByCat(@Param("catNo") String catNo);
    int deleteBoardFileByCat(@Param("catNo") String catNo);
    int deleteCommentByCat(@Param("catNo") String catNo);
    int deleteBoardByCat(@Param("catNo") String catNo);
    int deletePermissionByCat(@Param("catNo") String catNo);
    int deleteCategory(@Param("catNo") String catNo);



 // 게시글 삭제
    List<String> selectSaveFilenamesByBoard(@Param("boardNo") String boardNo);

    int deleteBoardReadByBoard(@Param("boardNo") String boardNo);
    int deleteBoardFileByBoard(@Param("boardNo") String boardNo);
    int deleteCommentByBoard(@Param("boardNo") String boardNo);
    int deleteBoard(@Param("boardNo") String boardNo);

 // BoardDAO.java (추가)
    CommentDTO selectCommentByNo(@Param("commentNo") String commentNo);
    int deleteCommentByNo(@Param("commentNo") String commentNo);

    
    
}
