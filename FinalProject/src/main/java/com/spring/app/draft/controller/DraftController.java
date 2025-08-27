package com.spring.app.draft.controller;

import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.draft.domain.ApprovalLineDTO;
import com.spring.app.draft.domain.ApprovalLinesForm;
import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.DraftForm;
import com.spring.app.draft.domain.DraftForm2;
import com.spring.app.draft.domain.DraftForm3;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.domain.LeaveDTO;
import com.spring.app.draft.domain.ProposalDTO;
import com.spring.app.draft.service.DraftService;
import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;
import com.spring.app.interceptor.LoginCheckInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import com.spring.app.common.FileManager;


@Controller
@RequestMapping("/draft/")
@RequiredArgsConstructor
public class DraftController {

    private final LoginCheckInterceptor loginCheckInterceptor;
    private final FileManager fileManager;
	
	private final DraftService draftService;
	private final EmpService empService;
	
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
	public String draftdetail (HttpSession session,@RequestParam(name="draft_no", defaultValue="") String draft_no , Model model,
								@RequestParam(name="draft_type", defaultValue="") String draft_type) {
		
		Map<String, String> draft = draftService.getdraftdetail(draft_no);
		List<Map<String, String>>  approvalLine = draftService.getapprovalLine(draft_no);
		String is_attached = draft.get("is_attached");
		if("EXPENSE".equals(draft_type)) {
			
			List<ExpenseDTO> expenseList = draftService.getexpenseList(draft_no);
			

			if(is_attached.equals("Y")) {
				List<Map<String, String>> fileList = draftService.getfileList(draft_no);
				model.addAttribute("fileList" , fileList);
			}

			model.addAttribute("expenseList" , expenseList);

		}
		else if("LEAVE".equals(draft_type)) {
			LeaveDTO Leave = draftService.getLeave(draft_no);
			List<Map<String, String>> Leave_type = draftService.getleaveType();
			
			if(is_attached.equals("Y")) {
				List<Map<String, String>> fileList = draftService.getfileList(draft_no);
				model.addAttribute("fileList" , fileList);
			}
			
			model.addAttribute("Leave" , Leave);
			model.addAttribute("Leave_type" , Leave_type);
			model.addAttribute("googleApiKey", "AIzaSyB13tCUo3glcIOHua3YZXVN8Rjo0yxqi20");
			
		}
		else if("PROPOSAL".equals(draft_type)) {
			
			ProposalDTO proposal = draftService.getproposal(draft_no);
			
			if(is_attached.equals("Y")) {
				List<Map<String, String>> fileList = draftService.getfileList(draft_no);
				model.addAttribute("fileList" , fileList);
			}
			
			model.addAttribute("proposal" , proposal);
		}
			
		model.addAttribute("approvalLine" , approvalLine);
		model.addAttribute("draft" , draft);
		model.addAttribute("draft_type" , draft_type);
		return "draft/draftUpdatecell";
	}
	
	@PostMapping("EXPENSE")
	public String updateExpense(@ModelAttribute DraftForm form, 
								@RequestParam(name="files", required=false) List<MultipartFile> fileList,
								HttpSession session , HttpServletRequest request ,
								@RequestParam(name="del_draft_file_no", required=false) List<String> del_draft_file_no) {
		DraftDTO draft = form.getDraft();
		List<ExpenseDTO> expenseList = form.getItems();
		String draft_no = draft.getDraft_no(); 
		
		  // === webapp 절대경로로 업로드 경로 생성 ===
        // /FinalProject/src/main/webapp/resources/draft_attach_file
        String root = session.getServletContext().getRealPath("/"); // webapp/
        String path = root + "resources" + File.separator + "draft_attach_file";
		// 문저 업데이트 
		draftService.draftSave(draft);
		
		draftService.expenseSave(expenseList , draft_no);
		
		draftService.fileSave(fileList,path ,draft_no);
		
		draftService.filedelete(del_draft_file_no ,path , draft_no);
		
		String message = "저장되었습니다";
		String loc = request.getContextPath()+"/draft/draftlist";
		
		request.setAttribute("message", message);  
		request.setAttribute("loc", loc);          
		return "msg";
	}
	
