package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LeaveDTO {

	private String	fk_draft_no;
	private String	fk_leave_type_no;
	private String	start_date;      
	private String	end_date;             
	private String	leave_days;    
	private String	leave_remark;     
}
