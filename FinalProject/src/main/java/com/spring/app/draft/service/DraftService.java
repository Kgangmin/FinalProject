package com.spring.app.draft.service;

import java.util.List;
import java.util.Map;

import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;

public interface DraftService {
	// 결제목록 가져오기
	List<DraftDTO> getdraftList(Map<String, String> map);
	//페이징 처리할 수 가져오기
	int getdraftcount(Map<String, String> map);
	// 결제 상세 가져오기
	Map<String, String>  getdraftdetail(String draft_no);
	// 지출결의서리스트 내용 가져오기
	List<ExpenseDTO> getexpenseList(String draft_no);
	// 결제라인 가져오기
	List<Map<String, String>> getapprovalLine(String draft_no);
	// 결제건에 파일첨부 가져오기
	List<Map<String, String>> getfileList(String draft_no);
	
	

}
