package com.spring.app.survey.service;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import com.spring.app.survey.domain.SurveyAnswerRow;
import com.spring.app.survey.domain.SurveyDTO;
import com.spring.app.survey.domain.SurveyDetailVO;
import com.spring.app.survey.domain.SurveyResultAggRow;
import com.spring.app.survey.model.SurveyDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SurveyService_imple implements SurveyService {

    private final SurveyDAO surveyDAO;
    private final SurveyMongoService surveyMongoService;

    @Override
    public List<SurveyDTO> getHomeCards(String empNo, int limit) {
        List<SurveyDTO> list = surveyDAO.selectHomeCards(empNo, limit <= 0 ? 6 : limit);
        fillMongoFields(list);
        return list;
    }

    @Override
    public List<SurveyDTO> getRecentList(String empNo, int limit) {
        List<SurveyDTO> list = surveyDAO.selectRecentForEmp(empNo, limit <= 0 ? 10 : limit);
        fillMongoFields(list);
        return list;
    }

    @Override
    public List<SurveyDTO> getListOngoing(String empNo, int page, int size) {
        int startRow = (page - 1) * size + 1;
        int endRow   = page * size;
        List<SurveyDTO> list = surveyDAO.selectListOngoingPaged(empNo, startRow, endRow);
        fillMongoFields(list);
        return list;
    }

    @Override
    public List<SurveyDTO> getListClosed(String empNo, int page, int size) {
        int startRow = (page - 1) * size + 1;
        int endRow   = page * size;
        List<SurveyDTO> list = surveyDAO.selectListClosedPaged(empNo, startRow, endRow);
        fillMongoFields(list);
        return list;
    }

    @Override
    public List<SurveyDTO> getListMine(String empNo, int page, int size) {
        int startRow = (page - 1) * size + 1;
        int endRow   = page * size;
        List<SurveyDTO> list = surveyDAO.selectListMinePaged(empNo, startRow, endRow);
        fillMongoFields(list);
        return list;
    }

    @Override public int getOngoingCount(String empNo){ return surveyDAO.countOngoingForEmp(empNo); }
    @Override public int getClosedCount(String empNo){  return surveyDAO.countClosedForEmp(empNo);  }
    @Override public int getMyCount(String empNo){      return surveyDAO.countMine(empNo);          }

    /** Mongo에서 title/introText 가져와 DTO에 주입 */
    private void fillMongoFields(List<SurveyDTO> list){
        if (list == null || list.isEmpty()) return;
        List<String> ids = list.stream()
            .map(SurveyDTO::getMongoSurveyId)
            .filter(Objects::nonNull)
            .distinct()
            .collect(Collectors.toList());

        Map<String, SurveyMongoService.MongoSummary> map = surveyMongoService.findSummariesByIds(ids);
        for (SurveyDTO s : list) {
            SurveyMongoService.MongoSummary mm = map.get(s.getMongoSurveyId());
            if (mm != null) {
                s.setTitle(mm.getTitle());
                s.setIntroText(mm.getIntroText());
            }
        }
    }
    
    
    
    @Override
    public SurveyDetailVO getDetail(String sid, String empNo) {
        SurveyDTO meta = surveyDAO.selectMetaById(sid, empNo);
        if (meta == null) return null;

        SurveyMongoService.MongoFullDoc doc = surveyMongoService.findFullById(meta.getMongoSurveyId());

        SurveyDetailVO vo = new SurveyDetailVO();
        vo.setSurveyId(meta.getSurveyId());
        vo.setMongoSurveyId(meta.getMongoSurveyId());
        vo.setOwnerEmpNo(meta.getOwnerEmpNo());
        vo.setOwnerName(meta.getOwnerName());
        vo.setStartDate(meta.getStartDate());
        vo.setEndDate(meta.getEndDate());
        vo.setResultPublicYn(meta.getResultPublicYn());
        vo.setClosedYn(meta.getClosedYn());
        vo.setStatus(meta.getStatus());
        vo.setParticipatedYn(meta.getParticipatedYn());

        if (doc != null) {
            vo.setTitle(doc.getTitle());
            vo.setIntroText(doc.getIntroText());

            if (!CollectionUtils.isEmpty(doc.getQuestions())) {
                List<SurveyDetailVO.QuestionVO> qlist = new ArrayList<>();
                for (SurveyMongoService.MongoFullDoc.Question q : doc.getQuestions()) {
                    SurveyDetailVO.QuestionVO qv = new SurveyDetailVO.QuestionVO();
                    qv.setId(q.getId());
                    qv.setText(q.getText());
                    qv.setMultiple(q.isMultiple());
                    if (!CollectionUtils.isEmpty(q.getOptions())) {
                        List<SurveyDetailVO.OptionVO> opts = new ArrayList<>();
                        for (SurveyMongoService.MongoFullDoc.Question.Option o : q.getOptions()) {
                            SurveyDetailVO.OptionVO ov = new SurveyDetailVO.OptionVO();
                            ov.setId(o.getId());
                            ov.setText(o.getText());
                            opts.add(ov);
                        }
                        qv.setOptions(opts);
                    }
                    qlist.add(qv);
                }
                vo.setQuestions(qlist);
            }
        }
        return vo;
    }

    @Override
    public int submitAnswers(String sid, String empNo, List<SurveyAnswerRow> rows) {
        // 대상 여부
        if (surveyDAO.isEligible(sid, empNo) == 0) return 0;

        // 메타 확인 (상태)
        SurveyDTO meta = surveyDAO.selectMetaById(sid, empNo);
        if (meta == null) return 0;
        boolean closed = "Y".equalsIgnoreCase(meta.getClosedYn()) ||
                         (meta.getEndDate() != null && "CLOSED".equals(meta.getStatus()));
        if (closed) return 0;

        // 중복 참여 방지
        if (surveyDAO.hasAnswered(sid, empNo) > 0) return 0;

        if (rows == null || rows.isEmpty()) return 0;
        return surveyDAO.insertAnswers(sid, empNo, rows);
    }

    @Override
    public Map<String, List<Map<String, Object>>> getAggregatedResult(String sid) {
        // 메타 & Mongo 로드 (옵션 텍스트 맵핑 필요)
        SurveyDTO meta = surveyDAO.selectMetaById(sid, null);
        if (meta == null) return Collections.emptyMap();
        SurveyMongoService.MongoFullDoc doc = surveyMongoService.findFullById(meta.getMongoSurveyId());
        if (doc == null || doc.getQuestions() == null) return Collections.emptyMap();

        // (q, o) → optionText 사전
        Map<String, Map<String,String>> labelMap = new HashMap<>();
        for (SurveyMongoService.MongoFullDoc.Question q : doc.getQuestions()) {
            Map<String,String> optMap = new HashMap<>();
            if (q.getOptions() != null) {
                for (SurveyMongoService.MongoFullDoc.Question.Option o : q.getOptions()) {
                    optMap.put(o.getId(), o.getText());
                }
            }
            labelMap.put(q.getId(), optMap);
        }

        List<SurveyResultAggRow> aggs = surveyDAO.selectAggregates(sid);
        // 질문별 List<{name, y}>
        Map<String, List<Map<String,Object>>> out = new LinkedHashMap<>();
        // 질문 순서를 Mongo 순서에 맞추고 싶다면 미리 키 생성
        for (SurveyMongoService.MongoFullDoc.Question q : doc.getQuestions()) {
            out.put(q.getId(), new ArrayList<>());
        }
        for (SurveyResultAggRow r : aggs) {
            String qk = r.getQuestionKey();
            String ok = r.getOptionKey();
            String name = labelMap.getOrDefault(qk, Collections.emptyMap()).getOrDefault(ok, ok);
            Map<String,Object> point = new LinkedHashMap<>();
            point.put("name", name);
            point.put("y", r.getCnt());
            out.computeIfAbsent(qk, k -> new ArrayList<>()).add(point);
        }
        return out;
    }
    
    @Override
    public String createSurvey(String ownerEmpNo, String startDate, String endDate,
                               String resultPublicYn, String targetScope,
                               List<String> deptNos, List<String> empNos,
                               SurveyMongoService.MongoFullDoc doc) {

        // 1) Mongo insert
        String mongoId = surveyMongoService.upsertSurveyDoc(null, doc);
        if (mongoId == null) return null;

        // 2) 새 survey_id
        String sid = surveyDAO.selectNextSurveyId();

        // 3) 메타 INSERT
        int n = surveyDAO.insertSurveyMeta(sid, mongoId, ownerEmpNo, startDate, endDate,
                                           ("Y".equalsIgnoreCase(resultPublicYn) ? "Y":"N"),
                                           targetScope);
        if (n == 0) return null;

        // 4) 대상 INSERT
        insertTargetsByScope(sid, targetScope, deptNos, empNos);

        return sid;
    }

    @Override
    public boolean editSurvey(String sid, String ownerEmpNo,
                              String startDate, String endDate,
                              String resultPublicYn, String targetScope,
                              List<String> deptNos, List<String> empNos,
                              SurveyMongoService.MongoFullDoc doc, String mongoId) {

        // 1) Mongo update
        String outId = surveyMongoService.upsertSurveyDoc(mongoId, doc);
        if (outId == null) return false;

        // 2) 메타 업데이트
        int n = surveyDAO.updateSurveyMetaForEdit(sid, ownerEmpNo, startDate, endDate,
                    ("Y".equalsIgnoreCase(resultPublicYn) ? "Y":"N"), targetScope);
        if (n == 0) return false;

        // 3) 대상 재설정
        surveyDAO.deleteTargets(sid);
        insertTargetsByScope(sid, targetScope, deptNos, empNos);

        return true;
    }

    private void insertTargetsByScope(String sid, String targetScope, List<String> deptNos, List<String> empNos){
        if ("ALL".equalsIgnoreCase(targetScope)) {
            surveyDAO.insertTargetAll(sid);
        } else if ("DEPT".equalsIgnoreCase(targetScope)) {
            if (deptNos != null) for (String d : deptNos) {
                if (d != null && !d.isBlank()) surveyDAO.insertTargetDept(sid, d);
            }
        } else if ("DIRECT".equalsIgnoreCase(targetScope)) {
            if (empNos != null) for (String e : empNos) {
                if (e != null && !e.isBlank()) surveyDAO.insertTargetEmp(sid, e);
            }
        }
    }

    @Override public boolean closeSurvey(String sid, String ownerEmpNo){
        return surveyDAO.markClosed(sid, ownerEmpNo) > 0;
    }
    @Override public boolean deleteSurvey(String sid, String ownerEmpNo){
        return surveyDAO.markDeleted(sid, ownerEmpNo) > 0;
    }
    
    @Override
    public List<Map<String, Object>> getDepartments() {
        return surveyDAO.selectDepartments();
    }

    
}
