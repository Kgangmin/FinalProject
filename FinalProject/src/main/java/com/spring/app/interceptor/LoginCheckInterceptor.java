package com.spring.app.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class LoginCheckInterceptor implements HandlerInterceptor {

	@Override
	public boolean preHandle(HttpServletRequest request,
			                 HttpServletResponse response,
			                 Object handler) throws Exception {
		
		// 로그인 여부 검사 
		HttpSession session = request.getSession();
				
		if(session.getAttribute("loginuser") == null) {
					
			// 로그인이 되지 않은 상태
			String message = "로그인이 필요합니다";
			String loc = request.getContextPath()+"/login/loginStart";  // 로그인 페이지로 이동 
					
			request.setAttribute("message", message);
			request.setAttribute("loc", loc);
					
			RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/msg.jsp"); 
			dispatcher.forward(request, response);
					
			return false;
		}
				
		return true;
	}
	/*
	   다음으로 com.spring.app.config.Interceptor_Configuration 에 가서 
	   사용하도록 설정을 해주어야 한다.  
	*/
	
}
