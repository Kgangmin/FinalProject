package com.spring.app.draft.domain;

import java.util.Date;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProposalDTO {
	
	private String fk_draft_no;      
	private String background;         
	private String proposal_content; 
	private String expected_effect; 

	private String task_title;
	
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date start_date;
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date end_date;
	
	private String fk_owner_emp_no;
	private String owner_emp_name ;
	private List<ProposalDeptDTO> departments; 		// tbl_proposal_department
	private List<ProposalAccessDTO> accesses;        // tbl_proposal_access
}
