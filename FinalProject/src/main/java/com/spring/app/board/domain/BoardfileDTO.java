package com.spring.app.board.domain;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class BoardfileDTO {
		
		private String board_file_no; // 게시글첨부파일번호
		private String fk_board_no; // 게시글고유번호
		private String board_origin_filename; // 원본파일명
		private String board_save_filename; // 저장된파일명
		private String board_filesize; // 파일크기
}
