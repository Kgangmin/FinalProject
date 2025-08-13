package com.spring.app.draft.service;

import java.util.List;
import java.util.Map;

import com.spring.app.draft.domain.DraftDTO;

public interface DraftService {
	// 결제목록 가져오기
	List<DraftDTO> getdraftList(Map<String, String> map);
	//페이징 처리할 수 가져오기
	int getdraftcount(Map<String, String> map);
	
	

}
