package com.spring.app.security;

import java.io.IOException;
import java.io.PrintWriter;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class CustomAccessDeniedHandler implements AccessDeniedHandler
{
	@Override
	public void handle(HttpServletRequest request
						,HttpServletResponse response
						,AccessDeniedException accessDeniedException) throws IOException, ServletException
	{
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<script>");
        out.println("alert('권한이 없습니다. 메인페이지로 이동합니다.');");
        out.println("location.href='" + request.getContextPath() + "/index';"); // 홈으로 이동
        out.println("</script>");

        out.flush();
	}
}
