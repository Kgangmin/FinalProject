// src/main/java/com/spring/app/board/controller/BoardController.java
package com.spring.app.board.controller;

import java.io.File;
import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.board.domain.*;
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

    /** 기본 목록: default=전사공지 */
    @GetMapping({"","/"})
    public String listDefault(@RequestParam(value="category", required=false) String board_category_no,
                              @RequestParam(value="page", required=false, defaultValue="1") int page,
                              @RequestParam(value="size", required=false, defaultValue="10") int size,
                              @RequestParam(value="searchType", required=false) String searchType,
                              @RequestParam(value="searchKeyword", required=false) String searchKeyword,
                              @RequestParam(value="sort", required=false, defaultValue="latest") String sort,
                              HttpServletRequest request,
                              Model model) {

        // 로그인 유저
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        // 카테고리 결정
        CategoryDTO cat;
        if (board_category_no == null) {
            cat = boardService.getCategoryByName("전사공지");             // 기본 카테고리
            if (cat == null) { // 없으면 첫 번째 카테고리
                var all = boardService.getAllCategories();
                if (all.isEmpty()) { model.addAttribute("message","카테고리가 없습니다."); model.addAttribute("loc","/index"); return "msg"; }
                cat = all.get(0);
            }
        } else {
            cat = boardService.getCategoryByNo(board_category_no);
            if (cat == null) { model.addAttribute("message","존재하지 않는 카테고리입니다."); model.addAttribute("loc","/board"); return "msg"; }
        }

        // 권한 체크(읽기)
      boolean canRead = boardService.canRead(cat.board_category_no, login.getEmp_no(), login.getFk_dept_no(), cat.board_category_name);
        if (!canRead) {
            model.addAttribute("message","해당 게시판을 열람할 권한이 없습니다.");
            model.addAttribute("loc","/board"); return "msg";
        }

        // 페이징 파라미터
        int startRow = (page - 1) * size + 1;
        int endRow   = page * size;

        Map<String,String> param = new HashMap<>();
        param.put("fk_board_category_no", cat.board_category_no);
        param.put("searchType",  (searchType == null ? "" : searchType));
        param.put("searchKeyword",(searchKeyword == null ? "" : searchKeyword));
        param.put("sort", sort);
        param.put("startRow", Integer.toString(startRow));
        param.put("endRow", Integer.toString(endRow));

        int totalCnt = boardService.countBoardList(param);
        List<BoardDTO> list = boardService.selectBoardList(param);

        // 페이지 계산
        int totalPage = (int)Math.ceil((double)totalCnt / size);

        // 사이드바용 전체 카테고리
        List<CategoryDTO> categories = boardService.getAllCategories();

        model.addAttribute("categories", categories);
        model.addAttribute("cat", cat);
        model.addAttribute("list", list);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("totalPage", totalPage);
        model.addAttribute("totalCnt", totalCnt);
        model.addAttribute("searchType", searchType);
        model.addAttribute("searchKeyword", searchKeyword);
        model.addAttribute("sort", sort);

        return "board/list"; // /WEB-INF/views/board/list.jsp
    }

    /** 글 상세 */
    @GetMapping("/view/{board_no}")
    public String view(@PathVariable String board_no, HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        // 상세 + 조회수 증가 + 읽은사람 기록(카테고리 허용 시)
        BoardDTO b = boardService.getBoardAndTouchRead(board_no, login.getEmp_no(), login.getFk_dept_no());
        if (b == null) { model.addAttribute("message","존재하지 않는 글입니다."); model.addAttribute("loc","/board"); return "msg"; }

        CategoryDTO cat = boardService.getCategoryByNo(b.fk_board_category_no);

        // 이전/다음
        BoardDTO prev = boardService.prevBoard(b.fk_board_category_no, b.board_no);
        BoardDTO next = boardService.nextBoard(b.fk_board_category_no, b.board_no);

        // 읽은사람(카테고리 허용 시)
        int readersCnt = 0; List<Map<String,String>> readers = List.of();
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

        return "board/view";
    }

    /** 글쓰기 화면 */
    @GetMapping("/write")
    public String writeForm(@RequestParam("category") String fk_board_category_no,
                            HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        CategoryDTO cat = boardService.getCategoryByNo(fk_board_category_no);
        if (cat == null) { model.addAttribute("message","존재하지 않는 카테고리입니다."); model.addAttribute("loc","/board"); return "msg"; }

        // 쓰기권한 체크 (자유게시판만 모두 허용, 그 외는 permission)
        if (!boardService.canWrite(cat.board_category_no, login.getEmp_no(), login.getFk_dept_no(), cat.board_category_name)) {
            model.addAttribute("message","해당 부서게시판에 글을 작성할 권한이 없습니다.");
            model.addAttribute("loc","/board?category="+fk_board_category_no); return "msg";
        }

        model.addAttribute("cat", cat);
        model.addAttribute("categories", boardService.getAllCategories()); // 글쓰기에서 카테고리 선택 가능(자유게시판 제외시 권한 체크)
        return "board/write";
    }

    /** 글쓰기 처리 */
    @PostMapping("/write")
    public String write(@RequestParam Map<String,String> form,
                        @RequestParam(value="files", required=false) List<MultipartFile> files,
                        HttpServletRequest request, Model model) throws Exception {

        HttpSession session = request.getSession();
        EmpDTO login = (EmpDTO) session.getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        String fk_board_category_no = form.get("fk_board_category_no");
        String board_title = form.get("board_title");
        String board_content = form.get("board_content");
        String is_pinned = form.getOrDefault("is_pinned", "N");
        String board_priority = form.get("board_priority"); // is_pinned='Y'면 필수

        CategoryDTO cat = boardService.getCategoryByNo(fk_board_category_no);
        if (cat == null) { model.addAttribute("message","존재하지 않는 카테고리입니다."); model.addAttribute("loc","/board"); return "msg"; }

        // "다른 부서 게시판에 글쓰기 금지" 요구사항 충족:
        // canWrite() 내부에서 자유게시판 제외하고 permission 없으면 false
        if (!boardService.canWrite(fk_board_category_no, login.getEmp_no(), login.getFk_dept_no(), cat.board_category_name)) {
            model.addAttribute("message","해당 부서게시판에 글을 작성할 권한이 없습니다.");
            model.addAttribute("loc","/board?category="+fk_board_category_no); return "msg";
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

    /** 댓글 등록 (5개 페이징은 view.jsp에서 호출 시 page=1부터) */
    @PostMapping("/comment")
    public String writeComment(@RequestParam("fk_board_no") String fk_board_no,
                               @RequestParam("comment_content") String comment_content,
                               HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

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

    /** 관리자: 부서게시판 추가(자동 READ/WRITE 권한 부여) */
    @PostMapping("/admin/category/add")
    public String addDeptCategory(@RequestParam("board_category_name") String board_category_name,
                                  @RequestParam("target_dept_no") String target_dept_no,
                                  @RequestParam(value="is_comment_enabled", defaultValue="Y") String is_comment_enabled,
                                  @RequestParam(value="is_read_enabled", defaultValue="Y") String is_read_enabled,
                                  HttpServletRequest request, Model model) {
        EmpDTO login = (EmpDTO) request.getSession().getAttribute("loginuser");
        if (login == null) { model.addAttribute("message","로그인 후 이용하세요."); model.addAttribute("loc","/login/loginStart"); return "msg"; }

        try {
            String newNo = boardService.createDepartmentCategory(login.getFk_dept_no(), board_category_name, target_dept_no,
                                                                is_comment_enabled, is_read_enabled);
            return "redirect:/board?category=" + newNo;
        } catch (RuntimeException ex) {
            model.addAttribute("message", ex.getMessage());
            model.addAttribute("loc","/board");
            return "msg";
        }
    }
}
