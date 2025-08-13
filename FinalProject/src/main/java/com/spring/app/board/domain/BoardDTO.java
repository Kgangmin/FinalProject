package com.spring.app.board.domain;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data 
public class BoardDTO {

	// 게시판
	private String board_no; // 게시글 고유번호
	private String fk_board_category_no; // 게시판구분번호
	private String fk_emp_no; // 작성자 사원번호
	private String board_title; // 게시글제목
	private String board_content; // 게시글내용
	private String is_pinned; // 상단고정여부
	private String view_cnt; // 조회수
	private String register_date; // 작성일시
	private String update_date; // 수정일시
	private String deleted_date; //삭제일시
	
	private String parent_board_no; // 게시글/답변게시글 계층구분
	private String board_priority; // 상단정렬우선순위
	private String is_attached; // 

	
	
	private MultipartFile attach;
	
	
}
