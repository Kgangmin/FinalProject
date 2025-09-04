package com.spring.app.attendance.service;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.spring.app.attendance.domain.AttendanceDTO;

public interface AttendanceService
{
    /** 해당 날짜 기준으로 결측 근태행을 생성(멱등) */
    int generateFor(LocalDate workDate);

    /** Asia/Seoul '오늘' 기준 실행 */
    int generateToday();

    //	로그인중인 사원의 오늘 근태정보 가져오기
	AttendanceDTO getToday(String empNo);
	
	//	출근시간 업데이트
	void clockIn(String empNo);
	
	//	퇴근시간 업데이트
	void clockOut(String empNo);
	
	// 주간 달력 일자 7개 (java.util.Date)
    List<Date> getWeekDays(LocalDate base);

    // 주간 근태 맵: key = "yyyy-MM-dd"
    Map<String, AttendanceDTO> getWeekMap(String empNo, LocalDate base);

    // 상단 네비용
    Date getWeekStart(LocalDate base);
    Date getWeekEnd(LocalDate base);

    //	주간 근무기록 계산용 조회
	List<AttendanceDTO> getAttendanceList(String empNo);
	long calculateWorkSeconds(Date clockIn, Date clockOut);

	//	비고란 작성
	void appendRemark(String empNo, LocalDate workDate, String entry);
}