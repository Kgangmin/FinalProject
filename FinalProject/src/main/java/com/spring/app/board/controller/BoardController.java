package com.spring.app.board.controller;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.domain.BoardFileDTO;
import com.spring.app.board.domain.CategoryDTO;
import com.spring.app.board.domain.CommentDTO;
import com.spring.app.board.service.BoardService;
import com.spring.app.emp.domain.EmpDTO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/board")
public class BoardController {

    private final BoardService boardService;

    // 업로드 경로(예시): 환경에 맞게 조정
    private final String uploadDir = System.getProperty("user.home") + File.separator + "board_uploads";

    
    @GetMapping({"","/"})
    public String listDefault(@RequestParam(value="category", required=false) String board_category_no,
                              @RequestParam(value="page", required=false, defaultValue="1") int page,
                              @RequestParam(value="size", required=false, defaultValue="10") int size,
                              @RequestParam(value="searchType", required=false) String searchType,
                              @RequestParam(value="searchKeyword", required=false) String searchKeyword,
                              @RequestParam(value="sort", required=false, defaultValue="latest") String sort,
                              HttpServletRequest request,
                              Model model,
                              RedirectAttributes ra) {

        // 로그인 유저 체크
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message","로그인 후 이용하세요.");
            model.addAttribute("loc","/login");
            return "msg";
        }
        final String deptNo = login.getFk_dept_no();

        // 1) 사이드바/권한용: "전사 + 해당 부서가 접근 가능한" 카테고리 목록만 조회
        //    (서비스에 새로 추가: getVisibleCategoriesForDept)
        List<CategoryDTO> visibleCategories = boardService.getVisibleCategories(login.getFk_dept_no(), login.getEmp_no());
        if (visibleCategories == null || visibleCategories.isEmpty()) {
            model.addAttribute("message","조회 가능한 게시판이 없습니다. 관리자에게 문의하세요.");
            model.addAttribute("loc","/index");
            return "msg";
        }

        // 헬퍼: 자주 쓰는 람다
        java.util.function.Predicate<CategoryDTO> isCorp =
            c -> "전사공지".equals(c.getBoard_category_name())
              || "전사알림".equals(c.getBoard_category_name())
              || "자유게시판".equals(c.getBoard_category_name());

        // 2) 현재 카테고리 결정: 쿼리파라미터가 가리키는 카테고리가 "visible"에 속하는지 검증
        CategoryDTO cat = null;
        if (board_category_no != null) {
            for (CategoryDTO c : visibleCategories) {
                if (c.getBoard_category_no().equals(board_category_no)) { cat = c; break; }
            }
        }
        if (cat == null) {
            // 기본은 전사공지 → 없으면 자유게시판 → 그래도 없으면 visible 첫 번째
            cat = visibleCategories.stream().filter(c -> "전사공지".equals(c.getBoard_category_name())).findFirst()
                    .orElseGet(() -> visibleCategories.stream().filter(c -> "자유게시판".equals(c.getBoard_category_name())).findFirst()
                    .orElse(visibleCategories.get(0)));
        }

        // 3) 읽기 권한 재검증 (URL로 직접 접근 대비)
        boolean canRead = boardService.canRead(
                cat.getBoard_category_no(),
                login.getEmp_no(),
                deptNo,
                cat.getBoard_category_name()
        );
        if (!canRead) {
            // 내 부서용 카테고리 중 아무거나 → 없으면 자유 → 없으면 전사공지
            CategoryDTO target =
                visibleCategories.stream().filter(c -> !isCorp.test(c)).findFirst()
                .orElseGet(() -> visibleCategories.stream().filter(c -> "자유게시판".equals(c.getBoard_category_name())).findFirst()
                .orElseGet(() -> visibleCategories.stream().filter(c -> "전사공지".equals(c.getBoard_category_name())).findFirst()
                .orElse(visibleCategories.get(0))));

            ra.addFlashAttribute("msg", "해당 게시판은 열람 권한이 없어 ‘" + target.getBoard_category_name() + "’으로 이동했습니다.");
            return "redirect:/board?category=" + target.getBoard_category_no();
        }

        // 4) 페이징 파라미터
        int startRow = (page - 1) * size + 1;
        int endRow   = page * size;

