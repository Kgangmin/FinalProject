package com.spring.app.board.domain;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class BoardFileDTO {

	 public String board_file_no;
	    public String fk_board_no;
	    public String board_origin_filename;
	    public String board_save_filename;
	    public String board_filesize;
}
