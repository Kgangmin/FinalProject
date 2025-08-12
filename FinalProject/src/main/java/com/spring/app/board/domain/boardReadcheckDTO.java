package com.spring.app.board.domain;

import lombok.Data;

@Data
public class boardReadcheckDTO {

	private String fk_board_no; // 게시글 고유번호
	private String fk_emp_no; // 사원번호
}
