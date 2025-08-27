package com.spring.app.survey.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.survey.domain.SurveyAnswerRow;
import com.spring.app.survey.domain.SurveyDTO;
import com.spring.app.survey.domain.SurveyResultAggRow;

@Mapper
public interface SurveyDAO {
    // 홈
    List<SurveyDTO> selectHomeCards(@Param("empNo") String empNo, @Param("limit") int limit);
    List<SurveyDTO> selectRecentForEmp(@Param("empNo") String empNo, @Param("limit") int limit);

    // 목록 3종 (페이지네이션)
    List<SurveyDTO> selectListOngoingPaged(@Param("empNo") String empNo,
                                           @Param("startRow") int startRow,
                                           @Param("endRow")   int endRow);
    List<SurveyDTO> selectListClosedPaged(@Param("empNo") String empNo,
                                          @Param("startRow") int startRow,
                                          @Param("endRow")   int endRow);
    List<SurveyDTO> selectListMinePaged(@Param("empNo") String empNo,
                                        @Param("startRow") int startRow,
                                        @Param("endRow")   int endRow);

    // 카운트
    int countOngoingForEmp(@Param("empNo") String empNo);
    int countClosedForEmp(@Param("empNo") String empNo);
    int countMine(@Param("empNo") String empNo);
    
    
    // 상세용(메타 + 상태/참여여부)
    SurveyDTO selectMetaById(@Param("sid") String sid, @Param("empNo") String empNo);

    // 대상 포함 여부
    int isEligible(@Param("sid") String sid, @Param("empNo") String empNo);

    // 참여 여부
    int hasAnswered(@Param("sid") String sid, @Param("empNo") String empNo);

    // 제출(배치)
    int insertAnswers(@Param("sid") String sid,
                      @Param("empNo") String empNo,
                      @Param("rows") List<SurveyAnswerRow> rows);

    // 집계
    List<SurveyResultAggRow> selectAggregates(@Param("sid") String sid);
    
 // ==== 작성/수정/마감/삭제 ====
    String selectNextSurveyId(); // 시퀀스로 SVYYYYMMDD#### 생성
    int insertSurveyMeta(@Param("sid") String sid,
                         @Param("mongoId") String mongoId,
                         @Param("ownerEmpNo") String ownerEmpNo,
                         @Param("startDate") String startDate,   // yyyy-MM-dd
                         @Param("endDate") String endDate,       // yyyy-MM-dd
                         @Param("resultPublicYn") String resultPublicYn,
                         @Param("targetScope") String targetScope);

    int insertTargetAll(@Param("sid") String sid);
    int insertTargetDept(@Param("sid") String sid, @Param("deptNo") String deptNo);
    int insertTargetEmp(@Param("sid") String sid, @Param("empNo") String empNo);
    int deleteTargets(@Param("sid") String sid);

    int updateSurveyMetaForEdit(@Param("sid") String sid,
                                @Param("ownerEmpNo") String ownerEmpNo, // 소유자 검증
                                @Param("startDate") String startDate,
                                @Param("endDate") String endDate,
                                @Param("resultPublicYn") String resultPublicYn,
                                @Param("targetScope") String targetScope);

    int markClosed(@Param("sid") String sid, @Param("ownerEmpNo") String ownerEmpNo);
    int markDeleted(@Param("sid") String sid, @Param("ownerEmpNo") String ownerEmpNo);

    // ==== 작성 페이지 보조 ====
    List<Map<String, Object>> selectDepartments(); // dept_no, dept_name
    List<Map<String, String>> searchEmployees(@Param("keyword") String keyword, @Param("limit") int limit);
    
    
}