        Map<String,String> param = new HashMap<>();
        param.put("fk_board_category_no", cat.getBoard_category_no());
        param.put("searchType",  (searchType == null ? "" : searchType));
        param.put("searchKeyword",(searchKeyword == null ? "" : searchKeyword));
        param.put("sort", sort);
        param.put("startRow", Integer.toString(startRow));
        param.put("endRow", Integer.toString(endRow));

        int totalCnt = boardService.countBoardList(param);
        List<BoardDTO> list = boardService.selectBoardList(param);
        int totalPage = (int)Math.ceil((double)totalCnt / size);

        // 블록/싱글 네비 계산 (네 로직 유지)
        int blockSize = 10;
        int blockStartPage = ((page - 1) / blockSize) * blockSize + 1;
        int blockEndPage   = Math.min(blockStartPage + blockSize - 1, totalPage);
        boolean useSingleNav = totalPage <= blockSize;

        boolean hasPrevNav, hasNextNav;
        int prevNavPage, nextNavPage;
        String prevLabel, nextLabel;

        if (useSingleNav) {
            hasPrevNav = page > 1;
            hasNextNav = page < totalPage;
            prevNavPage = Math.max(1, page - 1);
            nextNavPage = Math.min(totalPage, page + 1);
            prevLabel   = "◀ 이전";
            nextLabel   = "다음 ▶";
        } else {
            hasPrevNav = blockStartPage > 1;
            hasNextNav = blockEndPage < totalPage;
            prevNavPage = Math.max(1, blockStartPage - 1);
            nextNavPage = Math.min(totalPage, blockEndPage + 1);
            prevLabel   = "◀ 이전 10";
            nextLabel   = "다음 10 ▶";
        }

        // 5) 모델 바인딩: ★여기가 포인트
        model.addAttribute("categories", visibleCategories); // ← 사이드바엔 전사 + 내 부서만 보임
        model.addAttribute("cat", cat);
        model.addAttribute("list", list);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("totalPage", totalPage);
        model.addAttribute("totalCnt", totalCnt);
        model.addAttribute("searchType", searchType);
        model.addAttribute("searchKeyword", searchKeyword);
        model.addAttribute("sort", sort);

        model.addAttribute("blockSize", blockSize);
        model.addAttribute("blockStartPage", blockStartPage);
        model.addAttribute("blockEndPage", blockEndPage);
        model.addAttribute("useSingleNav", useSingleNav);
        model.addAttribute("hasPrevNav", hasPrevNav);
        model.addAttribute("hasNextNav", hasNextNav);
        model.addAttribute("prevNavPage", prevNavPage);
        model.addAttribute("nextNavPage", nextNavPage);
        model.addAttribute("prevLabel", prevLabel);
        model.addAttribute("nextLabel", nextLabel);

