package com.spring.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig
{
	@Bean
	public PasswordEncoder passwordEncoder()
	{
		return new BCryptPasswordEncoder();
	}
	
	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception
	{
		http
			//	CSRF 보호는 개발중 비활성화(수요 발생시 활성화 하기!)
			.csrf(csrf -> csrf.disable())
			
			//	URL별 접근권한 설정
			.authorizeHttpRequests(auth -> auth
				.requestMatchers(
						"/login", "/login/**","/loginProc",
				          "/error", "/error/**", "/favicon.ico",
				          "/bootstrap-4.6.2-dist/**", "/js/**", "/css/**", "/images/**", "/img/**", "/webjars/**"
				         ).permitAll()
				
				//	특정 권한이 있어야 접근가능한 URL
			//	.requestMatchers("/emp/emp_list).hasAuthority("SYS_VIEW")"
				
				//	위에서 지정한 URL 외의 모든 요청은 '인증(로그인)'된 사용자만 접근가능
				.anyRequest().authenticated()
			)
			//	로그인 폼(Form) 관련 설정
			.formLogin(form -> form
				.loginPage("/login")				//	우리가 커스텀한 로그인 페이지 URL
				.loginProcessingUrl("/loginProc")	//	로그인 form의 action URL
				.defaultSuccessUrl("/index", true)	//	로그인 성공 시 이동할 기본 URL
				.failureUrl("/login?error=true")	//	로그인 실패 시 이동할 URL
				.permitAll()						//	로그인 페이지는 누구나 접근가능
			)
			//	로그아웃 관련 설정
			.logout(logout -> logout
				.logoutUrl("/logout")			//	로그아웃 처리 URL
				.logoutSuccessUrl("/login")		//	로그아웃 성공 후 이동할 URL
				.invalidateHttpSession(true)	//	세션 무효화
				.deleteCookies("JSESSIONID")	//	쿠키삭제
			);
		
		return http.build();
	}
}
