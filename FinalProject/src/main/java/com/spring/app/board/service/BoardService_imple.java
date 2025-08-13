package com.spring.app.board.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.spring.app.board.domain.BoardCategoryDTO;
import com.spring.app.board.model.BoardDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BoardService_imple implements BoardService {

	private final BoardDAO boardDAO;

	// 게시판 목록/메인 (사이드바 카테고리)
	@Override
	public List<BoardCategoryDTO> getBoardCategories() {

		return boardDAO.getBoardCategories();
	}
		
	// 부모글 제목 조회 (답글 폼에서 [답변] 용)
	@Override
	public String findTitleById(String board_no) {

		return boardDAO.findTitleById(board_no);  // 바로 DAO 호출
	
	}

	// 게시판(카테고리) 추가 처리
	@Override
	public int addBoardCategory(BoardCategoryDTO boardCategoryDto) {
		
		return boardDAO.addBoardCategory(boardCategoryDto);
	}

	

	
}
	