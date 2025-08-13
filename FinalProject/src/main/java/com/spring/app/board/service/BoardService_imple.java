package com.spring.app.board.service;

import org.springframework.stereotype.Service;

import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.model.BoardDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BoardService_imple implements BoardService {

	private final BoardDAO boardDAO;
	
	
	

	// 부모글 제목 조회 (답글 폼에서 [답변] 용)
	@Override
	public String findTitleById(String board_no) {

		return boardDAO.findTitleById(board_no);  // 바로 DAO 호출
		
		
	}

	
}
	