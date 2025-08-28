package com.spring.app.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.NegatedRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;

import com.spring.app.security.LegacyLoginuserBridgeFilter;
import com.spring.app.security.LoginSuccessHandler;

import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig
{
	private final LoginSuccessHandler loginSuccessHandler;
	private final LegacyLoginuserBridgeFilter legacyLoginuserBridgeFilter;
	
	@Value("${app.security.csrf:false}")
	private boolean csrfEnabled;
	
	@Bean
	PasswordEncoder passwordEncoder()
	{
		return new BCryptPasswordEncoder();
	}
	
	@Bean
	SecurityFilterChain filterChain(HttpSecurity http) throws Exception
	{
		if (csrfEnabled) {
	           // 두 엔드포인트 묶기
	           RequestMatcher onlyPwdApis = new OrRequestMatcher(
	               new AntPathRequestMatcher("/emp/verifyPassword"),
	               new AntPathRequestMatcher("/emp/changePassword")
	           );
	           // ★ 두 엔드포인트의 "부정(NOT)" = 그 외 전부를 CSRF 무시
	           http.csrf(csrf -> csrf
	               .ignoringRequestMatchers(new NegatedRequestMatcher(onlyPwdApis))
	           );
	       } else {
	           http.csrf(csrf -> csrf.disable());
	       }
			
		http	
			//	URL별 접근권한 설정
			.authorizeHttpRequests(auth -> auth
				.requestMatchers(
						"/login", "/login/**","/loginProc",
				          "/error", "/error/**", "/favicon.ico",
				          "/bootstrap-4.6.2-dist/**", "/js/**", "/css/**", "/images/**", "/img/**", "/webjars/**",
				          "/WEB-INF/views/**"
				         ).permitAll()
				
				// ★ 알림 API는 AJAX로 호출 → 인증 없어도 조회 가능하게
                .requestMatchers("/api/notifications").permitAll()
                
				//	특정 권한이 있어야 접근가능한 URL
                .requestMatchers("/emp/emp_list").hasAuthority("HR_VIEW")
                
                
				//	위에서 지정한 URL 외의 모든 요청은 '인증(로그인)'된 사용자만 접근가능
				.anyRequest().authenticated()
			)
			
            // ★ API로 인증 안 된 접근 시 302 리다이렉트 대신 401을 주도록 설정
            .exceptionHandling(e -> e
                .defaultAuthenticationEntryPointFor(
                    new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED),
                    new AntPathRequestMatcher("/api/**")
                )
            )
			
			//	로그인 폼(Form) 관련 설정
			.formLogin(form -> form
				.loginPage("/login")				//	우리가 커스텀한 로그인 페이지 URL
				.loginProcessingUrl("/loginProc")	//	로그인 form의 action URL
				.successHandler(loginSuccessHandler)
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
		
		http.addFilterAfter(
	            legacyLoginuserBridgeFilter,
	            org.springframework.security.web.context.SecurityContextHolderFilter.class
	        );
		
		return http.build();
	}
}