        return "board/list";
    }


    /** 글 상세 */
    @GetMapping("/view/{board_no}")
    public String view(@PathVariable("board_no") String board_no, HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login"); return "msg"; }

        BoardDTO b = boardService.getBoardAndTouchRead(board_no, login.getEmp_no(), login.getFk_dept_no());
        if (b == null) { model.addAttribute("message","존재하지 않는 글입니다."); model.addAttribute("loc","/board"); return "msg"; }

        CategoryDTO cat = boardService.getCategoryByNo(b.fk_board_category_no);

        // 🔹 사이드바가 필요로 하는 공통 데이터 주입
        List<CategoryDTO> categories = boardService.getAllCategories();
        model.addAttribute("categories", categories);        // 최신 사이드바에서 사용
        model.addAttribute("boardCategories", categories);   // 예전 사이드바 호환용(있으면)
        model.addAttribute("currentCategoryNo", b.getFk_board_category_no()); // 선택 하이라이트용

        CategoryDTO free = boardService.getCategoryByName("자유게시판");
        if (free != null) {
            model.addAttribute("freeBoardCategoryNo", free.getBoard_category_no());
        }
        
        // 🔵 카테고리 기준 댓글 허용 여부
        boolean canComment = "Y".equalsIgnoreCase(cat.getIs_comment_enabled());

        // ✅ 댓글 리스트 세팅 (허용일 때만)
        if (canComment) {
            model.addAttribute("comments", boardService.getComments(b.getBoard_no()));
        } else {
            model.addAttribute("comments", java.util.Collections.emptyList());
        }

        // 이전/다음
        BoardDTO prev = boardService.prevBoard(b.fk_board_category_no, b.board_no);
        BoardDTO next = boardService.nextBoard(b.fk_board_category_no, b.board_no);

        // 읽은사람(카테고리 허용 시)
        int readersCnt = 0; java.util.List<java.util.Map<String,String>> readers = java.util.List.of();
        if ("Y".equals(cat.is_read_enabled)) {
            readers = boardService.getReaders(b.board_no);
            readersCnt = boardService.countReaders(b.board_no);
        }
        
        

        model.addAttribute("b", b);
        model.addAttribute("cat", cat);
        model.addAttribute("prev", prev);
        model.addAttribute("next", next);
        model.addAttribute("readers", readers);
        model.addAttribute("readersCnt", readersCnt);
        model.addAttribute("canComment", canComment);

        List<BoardFileDTO> files = boardService.getFilesByBoardNo(b.getBoard_no());
        model.addAttribute("files", files);
        
        return "board/view";
    }


    /** 글쓰기 화면 */
    @GetMapping("/write")
    public String writeForm(@RequestParam("category") String fk_board_category_no,
                            HttpServletRequest request, Model model,
                            RedirectAttributes ra) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login"); return "msg"; }

        CategoryDTO cat = boardService.getCategoryByNo(fk_board_category_no);
        if (cat == null) { model.addAttribute("message","존재하지 않는 카테고리입니다."); model.addAttribute("loc","/board"); return "msg"; }

     // 권한 없으면: 메시지 + 내 부서 쓰기 가능 카테고리로 이동
        if (!boardService.canWrite(cat.board_category_no, login.getEmp_no(), login.getFk_dept_no(), cat.board_category_name)) {
            CategoryDTO redirectCat = boardService.pickWriteRedirectCategory(login.getFk_dept_no());
            if (redirectCat != null) {
                ra.addFlashAttribute("msg", "이 카테고리는 작성 권한이 없습니다. 권한이 있는 ‘" 
                        + redirectCat.getBoard_category_name() + "’으로 이동합니다.");
                return "redirect:/board?category=" + redirectCat.getBoard_category_no();
            } else {
                ra.addFlashAttribute("msg", "작성 가능한 카테고리를 찾지 못했습니다.");
                return "redirect:/board";
            }
        }

        model.addAttribute("cat", cat);
        model.addAttribute(
        	    "categories",
        	    boardService.getVisibleCategories(login.getFk_dept_no(), login.getEmp_no())
        	);
        return "board/write";
    }

    /** 글쓰기 처리 */
    @PostMapping("/write")
    public String write(@RequestParam Map<String,String> form,
                        @RequestParam(value="files", required=false) List<MultipartFile> files,
                        HttpServletRequest request, Model model,
                        RedirectAttributes ra) throws Exception {

        HttpSession session = request.getSession();
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login"); return "msg"; }

        String fk_board_category_no = form.get("fk_board_category_no");
        String board_title = form.get("board_title");
        String board_content = form.get("board_content");
        String is_pinned = form.getOrDefault("is_pinned", "N");
        String board_priority = form.get("board_priority"); // is_pinned='Y'면 필수

        CategoryDTO cat = boardService.getCategoryByNo(fk_board_category_no);
        if (cat == null) { model.addAttribute("message","존재하지 않는 카테고리입니다."); model.addAttribute("loc","/board"); return "msg"; }

        // ✅ 권한 없으면: alert 띄우고 쓰기 화면으로 리다이렉트
        if (!boardService.canWrite(fk_board_category_no, login.getEmp_no(), login.getFk_dept_no(), cat.getBoard_category_name())) {

            // (보강) 부서번호 null 방지
            String myDeptNo = (login.getFk_dept_no() == null ? "" : login.getFk_dept_no().trim());

            // 1) 내 부서 게시판이 있으면 그쪽으로
            CategoryDTO target = boardService.getCategoryByNo(myDeptNo);
            // 2) 없으면 자유게시판
            if (target == null) target = boardService.getCategoryByName("자유게시판");

            if (target == null) {
                ra.addFlashAttribute("msg", "작성 권한이 없습니다.");
                return "redirect:/board";
            }

            // ✨ 폼 값(제목/내용) 보존 (파일은 보안상 재첨부 필요)
            ra.addFlashAttribute("msg", "해당 카테고리는 작성 권한이 없습니다. ‘" + target.getBoard_category_name() + "’에서 작성해 주세요.");
            ra.addFlashAttribute("draftTitle", board_title);
            ra.addFlashAttribute("draftContent", board_content);

            return "redirect:/board/write?category=" + target.getBoard_category_no();
        }

        // 파일 저장(메타만 DB에, 실제 저장은 파일 시스템)
        List<BoardFileDTO> filesMeta = new ArrayList<>();
        if (files != null) {
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            for (MultipartFile mf : files) {
                if (mf.isEmpty()) continue;
                String origin = mf.getOriginalFilename();
                String save = System.currentTimeMillis() + "_" + UUID.randomUUID() + "_" + origin;
                File dest = new File(dir, save);
                mf.transferTo(dest);

                BoardFileDTO f = new BoardFileDTO();
                f.setBoard_origin_filename(origin);
                f.setBoard_save_filename(save);
                f.setBoard_filesize(Long.toString(dest.length()));
                filesMeta.add(f);
            }
        }

     // 본문 DTO 만들 때
        BoardDTO dto = new BoardDTO();
        dto.setFk_board_category_no(fk_board_category_no);
        dto.setFk_emp_no(login.getEmp_no());
        dto.setBoard_title(board_title);
        dto.setBoard_content(board_content);
        dto.setIs_pinned(is_pinned);
        dto.setBoard_priority(board_priority);
        // 첨부여부
        dto.setIs_attached(filesMeta.size() > 0 ? "Y" : "N");
     // 공지 아닐때 우선순위 null 처리(체크 제약 회피)
        if (!"Y".equalsIgnoreCase(is_pinned)) dto.setBoard_priority(null);
        String newBoardNo;
        try {
            newBoardNo = boardService.writeBoard(dto, filesMeta);
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc", "/board?category="+fk_board_category_no);
            return "msg";
        }

        return "redirect:/board/view/" + newBoardNo;
    }
    
 // 첨부파일 다운로드
    @GetMapping("/file/{fileNo}")
    public ResponseEntity<?> download(@PathVariable("fileNo") String fileNo,
                                      HttpServletRequest request, Model model) throws Exception {
        // 로그인 체크(원하면 생략 가능: 상세 페이지 접근되는 수준이면 일반적으로 다운로드 허용)
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            return ResponseEntity.status(401).body("로그인 필요");
        }

        BoardFileDTO f = boardService.getFileByNo(fileNo);
        if (f == null) {
            return ResponseEntity.notFound().build();
        }

        // 파일 실경로
        File file = new File(uploadDir, f.getBoard_save_filename());
        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        // ContentType
        String mime = java.nio.file.Files.probeContentType(file.toPath());
        if (mime == null) mime = MediaType.APPLICATION_OCTET_STREAM_VALUE;

        // Content-Disposition (한글 파일명 안전 처리)
        ContentDisposition cd = ContentDisposition.attachment()
                .filename(f.getBoard_origin_filename(), java.nio.charset.StandardCharsets.UTF_8)
                .build();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(mime));
        headers.setContentDisposition(cd);
        headers.setContentLength(file.length());

        return ResponseEntity.ok()
                .headers(headers)
                .body(new InputStreamResource(new java.io.FileInputStream(file)));
    }

    /** 댓글 등록 (5개 페이징은 view.jsp에서 호출 시 page=1부터) */
    @PostMapping("/comment")
    public String writeComment(@RequestParam("fk_board_no") String fk_board_no,
                               @RequestParam("comment_content") String comment_content,
                               HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login"); return "msg"; }

        // 🔵 글 → 카테고리 조회
        BoardDTO b = boardService.getBoard(fk_board_no); 
        if (b == null) {
            model.addAttribute("message","존재하지 않는 글입니다.");
            model.addAttribute("loc","/board");
            return "msg";
        }
        CategoryDTO cat = boardService.getCategoryByNo(b.getFk_board_category_no());

        // 🔵 댓글 비활성 카테고리면 차단
        if (!"Y".equalsIgnoreCase(cat.getIs_comment_enabled())) {
            model.addAttribute("message","이 게시판은 댓글이 비활성화되었습니다.");
            model.addAttribute("loc","/board/view/" + fk_board_no);
            return "msg";
        }
        
        
        CommentDTO c = new CommentDTO();
        c.fk_board_no = fk_board_no;
        c.fk_emp_no = login.getEmp_no();
        c.comment_content = comment_content;

        try {
            boardService.writeComment(c);
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc", "/board/view/" + fk_board_no);
            return "msg";
        }

        return "redirect:/board/view/" + fk_board_no;
    }

    /** 관리자: 부서게시판 추가 폼 */
    @GetMapping("/admin/category/form")
    public String addDeptCategoryForm(HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login"); return "msg"; }

        // ★ 관리자만 폼 접근 허용
        if (!"01".equals(login.getFk_dept_no() == null ? "" : login.getFk_dept_no().trim())) {
            model.addAttribute("message","권한 없음(관리자만 접근 가능)");
            model.addAttribute("loc","/board");
            return "msg";
        }

        // 폼에 필요하면 부서 목록 등을 추가해도 됨(간단히 텍스트 입력으로 진행)
        return "board/admin/categoryForm";
    }
    
    
    /** 관리자: 부서게시판 추가(자동 READ/WRITE 권한 부여) */
    @PostMapping("/admin/category/add")
    public String addDeptCategory(
            @RequestParam("board_category_name") String board_category_name,
            @RequestParam("target_dept_no") String target_dept_no,
            @RequestParam(value="is_comment_enabled", defaultValue="Y") String is_comment_enabled,
            @RequestParam(value="is_read_enabled", defaultValue="Y") String is_read_enabled,
            HttpServletRequest request, Model model) {

        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message","로그인 후 이용하세요.");
            model.addAttribute("loc","/login");
            return "msg";
        }

        // ★ 관리자만 허용: 부서번호 "01"
        String dept = login.getFk_dept_no() == null ? "" : login.getFk_dept_no().trim();
        if (!"01".equals(dept)) {
            model.addAttribute("message","권한 없음(관리자만 생성 가능)");
            model.addAttribute("loc","/board");
            return "msg";
        }

        // ★ 간단 유효성
        String name = board_category_name == null ? "" : board_category_name.trim();
        String target = target_dept_no == null ? "" : target_dept_no.trim();
        if (name.isEmpty() || target.isEmpty()) {
            model.addAttribute("message","입력값이 부족합니다.");
            model.addAttribute("loc","/board/admin/category/form");
            return "msg";
        }

        // (선택) 중복 카테고리명 방지
        var exist = boardService.getCategoryByName(name);
        if (exist != null) {
            model.addAttribute("message","이미 존재하는 게시판 이름입니다.");
            model.addAttribute("loc","/board/admin/category/form");
            return "msg";
        }

        try {
            // 서비스에서 다시 한 번 "01" 관리자 체크 + INSERT + 권한(READ/WRITE) 부여
            String newNo = boardService.createDepartmentCategory(dept, name, target,
                                                                is_comment_enabled, is_read_enabled);
            return "redirect:/board?category=" + newNo;
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc","/board/admin/category/form");
            return "msg";
        }
    }

    
    
 // BoardController.java (추가)

    /** 관리자: 부서게시판 강제삭제 */
    @PostMapping("/admin/category/delete-force")
    public String deleteDeptCategoryForce(@RequestParam("category") String catNo,
                                          HttpServletRequest request,
                                          Model model,
                                          RedirectAttributes ra) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message","로그인 후 이용하세요.");
            model.addAttribute("loc","/login");
            return "msg";
        }

        // ★ 관리자(부서 '01')만
        String dept = login.getFk_dept_no() == null ? "" : login.getFk_dept_no().trim();
        if (!"01".equals(dept)) {
            model.addAttribute("message","권한 없음(관리자만 삭제 가능)");
            model.addAttribute("loc","/board");
            return "msg";
        }

        // ★ 번호 정규화(추천): 숫자만 들어오면 DB 포맷(10자리 0패딩)으로 변환
        String raw = catNo == null ? "" : catNo.trim();
        if (raw.matches("\\d{1,10}")) {
            catNo = String.format("%010d", Long.parseLong(raw));
        }

        CategoryDTO cat = boardService.getCategoryByNo(catNo);
        if (cat == null) {
            model.addAttribute("message","존재하지 않는 카테고리입니다.");
            model.addAttribute("loc","/board");
            return "msg";
        }

        // 전사 3종 보호
        String nm = (cat.getBoard_category_name() == null ? "" : cat.getBoard_category_name().replace(" ", ""));
        if ("전사공지".equals(nm) || "전사알림".equals(nm) || "자유게시판".equals(nm)) {
            model.addAttribute("message","해당 게시판은 삭제할 수 없습니다.");
            model.addAttribute("loc","/board");
            return "msg";
        }

        try {
            // 업로드 경로는 컨트롤러의 필드 uploadDir 사용
            boardService.deleteDepartmentCategoryForce(dept, catNo, uploadDir);
            ra.addFlashAttribute("msg", "‘" + cat.getBoard_category_name() + "’ 게시판과 모든 게시글이 삭제되었습니다.");
            return "redirect:/board";
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc","/board");
            return "msg";
        }
    }

 // BoardController.java (추가)
    @PostMapping("/delete/{board_no}")
    public String deleteMyBoard(@PathVariable("board_no") String boardNo,
                                HttpServletRequest request,
                                RedirectAttributes ra,
                                Model model) {

        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message","로그인 후 이용하세요.");
            model.addAttribute("loc","/login");
            return "msg";
        }

        // 글 확인
        BoardDTO b = boardService.getBoard(boardNo);
        if (b == null) {
            model.addAttribute("message","존재하지 않는 글입니다.");
            model.addAttribute("loc","/board");
            return "msg";
        }

        // ★ 본인만 삭제 허용
        if (!login.getEmp_no().equals(b.getFk_emp_no())) {
            model.addAttribute("message","본인이 작성한 글만 삭제할 수 있습니다.");
            model.addAttribute("loc","/board/view/" + boardNo);
            return "msg";
        }

        String catNo = b.getFk_board_category_no(); // 삭제 후 리다이렉트를 위해 미리 확보

        try {
            boardService.deleteBoardByOwner(boardNo, login.getEmp_no(), uploadDir);
            ra.addFlashAttribute("msg", "게시글이 삭제되었습니다.");
            return "redirect:/board?category=" + catNo;
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc","/board/view/" + boardNo);
            return "msg";
        }
    }

    

 // BoardController.java (추가)
    @PostMapping("/comment/delete/{commentNo}")
    public String deleteComment(@PathVariable("commentNo") String commentNo,
                                HttpServletRequest request,
                                RedirectAttributes ra,
                                Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            model.addAttribute("message","로그인 후 이용하세요.");
            model.addAttribute("loc","/login");
            return "msg";
        }

        // 댓글 조회 (리다이렉트 위해 원글 번호도 필요)
        CommentDTO cmt = boardService.getCommentByNo(commentNo);
        if (cmt == null) {
            model.addAttribute("message","존재하지 않는 댓글입니다.");
            model.addAttribute("loc","/board");
            return "msg";
        }

        // 본인만 삭제 가능
        if (!login.getEmp_no().equals(cmt.getFk_emp_no())) {
            model.addAttribute("message","본인이 작성한 댓글만 삭제할 수 있습니다.");
            model.addAttribute("loc","/board/view/" + cmt.getFk_board_no());
            return "msg";
        }

        try {
            boardService.deleteCommentByOwner(commentNo, login.getEmp_no());
            ra.addFlashAttribute("msg","댓글이 삭제되었습니다.");
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc","/board/view/" + cmt.getFk_board_no());
            return "msg";
        }
        return "redirect:/board/view/" + cmt.getFk_board_no() + "#comments";
    }

    // 위젯용 메소드
    @GetMapping("/api/top")
    @ResponseBody
    public Map<String,Object> apiTop(@RequestParam("name") String categoryName,
                                     @RequestParam(value="size", defaultValue="5") int size,
                                     HttpServletRequest request) {
        Map<String,Object> res = new HashMap<>();
        res.put("ok", false);

        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) {
            res.put("error", "UNAUTHORIZED");
            return res; // 200 + 메시지 (위젯에서 graceful 처리)
        }

        CategoryDTO cat = boardService.getCategoryByName(categoryName);
        if (cat == null) {
            res.put("ok", true);
            res.put("list", List.of());
            return res;
        }

        boolean canRead = boardService.canRead(cat.getBoard_category_no(),
                                               login.getEmp_no(),
                                               login.getFk_dept_no(),
                                               cat.getBoard_category_name());
        if (!canRead) {
            res.put("ok", true);
            res.put("list", List.of());
            return res;
        }

        int n = Math.max(1, Math.min(10, size)); // 1~10 제한
        List<BoardDTO> list = boardService.selectTopByCategory(cat.getBoard_category_no(), n);

        res.put("ok", true);
        res.put("list", list);
        return res;
    }
    

}
