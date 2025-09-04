package com.spring.app.draft.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.draft.domain.ApprovalLineDTO;
import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.domain.LeaveDTO;
import com.spring.app.draft.domain.ProposalAccessDTO;
import com.spring.app.draft.domain.ProposalDTO;
import com.spring.app.draft.domain.ProposalDeptDTO;


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

	void insertProposal(ProposalDTO proposal);

	void insertApprovalLine(ApprovalLineDTO line);

	void insertLeave(LeaveDTO leave);

	int getapprovecount(Map<String, String> map);

	List<DraftDTO> getapproveList(Map<String, String> map);

	int getNextOrder(String draft_no);

	void approveLineUpdate(Map<String, String> apprmap);

	void approveInsert(Map<String, String> apprmap);

	int countLine(Map<String, String> apprmap);

	void draftStatusUpdate(Map<String, String> apprmap);

	int countApprove(Map<String, String> apprmap);

	void updatedraft_status(DraftDTO draft);

	int getapproveReject(Map<String, String> draft_map);

	void approveReset(Map<String, String> draft_map);

	List<Map<String, String>> deptquickSearch(@Param("pattern") String pattern);

	void insertProposalDepartment(@Param("draft_no") String draft_no, @Param("dept_no") String dept_no,	@Param("task_dept_role") String task_dept_role);

	void insertProposalAccess(@Param("draft_no") String draft_no, @Param("target_type") String target_type, @Param("target_no") String target_no);

	List<ProposalDeptDTO> selectProposalDepartments(String draft_no);

	List<ProposalAccessDTO> selectProposalAccesses(String draft_no);

	void deleteProposalDepartments(String draft_no);

	void deleteProposalAccesses(String draft_no);

	void insertProposalDepartment(Map<String, String> draft_map);

	void insertProposalAccess(Map<String, String> draft_map);

	void insertTask(Map<String, String> apprmap);

	List<ProposalDeptDTO> getTaskdept(Map<String, String> apprmap);

	List<ProposalAccessDTO> getaTaskaccess(Map<String, String> apprmap);

	void insertTaskdept(@Param("pd")ProposalDeptDTO pd, @Param("task_no") String task_no);

	void insertTaskaccess(@Param("pa") ProposalAccessDTO pa,@Param("task_no") String task_no);
	
			
	
	

	

	

	
	

}