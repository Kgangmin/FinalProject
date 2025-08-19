package com.spring.app.draft.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.model.DraftDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DraftService_imple implements DraftService {
	
	private final DraftDAO Ddao;
	
	// 결제목록 가져오기
	@Override
	public List<DraftDTO>getdraftList(Map<String, String> map) {
		
		List<DraftDTO> getdraftList = Ddao.getdraftList(map);
	
		return getdraftList;
	}

	@Override
	public int getdraftcount(Map<String, String> map) {
		int getdraftcount = Ddao.getdraftcount(map);
		return getdraftcount;
	}
	
	
	// 결제 상세 가져오기
	@Override
	public Map<String, String>  getdraftdetail(String draft_no) {
		
		Map<String, String> ddto = Ddao.getdraftdetail(draft_no);
		return ddto;
	}
	// 지출결의서리스트 내용 가져오기
	@Override
	public List<ExpenseDTO> getexpenseList(String draft_no) {
		List<ExpenseDTO> expenseList = Ddao.getexpenseList(draft_no);
		return expenseList;
	}
	// 결제라인 가져오기
	@Override
	public List<Map<String, String>> getapprovalLine(String draft_no) {
		
		List<Map<String, String>> approvalLine = Ddao.getapprovalLine(draft_no);
		return approvalLine;
	}
	// 결제건에 파일첨부 가져오기
	@Override
	public List<Map<String, String>> getfileList(String draft_no) {
		
		List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
		return getfileList;
	}

}
