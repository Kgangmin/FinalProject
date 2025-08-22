package com.spring.app.board.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoardDTO {

	 public String board_no;
	    public String fk_board_category_no;
	    public String fk_emp_no;
	    public String board_title;
	    public String board_content;
	    public String is_pinned;      // 'Y'/'N'
	    public String view_cnt;       // NUMBER -> String으로 다룸
	    public String register_date;  // DATE -> String(TO_CHAR)로 매핑
	    public String update_date;
	    public String deleted_date;
	    public String parent_board_no;
	    public String board_priority; // is_pinned='Y'면 >0, 아니면 null
	    public String is_attached;    // 'Y'/'N'
	    
	 // 목록에서 작성자 이름 표시용 (SQL: e.emp_name AS writer_name)
	    private String writer_name;
	    
}
