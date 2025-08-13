package com.spring.app.board.service;

import java.util.List;

import com.spring.app.board.domain.BoardCategoryDTO;


public interface BoardService {

	// 부모글 제목 조회 (답글 폼에서 [답변] 용)
	String findTitleById(String board_no);

	// 게시판(카테고리) 추가 처리
	int addBoardCategory(BoardCategoryDTO boardCategoryDto);

	// 게시판 목록/메인 (사이드바 카테고리)
	List<BoardCategoryDTO> getBoardCategories();
		

	
	
}
