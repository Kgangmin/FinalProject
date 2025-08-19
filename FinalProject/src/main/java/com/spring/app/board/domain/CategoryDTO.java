package com.spring.app.board.domain;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class CategoryDTO {

	public String board_category_no;     // PK
    public String board_category_name;   // '전사공지','전사알림','자유게시판', '영업부', ...
    public String is_comment_enabled;    // 'Y'/'N' (카테고리 차원의 댓글 기능 허용)
    public String is_read_enabled;       // 'Y'/'N' (카테고리 차원의 '읽은 사람' 기능 허용)
}
