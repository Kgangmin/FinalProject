package com.spring.app.schedule.domain;

import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonIgnore;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class TaskDTO {
	
	// 응답(이벤트) 필드
	private String taskNo;     // 업무번호(pk)
	private String taskTitle;  // 제목
	private String taskDetail; // 업무상세
	private Timestamp startDate;  // 업무 시작일 
	private Timestamp endDate;    // 업무 종료일 
	private String type;  	   // 'MY' | 'DEPT' | 'COMP'
	private String deptNo;     // 부서번호
	 
	
	// 조회(요청) 필드
	@JsonIgnore private String empNo;  // 세션 사용자 사번
	@JsonIgnore private String qStart; // 조회 시작(FullCalendar start)
	@JsonIgnore private String qEnd;   // 조회 종료(FullCalendar end)


}
