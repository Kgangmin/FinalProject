package com.spring.app.board.service;

import java.util.List;
import java.util.Map;


public interface BoardService {

	// add.jsp에서 카테고리 필요 없으면 이 메서드도 나중에 없애도 됨
    List<Map<String, Object>> getCategories();
	
}
