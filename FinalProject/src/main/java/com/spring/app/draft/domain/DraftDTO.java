package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DraftDTO {

	
	       
	 private String 	draft_no; 
	 private String 	fk_draft_emp_no;   
	 private String		draft_type;
	 private String		draft_title;
	 private String		draft_date;            
	 private String 	approval_status;
	 private String		is_attached;
}
