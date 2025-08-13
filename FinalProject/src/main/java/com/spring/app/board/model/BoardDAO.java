package com.spring.app.board.model;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.repository.query.Param;

import com.spring.app.board.domain.BoardDTO;

@Mapper
public interface BoardDAO {

	// 부모글 제목 조회
	  String findTitleById(@Param("board_no") String boardNo);
		
	

	 

	

}











