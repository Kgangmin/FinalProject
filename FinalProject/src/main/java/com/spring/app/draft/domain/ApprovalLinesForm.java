package com.spring.app.draft.domain;

import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApprovalLinesForm {
	 private List<ApprovalLineDTO> approvalLines = new ArrayList<>();
}
