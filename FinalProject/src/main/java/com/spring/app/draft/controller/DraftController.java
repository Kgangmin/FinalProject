package com.spring.app.draft.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.service.DraftService;
import com.spring.app.member.domain.MemberDTO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/draft/")
@RequiredArgsConstructor
public class DraftController {

	
	private final DraftService draftService; 
	
	
	@GetMapping("draftList")
	public String draftList(HttpSession session , 
							@RequestParam(name="approval_status", defaultValue="대기")  String approval_status,
							@RequestParam(name="searchWord", defaultValue="")  String searchWord,
							@RequestParam(value="page",    defaultValue="1") String page,
							Model model ) {
		
		MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
		String emp_no = loginuser.getEmp_no();
		
		Map<String, String> map = new HashMap<>();
		
		map.put("approval_status" , approval_status);
		map.put("searchWord", searchWord);
		map.put("page", page);
		map.put("emp_no", emp_no);
		
		int pagePerSize = 5;
		// 결제목록 가져오기
		List<DraftDTO> arrList = draftService.getdraftList(map);
		//페이징 처리할 수 가져오기
		int totalcount = draftService.getdraftcount(map);
		
		int totalPage = (int)Math.ceil((double) totalcount/ pagePerSize);
		
		model.addAttribute("arrList",arrList);
		model.addAttribute("totalPage", totalPage);
		model.addAttribute("page", page);
		
		// 검색기록유지
		model.addAttribute("approval_status", approval_status);
		model.addAttribute("searchWord", searchWord);
		
		
		return "draft/draftList";
	}
	
}
