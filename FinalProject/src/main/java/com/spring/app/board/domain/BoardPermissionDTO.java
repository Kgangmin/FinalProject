package com.spring.app.board.domain;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class BoardPermissionDTO {

	  public String fk_board_category_no;
	    public String target_type;     // 'DEPT' | 'EMP'
	    public String target_no;       // 부서번호 또는 사번
	    public String permission_type; // 'READ' | 'WRITE' | 'ADMIN'
}
