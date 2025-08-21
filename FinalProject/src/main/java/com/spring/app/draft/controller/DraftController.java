package com.spring.app.draft.controller;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.DraftForm;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.service.DraftService;
import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.interceptor.LoginCheckInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/draft/")
@RequiredArgsConstructor
public class DraftController {

    private final LoginCheckInterceptor loginCheckInterceptor;

	
	private final DraftService draftService;

	
	@GetMapping("draftlist")
	public String draftList(HttpSession session,
	                        @RequestParam(name="approval_status", defaultValue="") String approval_status,
	                        @RequestParam(name="searchWord",      defaultValue="") String searchWord,
	                        @RequestParam(name="page",            defaultValue="1") String page,
	                        @RequestParam(name="draft_type",      defaultValue="") String draft_type,
	                        Model model) {

	    // 로그인 사용자
	    EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
	    String emp_no = loginuser.getEmp_no();

	    // 페이지 사이즈
	    String pagePerSize = "7";

	    // 검색어 공백정리
	    searchWord = searchWord.trim();

	    Map<String, String> map = new HashMap<>();
	    map.put("emp_no",          emp_no);
	    map.put("approval_status", approval_status);
	    map.put("searchWord",      searchWord);
	    map.put("draft_type",      draft_type);
	    map.put("pagePerSize",     pagePerSize);

	    // 총 개수 먼저 구해서 totalPage 계산
	    int totalcount = draftService.getdraftcount(map);
	    int size       = Integer.parseInt(pagePerSize);
	    int totalPage  = (int)Math.ceil((double) totalcount / size);
	    if (totalPage == 0) {
	    	totalPage = 1;
	    }

	    // page가 범위를 넘으면 마지막 페이지로 보정
	    if (Integer.parseInt(page) > totalPage) {
	    	page = String.valueOf(totalPage);
	    }

	    // offset 계산 후 맵에 반영 (문자열 유지)
	    int offset = (Integer.parseInt(page) - 1) * size;
	    map.put("page",   page);   // 사용 중인 키 유지
	    map.put("offset", String.valueOf(offset));  // 매퍼의 OFFSET #{offset}에 사용

	    // 목록 조회 (보정된 page/offset 기준)
	    List<DraftDTO> arrList = draftService.getdraftList(map);

	    // 뷰에서 필요한 값 바인딩 (선택값/검색값/페이지 유지)
	    model.addAttribute("arrList",         arrList);
	    model.addAttribute("totalPage",       totalPage);
	    model.addAttribute("page",            page);           // 산술 연산 위해 숫자로 전달
	    model.addAttribute("approval_status", approval_status); // 탭/링크 유지
	    model.addAttribute("searchWord",      searchWord);      // 검색값 유지
	    model.addAttribute("draft_type",      draft_type);      // 셀렉트 유지

	    return "draft/draftlist";
	}
	
	@GetMapping("draftdetail")
	public String draftdetail (HttpSession session,@RequestParam(name="draft_no", defaultValue="") String draft_no , Model model) {
		
		Map<String, String> draft = draftService.getdraftdetail(draft_no);
		List<ExpenseDTO> expenseList = draftService.getexpenseList(draft_no);
		List<Map<String, String>>  approvalLine = draftService.getapprovalLine(draft_no);
		
		String is_attached = draft.get("is_attached");
		
		if(is_attached.equals("Y")) {
			List<Map<String, String>> fileList = draftService.getfileList(draft_no);
			model.addAttribute("fileList" , fileList);
		}
			
		
		
		
		model.addAttribute("draft" , draft);
		model.addAttribute("expenseList" , expenseList);
		model.addAttribute("approvalLine" , approvalLine);
		return "draft/draftdetail";
	}
	
	@PostMapping("expense")
	public String updateExpense(@ModelAttribute DraftForm form, 
								@RequestParam(name="files", required=false) List<MultipartFile> fileList,
								HttpSession session , HttpServletRequest request) {
		DraftDTO draft = form.getDraft();
		List<ExpenseDTO> expenseList = form.getItems();
		String draft_no = draft.getDraft_no(); 
		
		  // === webapp 절대경로로 업로드 경로 생성 ===
        // /FinalProject/src/main/webapp/resources/draft_attach_file
        String root = session.getServletContext().getRealPath("/"); // webapp/
        String path = root + "resources" + File.separator + "draft_attach_file";
		// 문저 업데이트 
		draftService.draftSave(draft,fileList, path);
		
		draftService.expenseSave(expenseList , draft_no);
		
		draftService.fileSave(fileList,path ,draft_no);
		
		
		
		String message = "저장되었습니다";
		String loc = request.getContextPath()+"/draft/draftlist";
		
		request.setAttribute("message", message);  
		request.setAttribute("loc", loc);          
		return "msg";
	}
}
