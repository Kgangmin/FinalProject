package com.spring.app.board.service;

import java.util.List;
import java.util.Map;

import com.spring.app.board.domain.BoardDTO;


public interface BoardService {

	// 부모글 제목 조회 (답글 폼에서 [답변] 용)
	String findTitleById(String board_no);
		

	
	
}
