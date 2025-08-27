package com.spring.app.survey.service;

import java.util.List;
import java.util.Map;

import com.spring.app.survey.domain.SurveyDTO;
import com.spring.app.survey.domain.SurveyDetailVO;

public interface SurveyService {
    List<SurveyDTO> getHomeCards(String empNo, int limit);
    List<SurveyDTO> getRecentList(String empNo, int limit);

    // 목록 3종 (페이지네이션)
    List<SurveyDTO> getListOngoing(String empNo, int page, int size);
    List<SurveyDTO> getListClosed(String empNo, int page, int size);
    List<SurveyDTO> getListMine(String empNo, int page, int size);
    
    int getOngoingCount(String empNo);
    int getClosedCount(String empNo);
    int getMyCount(String empNo);
    
    // 상세
    SurveyDetailVO getDetail(String sid, String empNo);

    // 제출 (중복 참여 방지: 이미 참여한 경우 0 리턴)
    int submitAnswers(String sid, String empNo, List<com.spring.app.survey.domain.SurveyAnswerRow> rows);

    // 결과 집계 (질문별 옵션 텍스트 포함)
    Map<String, List<Map<String,Object>>> getAggregatedResult(String sid);
    
    String createSurvey(String ownerEmpNo,
            String startDate, String endDate,
            String resultPublicYn, String targetScope,
            List<String> deptNos, List<String> empNos,
            SurveyMongoService.MongoFullDoc doc);

	boolean editSurvey(String sid, String ownerEmpNo,
	           String startDate, String endDate,
	           String resultPublicYn, String targetScope,
	           List<String> deptNos, List<String> empNos,
	           SurveyMongoService.MongoFullDoc doc, String mongoId);
	
	boolean closeSurvey(String sid, String ownerEmpNo);
	boolean deleteSurvey(String sid, String ownerEmpNo);
	
	// 부서 목록 조회
	List<Map<String, Object>> getDepartments();
}
