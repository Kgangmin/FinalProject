package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApprovalLineDTO {
	
	private String	fk_draft_no;
	private String fk_approval_emp_no; // 결재자 사번
    private Integer approval_order;    // 결재 순서(1,2,3…)
	
}
