package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProposalDTO {
	
	private String fk_draft_no;      
	private String background;         
	private String proposal_content; 
	private String expected_effect; 

}
