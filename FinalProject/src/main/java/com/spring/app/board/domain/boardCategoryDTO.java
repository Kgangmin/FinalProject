package com.spring.app.board.domain;

import lombok.Data;

@Data
public class boardCategoryDTO {
	
	private String board_category_no; // 게시판구분번호
	private String board_category_name; // 게시판이름
	private String is_comment_enabled; //댓글허용여부
	private String is_read_enabled; // 수신확인 기능 활성화 여부
}
