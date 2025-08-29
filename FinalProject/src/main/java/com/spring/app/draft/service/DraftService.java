package com.spring.app.draft.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.spring.app.draft.domain.ApprovalLineDTO;
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
	// 다운로드할 파일 1개 가져오기
	Map<String, String> getfileOne(String draft_file_no);
	// 휴가 신청가져오기
	LeaveDTO getLeave(String draft_no);
	// 휴가타입 가져오기
	List<Map<String, String>> getleaveType();
	// 업무기안 가져오기
	ProposalDTO getproposal(String draft_no);
	// 결제목록 가져오기
	List<Map<String, String>> quickSearch(String pattern);
	// 업무 기안 작성
	void insertProposal(DraftDTO draft, ProposalDTO proposal, List<MultipartFile> fileList, String path , List<ApprovalLineDTO> approvalLines);
	// 휴가 신청 작성
	void insertLeave(DraftDTO draft, LeaveDTO leave, List<MultipartFile> fileList, String path, List<ApprovalLineDTO> approvalLines);
	// 지출결의서 작성
	void insertExpense(DraftDTO draft, List<ExpenseDTO> expenseList, List<MultipartFile> fileList, String path, List<ApprovalLineDTO> approvalLines);
	
	void updateExpense(DraftDTO draft, List<ExpenseDTO> expenseList, String draft_no, List<MultipartFile> fileList, String path, List<String> del_draft_file_no);
	
	void updateLeave(DraftDTO draft, LeaveDTO leave, List<MultipartFile> fileList, String path, String draft_no,List<String> del_draft_file_no);
	
	void updateProposal(DraftDTO draft, ProposalDTO proposal, List<MultipartFile> fileList, String path,String draft_no, List<String> del_draft_file_no);
	
	
	
	

}