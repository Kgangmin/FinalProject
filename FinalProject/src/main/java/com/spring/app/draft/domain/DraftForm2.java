package com.spring.app.draft.domain;

import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DraftForm2 {
	
	 private DraftDTO draft;               // 문서 정보
	 private LeaveDTO leave;       // 지출내역 리스트
}
