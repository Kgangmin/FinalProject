package com.spring.app.survey.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.survey.domain.SurveyAnswerRow;
import com.spring.app.survey.domain.SurveyDTO;
import com.spring.app.survey.domain.SurveyDetailVO;
import com.spring.app.survey.model.SurveyDAO;
import com.spring.app.survey.service.SurveyService;
import com.spring.app.survey.service.SurveyMongoService.MongoFullDoc;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/survey")
public class SurveyController {

    private final SurveyService surveyService;
    private final SurveyDAO surveyDAO;

    
    /** 설문 홈 */
    @GetMapping("/home")
    public String home(Model model, HttpSession session) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("loc", "/login/loginStart");
            return "msg";
        }

        String empNo = login.getEmp_no();
        List<SurveyDTO> cards = surveyService.getHomeCards(empNo, 6);
        List<SurveyDTO> recent = surveyService.getRecentList(empNo, 10);

        model.addAttribute("cardList", cards);
        model.addAttribute("recentList", recent);

     // 사이드바 배지
        model.addAttribute("ongoingCnt", surveyService.getOngoingCount(empNo));
        model.addAttribute("closedCnt",  surveyService.getClosedCount(empNo));
        model.addAttribute("myCnt",      surveyService.getMyCount(empNo));
        
        return "survey/survey_home"; // /WEB-INF/views/survey/survey_home.jsp
    }
    
    
    /** 목록 3종: /survey/list?type=ongoing|closed|mine&page=1&size=15 */
    @GetMapping("/list")
    public String list(@RequestParam(defaultValue = "ongoing") String type,
                       @RequestParam(defaultValue = "1")        int page,
                       @RequestParam(defaultValue = "15")       int size,
                       Model model,
                       HttpSession session) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("loc", "/login/loginStart");
            return "msg";
        }
        String empNo = login.getEmp_no();
        page = Math.max(1, page);
        size = Math.max(1, Math.min(100, size));

        List<SurveyDTO> list;
        int total;
        switch (type) {
            case "closed":
                list  = surveyService.getListClosed(empNo, page, size);
                total = surveyService.getClosedCount(empNo);
                break;
            case "mine":
                list  = surveyService.getListMine(empNo, page, size);
                total = surveyService.getMyCount(empNo);
                break;
            default: // ongoing
                type  = "ongoing";
                list  = surveyService.getListOngoing(empNo, page, size);
                total = surveyService.getOngoingCount(empNo);
        }

        int totalPages = (int)Math.ceil(total / (double)size);

        model.addAttribute("type", type);
        model.addAttribute("list", list);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("total", total);
        model.addAttribute("totalPages", totalPages);

        // 사이드바 배지
        model.addAttribute("ongoingCnt", surveyService.getOngoingCount(empNo));
        model.addAttribute("closedCnt",  surveyService.getClosedCount(empNo));
        model.addAttribute("myCnt",      surveyService.getMyCount(empNo));

        return "survey/survey_list"; // /WEB-INF/views/survey/survey_list.jsp
    }


    /** 상세 */
    @GetMapping("/detail")
    public String detail(@RequestParam("sid") String sid,
                         Model model, HttpSession session) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("loc", "/login/loginStart");
            return "msg";
        }
        String empNo = login.getEmp_no();
        SurveyDetailVO detail = surveyService.getDetail(sid, empNo);
        if (detail == null) {
            model.addAttribute("message", "존재하지 않는 설문입니다.");
            model.addAttribute("loc", "/finalproject/survey/home");
            return "msg";
        }
        model.addAttribute("detail", detail);
        model.addAttribute("isOwner", empNo != null && empNo.equals(detail.getOwnerEmpNo()));
        
     // 사이드바 배지
        model.addAttribute("ongoingCnt", surveyService.getOngoingCount(empNo));
        model.addAttribute("closedCnt",  surveyService.getClosedCount(empNo));
        model.addAttribute("myCnt",      surveyService.getMyCount(empNo));
        return "survey/survey_detail";
    }

    /** 제출(복수선택 처리) */
    @PostMapping("/submit")
    public String submit(HttpServletRequest request,
                         @RequestParam("sid") String sid,
                         HttpSession session,
                         Model model) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("loc", "/login/loginStart");
            return "msg";
        }
        String empNo = login.getEmp_no();

        // form 파라미터에서 q_{questionId} 읽어 rows 구성
        // checkbox/radio 모두 name="q_{id}" 사용, 값은 optionKey (복수 체크박스면 다중값)
        List<SurveyAnswerRow> rows = new ArrayList<>();
        Map<String, String[]> paramMap = request.getParameterMap();
        for (String key : paramMap.keySet()) {
            if (key.startsWith("q_")) {
                String qid = key.substring(2);
                String[] vals = request.getParameterValues(key);
                if (vals != null) {
                    for (String v : vals) {
                        if (v != null && !v.isBlank()) {
                            rows.add(new SurveyAnswerRow(qid, v));
                        }
                    }
                }
            }
        }

        int inserted = surveyService.submitAnswers(sid, empNo, rows);
        if (inserted <= 0) {
            // 이미 참여 or 마감/비대상 등
            model.addAttribute("message", "제출이 불가합니다. (이미 참여하거나, 대상/기간이 아닐 수 있습니다)");
            model.addAttribute("loc", "/finalproject/survey/detail?sid=" + sid);
            return "msg";
        }

        // 결과 공개 여부에 따라 분기
        SurveyDetailVO after = surveyService.getDetail(sid, empNo);
        if (after != null && "Y".equalsIgnoreCase(after.getResultPublicYn())) {
            return "redirect:/survey/result?sid=" + sid;
        } else {
            model.addAttribute("message", "설문에 참여해 주셔서 감사합니다.");
            model.addAttribute("loc", "/finalproject/survey/home");
            return "msg";
        }
    }

    /** 결과 페이지 (공개형만 의미 있음) */
    @GetMapping("/result")
    public String result(@RequestParam("sid") String sid,
                         HttpSession session,
                         Model model) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        String empNo = login.getEmp_no();
        if (login == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("loc", "/login/loginStart");
            return "msg";
        }
        // 상세(제목/질문) + 집계 데이터
        SurveyDetailVO detail = surveyService.getDetail(sid, login.getEmp_no());
        if (detail == null) {
            model.addAttribute("message", "존재하지 않는 설문입니다.");
            model.addAttribute("loc", "/finalproject/survey/home");
            return "msg";
        }
        if (!"Y".equalsIgnoreCase(detail.getResultPublicYn())) {
            model.addAttribute("message", "이 설문은 결과 비공개입니다.");
            model.addAttribute("loc", "/finalproject/survey/detail?sid=" + sid);
            return "msg";
        }
        Map<String, List<Map<String,Object>>> agg = surveyService.getAggregatedResult(sid);
        model.addAttribute("detail", detail);
        model.addAttribute("agg", agg);
        
     // 사이드바 배지
        model.addAttribute("ongoingCnt", surveyService.getOngoingCount(empNo));
        model.addAttribute("closedCnt",  surveyService.getClosedCount(empNo));
        model.addAttribute("myCnt",      surveyService.getMyCount(empNo));
        return "survey/survey_result";
    }
    
    // ==== 작성 페이지 ====
    @GetMapping("/create")
    public String createForm(Model model, HttpSession session) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인이 필요합니다."); model.addAttribute("loc","/login/loginStart"); return "msg"; }
        String empNo = login.getEmp_no();
        model.addAttribute("deptList", surveyDAO.selectDepartments());
        
        // 사이드바 배지
        model.addAttribute("ongoingCnt", surveyService.getOngoingCount(empNo));
        model.addAttribute("closedCnt",  surveyService.getClosedCount(empNo));
        model.addAttribute("myCnt",      surveyService.getMyCount(empNo));
        return "survey/survey_create";
    }

    @PostMapping("/create")
    public String createSubmit(HttpServletRequest request, HttpSession session, Model model) throws Exception {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인이 필요합니다."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        String title  = request.getParameter("title");
        String intro  = request.getParameter("introText");
        String start  = request.getParameter("startDate");
        String end    = request.getParameter("endDate");
        String scope  = request.getParameter("targetScope"); // ALL/DEPT/DIRECT
        String pubYn  = request.getParameter("resultPublicYn"); // Y/N
        String qjson  = request.getParameter("docJson"); // 질문/보기 JSON (클라이언트에서 생성)
        String deptCsv= request.getParameter("deptNos"); // "D001,D002"
        String empCsv = request.getParameter("empNos");  // "20240001,20240002"

        // MongoFullDoc 구성
        ObjectMapper om = new ObjectMapper();
        MongoFullDoc doc = new MongoFullDoc();
        doc.setTitle(title);
        doc.setIntroText(intro);
        // docJson은 질문/보기만 포함(JSON 배열 형태) 또는 전체 객체로 올 수 있음
        // 본 예시는 배열만 넘어온다고 가정: [{id,text,multiple,options:[{id,text}...]}...]
        List<MongoFullDoc.Question> qs = Arrays.asList(om.readValue(qjson, MongoFullDoc.Question[].class));
        doc.setQuestions(qs);

        List<String> deptNos = parseCsv(deptCsv);
        List<String> empNos  = parseCsv(empCsv);

        String sid = surveyService.createSurvey(login.getEmp_no(), start, end, pubYn, scope, deptNos, empNos, doc);
        if (sid == null) {
            model.addAttribute("message", "설문 생성에 실패했습니다.");
            model.addAttribute("loc", "/finalproject/survey/create");
            return "msg";
        }
        return "redirect:/survey/detail?sid=" + sid;
    }

    // ==== 수정 ====
    @GetMapping("edit")
    public String edit(@RequestParam("sid") String sid,
                       HttpServletRequest request,
                       Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        String empNo = (login != null ? login.getEmp_no() : null);

        SurveyDetailVO detail = surveyService.getDetail(sid, empNo);
        model.addAttribute("detail", detail);
        model.addAttribute("deptList", surveyService.getDepartments());

        String questionsJson = "[]";
        try {
            ObjectMapper om = new ObjectMapper();
            questionsJson = om.writeValueAsString(detail.getQuestions()); // 안전한 JSON
        } catch (Exception ignore) {}
        model.addAttribute("questionsJson", questionsJson);

        // 사이드바 배지
        model.addAttribute("ongoingCnt", surveyService.getOngoingCount(empNo));
        model.addAttribute("closedCnt",  surveyService.getClosedCount(empNo));
        model.addAttribute("myCnt",      surveyService.getMyCount(empNo));
        return "survey/survey_edit";
    }

    @PostMapping("/edit")
    public String editSubmit(HttpServletRequest request, HttpSession session, Model model) throws Exception {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인이 필요합니다."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        String sid    = request.getParameter("sid");
        String mongoId= request.getParameter("mongoId");
        String title  = request.getParameter("title");
        String intro  = request.getParameter("introText");
        String start  = request.getParameter("startDate");
        String end    = request.getParameter("endDate");
        String scope  = request.getParameter("targetScope");
        String pubYn  = request.getParameter("resultPublicYn");
        String qjson  = request.getParameter("docJson");
        String deptCsv= request.getParameter("deptNos");
        String empCsv = request.getParameter("empNos");

        ObjectMapper om = new ObjectMapper();
        MongoFullDoc doc = new MongoFullDoc();
        doc.setTitle(title);
        doc.setIntroText(intro);
        List<MongoFullDoc.Question> qs = Arrays.asList(om.readValue(qjson, MongoFullDoc.Question[].class));
        doc.setQuestions(qs);

        boolean ok = surveyService.editSurvey(sid, login.getEmp_no(), start, end, pubYn, scope,
                            parseCsv(deptCsv), parseCsv(empCsv), doc, mongoId);
        if (!ok) {
            model.addAttribute("message", "수정에 실패했습니다.");
            model.addAttribute("loc", "/finalproject/survey/edit?sid=" + sid);
            return "msg";
        }
        return "redirect:/survey/detail?sid=" + sid;
    }

    // ==== 마감/삭제 ====
    @PostMapping("/close")
    public String close(@RequestParam("sid") String sid, HttpSession session, Model model) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인이 필요합니다."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        if (!surveyService.closeSurvey(sid, login.getEmp_no())) {
            model.addAttribute("message","마감 권한이 없거나 실패했습니다.");
            model.addAttribute("loc","/finalproject/survey/detail?sid=" + sid);
            return "msg";
        }
        return "redirect:/survey/detail?sid=" + sid;
    }

    @PostMapping("/delete")
    public String delete(@RequestParam("sid") String sid, HttpSession session, Model model) {
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인이 필요합니다."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        if (!surveyService.deleteSurvey(sid, login.getEmp_no())) {
            model.addAttribute("message","삭제 권한이 없거나 실패했습니다.");
            model.addAttribute("loc","/finalproject/survey/detail?sid=" + sid);
            return "msg";
        }
        model.addAttribute("message","삭제되었습니다.");
        model.addAttribute("loc","/finalproject/survey/home");
        return "msg";
    }

    // ==== 보조 API ====
    @ResponseBody
    @GetMapping("/api/departments")
    public List<Map<String,Object>> apiDepartments() {
        return surveyDAO.selectDepartments();
    }

    @ResponseBody
    @GetMapping("/api/employees")
    public List<Map<String,String>> apiEmployees(@RequestParam("q") String keyword,
                                                 @RequestParam(value="limit", defaultValue="20") int limit) {
        return surveyDAO.searchEmployees(keyword, Math.max(1, Math.min(50, limit)));
    }

    // ==== util ====
    private static List<String> parseCsv(String csv){
        if (csv == null || csv.isBlank()) return Collections.emptyList();
        return Arrays.stream(csv.split(","))
                     .map(String::trim)
                     .filter(s -> !s.isEmpty())
                     .distinct()
                     .collect(Collectors.toList());
    }
}
