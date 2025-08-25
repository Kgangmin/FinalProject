package com.spring.app.draft.domain;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LeaveDTO {

	private String	fk_draft_no;
	private String	fk_leave_type_no;
	
	@DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
	private Date	start_date;      
	
	@DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
	private Date	end_date;     
	
	private String	leave_days;    
	private String	leave_remark;     
}
