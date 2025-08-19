package com.spring.app.board.domain;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class CommentDTO {

	  public String comment_no;
	    public String fk_board_no;
	    public String fk_emp_no;
	    public String comment_content;
	    public String register_date;
	    public String update_date;
	    public String delete_date;
	    public String parent_comment_no;
}
