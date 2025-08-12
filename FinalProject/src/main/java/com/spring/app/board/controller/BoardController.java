package com.spring.app.board.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.spring.app.board.service.BoardService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor  // @RequiredArgsConstructor는 Lombok 라이브러리에서 제공하는 애너테이션으로, final 필드 또는 @NonNull이 붙은 필드에 대해 생성자를 자동으로 생성해준다.
@RequestMapping(value="/board/")
public class BoardController {

	// 의존객체를 생성자 주입(DI : Dependency Injection)
		private final BoardService service;
		
		
	@GetMapping("boardHome")
	public String board(){
		
		return "boardContent/boardHome";
		
	}
	
	@GetMapping("addPost")
	public ModelAndView requiredLogin_add(HttpServletRequest request,
            HttpServletResponse response,
            ModelAndView mav) {
		
		mav.setViewName("boardContent/addPost");
		
		return mav;
	}
	
	// === 새로 추가: 게시판(카테고리) 추가 화면 ===
    @GetMapping("addBoard")
    public ModelAndView addBoard(ModelAndView mav) {
        // 필요하면 여기서 기본값/드롭다운 데이터 주입 가능
        mav.setViewName("boardContent/addBoard"); // /WEB-INF/views/boardContent/addBoard.jsp
        return mav;
    }
	
}
