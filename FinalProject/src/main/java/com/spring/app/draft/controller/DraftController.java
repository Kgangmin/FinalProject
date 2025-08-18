package com.spring.app.draft.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.app.draft.domain.DraftDTO;
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
		
		DraftDTO ddto = draftService.getdraftdetail(draft_no);
		
		
		
		model.addAttribute(ddto , ddto);
		
		
		return "draft/draftdetail";
	}
	
}
