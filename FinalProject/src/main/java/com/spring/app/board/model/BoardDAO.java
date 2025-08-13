package com.spring.app.board.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.repository.query.Param;

import com.spring.app.board.domain.BoardCategoryDTO;

@Mapper
public interface BoardDAO {

	// 부모글 제목 조회
	  String findTitleById(@Param("board_no") String boardNo);

	// 게시판(카테고리) 추가 처리
	  int addBoardCategory(BoardCategoryDTO boardCategoryDto);

	// 게시판 목록/메인 (사이드바 카테고리)
	  List<BoardCategoryDTO> getBoardCategories();
		
	

	 

	

}











