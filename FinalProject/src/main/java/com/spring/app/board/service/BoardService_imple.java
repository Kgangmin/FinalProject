package com.spring.app.board.service;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

@Service
public class BoardService_imple implements BoardService {

	 @Override
	    public List<Map<String, Object>> getCategories() {
	        // 아직 DB 연결 전이니 일단 빈 리스트 반환해서 화면만 뜨게 함.
	        return Collections.emptyList();
	    }
}
	