package com.spring.app.draft.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;


@Mapper
public interface DraftDAO {

	List<DraftDTO> getdraftList(Map<String, String> map);

	int getdraftcount(Map<String, String> map);

	Map<String, String>  getdraftdetail(String draft_no);
	
	List<ExpenseDTO> getexpenseList(String draft_no);

	List<Map<String, String>> getapprovalLine(String draft_no);

	List<Map<String, String>> getfileList(String draft_no);

	
	

}
