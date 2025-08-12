package com.spring.app.board.service;

import java.util.List;
import java.util.Map;

import com.spring.app.board.domain.BoardDTO;


public interface BoardService {

    // 게시글 작성
	int submitPost(BoardDTO boardDto);
	
}
