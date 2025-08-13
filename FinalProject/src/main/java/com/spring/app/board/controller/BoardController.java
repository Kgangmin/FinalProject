package com.spring.app.board.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.app.board.domain.BoardCategoryDTO;
import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.service.BoardService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor  // @RequiredArgsConstructor는 Lombok 라이브러리에서 제공하는 애너테이션으로, final 필드 또는 @NonNull이 붙은 필드에 대해 생성자를 자동으로 생성해준다.
@RequestMapping(value="/board/")
public class BoardController {

	// 의존객체를 생성자 주입(DI : Dependency Injection)
		private final BoardService boardservice;
	
    // 게시판 목록/메인 (사이드바 카테고리)
		@GetMapping("boardHome")
		public String boardHome(Model model) {
			
		    List<BoardCategoryDTO> boardCategories = boardservice.getBoardCategories();
		    model.addAttribute("boardCategories", boardCategories);
		    
		    return "boardContent/boardHome";
		}
	
	// 게시글 작성 폼 
	@GetMapping("addPost")                                  // 1) /board/addPost GET 요청을 처리
	public String addPost(@RequestParam String fk_board_category_no,         // 2) 쿼리스트링의 fk_board_category_no를 필수로 받음
	                      @RequestParam(required=false) String parent_board_no, // 3) parent_board_no는 선택(원글이면 없음)
	                      Model model) {                                      // 4) 뷰로 보낼 데이터 바구니(Model)

	    model.addAttribute("fk_board_category_no", fk_board_category_no);     // 5) JSP에서 ${fk_board_category_no}로 쓰게 전달

	    if (parent_board_no != null && !parent_board_no.isBlank()) {          // 6) 답글쓰기라면(부모글 번호가 있으면)
	        String parentTitle = boardservice.findTitleById(parent_board_no);     // 7) DB에서 부모글 제목 조회
	        String prefixed = "[답변] " + (parentTitle == null ? "" : parentTitle); // 8) 앞에 [답변] 붙여 미리 보여줄 텍스트 만들기
	        model.addAttribute("board_title", prefixed);                       // 9) JSP input value로 쓰려고 제목 전달
	        model.addAttribute("parent_board_no", parent_board_no);            // 10) hidden에 넣어 제출 시 답글임을 알리기
	    }

	    return "boardContent/addPost";                                         // 11) 이 뷰(JSP)로 forward (모델 값들이 request에 실림)
	}
		

	// === 게시판(카테고리) 추가 화면 ===
    @GetMapping("addBoard")
    public ModelAndView addBoard(ModelAndView mav) {
        // 필요하면 여기서 기본값/드롭다운 데이터 주입 가능
        mav.setViewName("boardContent/addBoard"); // /WEB-INF/views/boardContent/addBoard.jsp
        return mav;
    }
	
 // 게시판(카테고리) 추가 처리
    @PostMapping("addBoard")
    public String addBoardPost(@ModelAttribute BoardCategoryDTO boardCategoryDto,   // 1) DTO로 폼 데이터 자동 바인딩
                               RedirectAttributes rttr) {                            // 2) 리다이렉트 후 1회성 메시지 전달용

        // 3) 체크박스 기본값 보정
        if (boardCategoryDto.getIs_comment_enabled() == null) boardCategoryDto.setIs_comment_enabled("N");
        if (boardCategoryDto.getIs_read_enabled() == null)    boardCategoryDto.setIs_read_enabled("N");

        // 4) 이름 공백 정리
        if (boardCategoryDto.getBoard_category_name() != null) {
            boardCategoryDto.setBoard_category_name(boardCategoryDto.getBoard_category_name().trim());
        }

        // 5) 서버측 유효성 검사
        if (boardCategoryDto.getBoard_category_name() == null || boardCategoryDto.getBoard_category_name().isEmpty()) {
            rttr.addFlashAttribute("error", "게시판 이름을 입력하세요.");
            return "redirect:/board/addBoard";    // 다시 폼으로
        }

        // 6) 서비스 호출
        int n = boardservice.addBoardCategory(boardCategoryDto);

        // 7) 결과 처리
        if (n == 1) {
            rttr.addFlashAttribute("msg", "게시판을 추가했습니다.");
            return "redirect:/board/boardHome";
        } else {
            rttr.addFlashAttribute("error", "게시판 추가에 실패했습니다.");
            return "redirect:/board/addBoard";
        }
    }

    

    
    
    
    
    
    
    
}
