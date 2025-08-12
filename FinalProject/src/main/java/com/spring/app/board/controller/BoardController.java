package com.spring.app.board.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.spring.app.board.domain.BoardDTO;
import com.spring.app.board.service.BoardService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor  // @RequiredArgsConstructor는 Lombok 라이브러리에서 제공하는 애너테이션으로, final 필드 또는 @NonNull이 붙은 필드에 대해 생성자를 자동으로 생성해준다.
@RequestMapping(value="/board/")
public class BoardController {

	// 의존객체를 생성자 주입(DI : Dependency Injection)
		private final BoardService boardservice;
		
	// 게시판 메인 홈	
	@GetMapping("boardHome")
	public String board(){
		
		return "boardContent/boardHome";
		
	}
	
	// 게시글 작성 폼 
	@GetMapping("addPost")
	public ModelAndView requiredLogin_add(HttpServletRequest request,
            HttpServletResponse response,
            ModelAndView mav) {
		
		mav.setViewName("boardContent/addPost");
		
		return mav;
	}
	
	
	// 게시글 작성 
	@PostMapping("submitPost")
	public String submitPost(BoardDTO boardDto){
		
		int n = boardservice.submitPost(boardDto);
		
		String fk_board_category_no = boardDto.getFk_board_category_no();
		
		if(n == 1){
		
			return "redirect:/board/board?fk_board_category_no=" + fk_board_category_no;
		} 
		else{
			return "redirect:/board/addPost?fk_board_category_no=" + boardDto.getFk_board_category_no();
		}
		
		
	}
	
	
	
	
	
	
	
	
	// === 새로 추가: 게시판(카테고리) 추가 화면 ===
    @GetMapping("addBoard")
    public ModelAndView addBoard(ModelAndView mav) {
        // 필요하면 여기서 기본값/드롭다운 데이터 주입 가능
        mav.setViewName("boardContent/addBoard"); // /WEB-INF/views/boardContent/addBoard.jsp
        return mav;
    }
	
    
    
    
    
    
    
    
    
}