	@GetMapping("file/download")
	public void requiredLogin_downloadComment(@RequestParam(name="draft_file_no") String draft_file_no
											, HttpServletRequest request
            								, HttpServletResponse response) {  
	
	
	// 첨부파일이 있는 글번호 

	// **** 웹브라우저에 출력하기 시작 **** //
	// HttpServletResponse response 객체는 전송되어져온 데이터를 조작해서 결과물을 나타내고자 할때 쓰인다.
	response.setContentType("text/html; charset=UTF-8");
	
	PrintWriter out = null;
	// out 은 웹브라우저에 기술하는 대상체라고 생각하자.
	
	Map<String, String> paraMap = new HashMap<>();
	paraMap.put("draft_file_no", draft_file_no);
	
	Map<String, String> filemap = draftService.getfileOne(draft_file_no); 
	
	
	try {
		
		if(filemap.size() == 0) {
			out = response.getWriter();
			// out 은 웹브라우저에 기술하는 대상체라고 생각하자.
			
			out.println("<script type='text/javascript'>alert('파일다운로드가 불가합니다. null'); history.back();</script>"); 
			return;
		}
		
		else {
			// 정상적으로 다운로드가 되어질 경우 
			
			String fileName = filemap.get("draft_save_filename");
			//System.out.println(fileName);
			
			String orgFilename = filemap.get("draft_origin_filename");
			//System.out.println(orgFilename);
			HttpSession session = request.getSession();
			String root = session.getServletContext().getRealPath("/");
	
			String path = root+"resources"+File.separator+"draft_attach_file/" + filemap.get("fk_draft_no") ;
			//System.out.println(path);
			// **** file 다운로드하기 **** //
			boolean flag = false; // file 다운로드 성공, 실패인지 여부를 알려주는 용도
			flag = fileManager.doFileDownload(fileName, orgFilename, path, response);
			// file 다운로드 성공시 flag 는 true,
			// file 다운로드 실패시 flag 는 false 를 가진다.
			
			if(!flag) {
			// 다운로드가 실패한 경우 메시지를 띄운다.
			out = response.getWriter();
			// out 은 웹브라우저에 기술하는 대상체라고 생각하자.
			
			out.println("<script type='text/javascript'>alert('파일다운로드가 실패되었습니다.'); history.back();</script>"); 
			}
		
		}
		
	} catch(Exception e) {
		e.printStackTrace();
		try {
			out = response.getWriter();
			// out 은 웹브라우저에 기술하는 대상체라고 생각하자.
			
			out.println("<script type='text/javascript'>alert('파일다운로드가 불가합니다.'); history.back();</script>");
		} catch(Exception e1) {
			e1.printStackTrace();
		}
	}
	
	}
	
	
	@PostMapping("LEAVE")
	public String updateLeave(@ModelAttribute DraftForm2 form, 
								@RequestParam(name="files", required=false) List<MultipartFile> fileList,
								HttpSession session , HttpServletRequest request ,
								@RequestParam(name="del_draft_file_no", required=false) List<String> del_draft_file_no) {
		
		DraftDTO draft = form.getDraft();
		
		LeaveDTO leave = form.getLeave();
		
		String draft_no = draft.getDraft_no(); 
		
		  // === webapp 절대경로로 업로드 경로 생성 ===
        // /FinalProject/src/main/webapp/resources/draft_attach_file
        String root = session.getServletContext().getRealPath("/"); // webapp/
        String path = root + "resources" + File.separator + "draft_attach_file";
		// 문저 업데이트 
		draftService.draftSave(draft);
		
		draftService.leaveSave(leave);
		
		draftService.fileSave(fileList,path ,draft_no);
		
		draftService.filedelete(del_draft_file_no ,path , draft_no);
		
		String message = "저장되었습니다";
		String loc = request.getContextPath()+"/draft/draftlist";
		
		request.setAttribute("message", message);  
		request.setAttribute("loc", loc);          
		return "msg";
		
	}
	
	@PostMapping("PROPOSAL")
	public String updateProposal(@ModelAttribute DraftForm3 form, 
								@RequestParam(name="files", required=false) List<MultipartFile> fileList,
								HttpSession session , HttpServletRequest request ,
								@RequestParam(name="del_draft_file_no", required=false) List<String> del_draft_file_no) {
		
		DraftDTO draft = form.getDraft();
		
		ProposalDTO proposal = form.getProposal();
		
		String draft_no = draft.getDraft_no(); 
		
		  // === webapp 절대경로로 업로드 경로 생성 ===
        // /FinalProject/src/main/webapp/resources/draft_attach_file
        String root = session.getServletContext().getRealPath("/"); // webapp/
        String path = root + "resources" + File.separator + "draft_attach_file";
		// 문저 업데이트 
		draftService.draftSave(draft);
		
		draftService.proposalSave(proposal);
		
		draftService.fileSave(fileList,path ,draft_no);
		
		draftService.filedelete(del_draft_file_no ,path , draft_no);
		
		String message = "저장되었습니다";
		String loc = request.getContextPath()+"/draft/draftlist";
		
		request.setAttribute("message", message);  
		request.setAttribute("loc", loc);          
		return "msg";
		
	}
	
	@GetMapping("register")
	public String draftRegister(@RequestParam(name="type") String draft_type ,
			 					HttpServletRequest request ,
			 					HttpSession session) {
		EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
		String emp_no = loginuser.getEmp_no();
		
		EmpDTO emp = empService.getEmpInfoByEmpno(emp_no);
		
		request.setAttribute("draft_type", draft_type);
		request.setAttribute("emp", emp);
		
		return "draft/draftRegistercell";
	}
	
	 @GetMapping("quick")
	 @ResponseBody
	 public List<Map<String, String>> approvalsearch(@RequestParam(name="q", required=false) String q) {
		 	
		 	q = q.trim().toLowerCase(Locale.ROOT);
	        String pattern = "%" +  q + "%";
	        return draftService.quickSearch(pattern); // limit 제거
	  }
	 
	 
	 @PostMapping("PROPOSAL/insert")
		public String insertProposal(@ModelAttribute ProposalDTO proposal, 
									@RequestParam(name="files", required=false) List<MultipartFile> fileList,
									HttpSession session , HttpServletRequest request ,
									@ModelAttribute DraftDTO draft,
									@ModelAttribute ApprovalLinesForm form) {
		 	
		 	List<ApprovalLineDTO> approvalLines = form.getApprovalLines();
			  // === webapp 절대경로로 업로드 경로 생성 ===
	        // /FinalProject/src/main/webapp/resources/draft_attach_file
	        String root = session.getServletContext().getRealPath("/"); // webapp/
	        String path = root + "resources" + File.separator + "draft_attach_file";
			// 문저 업데이트 	       
			draftService.insertProposal(draft , proposal , fileList, path , approvalLines);
			
			
			String message = "저장되었습니다";
			String loc = request.getContextPath()+"/draft/draftlist";
			
			request.setAttribute("message", message);  
			request.setAttribute("loc", loc);          
			return "msg";
			
		}
}
