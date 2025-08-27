package com.spring.app.draft.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.spring.app.draft.domain.ApprovalLineDTO;
import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.domain.LeaveDTO;
import com.spring.app.draft.domain.ProposalDTO;


@Mapper
public interface DraftDAO {

	List<DraftDTO> getdraftList(Map<String, String> map);

	int getdraftcount(Map<String, String> map);

	Map<String, String>  getdraftdetail(String draft_no);
	
	List<ExpenseDTO> getexpenseList(String draft_no);

	List<Map<String, String>> getapprovalLine(String draft_no);

	List<Map<String, String>> getfileList(String draft_no);

	void draftupdate(DraftDTO draft);

	List<String> selectExpense_no(String draft_no);

	void expenseUpdate(ExpenseDTO e);

	void expenseInsert(ExpenseDTO e);

	void expenseDelete(List<String> delete_ex_no);
	
	void insertfile(Map<String, Object> fileMap);

	Map<String, String> getfileOne(String draft_file_no);

	List<String> getdel_fileList(@Param("list") List<String> del_draft_file_no , @Param("draft_no") String draft_no);

	void file_delete( @Param("draft_no") String draft_no, @Param("list") List<String> del_draft_file_no);

	void updateattch_N(String draft_no);

	void updateattch_Y(String draft_no);

	LeaveDTO getLeave(String draft_no);

	List<Map<String, String>> getleaveType();

	void leaveUpdate(LeaveDTO leave);

	ProposalDTO getproposal(String draft_no);

	void proposalUpdate(ProposalDTO proposal);

	List<Map<String, String>> quickSearch(@Param("pattern") String pattern);

	void insertdraft(DraftDTO draft);

	void insertproposal(ProposalDTO proposal);

	void insertApprovalLine(ApprovalLineDTO line);

	

	
	

}