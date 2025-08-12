package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DraftDTO {

	
	 private String		approval_line_no;       
	 private String 	fk_draft_no;          
	 private String 	fk_approval_emp_no;   
	 private String 	approval_order;             
	 private String 	approval_status;      
}
