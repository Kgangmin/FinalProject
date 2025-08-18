package com.spring.app.draft.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.spring.app.draft.domain.DraftDTO;
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
	public DraftDTO getdraftdetail(String draft_no) {
		
		DraftDTO ddto = Ddao.getdraftdetail(draft_no);
		return ddto;
	}

}
