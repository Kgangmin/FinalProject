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

    BoardDTO selectBoardByNo(@Param("boardNo") String boardNo);
    void increaseViewCnt(@Param("boardNo") String boardNo);

    void insertReadIfAbsent(@Param("boardNo") String boardNo, @Param("empNo") String empNo);
    List<Map<String,String>> selectReaders(@Param("boardNo") String boardNo);
    int countReaders(@Param("boardNo") String boardNo);

    BoardDTO selectPrevBoard(@Param("catNo") String catNo, @Param("boardNo") String boardNo);
    BoardDTO selectNextBoard(@Param("catNo") String catNo, @Param("boardNo") String boardNo);

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
}
