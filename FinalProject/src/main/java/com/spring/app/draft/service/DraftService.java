package com.spring.app.draft.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.domain.LeaveDTO;
import com.spring.app.draft.domain.ProposalDTO;

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
	// 문서 업데이트 / 인서트
	void draftSave(DraftDTO draft, List<MultipartFile> fileList, String path);
	void expenseSave(List<ExpenseDTO> expenseList , String draft_no);
	void fileSave(List<MultipartFile> fileList, String path ,String draft_no );
	// 다운로드할 파일 1개 가져오기
	Map<String, String> getfileOne(String draft_file_no);
	// 파일 지우기
	void filedelete(List<String> del_draft_file_no, String path , String draft_no);
	// 휴가 신청가져오기
	LeaveDTO getLeave(String draft_no);
	// 휴가타입 가져오기
	List<Map<String, String>> getleaveType();
	// 휴가신청 저장
	void leaveSave(LeaveDTO leave);
	// 업무기안 가져오기
	ProposalDTO getproposal(String draft_no);
	
	
	

}