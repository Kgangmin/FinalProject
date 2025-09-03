package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProposalAccessDTO {
	 private String fk_draft_no;
	 private String target_type; // target_type[]  ("dept" / "emp")
	 private String target_no;   // target_no[]    (부서번호 or 사번)
	 private String emp_name;
	 private String dept_name;
}
