package com.spring.app.draft.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProposalDeptDTO {
	private String fk_draft_no;
	private String fk_dept_no; // dept_no[]
    private String task_dept_role;   // task_dept_role[]  ("주관" / "협력")
    private String dept_name;
}
