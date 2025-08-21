package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ExpenseDTO {
	
	
	private String fk_draft_no;    
	private String payee_name;    
	private String payee_type;    
	private String payee_account;    
	private String payee_bank;  
	private String expense_type;  
	private String expense_amount;         
	private String expense_date;            
	private String expense_desc;    

}
